@echo off
echo === Installation et configuration des bases de données ===

REM Vérifier si PostgreSQL est installé
where psql >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo PostgreSQL n'est pas installé. Veuillez l'installer depuis :
    echo https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
    echo Utilisez le mot de passe : postgres
    pause
    exit /b
)

REM Vérifier si MongoDB est installé
where mongod >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo MongoDB n'est pas installé. Veuillez l'installer depuis :
    echo https://www.mongodb.com/try/download/community
    pause
    exit /b
)

REM Créer la base de données PostgreSQL
echo Création de la base de données PostgreSQL...
psql -U postgres -c "CREATE DATABASE lotodb;"

REM Exécuter le script de migration
echo Migration des données de SQLite vers PostgreSQL...
python src/main/resources/db/migration/sqlite_to_postgres.py

REM Démarrer MongoDB
echo Démarrage de MongoDB...
start mongod

REM Compiler et démarrer l'application
echo Compilation et démarrage de l'application...
call mvn clean install -DskipTests
call mvn spring-boot:run

echo === Configuration terminée ===
pause
