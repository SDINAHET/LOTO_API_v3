@echo off
echo === Migration SQLite vers PostgreSQL et demarrage de l'application ===

REM Verifier que le script est execute en tant qu'administrateur
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Ce script doit etre execute en tant qu'administrateur
    echo Clic droit sur le script et "Executer en tant qu'administrateur"
    pause
    exit /b 1
)

REM Definir les variables PostgreSQL
set PGPASSWORD=postgres
set PGUSER=postgres
set PGDATABASE=lotodb

REM Demarrer PostgreSQL
echo Demarrage de PostgreSQL...
call start_postgres.bat

REM Configurer le mot de passe PostgreSQL
echo Configuration du mot de passe PostgreSQL...
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -c "ALTER USER postgres WITH PASSWORD 'postgres';"

REM Creer la base de donnees et les tables
echo Creation de la base de donnees...
"C:\Program Files\PostgreSQL\16\bin\createdb.exe" -U postgres %PGDATABASE%
if %ERRORLEVEL% NEQ 0 (
    echo La base de donnees existe peut-etre deja, on continue...
)

REM Creer les tables
echo Creation des tables...
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d %PGDATABASE% -f src/main/resources/db/migration/V1__initial_schema.sql

REM Executer la migration des donnees
echo Migration des donnees depuis SQLite...
python src/main/resources/db/migration/sqlite_to_postgres.py

REM Compiler et demarrer l'application
echo Compilation et demarrage de l'application...
call mvn clean install -DskipTests
call mvn spring-boot:run

echo === Processus termine ===
pause
