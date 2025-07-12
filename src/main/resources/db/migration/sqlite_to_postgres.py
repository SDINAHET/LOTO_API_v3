# -*- coding: utf-8 -*-
import sqlite3
import psycopg2
from psycopg2 import Error
import sys
import codecs

# Forcer l'encodage UTF-8 pour la sortie
sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

def migrate_data():
    sqlite_conn = None
    postgres_conn = None

    try:
        print("=== Migration des donnees ===")

        # Connexion à SQLite
        print("Connection SQLite...")
        sqlite_conn = sqlite3.connect('loto.db')
        sqlite_cursor = sqlite_conn.cursor()

        # Connexion à PostgreSQL
        print("Connection PostgreSQL...")
        postgres_conn = psycopg2.connect(
            database="lotodb",
            user="postgres",
            password="postgres",
            host="localhost",
            port="5432"
        )
        postgres_cursor = postgres_conn.cursor()

        # Migration de la table users
        print("Migration users...")
        sqlite_cursor.execute("SELECT * FROM users")
        users = sqlite_cursor.fetchall()

        for user in users:
            try:
                postgres_cursor.execute(
                    """
                    INSERT INTO users (id, first_name, last_name, email, password, is_admin)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    user
                )
            except Exception as e:
                print(f"Erreur insertion user: {str(e)}")

        # Migration de la table tickets
        print("Migration tickets...")
        sqlite_cursor.execute("SELECT * FROM tickets")
        tickets = sqlite_cursor.fetchall()

        for ticket in tickets:
            try:
                postgres_cursor.execute(
                    """
                    INSERT INTO tickets (id, user_id, numbers, lucky_number, draw_date, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    ticket
                )
            except Exception as e:
                print(f"Erreur insertion ticket: {str(e)}")

        # Commit des changements
        postgres_conn.commit()
        print("Migration reussie")

    except Exception as error:
        print("Erreur:", str(error))

    finally:
        if sqlite_conn:
            sqlite_cursor.close()
            sqlite_conn.close()
        if postgres_conn:
            postgres_cursor.close()
            postgres_conn.close()

if __name__ == "__main__":
    try:
        print("Debut migration")
        migrate_data()
        print("Fin migration")
    except Exception as e:
        print("Erreur principale:", str(e))
