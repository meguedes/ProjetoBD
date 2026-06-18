-- CADASTRO DE USUÁRIO
CREATE OR REPLACE PROCEDURE proc_cadastrar_usuario(
	p_cpf VARCHAR(14), --p de paramêtro
	p_nome VARCHAR(150),
	p_email VARCHAR(100),
	p_registro_institucional VARCHAR(20),
	p_telefone VARCHAR(15)
)

-- OBS.: Definição do uso da linguagem padrão
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO Usuario(cpf, nome, email, registro_institucional, tipo_usuario, telefone)
	VALUES (p_cpf, p_nome, p_email, p_registro_institucional, FALSE, p_telefone);
END;
$$;

-- Sensor de autenticação do usuário
CREATE OR REPLACE FUNCTION fn_notificar_login()
RETURNS TRIGGER AS $$
BEGIN
	IF OLD.tipo_usuario = FALSE AND NEW.tipo_usuario = TRUE THEN
		INSERT INTO Noticicacao (cpf, status_leitura)
		VALUES (NEW.cpf, 'Não lida');
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER tg_usuario_autenticado
AFTER UPDATE ON Usuario
FOR EACH ROW
EXECUTE FUNCTION fn_notificar_login();

-- Visualização do "perfil"
CREATE OR REPLACE VIEW vw_perfil_publico AS
SELECT 
	nome,
	email,
	telefone,
	registro_institucional,
	tipo_usuario AS esta_autenticado
FROM Usuario;

CALL proc_cadastrar_usuario('123.456.789-00', 'Ana Costa', 'ana@unb.br', '2026999', '61999998888');

SELECT * FROM vw_perfil_publico;


