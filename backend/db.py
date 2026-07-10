import os

import psycopg
from dotenv import load_dotenv
from psycopg.rows import dict_row

load_dotenv()

print("BANCO:", os.getenv("DB_NAME"))
print("USUARIO:", os.getenv("DB_USER"))
print("SENHA:", os.getenv("DB_PASSWORD"))


def get_conn():
    return psycopg.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "achados_e_perdidos"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "senha123"),
        row_factory=dict_row,
    )