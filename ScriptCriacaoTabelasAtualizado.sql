-- =====================================================
-- SCRIPT DE CRIAÇÃO DO BANCO (gerado a partir do schema
-- real em produção com pg_dump --schema-only, incluindo
-- as procedures/views/triggers e as correções aplicadas
-- em 2026-07-01: fn_notificar_login/fn_processar_devolucao
-- corrigidas e trigger tg_processar_devolucao criada)
-- =====================================================

--
-- PostgreSQL database dump
--

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP VIEW IF EXISTS public.vw_feed_completo CASCADE;
DROP VIEW IF EXISTS public.vw_perfil_publico CASCADE;

DROP TRIGGER IF EXISTS tg_processar_devolucao ON public.devolucao CASCADE;
DROP TRIGGER IF EXISTS tg_usuario_autenticado ON public.usuario CASCADE;

DROP TABLE IF EXISTS public.mensagem CASCADE;
DROP TABLE IF EXISTS public.conversa CASCADE;
DROP TABLE IF EXISTS public.devolucao CASCADE;
DROP TABLE IF EXISTS public.notificacao CASCADE;
DROP TABLE IF EXISTS public.postagem CASCADE;
DROP TABLE IF EXISTS public.objeto CASCADE;
DROP TABLE IF EXISTS public.localizacao CASCADE;
DROP TABLE IF EXISTS public.categoria_objeto CASCADE;
DROP TABLE IF EXISTS public.campi CASCADE;
DROP TABLE IF EXISTS public.usuario CASCADE;

DROP FUNCTION IF EXISTS public.fn_buscar_postagens_por_categoria(character varying) CASCADE;
DROP FUNCTION IF EXISTS public.fn_notificar_login() CASCADE;
DROP FUNCTION IF EXISTS public.fn_processar_devolucao() CASCADE;
DROP PROCEDURE IF EXISTS public.proc_anexar_foto_objeto(integer, bytea) CASCADE;
DROP PROCEDURE IF EXISTS public.proc_cadastrar_usuario(character varying, character varying, character varying, character varying, character varying) CASCADE;
DROP PROCEDURE IF EXISTS public.proc_cadastrar_usuario(character varying, character varying, character varying, character varying, character varying, text, character varying) CASCADE;
DROP PROCEDURE IF EXISTS public.proc_registrar_devolucao(integer, character varying, text) CASCADE;
DROP PROCEDURE IF EXISTS public.proc_registrar_postagem(character varying, integer, character varying, character varying, character varying, text, integer, character varying) CASCADE;

DROP SEQUENCE IF EXISTS public.campi_id_campi_seq CASCADE;
DROP SEQUENCE IF EXISTS public.categoria_objeto_id_categoria_seq CASCADE;
DROP SEQUENCE IF EXISTS public.conversa_id_conversa_seq CASCADE;
DROP SEQUENCE IF EXISTS public.devolucao_id_dev_seq CASCADE;
DROP SEQUENCE IF EXISTS public.localizacao_id_local_seq CASCADE;
DROP SEQUENCE IF EXISTS public.mensagem_id_mensagem_seq CASCADE;
DROP SEQUENCE IF EXISTS public.notificacao_id_notificacao_seq CASCADE;
DROP SEQUENCE IF EXISTS public.objeto_id_obj_seq CASCADE;
DROP SEQUENCE IF EXISTS public.postagem_id_post_seq CASCADE;

--
-- Name: fn_buscar_postagens_por_categoria(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_buscar_postagens_por_categoria(p_categoria character varying) RETURNS TABLE(id_post integer, nome_obj text, categoria text, tipo_postagem text, status_postagem text, autor text)
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


--
-- Name: fn_notificar_login(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_notificar_login() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF OLD.tipo_usuario = FALSE AND NEW.tipo_usuario = TRUE THEN
            INSERT INTO Notificacao (cpf, mensagem, status_leitura)
            VALUES (NEW.cpf, 'Login realizado com sucesso!', 'Não lida');
        END IF;

        RETURN NEW;
    END;
    $$;


--
-- Name: fn_processar_devolucao(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_processar_devolucao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
    $$;


--
-- Name: proc_anexar_foto_objeto(integer, bytea); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.proc_anexar_foto_objeto(IN p_id_obj integer, IN p_foto bytea)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE Objeto SET foto_obj = p_foto WHERE id_obj = p_id_obj;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Objeto % nao encontrado.', p_id_obj;
    END IF;
END;
$$;


--
-- Name: proc_cadastrar_usuario(character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.proc_cadastrar_usuario(IN p_cpf character varying, IN p_nome character varying, IN p_email character varying, IN p_registro_institucional character varying, IN p_telefone character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO Usuario(cpf, nome, email, registro_institucional, tipo_usuario, telefone)
	VALUES (p_cpf, p_nome, p_email, p_registro_institucional, FALSE, p_telefone);
END;
$$;


--
-- Name: proc_cadastrar_usuario(character varying, character varying, character varying, character varying, character varying, text, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.proc_cadastrar_usuario(IN p_cpf character varying, IN p_nome character varying, IN p_email character varying, IN p_registro_institucional character varying, IN p_telefone character varying, IN p_senha text DEFAULT NULL::text, IN p_perfil character varying DEFAULT NULL::character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Usuario(cpf, nome, email, registro_institucional, tipo_usuario, telefone, senha, perfil)
    VALUES (p_cpf, p_nome, p_email, p_registro_institucional, FALSE, p_telefone, p_senha, p_perfil);
END;
$$;


--
-- Name: proc_registrar_devolucao(integer, character varying, text); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.proc_registrar_devolucao(IN p_id_post integer, IN p_cpf_recebedor character varying, IN p_observacao text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Devolucao (id_post, cpf, observacao)
    VALUES (p_id_post, p_cpf_recebedor, p_observacao);
END;
$$;


--
-- Name: proc_registrar_postagem(character varying, integer, character varying, character varying, character varying, text, integer, character varying); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.proc_registrar_postagem(IN p_cpf character varying, IN p_id_categoria integer, IN p_nome_obj character varying, IN p_cor character varying, IN p_tamanho character varying, IN p_descricao text, IN p_id_local integer, IN p_tipo_postagem character varying)
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: campi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campi (
    id_campi integer NOT NULL,
    nome_campi character varying(100) NOT NULL
);


--
-- Name: campi_id_campi_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campi_id_campi_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campi_id_campi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campi_id_campi_seq OWNED BY public.campi.id_campi;


--
-- Name: categoria_objeto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categoria_objeto (
    id_categoria integer NOT NULL,
    nome_categoria character varying(50) NOT NULL
);


--
-- Name: categoria_objeto_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categoria_objeto_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categoria_objeto_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categoria_objeto_id_categoria_seq OWNED BY public.categoria_objeto.id_categoria;


--
-- Name: conversa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversa (
    id_conversa integer NOT NULL,
    id_post integer NOT NULL,
    data_criacao timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: conversa_id_conversa_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conversa_id_conversa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversa_id_conversa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conversa_id_conversa_seq OWNED BY public.conversa.id_conversa;


--
-- Name: devolucao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devolucao (
    id_dev integer NOT NULL,
    id_post integer NOT NULL,
    cpf character varying(14) NOT NULL,
    data_entrega timestamp without time zone DEFAULT now() NOT NULL,
    observacao text
);


--
-- Name: devolucao_id_dev_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.devolucao_id_dev_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devolucao_id_dev_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.devolucao_id_dev_seq OWNED BY public.devolucao.id_dev;


--
-- Name: localizacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localizacao (
    id_local integer NOT NULL,
    id_campi integer NOT NULL,
    descricao character varying(100) NOT NULL
);


--
-- Name: localizacao_id_local_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localizacao_id_local_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localizacao_id_local_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localizacao_id_local_seq OWNED BY public.localizacao.id_local;


--
-- Name: mensagem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mensagem (
    id_mensagem integer NOT NULL,
    id_conversa integer NOT NULL,
    cpf character varying(14) NOT NULL,
    conteudo text NOT NULL,
    data_hora timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: mensagem_id_mensagem_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mensagem_id_mensagem_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mensagem_id_mensagem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mensagem_id_mensagem_seq OWNED BY public.mensagem.id_mensagem;


--
-- Name: notificacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notificacao (
    id_notificacao integer NOT NULL,
    cpf character varying(14) NOT NULL,
    data_hora timestamp without time zone DEFAULT now() NOT NULL,
    status_leitura character varying(20),
    mensagem text
);


--
-- Name: notificacao_id_notificacao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notificacao_id_notificacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notificacao_id_notificacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notificacao_id_notificacao_seq OWNED BY public.notificacao.id_notificacao;


--
-- Name: objeto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.objeto (
    id_obj integer NOT NULL,
    id_categoria integer NOT NULL,
    nome_obj character varying(50) NOT NULL,
    cor character varying(20),
    tamanho character varying(50),
    descricao text,
    foto_obj bytea
);


--
-- Name: objeto_id_obj_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.objeto_id_obj_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: objeto_id_obj_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.objeto_id_obj_seq OWNED BY public.objeto.id_obj;


--
-- Name: postagem; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postagem (
    id_post integer NOT NULL,
    cpf character varying(14) NOT NULL,
    id_local integer NOT NULL,
    id_obj integer NOT NULL,
    data_hora timestamp without time zone DEFAULT now() NOT NULL,
    tipo_postagem character varying(20) NOT NULL,
    status_postagem character varying(30) NOT NULL
);


--
-- Name: postagem_id_post_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.postagem_id_post_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: postagem_id_post_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.postagem_id_post_seq OWNED BY public.postagem.id_post;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    cpf character varying(14) NOT NULL,
    nome character varying(150) NOT NULL,
    email character varying(100) NOT NULL,
    registro_institucional character varying(20),
    tipo_usuario boolean,
    telefone character varying(15),
    senha text,
    perfil character varying(50)
);


--
-- Name: vw_feed_completo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_feed_completo AS
 SELECT p.id_post,
    p.tipo_postagem,
    p.status_postagem,
    p.data_hora,
    p.cpf,
    u.nome AS autor,
    u.email AS email_autor,
    u.telefone AS telefone_autor,
    o.id_obj,
    o.nome_obj,
    o.cor,
    o.tamanho,
    o.descricao,
    encode(o.foto_obj, 'base64'::text) AS foto_base64,
    c.id_categoria,
    c.nome_categoria,
    l.id_local,
    l.descricao AS local,
    cp.id_campi,
    cp.nome_campi AS campus
   FROM (((((public.postagem p
     JOIN public.usuario u ON (((u.cpf)::text = (p.cpf)::text)))
     JOIN public.objeto o ON ((o.id_obj = p.id_obj)))
     JOIN public.categoria_objeto c ON ((c.id_categoria = o.id_categoria)))
     JOIN public.localizacao l ON ((l.id_local = p.id_local)))
     JOIN public.campi cp ON ((cp.id_campi = l.id_campi)))
  ORDER BY p.data_hora DESC;


--
-- Name: vw_perfil_publico; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_perfil_publico AS
 SELECT nome,
    email,
    telefone,
    registro_institucional,
    tipo_usuario AS esta_autenticado
   FROM public.usuario;


--
-- Name: campi id_campi; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campi ALTER COLUMN id_campi SET DEFAULT nextval('public.campi_id_campi_seq'::regclass);


--
-- Name: categoria_objeto id_categoria; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categoria_objeto ALTER COLUMN id_categoria SET DEFAULT nextval('public.categoria_objeto_id_categoria_seq'::regclass);


--
-- Name: conversa id_conversa; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversa ALTER COLUMN id_conversa SET DEFAULT nextval('public.conversa_id_conversa_seq'::regclass);


--
-- Name: devolucao id_dev; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devolucao ALTER COLUMN id_dev SET DEFAULT nextval('public.devolucao_id_dev_seq'::regclass);


--
-- Name: localizacao id_local; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localizacao ALTER COLUMN id_local SET DEFAULT nextval('public.localizacao_id_local_seq'::regclass);


--
-- Name: mensagem id_mensagem; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mensagem ALTER COLUMN id_mensagem SET DEFAULT nextval('public.mensagem_id_mensagem_seq'::regclass);


--
-- Name: notificacao id_notificacao; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacao ALTER COLUMN id_notificacao SET DEFAULT nextval('public.notificacao_id_notificacao_seq'::regclass);


--
-- Name: objeto id_obj; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.objeto ALTER COLUMN id_obj SET DEFAULT nextval('public.objeto_id_obj_seq'::regclass);


--
-- Name: postagem id_post; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postagem ALTER COLUMN id_post SET DEFAULT nextval('public.postagem_id_post_seq'::regclass);


--
-- Name: campi campi_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campi
    ADD CONSTRAINT campi_pkey PRIMARY KEY (id_campi);


--
-- Name: categoria_objeto categoria_objeto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categoria_objeto
    ADD CONSTRAINT categoria_objeto_pkey PRIMARY KEY (id_categoria);


--
-- Name: conversa conversa_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversa
    ADD CONSTRAINT conversa_pkey PRIMARY KEY (id_conversa);


--
-- Name: devolucao devolucao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devolucao
    ADD CONSTRAINT devolucao_pkey PRIMARY KEY (id_dev);


--
-- Name: localizacao localizacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localizacao
    ADD CONSTRAINT localizacao_pkey PRIMARY KEY (id_local);


--
-- Name: mensagem mensagem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mensagem
    ADD CONSTRAINT mensagem_pkey PRIMARY KEY (id_mensagem);


--
-- Name: notificacao notificacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacao
    ADD CONSTRAINT notificacao_pkey PRIMARY KEY (id_notificacao);


--
-- Name: objeto objeto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.objeto
    ADD CONSTRAINT objeto_pkey PRIMARY KEY (id_obj);


--
-- Name: postagem postagem_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postagem
    ADD CONSTRAINT postagem_pkey PRIMARY KEY (id_post);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (cpf);


--
-- Name: devolucao tg_processar_devolucao; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tg_processar_devolucao AFTER INSERT ON public.devolucao FOR EACH ROW EXECUTE FUNCTION public.fn_processar_devolucao();


--
-- Name: usuario tg_usuario_autenticado; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tg_usuario_autenticado AFTER UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_notificar_login();


--
-- Name: conversa conversa_id_post_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversa
    ADD CONSTRAINT conversa_id_post_fkey FOREIGN KEY (id_post) REFERENCES public.postagem(id_post) ON DELETE CASCADE;


--
-- Name: devolucao devolucao_cpf_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devolucao
    ADD CONSTRAINT devolucao_cpf_fkey FOREIGN KEY (cpf) REFERENCES public.usuario(cpf);


--
-- Name: devolucao devolucao_id_post_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devolucao
    ADD CONSTRAINT devolucao_id_post_fkey FOREIGN KEY (id_post) REFERENCES public.postagem(id_post);


--
-- Name: localizacao localizacao_id_campi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localizacao
    ADD CONSTRAINT localizacao_id_campi_fkey FOREIGN KEY (id_campi) REFERENCES public.campi(id_campi) ON DELETE RESTRICT;


--
-- Name: mensagem mensagem_cpf_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mensagem
    ADD CONSTRAINT mensagem_cpf_fkey FOREIGN KEY (cpf) REFERENCES public.usuario(cpf);


--
-- Name: mensagem mensagem_id_conversa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mensagem
    ADD CONSTRAINT mensagem_id_conversa_fkey FOREIGN KEY (id_conversa) REFERENCES public.conversa(id_conversa) ON DELETE CASCADE;


--
-- Name: notificacao notificacao_cpf_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacao
    ADD CONSTRAINT notificacao_cpf_fkey FOREIGN KEY (cpf) REFERENCES public.usuario(cpf) ON DELETE CASCADE;


--
-- Name: objeto objeto_id_categoria_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.objeto
    ADD CONSTRAINT objeto_id_categoria_fkey FOREIGN KEY (id_categoria) REFERENCES public.categoria_objeto(id_categoria) ON DELETE RESTRICT;


--
-- Name: postagem postagem_cpf_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postagem
    ADD CONSTRAINT postagem_cpf_fkey FOREIGN KEY (cpf) REFERENCES public.usuario(cpf);


--
-- Name: postagem postagem_id_local_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postagem
    ADD CONSTRAINT postagem_id_local_fkey FOREIGN KEY (id_local) REFERENCES public.localizacao(id_local);


--
-- Name: postagem postagem_id_obj_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postagem
    ADD CONSTRAINT postagem_id_obj_fkey FOREIGN KEY (id_obj) REFERENCES public.objeto(id_obj);


--
-- PostgreSQL database dump complete
--

-- =====================================================
-- DADOS INICIAIS (campi e categorias usados pelo front-end)
-- =====================================================

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
