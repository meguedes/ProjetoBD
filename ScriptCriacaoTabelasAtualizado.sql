-- =====================================================================
-- Projeto BD - Sistema de Achados e Perdidos (UnB) - "UnBGram"
--
-- Script único e definitivo do banco de dados. Consolida em um só
-- arquivo o que antes estava espalhado em 3 fontes diferentes
-- (o dump antigo deste mesmo arquivo, o rascunho ModuloUsuarioeComunicacao.sql
-- e um rascunho paralelo de schema/lógica/dados de demonstração).
-- A partir de 2026-07-06 esta é a ÚNICA fonte de verdade do banco -
-- todo o grupo deve criar/recriar o banco só a partir deste arquivo.
--
-- É reexecutável do zero (os DROPs no início permitem rodar de novo
-- em cima de um banco já existente).
--
-- Ordem interna:
--   1) limpeza          4) functions (usadas pelos triggers)
--   2) tabelas          5) triggers
--   3) procedures       6) views
--                       7) dados iniciais (seed) usados pelo front-end
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) LIMPEZA
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS Devolucao        CASCADE;
DROP TABLE IF EXISTS Notificacao      CASCADE;
DROP TABLE IF EXISTS Mensagem         CASCADE;
DROP TABLE IF EXISTS Conversa         CASCADE;
DROP TABLE IF EXISTS Postagem         CASCADE;
DROP TABLE IF EXISTS Objeto           CASCADE;
DROP TABLE IF EXISTS Categoria_objeto CASCADE;
DROP TABLE IF EXISTS Localizacao      CASCADE;
DROP TABLE IF EXISTS Campi            CASCADE;
DROP TABLE IF EXISTS Usuario          CASCADE;

-- ---------------------------------------------------------------------
-- 2) TABELAS
-- ---------------------------------------------------------------------

-- Usuario
-- tipo_usuario = flag de "autenticado": vira TRUE no login (dispara
-- tg_usuario_autenticado) e volta a FALSE no logout.
-- perfil = tipo de vínculo com a universidade (Aluno/Professor/...).
CREATE TABLE Usuario (
    cpf                    VARCHAR(14)  PRIMARY KEY,
    nome                   VARCHAR(150) NOT NULL,
    email                  VARCHAR(100) UNIQUE NOT NULL,
    registro_institucional VARCHAR(20),
    tipo_usuario           BOOLEAN      NOT NULL DEFAULT FALSE,
    telefone               VARCHAR(15),
    senha                  TEXT,
    perfil                 VARCHAR(50)
);

-- Categoria_objeto
CREATE TABLE Categoria_objeto (
    id_categoria   SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
);

-- Objeto (foto_obj guarda o dado binário - BYTEA)
CREATE TABLE Objeto (
    id_obj       SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_obj     VARCHAR(50) NOT NULL,
    cor          VARCHAR(20),
    tamanho      VARCHAR(50),
    descricao    TEXT,
    foto_obj     BYTEA,
    FOREIGN KEY (id_categoria) REFERENCES Categoria_objeto(id_categoria) ON DELETE RESTRICT
);

-- Campi
CREATE TABLE Campi (
    id_campi   SERIAL PRIMARY KEY,
    nome_campi VARCHAR(100) NOT NULL
);

-- Localizacao
CREATE TABLE Localizacao (
    id_local  SERIAL PRIMARY KEY,
    id_campi  INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_campi) REFERENCES Campi(id_campi) ON DELETE RESTRICT
);

-- Postagem (liga Usuario + Localizacao + Objeto)
-- Os CHECKs fixam o domínio de valores que o restante do sistema usa:
-- cadastro_objeto.html só oferece 'Perdido'/'Encontrado', e status_postagem
-- cobre exatamente os estados que feed.js e minhas_postagens.js tratam.
CREATE TABLE Postagem (
    id_post         SERIAL PRIMARY KEY,
    cpf             VARCHAR(14) NOT NULL,
    id_local        INT NOT NULL,
    id_obj          INT NOT NULL,
    data_hora       TIMESTAMP NOT NULL DEFAULT NOW(),
    tipo_postagem   VARCHAR(20) NOT NULL
        CHECK (tipo_postagem IN ('Perdido', 'Encontrado')),
    status_postagem VARCHAR(30) NOT NULL DEFAULT 'Aberta'
        CHECK (status_postagem IN ('Aberta', 'Em contato', 'Resolvido', 'Devolvido')),
    FOREIGN KEY (cpf)      REFERENCES Usuario(cpf),
    FOREIGN KEY (id_local) REFERENCES Localizacao(id_local),
    FOREIGN KEY (id_obj)   REFERENCES Objeto(id_obj) ON DELETE RESTRICT
);

-- Conversa
CREATE TABLE Conversa (

    id_conversa SERIAL PRIMARY KEY,

    id_post INT NOT NULL,

    cpf_criador VARCHAR(14) NOT NULL,

    cpf_interessado VARCHAR(14) NOT NULL,

    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(),


    FOREIGN KEY (id_post)
    REFERENCES Postagem(id_post)
    ON DELETE RESTRICT,


    FOREIGN KEY (cpf_criador)
    REFERENCES Usuario(cpf),


    FOREIGN KEY (cpf_interessado)
    REFERENCES Usuario(cpf),


    -- impede criar duas conversas iguais
    UNIQUE(id_post, cpf_interessado)

);

-- Mensagem
CREATE TABLE Mensagem (

    id_mensagem SERIAL PRIMARY KEY,

    id_conversa INT NOT NULL,

    cpf_remetente VARCHAR(14) NOT NULL,

    conteudo TEXT NOT NULL,

    data_envio TIMESTAMP NOT NULL DEFAULT NOW(),


    FOREIGN KEY (id_conversa)
    REFERENCES Conversa(id_conversa)
    ON DELETE RESTRICT,


    FOREIGN KEY (cpf_remetente)
    REFERENCES Usuario(cpf)

);

-- Notificacao
CREATE TABLE Notificacao (
    id_notificacao SERIAL PRIMARY KEY,
    cpf            VARCHAR(14) NOT NULL,
    data_hora      TIMESTAMP NOT NULL DEFAULT NOW(),
    status_leitura VARCHAR(20) DEFAULT 'Não lida',
    mensagem       TEXT,
    FOREIGN KEY (cpf) REFERENCES Usuario(cpf) ON DELETE CASCADE
);

-- Devolucao
-- Sem ON DELETE em id_post de propósito: é a demonstração do roteiro de
-- "conflito entre PK e FK" (não dá para excluir a Postagem sem antes
-- excluir a Devolucao que aponta pra ela - ver app.py/excluir_postagem).
CREATE TABLE Devolucao (
    id_dev       SERIAL PRIMARY KEY,
    id_post      INT NOT NULL,
    cpf          VARCHAR(14) NOT NULL,
    data_entrega TIMESTAMP NOT NULL DEFAULT NOW(),
    observacao   TEXT,
    FOREIGN KEY (id_post) REFERENCES Postagem(id_post),
    FOREIGN KEY (cpf)     REFERENCES Usuario(cpf)
);

-- ---------------------------------------------------------------------
-- 3) PROCEDURES
-- ---------------------------------------------------------------------

-- Cadastro de usuário (a senha já chega com hash feito no backend, em
-- werkzeug.generate_password_hash - a procedure só grava o que recebe)
CREATE OR REPLACE PROCEDURE proc_cadastrar_usuario(
    p_cpf                    VARCHAR(14),
    p_nome                   VARCHAR(150),
    p_email                  VARCHAR(100),
    p_registro_institucional VARCHAR(20),
    p_telefone               VARCHAR(15),
    p_senha                  TEXT DEFAULT NULL,
    p_perfil                 VARCHAR(50) DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuario (cpf, nome, email, registro_institucional, tipo_usuario, telefone, senha, perfil)
    VALUES (p_cpf, p_nome, p_email, p_registro_institucional, FALSE, p_telefone, p_senha, p_perfil);
END;
$$;

-- Editar dados cadastrais do usuário (botão "Editar Perfil").
-- p_senha fica NULL quando o usuário não quer trocar a senha (COALESCE mantém a atual).
CREATE OR REPLACE PROCEDURE proc_editar_usuario(
    p_cpf                    VARCHAR(14),
    p_nome                   VARCHAR(150),
    p_telefone               VARCHAR(15),
    p_registro_institucional VARCHAR(20),
    p_senha                  TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Usuario
       SET nome                   = p_nome,
           telefone               = p_telefone,
           registro_institucional = p_registro_institucional,
           senha                  = COALESCE(p_senha, senha)
     WHERE cpf = p_cpf;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuario % nao encontrado.', p_cpf;
    END IF;
END;
$$;

-- Registrar postagem [grava em 2 tabelas na mesma transação: Objeto + Postagem]
CREATE OR REPLACE PROCEDURE proc_registrar_postagem(
    p_cpf           VARCHAR(14),
    p_id_categoria  INT,
    p_nome_obj      VARCHAR(50),
    p_cor           VARCHAR(20),
    p_tamanho       VARCHAR(50),
    p_descricao     TEXT,
    p_id_local      INT,
    p_tipo_postagem VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_obj INT;
BEGIN
    INSERT INTO Objeto (id_categoria, nome_obj, cor, tamanho, descricao)
    VALUES (p_id_categoria, p_nome_obj, p_cor, p_tamanho, p_descricao)
    RETURNING id_obj INTO v_id_obj;

    INSERT INTO Postagem (cpf, id_local, id_obj, tipo_postagem, status_postagem)
    VALUES (p_cpf, p_id_local, v_id_obj, p_tipo_postagem, 'Aberta');
END;
$$;

-- Editar os dados do objeto de uma postagem já existente (botão "Editar")
CREATE OR REPLACE PROCEDURE proc_editar_objeto(
    p_id_obj    INT,
    p_nome_obj  VARCHAR(50),
    p_cor       VARCHAR(20),
    p_tamanho   VARCHAR(50),
    p_descricao TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Objeto
       SET nome_obj  = p_nome_obj,
           cor       = p_cor,
           tamanho   = p_tamanho,
           descricao = p_descricao
     WHERE id_obj = p_id_obj;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Objeto % nao encontrado.', p_id_obj;
    END IF;
END;
$$;

-- Anexar foto (dado binário) a um objeto já existente
CREATE OR REPLACE PROCEDURE proc_anexar_foto_objeto(
    p_id_obj INT,
    p_foto   BYTEA
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Objeto SET foto_obj = p_foto WHERE id_obj = p_id_obj;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Objeto % nao encontrado.', p_id_obj;
    END IF;
END;
$$;

-- Registrar devolução [dispara tg_processar_devolucao]
CREATE OR REPLACE PROCEDURE proc_registrar_devolucao(
    p_id_post       INT,
    p_cpf_recebedor VARCHAR(14),
    p_observacao    TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Devolucao (id_post, cpf, observacao)
    VALUES (p_id_post, p_cpf_recebedor, p_observacao);
END;
$$;

-- Desfazer uma devolução (botão "Remover Devolução"): sem isso, a
-- Postagem fica presa para sempre, porque Devolucao.id_post não tem
-- ON DELETE - excluir a postagem exige excluir a devolução antes.
CREATE OR REPLACE PROCEDURE proc_remover_devolucao(
    p_id_post INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Devolucao WHERE id_post = p_id_post;

    UPDATE Postagem
       SET status_postagem = 'Aberta'
     WHERE id_post = p_id_post;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Postagem % nao encontrada.', p_id_post;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE proc_criar_conversa(

    p_id_post INT,

    p_cpf_interessado VARCHAR

)

LANGUAGE plpgsql

AS $$


DECLARE

    v_dono VARCHAR(14);


BEGIN


    -- descobre o dono da postagem

    SELECT cpf
    INTO v_dono

    FROM Postagem

    WHERE id_post = p_id_post;



    IF v_dono IS NULL THEN

        RAISE EXCEPTION
        'Postagem não encontrada';

    END IF;



    -- evita conversa consigo mesmo

    IF v_dono = p_cpf_interessado THEN

        RAISE EXCEPTION
        'Você não pode conversar com sua própria postagem';

    END IF;



    -- cria apenas se não existir

    INSERT INTO Conversa(

        id_post,

        cpf_criador,

        cpf_interessado

    )

    VALUES(

        p_id_post,

        v_dono,

        p_cpf_interessado

    )


    ON CONFLICT
    (id_post, cpf_interessado)

    DO NOTHING;


END;

$$;

CREATE OR REPLACE PROCEDURE proc_enviar_mensagem(

    p_id_conversa INT,

    p_cpf VARCHAR,

    p_texto TEXT

)

LANGUAGE plpgsql

AS $$


BEGIN


    INSERT INTO Mensagem(

        id_conversa,

        cpf_remetente,

        conteudo

    )

    VALUES(

        p_id_conversa,

        p_cpf,

        p_texto

    );


END;

$$;

-- ---------------------------------------------------------------------
-- 4) FUNCTIONS
-- ---------------------------------------------------------------------

-- Notifica quando o usuário autentica (transição FALSE -> TRUE em tipo_usuario)
CREATE OR REPLACE FUNCTION fn_notificar_login()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.tipo_usuario = FALSE AND NEW.tipo_usuario = TRUE THEN
        INSERT INTO Notificacao (cpf, mensagem, status_leitura)
        VALUES (NEW.cpf, 'Login realizado com sucesso!', 'Não lida');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Processa a devolução: atualiza status_postagem e notifica o dono
CREATE OR REPLACE FUNCTION fn_processar_devolucao()
RETURNS TRIGGER AS $$
DECLARE
    v_cpf_dono VARCHAR(14);
    v_nome_obj VARCHAR(50);
BEGIN
    SELECT p.cpf, o.nome_obj
      INTO v_cpf_dono, v_nome_obj
      FROM Postagem p
      JOIN Objeto   o ON o.id_obj = p.id_obj
     WHERE p.id_post = NEW.id_post;

    UPDATE Postagem
       SET status_postagem = 'Devolvido'
     WHERE id_post = NEW.id_post;

    INSERT INTO Notificacao (cpf, mensagem, status_leitura)
    VALUES (v_cpf_dono, 'O item "' || v_nome_obj || '" foi marcado como devolvido.', 'Não lida');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Busca postagens por categoria (função de consulta avulsa, útil para
-- SELECT * FROM fn_buscar_postagens_por_categoria('Eletrônicos') numa demo)
CREATE OR REPLACE FUNCTION fn_buscar_postagens_por_categoria(p_categoria VARCHAR)
RETURNS TABLE (
    id_post         INT,
    nome_obj        TEXT,
    categoria       TEXT,
    tipo_postagem   TEXT,
    status_postagem TEXT,
    autor           TEXT
)
LANGUAGE sql
AS $$
    SELECT p.id_post,
           o.nome_obj::TEXT,
           c.nome_categoria::TEXT,
           p.tipo_postagem::TEXT,
           p.status_postagem::TEXT,
           u.nome::TEXT
      FROM Postagem p
      JOIN Objeto           o ON o.id_obj = p.id_obj
      JOIN Categoria_objeto c ON c.id_categoria = o.id_categoria
      JOIN Usuario          u ON u.cpf = p.cpf
     WHERE c.nome_categoria ILIKE p_categoria;
$$;

CREATE OR REPLACE FUNCTION fn_notificar_mensagem()
RETURNS TRIGGER AS $$

DECLARE

    v_destinatario VARCHAR(14);

BEGIN


    SELECT 
        CASE

            WHEN NEW.cpf_remetente = c.cpf_criador
            THEN c.cpf_interessado

            ELSE c.cpf_criador

        END

    INTO v_destinatario

    FROM Conversa c

    WHERE c.id_conversa = NEW.id_conversa;



    INSERT INTO Notificacao(
        cpf,
        mensagem,
        status_leitura
    )

    VALUES(

        v_destinatario,

        'Você recebeu uma nova mensagem.',

        'Não lida'

    );


    RETURN NEW;


END;

$$ LANGUAGE plpgsql;





-- ---------------------------------------------------------------------
-- 5) TRIGGERS (DROP antes de criar para o script ser reexecutável)
-- ---------------------------------------------------------------------

DROP TRIGGER IF EXISTS tg_usuario_autenticado ON Usuario;
CREATE TRIGGER tg_usuario_autenticado
AFTER UPDATE ON Usuario
FOR EACH ROW
EXECUTE FUNCTION fn_notificar_login();

DROP TRIGGER IF EXISTS tg_processar_devolucao ON Devolucao;
CREATE TRIGGER tg_processar_devolucao
AFTER INSERT ON Devolucao
FOR EACH ROW
EXECUTE FUNCTION fn_processar_devolucao();

DROP TRIGGER IF EXISTS tg_nova_mensagem 
ON Mensagem;
CREATE TRIGGER tg_nova_mensagem
AFTER INSERT
ON Mensagem
FOR EACH ROW
EXECUTE FUNCTION fn_notificar_mensagem();

-- ---------------------------------------------------------------------
-- 6) VIEWS
-- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_perfil_publico AS
SELECT nome,
       email,
       telefone,
       registro_institucional,
       tipo_usuario AS esta_autenticado
  FROM Usuario;

-- Feed completo: junta as 6 tabelas usadas para montar cada card do
-- front, com a foto já inclusa.
CREATE OR REPLACE VIEW vw_feed_completo AS
SELECT p.id_post,
       p.tipo_postagem,
       p.status_postagem,
       p.data_hora,
       p.cpf,
       u.nome        AS autor,
       u.email       AS email_autor,
       u.telefone    AS telefone_autor,
       o.id_obj,
       o.nome_obj,
       o.cor,
       o.tamanho,
       o.descricao,
       encode(o.foto_obj, 'base64') AS foto_base64,
       c.id_categoria,
       c.nome_categoria,
       l.id_local,
       l.descricao   AS local,
       cp.id_campi,
       cp.nome_campi AS campus
  FROM Postagem p
  JOIN Usuario          u  ON u.cpf = p.cpf
  JOIN Objeto           o  ON o.id_obj = p.id_obj
  JOIN Categoria_objeto c  ON c.id_categoria = o.id_categoria
  JOIN Localizacao      l  ON l.id_local = p.id_local
  JOIN Campi            cp ON cp.id_campi = l.id_campi
 ORDER BY p.data_hora DESC;

-- Itens ainda pendentes (não devolvidos) - construída sobre vw_feed_completo
CREATE OR REPLACE VIEW vw_itens_pendentes AS
SELECT * FROM vw_feed_completo
 WHERE status_postagem <> 'Devolvido';

-- ---------------------------------------------------------------------
-- 7) DADOS INICIAIS (seed usado pelo front-end)
-- Precisam bater com CAMPUS_NOMES em backend/app.py e com as opções do
-- <select> em site_Projeto_BD/html/cadastro_objeto.html.
-- ---------------------------------------------------------------------

SET search_path TO public;

INSERT INTO Campi (nome_campi) VALUES
    ('Darcy Ribeiro'),
    ('FGA - Gama'),
    ('FCE - Ceilândia'),
    ('FUP - Planaltina');

INSERT INTO Categoria_objeto (nome_categoria) VALUES
    ('Eletrônicos'),
    ('Documentos'),
    ('Mochilas'),
    ('Roupas'),
    ('Acessórios'),
    ('Material Escolar'),
    ('Outro');

-- =====================================================================
-- 8) TESTES DE APRESENTAÇÃO
-- Roteiro pensado para cobrir, em ordem, cada item exigido na
-- apresentação em sala:
--   - banco criado com pelo menos 5 registros por tabela principal
--   - CRUD completo em >= 3 tabelas relacionadas (Usuario, Postagem, Objeto)
--   - view funcionando
--   - procedure funcionando
--   - trigger funcionando
--   - inserção de dado binário (foto em BYTEA)
-- Bloco autossuficiente: roda direto depois das seções 1-7 num banco
-- recém-criado (os IDs abaixo assumem sequences resetadas do zero pelos
-- DROPs do início do script).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 8.1) CREATE - 5 usuários (procedure proc_cadastrar_usuario)
-- ---------------------------------------------------------------------
CALL proc_cadastrar_usuario('11111111111', 'Ana Souza',   'ana.souza@aluno.unb.br',   '20230011', '61999990001', 'senha123', 'Aluno');
CALL proc_cadastrar_usuario('22222222222', 'Bruno Lima',  'bruno.lima@aluno.unb.br',  '20230012', '61999990002', 'senha123', 'Aluno');
CALL proc_cadastrar_usuario('33333333333', 'Carla Dias',  'carla.dias@unb.br',        '20230013', '61999990003', 'senha123', 'Professor');
CALL proc_cadastrar_usuario('44444444444', 'Diego Alves', 'diego.alves@aluno.unb.br', '20230014', '61999990004', 'senha123', 'Aluno');
CALL proc_cadastrar_usuario('55555555555', 'Elisa Rocha', 'elisa.rocha@unb.br',       '20230015', '61999990005', 'senha123', 'Servidor');

SELECT * FROM Usuario;  -- 5 registros

-- ---------------------------------------------------------------------
-- 8.2) CREATE - 5 localizações (ligadas aos 4 campi já semeados)
-- ---------------------------------------------------------------------
INSERT INTO Localizacao (id_campi, descricao) VALUES
    (1, 'Biblioteca Central (BCE)'),
    (1, 'Restaurante Universitário (RU)'),
    (2, 'Bloco A - FGA'),
    (3, 'Bloco B - FCE'),
    (4, 'Bloco Central - FUP');

SELECT * FROM Localizacao;  -- 5 registros

-- ---------------------------------------------------------------------
-- 8.3) CREATE - 5 postagens (proc_registrar_postagem grava em Objeto +
-- Postagem na mesma transação: mostra a procedure funcionando e o
-- relacionamento entre 3 tabelas: Usuario -> Postagem -> Objeto)
-- ---------------------------------------------------------------------
CALL proc_registrar_postagem('11111111111', 1, 'Fone de Ouvido Bluetooth', 'Preto',  'Único',   'Encontrado próximo à cantina do ICC',   1, 'Encontrado');
CALL proc_registrar_postagem('22222222222', 3, 'Mochila Azul',             'Azul',   'Médio',   'Perdida na saída do RU',                2, 'Perdido');
CALL proc_registrar_postagem('33333333333', 2, 'Carteira de Documentos',   'Marrom', 'Pequeno', 'Encontrada no Bloco A da FGA',          3, 'Encontrado');
CALL proc_registrar_postagem('44444444444', 5, 'Óculos de Sol',            'Preto',  'Único',   'Perdido no Bloco B da FCE',             4, 'Perdido');
CALL proc_registrar_postagem('55555555555', 6, 'Calculadora Científica',   'Cinza',  'Pequeno', 'Encontrada no bloco central da FUP',    5, 'Encontrado');

SELECT * FROM Objeto;    -- 5 registros
SELECT * FROM Postagem;  -- 5 registros

-- ---------------------------------------------------------------------
-- 8.4) READ - junção das 3 tabelas relacionadas (Usuario + Postagem + Objeto)
-- ---------------------------------------------------------------------
SELECT p.id_post, u.nome AS autor, o.nome_obj, p.tipo_postagem, p.status_postagem
  FROM Postagem p
  JOIN Usuario u ON u.cpf = p.cpf
  JOIN Objeto  o ON o.id_obj = p.id_obj
 ORDER BY p.id_post;

-- ---------------------------------------------------------------------
-- 8.5) UPDATE - procedures de edição + update direto de status
-- ---------------------------------------------------------------------
CALL proc_editar_usuario('55555555555', 'Elisa Rocha Martins', '61999990099', '20230015');
SELECT nome, telefone FROM Usuario WHERE cpf = '55555555555';

CALL proc_editar_objeto(4, 'Óculos de Sol Ray-Ban', 'Preto Fosco', 'Único', 'Perdido no Bloco B da FCE, armação preta fosca');
SELECT nome_obj, cor, descricao FROM Objeto WHERE id_obj = 4;

UPDATE Postagem SET status_postagem = 'Em contato' WHERE id_post = 2;
SELECT id_post, status_postagem FROM Postagem WHERE id_post = 2;

-- ---------------------------------------------------------------------
-- 8.6) INSERÇÃO DE DADO BINÁRIO - anexa uma foto (PNG) ao objeto 1 via
-- proc_anexar_foto_objeto. O literal abaixo é um PNG 1x1 válido
-- codificado em base64: não depende de nenhum arquivo externo, então
-- roda igual em qualquer máquina do grupo.
-- ---------------------------------------------------------------------
CALL proc_anexar_foto_objeto(
    1,
    decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        'base64'
    )
);

SELECT id_obj, nome_obj, (foto_obj IS NOT NULL) AS tem_foto, length(foto_obj) AS tamanho_bytes
  FROM Objeto
 WHERE id_obj = 1;

-- ---------------------------------------------------------------------
-- 8.7) TRIGGER 1 - tg_usuario_autenticado (login gera notificação)
-- ---------------------------------------------------------------------
UPDATE Usuario SET tipo_usuario = TRUE WHERE cpf = '11111111111';
SELECT tipo_usuario FROM Usuario WHERE cpf = '11111111111';
SELECT * FROM Notificacao WHERE cpf = '11111111111';  -- "Login realizado com sucesso!"

-- ---------------------------------------------------------------------
-- 8.8) TRIGGER 2 - tg_processar_devolucao (devolução fecha a postagem
-- e notifica o dono)
-- ---------------------------------------------------------------------
CALL proc_registrar_devolucao(3, '11111111111', 'Carteira devolvida na portaria da FGA.');
SELECT id_post, status_postagem FROM Postagem WHERE id_post = 3;  -- vira 'Devolvido'
SELECT * FROM Notificacao WHERE cpf = '33333333333' ORDER BY data_hora DESC;  -- dono da postagem 3

-- ---------------------------------------------------------------------
-- 8.9) TRIGGER 3 + CRUD em Conversa/Mensagem - proc_criar_conversa,
-- proc_enviar_mensagem e tg_nova_mensagem (mensagem gera notificação)
-- ---------------------------------------------------------------------
CALL proc_criar_conversa(2, '44444444444');  -- Diego acha a mochila e entra em contato com Bruno (dono da postagem 2)
SELECT * FROM Conversa;  -- id_conversa = 1

CALL proc_enviar_mensagem(1, '44444444444', 'Oi, acho que encontrei sua mochila azul perto do RU. Ainda está perdida?');
CALL proc_enviar_mensagem(1, '22222222222', 'Oi! Sim, ainda estou procurando. Podemos combinar de buscar no RU?');

SELECT m.id_mensagem, u.nome AS remetente, m.conteudo, m.data_envio
  FROM Mensagem m
  JOIN Usuario u ON u.cpf = m.cpf_remetente
 WHERE m.id_conversa = 1
 ORDER BY m.data_envio;

SELECT * FROM Notificacao WHERE cpf IN ('22222222222', '44444444444') ORDER BY data_hora DESC;

-- ---------------------------------------------------------------------
-- 8.10) VIEWS
-- ---------------------------------------------------------------------
SELECT * FROM vw_perfil_publico;

SELECT id_post, autor, nome_obj, campus, status_postagem
  FROM vw_feed_completo
 ORDER BY id_post;

SELECT id_post, status_postagem
  FROM vw_itens_pendentes
 ORDER BY id_post;  -- não deve trazer id_post = 3 (já devolvido)

-- ---------------------------------------------------------------------
-- 8.11) DELETE - remove uma postagem sem devolução/conversa vinculada
-- (mesmo fluxo do DELETE /api/postagens/<id> em app.py: apaga a
-- Postagem e depois o Objeto associado a ela)
-- ---------------------------------------------------------------------
DELETE FROM Postagem WHERE id_post = 5;
DELETE FROM Objeto   WHERE id_obj  = 5;
SELECT * FROM Postagem WHERE id_post = 5;  -- vazio: confirma a exclusão

-- ---------------------------------------------------------------------
-- 8.12) BÔNUS - integridade referencial (PK x FK): a Postagem 3 tem uma
-- Devolucao vinculada (sem ON DELETE) e o Postgres recusa a exclusão
-- direta - é preciso remover a devolução antes (proc_remover_devolucao).
-- Descomente a linha abaixo para ver o erro de violação de FK.
-- ---------------------------------------------------------------------
-- DELETE FROM Postagem WHERE id_post = 3;  -- ERRO: violates foreign key constraint
CALL proc_remover_devolucao(3);
SELECT id_post, status_postagem FROM Postagem WHERE id_post = 3;  -- volta para 'Aberta'
