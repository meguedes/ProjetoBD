-- CADASTRO DE USUÁRIO
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

-- Notificação automática para novos usuários
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

DROP TRIGGER IF EXISTS tg_novo_usuario ON Usuario;

CREATE TRIGGER tg_novo_usuario
AFTER INSERT ON Usuario
FOR EACH ROW
EXECUTE FUNCTION fn_notificar_novo_usuario();

-- Visualização do perfil público
CREATE OR REPLACE VIEW vw_perfil_publico AS
SELECT
    nome,
    email,
    telefone,
    registro_institucional,
    tipo_usuario
FROM Usuario;

-- Delete porque estava dando problema de duplicidade de PK
DELETE FROM Usuario WHERE cpf = '123.456.789-00';

-- Teste da procedure
CALL proc_cadastrar_usuario(
    '123.456.789-00',
    'Ana Costa',
    'ana@unb.br',
    '123456',
    '2026999',
    'Aluno',
    '61999998888'
);

-- Teste da view
SELECT * FROM vw_perfil_publico;

-- Teste das notificações
SELECT * FROM Notificacao;