import psycopg2
import sqlite3
from datetime import datetime, timedelta
import uuid

# Configuration PostgreSQL
PG_CONFIG = {
    'dbname': 'lotodb',
    'user': 'postgres',
    'password': 'postgres',
    'host': 'localhost',
    'port': '5432'
}

# Connexion à SQLite (base source)
sqlite_conn = sqlite3.connect('loto.db')
sqlite_cursor = sqlite_conn.cursor()

try:
    # Connexion à PostgreSQL (base cible)
    pg_conn = psycopg2.connect(**PG_CONFIG)
    pg_cursor = pg_conn.cursor()

    # Migration des tickets
    print("🔄 Migration des tickets...")
    sqlite_cursor.execute("SELECT * FROM tickets")
    tickets = sqlite_cursor.fetchall()

    for ticket in tickets:
        pg_cursor.execute("""
            INSERT INTO tickets (id, user_id, numbers, lucky_number, draw_date, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, ticket)

    print(f"✅ {len(tickets)} tickets migrés avec succès")

    # Validation des changements dans PostgreSQL
    pg_conn.commit()
    print("✅ Migration terminée avec succès!")

except Exception as e:
    print(f"❌ Erreur pendant la migration: {e}")
    pg_conn.rollback()

finally:
    # Fermeture des connexions
    sqlite_cursor.close()
    sqlite_conn.close()
    pg_cursor.close()
    pg_conn.close()

print("🏁 Script de migration terminé")
