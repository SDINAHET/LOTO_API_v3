@echo off
echo === Configuration de PostgreSQL ===

REM Créer la base de données
echo Creation de la base de données...
"C:\Program Files\PostgreSQL\16\bin\createdb.exe" -U postgres lotodb
if %ERRORLEVEL% NEQ 0 (
    echo La base de données existe déjà ou une erreur s'est produite
)

REM Créer les tables
echo Creation des tables...
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d lotodb -f src/main/resources/db/migration/V1__initial_schema.sql

REM Exécuter la migration
echo Migration des données depuis SQLite...
python src/main/resources/db/migration/sqlite_to_postgres.py

echo === Configuration terminée ===
echo Appuyez sur une touche pour continuer...
pause
