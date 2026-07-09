Desenvolvimento de um sistema de gerenciamento de achados e perdidos no ambiente universitário, capaz de armazenar e gerenciar informações sobre itens perdidos e encontrados, permitindo o rastreamento, a correspondência entre itens e usuários e o controle de devoluções.

## Como rodar o projeto

O sistema tem 3 partes: banco de dados (PostgreSQL), backend (API em Flask/Python, pasta `backend/`) e frontend (HTML/CSS/JS estático, pasta `site_Projeto_BD/`). Precisa das 3 rodando ao mesmo tempo.

### Pré-requisitos (instalar uma vez)

- **PostgreSQL** (usamos a versão 17): https://www.postgresql.org/download/
- **Python 3.12+**: https://www.python.org/downloads/ (marque "Add python.exe to PATH" no instalador)

### 1. Criar o banco de dados

Abra o pgAdmin (ou psql), crie um banco novo chamado `achados_e_perdidos` e rode nele o script [ScriptCriacaoTabelasAtualizado.sql](ScriptCriacaoTabelasAtualizado.sql). Esse script já cria todas as tabelas, procedures, views e triggers, além de popular campi/categorias iniciais.

### 2. Configurar e rodar o backend

```
cd backend
python -m venv venv
.\venv\Scripts\pip.exe install -r requirements.txt
copy .env.example .env
```

Abra o arquivo `backend\.env` e preencha `DB_PASSWORD` com a senha do seu usuário `postgres` local (os outros campos já vêm com os valores padrão: banco `achados_e_perdidos`, usuário `postgres`, porta `5432`).

Depois, para rodar (repita esse comando toda vez que for usar o projeto):

```
.\venv\Scripts\python.exe app.py
```

A API sobe em `http://localhost:5000`.

### 3. Rodar o frontend

Em outro terminal, sem precisar de venv nem instalar nada:

```
python site_Projeto_BD\serve.py
```

Isso serve o frontend em `http://localhost:5501` — abra `http://localhost:5501/html/index.html` no navegador. O script sempre serve a partir da própria pasta `site_Projeto_BD`, então funciona não importa de onde o repositório esteja ou qual pasta está aberta no editor.

### Observações

- Se a porta 5501 estiver ocupada (ex: Live Server do VS Code também usando a mesma porta), troque o número de `PORTA` no início de `site_Projeto_BD/serve.py`.
- O arquivo `backend/.env` (com sua senha) não é versionado — cada pessoa cria o seu localmente a partir do `.env.example`.
- Se der erro ao instalar `psycopg2-binary`/`psycopg`, confira se está usando Python 3.12+ (o `requirements.txt` já usa `psycopg[binary]`, que tem binário pronto pras versões recentes do Python no Windows).
