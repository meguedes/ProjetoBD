import psycopg
from flask import Flask, jsonify, request
from flask_cors import CORS
from werkzeug.security import check_password_hash, generate_password_hash

from db import get_conn

app = Flask(__name__)
CORS(app)

CAMPUS_NOMES = {
    "darcy": "Darcy Ribeiro",
    "fga": "FGA - Gama",
    "fce": "FCE - Ceilândia",
    "fup": "FUP - Planaltina",
}


def find_or_create(cur, tabela, coluna_id, coluna_busca, valor, colunas_extra=None):
    cur.execute(
        f"SELECT {coluna_id} FROM {tabela} WHERE {coluna_busca} = %s ORDER BY {coluna_id} ASC LIMIT 1",
        (valor,),
    )
    row = cur.fetchone()
    if row:
        return row[coluna_id]

    colunas_extra = colunas_extra or {}
    colunas = [coluna_busca, *colunas_extra.keys()]
    valores = [valor, *colunas_extra.values()]
    placeholders = ", ".join(["%s"] * len(valores))
    cur.execute(
        f"INSERT INTO {tabela} ({', '.join(colunas)}) VALUES ({placeholders}) RETURNING {coluna_id}",
        valores,
    )
    return cur.fetchone()[coluna_id]


def ultimo_id(cur, tabela, coluna_id):
    cur.execute("SELECT currval(pg_get_serial_sequence(%s, %s)) AS id", (tabela, coluna_id))
    return cur.fetchone()["id"]


@app.get("/api/health")
def health():
    return jsonify({"status": "ok"})


# =====================================================
# USUARIOS
# =====================================================

@app.post("/api/usuarios")
def criar_usuario():
    dados = request.get_json(force=True)

    obrigatorios = ["cpf", "nome", "email", "senha", "tipoUsuario"]
    faltando = [campo for campo in obrigatorios if not dados.get(campo)]
    if faltando:
        return jsonify({"erro": f"Campos obrigatórios: {', '.join(faltando)}"}), 400

    senha_hash = generate_password_hash(dados["senha"])

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "CALL proc_cadastrar_usuario(%s, %s, %s, %s, %s, %s, %s)",
                (
                    dados["cpf"],
                    dados["nome"],
                    dados["email"],
                    dados.get("registro"),
                    dados.get("telefone"),
                    senha_hash,
                    dados["tipoUsuario"],
                ),
            )
        conn.commit()
        return jsonify({"ok": True}), 201
    except psycopg.errors.UniqueViolation:
        conn.rollback()
        return jsonify({"erro": "CPF ou e-mail já cadastrado"}), 409
    finally:
        conn.close()


@app.post("/api/login")
def login():
    dados = request.get_json(force=True)

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """SELECT cpf, nome, email, senha, telefone,
                          registro_institucional, perfil
                   FROM Usuario WHERE email = %s""",
                (dados.get("email"),),
            )
            usuario = cur.fetchone()

            if not usuario or not check_password_hash(usuario["senha"] or "", dados.get("senha", "")):
                return jsonify({"erro": "Email ou senha inválidos"}), 401

            # Ativa a flag de autenticado -> dispara tg_usuario_autenticado
            # (cria notificação de boas-vindas na primeira vez que loga)
            cur.execute(
                "UPDATE Usuario SET tipo_usuario = TRUE WHERE cpf = %s",
                (usuario["cpf"],),
            )
        conn.commit()
    finally:
        conn.close()

    return jsonify({
        "cpf": usuario["cpf"],
        "nome": usuario["nome"],
        "email": usuario["email"],
        "telefone": usuario["telefone"],
        "registro": usuario["registro_institucional"],
        "tipoUsuario": usuario["perfil"],
    })


@app.post("/api/logout")
def logout():
    dados = request.get_json(force=True)
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "UPDATE Usuario SET tipo_usuario = FALSE WHERE cpf = %s",
                (dados.get("cpf"),),
            )
        conn.commit()
    finally:
        conn.close()
    return jsonify({"ok": True})


@app.get("/api/perfil/<cpf>")
def perfil_publico(cpf):
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """SELECT v.* FROM vw_perfil_publico v
                   JOIN Usuario u ON u.email = v.email
                   WHERE u.cpf = %s""",
                (cpf,),
            )
            perfil = cur.fetchone()
    finally:
        conn.close()

    if not perfil:
        return jsonify({"erro": "Usuário não encontrado"}), 404
    return jsonify(dict(perfil))


# =====================================================
# POSTAGENS (Objeto + Postagem via procedures existentes)
# =====================================================

@app.get("/api/postagens")
def listar_postagens():
    cpf = request.args.get("cpf")

    query = "SELECT * FROM vw_feed_completo"
    params = []
    if cpf:
        query += " WHERE cpf = %s"
        params.append(cpf)
    query += " ORDER BY data_hora DESC"

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(query, params)
            linhas = cur.fetchall()
    finally:
        conn.close()

    postagens = [{
        "id_post": linha["id_post"],
        "cpf": linha["cpf"],
        "usuario": linha["autor"],
        "nomeObjeto": linha["nome_obj"],
        "cor": linha["cor"],
        "tamanho": linha["tamanho"],
        "descricao": linha["descricao"],
        "categoria": linha["nome_categoria"],
        "tipo_postagem": linha["tipo_postagem"],
        "status_postagem": linha["status_postagem"],
        "data_hora": linha["data_hora"].strftime("%d/%m/%Y %H:%M") if linha["data_hora"] else None,
        "localizacao": f"{linha['local']} - {linha['campus']}",
        "foto": f"data:image/jpeg;base64,{linha['foto_base64']}" if linha["foto_base64"] else None,
    } for linha in linhas]

    return jsonify(postagens)


@app.post("/api/postagens")
def criar_postagem():
    form = request.form
    obrigatorios = ["cpf", "nome_objeto", "categoria", "tipo_postagem", "campus"]
    faltando = [campo for campo in obrigatorios if not form.get(campo)]
    if faltando:
        return jsonify({"erro": f"Campos obrigatórios: {', '.join(faltando)}"}), 400

    localizacao = form.get("outro_local") or form.get("localizacao")
    if not localizacao:
        return jsonify({"erro": "Informe a localização"}), 400

    foto = request.files.get("foto")
    foto_bytes = foto.read() if foto else None

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            id_categoria = find_or_create(
                cur, "Categoria_objeto", "id_categoria", "nome_categoria", form["categoria"]
            )
            nome_campi = CAMPUS_NOMES.get(form["campus"], form["campus"])
            id_campi = find_or_create(cur, "Campi", "id_campi", "nome_campi", nome_campi)
            id_local = find_or_create(
                cur, "Localizacao", "id_local", "descricao", localizacao,
                colunas_extra={"id_campi": id_campi},
            )

            cur.execute(
                "CALL proc_registrar_postagem(%s, %s, %s, %s, %s, %s, %s, %s)",
                (
                    form["cpf"], id_categoria, form["nome_objeto"], form.get("cor"),
                    form.get("tamanho"), form.get("descricao"), id_local, form["tipo_postagem"],
                ),
            )
            id_obj = ultimo_id(cur, "objeto", "id_obj")
            id_post = ultimo_id(cur, "postagem", "id_post")

            if foto_bytes:
                cur.execute("CALL proc_anexar_foto_objeto(%s, %s)", (id_obj, foto_bytes))

        conn.commit()
        return jsonify({"id_post": id_post}), 201
    except Exception as erro:
        conn.rollback()
        return jsonify({"erro": str(erro)}), 400
    finally:
        conn.close()


@app.put("/api/postagens/<int:id_post>/devolver")
def devolver_postagem(id_post):
    dados = request.get_json(force=True)
    cpf = dados.get("cpf")

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT cpf FROM Postagem WHERE id_post = %s", (id_post,))
            postagem = cur.fetchone()
            if not postagem:
                return jsonify({"erro": "Postagem não encontrada"}), 404
            if postagem["cpf"] != cpf:
                return jsonify({"erro": "Você não é o dono desta postagem"}), 403

            # Dispara tg_processar_devolucao: atualiza status_postagem e notifica
            cur.execute(
                "CALL proc_registrar_devolucao(%s, %s, %s)",
                (id_post, cpf, "Marcado como devolvido pelo usuário"),
            )
        conn.commit()
        return jsonify({"ok": True})
    finally:
        conn.close()


@app.put("/api/postagens/<int:id_post>")
def editar_postagem(id_post):
    dados = request.get_json(force=True)
    cpf = dados.get("cpf")

    if not dados.get("nome_objeto"):
        return jsonify({"erro": "Campo obrigatório: nome_objeto"}), 400

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT cpf, id_obj FROM Postagem WHERE id_post = %s", (id_post,))
            postagem = cur.fetchone()
            if not postagem:
                return jsonify({"erro": "Postagem não encontrada"}), 404
            if postagem["cpf"] != cpf:
                return jsonify({"erro": "Você não é o dono desta postagem"}), 403

            cur.execute(
                "CALL proc_editar_objeto(%s, %s, %s, %s, %s)",
                (
                    postagem["id_obj"], dados["nome_objeto"], dados.get("cor"),
                    dados.get("tamanho"), dados.get("descricao"),
                ),
            )
        conn.commit()
        return jsonify({"ok": True})
    finally:
        conn.close()


@app.delete("/api/postagens/<int:id_post>")
def excluir_postagem(id_post):
    cpf = request.args.get("cpf")

    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM Postagem WHERE id_post = %s AND cpf = %s",
                (id_post, cpf),
            )
            if cur.rowcount == 0:
                conn.rollback()
                return jsonify({"erro": "Postagem não encontrada"}), 404
        conn.commit()
        return jsonify({"ok": True})
    except psycopg.errors.ForeignKeyViolation:
        # A postagem é chave estrangeira em Devolucao (sem ON DELETE CASCADE):
        # o Postgres recusa o DELETE enquanto existir devolução registrada.
        conn.rollback()
        return jsonify({
            "erro": "Não é possível excluir: existe uma devolução registrada "
                    "para esta postagem. Remova a devolução antes de excluir."
        }), 409
    finally:
        conn.close()


# =====================================================
# NOTIFICACOES
# =====================================================

@app.get("/api/notificacoes/<cpf>")
def listar_notificacoes(cpf):
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """SELECT mensagem,
                          to_char(data_hora, 'DD/MM/YYYY HH24:MI') AS data_hora
                   FROM Notificacao WHERE cpf = %s
                   ORDER BY data_hora DESC""",
                (cpf,),
            )
            linhas = cur.fetchall()
    finally:
        conn.close()

    return jsonify([
        {"mensagem": linha["mensagem"], "data": linha["data_hora"]}
        for linha in linhas
    ])


if __name__ == "__main__":
    app.run(debug=True, port=5000)
