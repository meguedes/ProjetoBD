--Para fins de testes
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
	nome VARCHAR(50) NOT NULL,
	email VARCHAR(100),
	registro_institucional VARCHAR(10), -- mat/siape
	tipo_usuario VARCHAR(10), --aluno, professor e servidor
	telefone VARCHAR(15) --11 no formato sem parenteses, hifem e espaco
);

CREATE TABLE Notificacao(
	id_notificacao SERIAL PRIMARY KEY,
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf),
	-- Atributo data_hora sem fuso horario, obrigatorio e automatico
    data_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE Categoria_objeto(
	id_categoria SERIAL PRIMARY KEY,
	nome_categoria VARCHAR(30)
);

CREATE TABLE Objeto(
	id_obj SERIAL PRIMARY KEY,
	idcategoria_objeto SERIAL,
	FOREIGN KEY (idcategoria_objeto) REFERENCES Categoria_objeto(id_categoria),
	nome_obj VARCHAR(20),
	cor VARCHAR(10),
	tamanho VARCHAR(5),
	descricao VARCHAR(100),
	foto_obj BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Campi(
	idcampi SERIAL PRIMARY KEY,
	nome_campi VARCHAR(20)
);

CREATE TABLE Localizacao(
	id_local SERIAL PRIMARY KEY,
	idcampi SERIAL,
	FOREIGN KEY (idcampi) REFERENCES Campi(idcampi),
	descricao VARCHAR(50)
);

CREATE TABLE Postagem(
	id_post SERIAL PRIMARY KEy,
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf),
	id_localizacao SERIAL,
	FOREIGN KEY (id_localizacao) REFERENCES Localizacao(id_local),
	idobjeto SERIAL,
	FOREIGN KEY (idobjeto) REFERENCES Objeto(id_obj),
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
	idconversa SERIAL,
	FOREIGN KEY (idconversa) REFERENCES Conversa(id_conversa),
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf),
	conteudo VARCHAR(100),
	data_hora TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE Devolucao(
	id_dev SERIAL PRIMARY KEY,
	idpostagem SERIAL,
	FOREIGN KEY (idpostagem) REFERENCES Postagem(id_post),
	cpf VARCHAR(14),
	FOREIGN KEY (cpf) REFERENCES Usuario(cpf),
	data_entrega DATE NOT NULL,
	observacao VARCHAR(100)
);