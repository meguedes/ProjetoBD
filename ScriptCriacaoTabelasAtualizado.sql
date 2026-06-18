-- =====================================================================
-- Projeto BD - Sistema de Achados e Perdidos (UnB)
-- 01_schema.sql  ->  Criacao das tabelas
--
-- Ordem de execucao dos scripts:
--   1) 01_schema.sql
--   2) 02_logica.sql           (procedures, functions, triggers, views)
--   3) 03_dados_demo.sql       (carga de dados + demonstracao de CRUD)
-- =====================================================================

-- Limpeza (permite reexecutar o script do zero, em ordem inversa de dependencia)
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
-- Usuario
-- tipo_usuario = flag de conta autenticada/verificada (FALSE ao cadastrar)
-- ---------------------------------------------------------------------
CREATE TABLE Usuario (
    cpf                    VARCHAR(14)  PRIMARY KEY,
    nome                   VARCHAR(150) NOT NULL,
    email                  VARCHAR(100) UNIQUE NOT NULL,
    registro_institucional VARCHAR(20),
    tipo_usuario           BOOLEAN      NOT NULL DEFAULT FALSE,
    telefone               VARCHAR(15)
);

-- ---------------------------------------------------------------------
-- Categoria_objeto  (PK gerada automaticamente pelo SGBD via SERIAL)
-- ---------------------------------------------------------------------
CREATE TABLE Categoria_objeto (
    id_categoria   SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------
-- Objeto  (foto_obj armazena dado binario - BYTEA)
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- Campi
-- ---------------------------------------------------------------------
CREATE TABLE Campi (
    id_campi   SERIAL PRIMARY KEY,
    nome_campi VARCHAR(100) NOT NULL
);

-- ---------------------------------------------------------------------
-- Localizacao
-- ---------------------------------------------------------------------
CREATE TABLE Localizacao (
    id_local  SERIAL PRIMARY KEY,
    id_campi  INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_campi) REFERENCES Campi(id_campi) ON DELETE RESTRICT
);

-- ---------------------------------------------------------------------
-- Postagem  (liga Usuario + Localizacao + Objeto)
-- CHECKs garantem dominio de valores; ajuste a lista conforme o front.
-- ---------------------------------------------------------------------
CREATE TABLE Postagem (
    id_post         SERIAL PRIMARY KEY,
    cpf             VARCHAR(14) NOT NULL,
    id_local        INT NOT NULL,
    id_obj          INT NOT NULL,
    data_hora       TIMESTAMP NOT NULL DEFAULT NOW(),
    tipo_postagem   VARCHAR(20) NOT NULL
        CHECK (tipo_postagem IN ('Perdido', 'Encontrado')),
    status_postagem VARCHAR(30) NOT NULL DEFAULT 'Aberta'
        CHECK (status_postagem IN ('Aberta', 'Em andamento', 'Resolvido', 'Devolvido')),
    FOREIGN KEY (cpf)      REFERENCES Usuario(cpf),
    FOREIGN KEY (id_local) REFERENCES Localizacao(id_local),
    FOREIGN KEY (id_obj)   REFERENCES Objeto(id_obj)
);

-- ---------------------------------------------------------------------
-- Conversa
-- ---------------------------------------------------------------------
CREATE TABLE Conversa (
    id_conversa  SERIAL PRIMARY KEY,
    id_post      INT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_post) REFERENCES Postagem(id_post) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- Mensagem
-- ---------------------------------------------------------------------
CREATE TABLE Mensagem (
    id_mensagem SERIAL PRIMARY KEY,
    id_conversa INT NOT NULL,
    cpf         VARCHAR(14) NOT NULL,
    conteudo    TEXT NOT NULL,
    data_hora   TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (id_conversa) REFERENCES Conversa(id_conversa) ON DELETE CASCADE,
    FOREIGN KEY (cpf)         REFERENCES Usuario(cpf)
);

-- ---------------------------------------------------------------------
-- Notificacao  (colunas titulo/descricao/tipo tornam a notificacao util)
-- ---------------------------------------------------------------------
CREATE TABLE Notificacao (
    id_notificacao   SERIAL PRIMARY KEY,
    cpf              VARCHAR(14) NOT NULL,
    tipo_notificacao VARCHAR(30),
    titulo           VARCHAR(100),
    descricao        TEXT,
    data_hora        TIMESTAMP NOT NULL DEFAULT NOW(),
    status_leitura   VARCHAR(20) DEFAULT 'Não lida',
    FOREIGN KEY (cpf) REFERENCES Usuario(cpf) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- Devolucao
-- ---------------------------------------------------------------------
CREATE TABLE Devolucao (
    id_dev       SERIAL PRIMARY KEY,
    id_post      INT NOT NULL,
    cpf          VARCHAR(14) NOT NULL,
    data_entrega TIMESTAMP NOT NULL DEFAULT NOW(),
    observacao   TEXT,
    FOREIGN KEY (id_post) REFERENCES Postagem(id_post),
    FOREIGN KEY (cpf)     REFERENCES Usuario(cpf)
);


-- =====================================================================
-- 02_logica.sql  ->  PROCEDURES, FUNCTIONS, TRIGGERS e VIEWS
-- Pre-requisito: rodar 01_schema.sql antes.
-- =====================================================================


-- =====================================================================
-- PROCEDURES
-- =====================================================================

-- (1) Cadastro de usuario --------------------------------------------
CREATE OR REPLACE PROCEDURE proc_cadastrar_usuario(
    p_cpf                    VARCHAR(14),  -- p_ = parametro
    p_nome                   VARCHAR(150),
    p_email                  VARCHAR(100),
    p_registro_institucional VARCHAR(20),
    p_telefone               VARCHAR(15)
)

-- OBS.: Definição do uso da linguagem padrão
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Usuario (cpf, nome, email, registro_institucional, tipo_usuario, telefone)
    VALUES (p_cpf, p_nome, p_email, p_registro_institucional, FALSE, p_telefone);
END;
$$;


-- (2) Registrar postagem  [CRUD em MAIS DE UMA TABELA] ---------------
-- Cria o Objeto e, na sequencia, a Postagem que o referencia.
-- As FKs garantem integridade referencial (Usuario, Localizacao,
-- Categoria precisam existir). Se qualquer passo falhar, a procedure
-- aborta e nada e gravado.
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
    -- Tabela 1: Objeto
    INSERT INTO Objeto (id_categoria, nome_obj, cor, tamanho, descricao)
    VALUES (p_id_categoria, p_nome_obj, p_cor, p_tamanho, p_descricao)
    RETURNING id_obj INTO v_id_obj;

    -- Tabela 2: Postagem (liga Usuario + Localizacao + Objeto recem-criado)
    INSERT INTO Postagem (cpf, id_local, id_obj, tipo_postagem, status_postagem)
    VALUES (p_cpf, p_id_local, v_id_obj, p_tipo_postagem, 'Aberta');
END;
$$;


-- (3) Registrar devolucao  [CRUD em MAIS DE UMA TABELA, via trigger] -
-- Insere a Devolucao; o trigger tg_devolucao atualiza a Postagem e
-- gera a Notificacao para o autor da postagem.
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


-- (4) Anexar foto (dado binario) a um objeto -------------------------
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


-- =====================================================================
-- FUNCTIONS
-- =====================================================================

-- (A) Funcao de trigger: notifica quando o usuario e autenticado ------
CREATE OR REPLACE FUNCTION fn_notificar_login()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.tipo_usuario = FALSE AND NEW.tipo_usuario = TRUE THEN
        INSERT INTO Notificacao (cpf, tipo_notificacao, titulo, descricao, status_leitura)
        VALUES (NEW.cpf, 'AUTENTICACAO', 'Conta autenticada',
                'Sua conta foi autenticada com sucesso.', 'Não lida');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- (B) Funcao de trigger: processa a devolucao ------------------------
-- Acessa Postagem + Objeto, atualiza o status da Postagem e cria a
-- Notificacao para o autor.
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

    INSERT INTO Notificacao (cpf, tipo_notificacao, titulo, descricao, status_leitura)
    VALUES (v_cpf_dono, 'DEVOLUCAO', 'Item devolvido',
            'O item "' || v_nome_obj || '" foi marcado como devolvido.', 'Não lida');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- (C) Funcao de consulta: busca postagens por categoria --------------
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


-- =====================================================================
-- TRIGGERS  (DROP antes de criar para o script ser reexecutavel)
-- =====================================================================

DROP TRIGGER IF EXISTS tg_usuario_autenticado ON Usuario;
CREATE TRIGGER tg_usuario_autenticado
AFTER UPDATE ON Usuario
FOR EACH ROW
EXECUTE FUNCTION fn_notificar_login();

DROP TRIGGER IF EXISTS tg_devolucao ON Devolucao;
CREATE TRIGGER tg_devolucao
AFTER INSERT ON Devolucao
FOR EACH ROW
EXECUTE FUNCTION fn_processar_devolucao();


-- =====================================================================
-- VIEWS
-- =====================================================================

-- (I) Perfil publico do usuario
CREATE OR REPLACE VIEW vw_perfil_publico AS
SELECT nome,
       email,
       telefone,
       registro_institucional,
       tipo_usuario AS esta_autenticado
  FROM Usuario;

-- (II) Postagens com todos os dados relacionados (6 tabelas)
CREATE OR REPLACE VIEW vw_postagens_completas AS
SELECT p.id_post,
       p.tipo_postagem,
       p.status_postagem,
       p.data_hora,
       u.nome        AS autor,
       u.email       AS email_autor,
       o.nome_obj,
       o.cor,
       o.tamanho,
       c.nome_categoria,
       l.descricao   AS local,
       cp.nome_campi AS campus
  FROM Postagem p
  JOIN Usuario          u  ON u.cpf = p.cpf
  JOIN Objeto           o  ON o.id_obj = p.id_obj
  JOIN Categoria_objeto c  ON c.id_categoria = o.id_categoria
  JOIN Localizacao      l  ON l.id_local = p.id_local
  JOIN Campi            cp ON cp.id_campi = l.id_campi;

-- (III) Apenas itens ainda pendentes (nao devolvidos)
CREATE OR REPLACE VIEW vw_itens_pendentes AS
SELECT * FROM vw_postagens_completas
 WHERE status_postagem <> 'Devolvido';



 -- =====================================================================
-- Projeto BD - Sistema de Achados e Perdidos (UnB)
-- 03_dados_demo.sql  ->  Carga de dados + demonstracao de CRUD
-- Pre-requisito: rodar 01_schema.sql e 02_logica.sql antes.
-- =====================================================================

-- ------------------- CREATE (INSERT) --------------------------------

INSERT INTO Campi (nome_campi)
VALUES ('Darcy Ribeiro'), ('FCE Ceilandia'), ('FGA Gama');

INSERT INTO Categoria_objeto (nome_categoria)
VALUES ('Eletronicos'), ('Documentos'), ('Vestuario'), ('Acessorios');

INSERT INTO Localizacao (id_campi, descricao) VALUES
    (1, 'Biblioteca Central - BCE'),
    (1, 'ICC Norte - Subsolo'),
    (2, 'Bloco UED - Recepcao');

-- Usuarios cadastrados via PROCEDURE
CALL proc_cadastrar_usuario('111.222.333-44', 'Rafael Henrique', 'rafael@unb.br', '230001', '61988889999');
CALL proc_cadastrar_usuario('222.333.444-55', 'Ana Costa',       'ana@unb.br',    '230002', '61999998888');

SELECT * FROM Usuario;

-- Autenticar um usuario -> dispara o TRIGGER tg_usuario_autenticado
-- (gera automaticamente uma Notificacao)
UPDATE Usuario SET tipo_usuario = TRUE WHERE cpf = '111.222.333-44';

-- Postagens via PROCEDURE multi-tabela (cria Objeto + Postagem juntos)
CALL proc_registrar_postagem('111.222.333-44', 1, 'Garrafa Stanley', 'Azul', '600ml',
     'Garrafa termica encontrada na BCE', 1, 'Encontrado');     -- gera Objeto 1 / Postagem 1

CALL proc_registrar_postagem('222.333.444-55', 2, 'Carteira de estudante', 'Vermelho', 'Pequeno',
     'Carteira perdida no ICC', 2, 'Perdido');                  -- gera Objeto 2 / Postagem 2

-- Conversa + mensagens (chat estilo rede social)
INSERT INTO Conversa (id_post) VALUES (1);
INSERT INTO Mensagem (id_conversa, cpf, conteudo) VALUES
    (1, '222.333.444-55', 'Oi! Acho que essa garrafa e minha.'),
    (1, '111.222.333-44', 'Pode descrever o adesivo na lateral?');

-- ------------------- DADO BINARIO (foto) ----------------------------
-- Opcao A (PORTAVEL, recomendada): PNG 1x1 embutido em base64,
-- sem depender de arquivo externo. Funciona em qualquer maquina.
CALL proc_anexar_foto_objeto(1, decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
    'base64'));

SELECT foto_obj
FROM OBJETO;

-- Opcao B (arquivo real do disco): exige rodar como superusuario e
-- ajustar o caminho. Deixe comentado se for entregar o script.
-- UPDATE Objeto
--    SET foto_obj = pg_read_binary_file('/caminho/para/garrafa-azul.png')
--  WHERE id_obj = 1;

-- Confirma que o binario foi gravado (tamanho em bytes > 0)
SELECT id_obj, nome_obj, octet_length(foto_obj) AS bytes_foto
  FROM Objeto WHERE id_obj = 1;

-- ------------------- READ (SELECT) ----------------------------------
SELECT * FROM vw_postagens_completas;            -- listagem completa
SELECT * FROM vw_itens_pendentes;                -- so os pendentes
SELECT * FROM vw_perfil_publico;                 -- perfis
SELECT * FROM fn_buscar_postagens_por_categoria('Eletronicos');  -- busca

-- ------------------- UPDATE -----------------------------------------
UPDATE Usuario
   SET telefone = '61977776666'
 WHERE cpf = '222.333.444-55';

UPDATE Objeto
   SET cor = 'Grafite', descricao = 'Garrafa Stanley com arranhao na base'
 WHERE id_obj = 1;
 
SELECT * FROM Objeto; 

-- ------------------- DEVOLUCAO (proc + trigger) ---------------------
-- Insere a Devolucao; o TRIGGER tg_devolucao atualiza o status da
-- Postagem para 'Devolvido' e cria uma Notificacao para o autor.
CALL proc_registrar_devolucao(1, '111.222.333-44', 'Entregue ao dono na portaria.');

-- Verifica os efeitos do trigger
SELECT id_post, status_postagem FROM Postagem WHERE id_post = 1;   -- deve estar 'Devolvido'
SELECT cpf, tipo_notificacao, titulo, descricao FROM Notificacao;  -- 2 notificacoes (login + devolucao)

-- ------------------- DELETE -----------------------------------------
-- A conversa some junto com a postagem (ON DELETE CASCADE).
-- DELETE FROM Postagem WHERE id_post = 2;
-- SELECT * FROM Postagem;