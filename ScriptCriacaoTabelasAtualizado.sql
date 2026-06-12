-- Para fins de testes
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

-- 	Criação das tabelas
CREATE TABLE Usuario(
    cpf VARCHAR(14) PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    registro_institucional VARCHAR(20),
    tipo_usuario BOOLEAN,
    telefone VARCHAR(15)
);

CREATE TABLE Categoria_objeto(
    id_categoria SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(50) NOT NULL
);

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

CREATE TABLE Campi(
    id_campi SERIAL PRIMARY KEY,
    nome_campi VARCHAR(100) NOT NULL
);

CREATE TABLE Localizacao(
    id_local SERIAL PRIMARY KEY,
    id_campi INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,

    FOREIGN KEY (id_campi)
        REFERENCES Campi(id_campi)
        ON DELETE RESTRICT
);

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

CREATE TABLE Conversa(
    id_conversa SERIAL PRIMARY KEY,
    id_post INT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT NOW(),

    FOREIGN KEY (id_post)
        REFERENCES Postagem(id_post)
        ON DELETE CASCADE
);

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

CREATE TABLE Notificacao(
    id_notificacao SERIAL PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL,

    data_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    status_leitura VARCHAR(20),

    FOREIGN KEY (cpf)
        REFERENCES Usuario(cpf)
        ON DELETE CASCADE
);

CREATE TABLE Devolucao(
    id_dev SERIAL PRIMARY KEY,
    id_post INT NOT NULL,
    cpf VARCHAR(14) NOT NULL,

    data_entrega TIMESTAMP NOT NULL DEFAULT NOW(),
    observacao TEXT,

    FOREIGN KEY (id_post)
        REFERENCES Postagem(id_post),

    FOREIGN KEY (cpf)
        REFERENCES Usuario(cpf)
);

-- CRUD (INSERT)

INSERT INTO campi(nome_campi)
VALUES ('Darcy Ribeiro');

SELECT * FROM Campi;

INSERT INTO categoria_objeto (nome_categoria) 
VALUES ('Eletrônicos')
ON CONFLICT DO NOTHING; -- Evitar erro se já existir 

SELECT * FROM categoria_objeto;

INSERT INTO objeto (nome_obj, id_categoria, cor, tamanho, descricao, foto_obj) 
VALUES ('Garrafa ', 1, 'azul', '600ml', 'Garrafa azul de 600ml da marca Stanley', pg_read_binary_file('C:/Users/rafae/OneDrive/Imagens/garrafa-azul.webp')
);

INSERT INTO usuario (cpf, nome, email) 
VALUES ('111.222.333-44', 'Rafael Henrique', 'rafael@unb.br');

SELECT * FROM Usuario;

-- UPDATE

UPDATE Usuario 
SET telefone = '61988889999', registro_institucional = 'Servidor' 
WHERE cpf = '111.222.333-44';

SELECT * FROM Usuario;

UPDATE Campi 
SET nome_campi = 'Darcy Ribeiro - Asa Norte' 
WHERE id_campi = 1;

SELECT * FROM Campi;

UPDATE Objeto 
SET cor = 'Grafite', descricao = 'Garrafa Stanley preta com arranhão na base' 
WHERE id_obj = 1;

SELECT * FROM Objeto;

-- DELETE

DELETE FROM Postagem 
WHERE id_post = 1;

SELECT * FROM Postagem;

DELETE FROM Usuario 
WHERE cpf = '111.222.333-44';

SELECT * FROM Usuario;


