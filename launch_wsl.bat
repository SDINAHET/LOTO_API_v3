@echo off
echo === Configuration PostgreSQL et lancement de l'application via WSL ===

REM Vérifier que WSL est installé
wsl --status >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo WSL n'est pas installe. Veuillez l'installer d'abord.
    pause
    exit /b 1
)

REM Se placer dans le bon répertoire et configurer PostgreSQL
echo Configuration de PostgreSQL...
wsl sudo bash -c "cd %CD:\=/% && chmod +x configure_postgres.sh && ./configure_postgres.sh"

REM Exécuter l'application
echo Lancement de l'application...
wsl bash -c "cd %CD:\=/% && chmod +x start_wsl.sh && ./start_wsl.sh"

echo === Processus termine ===
pause
