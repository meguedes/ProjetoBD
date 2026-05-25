-- Para fins de testes
DROP TABLE IF EXISTS Usuario CASCADE;
DROP TABLE IF EXISTS Notificacao CASCADE;
DROP TABLE IF EXISTS Categoria_objeto CASCADE;
DROP TABLE IF EXISTS Objeto CASCADE;
DROP TABLE IF EXISTS Campi CASCADE;
DROP TABLE IF EXISTS Postagem CASCADE;
DROP TABLE IF EXISTS Localizacao CASCADE;
DROP TABLE IF EXISTS Conversa CASCADE;
DROP TABLE IF EXISTS Mensagem CASCADE;
DROP TABLE IF EXISTS Devolucao CASCADE;

CREATE TABLE Usuario(
	cpf VARCHAR(14) PRIMARY KEY, -- 11 se for somente os numeros/14 para pontos e traco
	nome VARCHAR(150) NOT NULL,
	email VARCHAR(100) UNIQUE,
	registro_institucional VARCHAR(10), -- mat/siape
	tipo_usuario BOOLEAN, -- aluno, professor e servidor
	telefone VARCHAR(15) -- 11 no formato sem parenteses, hifem e espaco
);

CREATE TABLE Notificacao(
	id_notificacao SERIAL PRIMARY KEY,
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf) ON DELETE CASCADE,
	-- Atributo data_hora sem fuso horario, obrigatorio e automatico
    data_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE Categoria_objeto(
	id_categoria SERIAL PRIMARY KEY,
	nome_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE Objeto(
	id_obj SERIAL PRIMARY KEY,
	idcategoria_objeto INT,
	FOREIGN KEY (idcategoria_objeto) REFERENCES Categoria_objeto(id_categoria) ON DELETE RESTRICT,
	nome_obj VARCHAR(50) NOT NULL,
	cor VARCHAR(20),
	tamanho VARCHAR(50),
    foto_obj BYTEA, -- BYTEA para o formato binário.
	descricao TEXT
);

CREATE TABLE Campi(
	idcampi SERIAL PRIMARY KEY,
	nome_campi VARCHAR(100) NOT NULL
);

CREATE TABLE Localizacao(
	id_local SERIAL PRIMARY KEY,
	idcampi INT,
	FOREIGN KEY (idcampi) REFERENCES Campi(idcampi) ON DELETE RESTRICT,
	descricao VARCHAR(50) NOT NULL
);

CREATE TABLE Postagem(
	id_post SERIAL PRIMARY KEy,
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf) ON DELETE RESTRICT,
	id_localizacao INT,
	FOREIGN KEY (id_localizacao) REFERENCES Localizacao(id_local) ON DELETE RESTRICT,
	idobjeto INT,
	FOREIGN KEY (idobjeto) REFERENCES Objeto(id_obj) ON DELETE CASCADE,
	-- Atributo data_hora sem fuso horario, obrigatorio e automatico
    data_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	tipo_postagem VARCHAR(10),
	status_postagem VARCHAR(10)
);

CREATE TABLE Conversa(
	id_conversa SERIAL PRIMARY KEY,
	idpostagem SERIAL,
	FOREIGN KEY (idpostagem) REFERENCES Postagem(id_post),
	data_criacao DATE NOT NULL
);

CREATE TABLE Mensagem(
	id_mensagem SERIAL PRIMARY KEY,
	idconversa INT,
	FOREIGN KEY (idconversa) REFERENCES Conversa(id_conversa) ON DELETE CASCADE,
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf) ON DELETE RESTRICT,
	conteudo TEXT NOT NULL,
	data_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE Devolucao(
	id_dev SERIAL PRIMARY KEY,
	idpostagem INT,
	FOREIGN KEY (idpostagem) REFERENCES Postagem(id_post) ON DELETE RESTRICT,
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf),
	data_entrega TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	observacao TEXT
);
