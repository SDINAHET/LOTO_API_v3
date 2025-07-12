@echo off
echo === Libération du port 5432 pour PostgreSQL ===

REM Trouver le processus qui utilise le port 5432
netstat -ano | findstr :5432
echo.
echo Si un processus utilise le port 5432, son PID sera affiché ci-dessus

REM Arrêter le service PostgreSQL s'il existe
net stop postgresql
net stop "postgresql-x64-16"

REM Afficher les instructions
echo.
echo Pour libérer le port 5432 :
echo 1. Notez le PID (dernier nombre) de la ligne contenant :5432
echo 2. Si un PID est trouvé, utilisez la commande : taskkill /F /PID [numero_pid]
echo 3. Une fois le port libéré, vous pourrez installer PostgreSQL
echo.
echo Appuyez sur une touche pour continuer...
pause
