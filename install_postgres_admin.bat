@echo off
echo Installation de PostgreSQL...

REM Exécuter PowerShell en tant qu'administrateur
powershell -Command "Start-Process powershell -ArgumentList '-File %~dp0install_postgres.ps1' -Verb RunAs"

echo Une fois l'installation terminée, nous pourrons :
echo 1. Migrer les données depuis SQLite
echo 2. Démarrer l'application
pause
