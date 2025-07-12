@echo off
echo === Migration SQLite vers PostgreSQL et demarrage ===

REM Variables pour PostgreSQL
set PGBIN=C:\Program Files\PostgreSQL\16\bin
set PGUSER=postgres
set PGPASSWORD=postgres

REM Verifier si loto.db existe
if not exist loto.db (
    echo Erreur: loto.db non trouve
    echo Copiez votre base de donnees SQLite dans le repertoire courant
    pause
    exit /b
)

REM Verifier si PostgreSQL est installe
if not exist "%PGBIN%\psql.exe" (
    echo PostgreSQL n'est pas installe dans %PGBIN%
    echo Executez d'abord install_postgres_admin.bat
    pause
    exit /b
)

REM Creer la base de donnees PostgreSQL
echo Creation de la base de donnees PostgreSQL...
"%PGBIN%\createdb.exe" -U %PGUSER% lotodb
if %ERRORLEVEL% NEQ 0 (
    echo La base de donnees existe peut-etre deja, on continue...
)

REM Creer les tables
echo Creation des tables...
"%PGBIN%\psql.exe" -U %PGUSER% -d lotodb -f src/main/resources/db/migration/V1__initial_schema.sql

REM Executer le script de migration
echo Migration des donnees...
python src/main/resources/db/migration/sqlite_to_postgres.py

REM Compiler et demarrer l'application
echo Compilation et demarrage de l'application...
call mvn clean install -DskipTests
call mvn spring-boot:run

echo === Fin du processus ===
pause
