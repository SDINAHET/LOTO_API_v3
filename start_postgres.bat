@echo off
echo === Demarrage de PostgreSQL ===

REM Arreter le service PostgreSQL s'il est en cours
net stop postgresql
net stop "postgresql-x64-16"

REM Demarrer le service PostgreSQL
echo Demarrage du service PostgreSQL...
net start postgresql
net start "postgresql-x64-16"

REM Verifier si le service est bien demarre
pg_isready -h localhost -p 5432
if %ERRORLEVEL% NEQ 0 (
    echo Erreur: PostgreSQL n'est pas demarre correctement
    pause
    exit /b 1
)

echo PostgreSQL est demarre et pret !
echo Port: 5432
echo.
pause
