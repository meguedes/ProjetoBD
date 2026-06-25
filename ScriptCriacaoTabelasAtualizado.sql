-- =====================================================
-- LIMPEZA DAS TABELAS (PARA TESTES)
-- =====================================================

DROP TABLE IF EXISTS Notificacao CASCADE;
DROP TABLE IF EXISTS Mensagem CASCADE;
DROP TABLE IF EXISTS Devolucao CASCADE;
DROP TABLE IF EXISTS Conversa CASCADE;
DROP TABLE IF EXISTS Postagem CASCADE;
DROP TABLE IF EXISTS Objeto CASCADE;
DROP TABLE IF EXISTS Categoria_objeto CASCADE;
DROP TABLE IF EXISTS Localizacao CASCADE;
DROP TABLE IF EXISTS Campi CASCADE;
DROP TABLE IF EXISTS Usuario CASCADE;

-- =====================================================
-- TABELA USUARIO
-- =====================================================

CREATE TABLE Usuario(
    cpf VARCHAR(14) PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    registro_institucional VARCHAR(20),
    tipo_usuario VARCHAR(20) NOT NULL,
    telefone VARCHAR(15)
);

-- =====================================================
-- TABELA CATEGORIA_OBJETO
-- =====================================================

CREATE TABLE Categoria_objeto(
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL
);

-- =====================================================
-- TABELA OBJETO
-- =====================================================

CREATE TABLE Objeto(
    id_obj SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome_obj VARCHAR(50) NOT NULL,
    cor VARCHAR(20),
    tamanho VARCHAR(50),
    descricao TEXT,
    foto_obj BYTEA,

    FOREIGN KEY (id_categoria)
        REFERENCES Categoria_objeto(id_categoria)
        ON DELETE RESTRICT
);

-- =====================================================
-- TABELA CAMPI
-- =====================================================

CREATE TABLE Campi(
    id_campi SERIAL PRIMARY KEY,
    nome_campi VARCHAR(100) NOT NULL
);

-- =====================================================
-- TABELA LOCALIZACAO
-- =====================================================

CREATE TABLE Localizacao(
    id_local SERIAL PRIMARY KEY,
    id_campi INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,

    FOREIGN KEY (id_campi)
        REFERENCES Campi(id_campi)
        ON DELETE RESTRICT
);

-- =====================================================
-- TABELA POSTAGEM
-- =====================================================

CREATE TABLE Postagem(
    id_post SERIAL PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL,
    id_local INT NOT NULL,
    id_obj INT NOT NULL,

    data_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    tipo_postagem VARCHAR(20) NOT NULL,
    status_postagem VARCHAR(30) NOT NULL,

    FOREIGN KEY (cpf)
        REFERENCES Usuario(cpf),

    FOREIGN KEY (id_local)
        REFERENCES Localizacao(id_local),

    FOREIGN KEY (id_obj)
        REFERENCES Objeto(id_obj)
);

-- =====================================================
-- TABELA CONVERSA
-- =====================================================

CREATE TABLE Conversa(
    id_conversa SERIAL PRIMARY KEY,
    id_post INT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(),

    FOREIGN KEY (id_post)
        REFERENCES Postagem(id_post)
        ON DELETE CASCADE
);

-- =====================================================
-- TABELA MENSAGEM
-- =====================================================

CREATE TABLE Mensagem(
    id_mensagem SERIAL PRIMARY KEY,
    id_conversa INT NOT NULL,
    cpf VARCHAR(14) NOT NULL,

    conteudo TEXT NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT NOW(),

    FOREIGN KEY (id_conversa)
        REFERENCES Conversa(id_conversa)
        ON DELETE CASCADE,

    FOREIGN KEY (cpf)
        REFERENCES Usuario(cpf)
);

-- =====================================================
-- TABELA NOTIFICACAO
-- =====================================================

CREATE TABLE Notificacao(
    id_notificacao SERIAL PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL,

    mensagem_notificacao TEXT NOT NULL,

    data_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    status_leitura VARCHAR(20) DEFAULT 'Não lida',

    FOREIGN KEY (cpf)
        REFERENCES Usuario(cpf)
        ON DELETE CASCADE
);

-- =====================================================
-- TABELA DEVOLUCAO
-- =====================================================

CREATE TABLE Devolucao(
    id_dev SERIAL PRIMARY KEY,
    id_post INT NOT NULL,
    cpf VARCHAR(14) NOT NULL,

    data_entrega TIMESTAMP NOT NULL DEFAULT NOW(),
    observacao TEXT,

    FOREIGN KEY (id_post)
        REFERENCES Postagem(id_post)
        ON DELETE CASCADE,

    FOREIGN KEY (cpf)
        REFERENCES Usuario(cpf)
);

-- =====================================================
-- PROCEDURE DE CADASTRO DE USUARIO
-- =====================================================

CREATE OR REPLACE PROCEDURE proc_cadastrar_usuario(
    p_cpf VARCHAR(14),
    p_nome VARCHAR(150),
    p_email VARCHAR(100),
    p_senha VARCHAR(255),
    p_registro_institucional VARCHAR(20),
    p_tipo_usuario VARCHAR(20),
    p_telefone VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO Usuario(
        cpf,
        nome,
        email,
        senha,
        registro_institucional,
        tipo_usuario,
        telefone
    )
    VALUES(
        p_cpf,
        p_nome,
        p_email,
        p_senha,
        p_registro_institucional,
        p_tipo_usuario,
        p_telefone
    );

END;
$$;

-- =====================================================
-- FUNCAO DA TRIGGER
-- =====================================================

CREATE OR REPLACE FUNCTION fn_notificar_novo_usuario()
RETURNS TRIGGER AS $$
BEGIN

    INSERT INTO Notificacao(
        cpf,
        mensagem_notificacao,
        status_leitura
    )
    VALUES(
        NEW.cpf,
        'Bem-vindo ao sistema UnBGram!',
        'Não lida'
    );

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGER
-- =====================================================

CREATE TRIGGER tg_novo_usuario
AFTER INSERT ON Usuario
FOR EACH ROW
EXECUTE FUNCTION fn_notificar_novo_usuario();

-- =====================================================
-- VIEW PERFIL PUBLICO
-- =====================================================

CREATE OR REPLACE VIEW vw_perfil_publico AS
SELECT
    nome,
    email,
    telefone,
    registro_institucional,
    tipo_usuario
FROM Usuario;

-- =====================================================
-- INSERTS DE TESTE
-- =====================================================

INSERT INTO Campi(nome_campi)
VALUES ('Darcy Ribeiro');

INSERT INTO Categoria_objeto(nome_categoria)
VALUES ('Eletrônicos');

-- Em produção a senha deve ser armazenada criptografada (hash)

INSERT INTO Usuario(
    cpf,
    nome,
    email,
    senha,
    registro_institucional,
    tipo_usuario,
    telefone
)
VALUES(
    '111.222.333-44',
    'Rafael Henrique',
    'rafael@unb.br',
    '123456',
    '20260001',
    'Aluno',
    '61988889999'
);

CALL proc_cadastrar_usuario(
    '123.456.789-00',
    'Ana Costa',
    'ana@unb.br',
    '123456',
    '2026999',
    'Aluno',
    '61999998888'
);

-- =====================================================
-- CONSULTAS DE TESTE
-- =====================================================

SELECT * FROM Usuario;
SELECT * FROM Notificacao;
SELECT * FROM Campi;
SELECT * FROM Categoria_objeto;
SELECT * FROM vw_perfil_publico;

-- =====================================================
-- UPDATES DE TESTE
-- =====================================================

UPDATE Usuario
SET
    telefone = '61988889999',
    registro_institucional = '202611111'
WHERE cpf = '111.222.333-44';

UPDATE Campi
SET nome_campi = 'Darcy Ribeiro - Asa Norte'
WHERE id_campi = 1;

-- =====================================================
-- DELETES DE TESTE
-- =====================================================

DELETE FROM Postagem
WHERE id_post = 1;

DELETE FROM Usuario
WHERE cpf = '111.222.333-44';