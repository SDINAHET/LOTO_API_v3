# Script PowerShell pour installer PostgreSQL

# Télécharger l'installateur PostgreSQL
$url = "https://get.enterprisedb.com/postgresql/postgresql-16.2-1-windows-x64.exe"
$output = "$env:TEMP\postgresql-installer.exe"

Write-Host "Téléchargement de PostgreSQL..."
Invoke-WebRequest -Uri $url -OutFile $output

# Installer PostgreSQL silencieusement
Write-Host "Installation de PostgreSQL..."
$arguments = "--mode unattended --unattendedmodeui none " + `
            "--superpassword postgres " + `
            "--serverport 5432"

Start-Process -FilePath $output -ArgumentList $arguments -Wait

# Attendre que le service démarre
Write-Host "Démarrage du service PostgreSQL..."
Start-Sleep -s 10

# Créer la base de données
Write-Host "Création de la base de données..."
$env:PGPASSWORD = "postgres"
& "C:\Program Files\PostgreSQL\16\bin\createdb.exe" -U postgres lotodb

Write-Host "Installation terminée!"
Write-Host "Base de données 'lotodb' créée avec succès."
Write-Host "Utilisateur: postgres"
Write-Host "Mot de passe: postgres"
Write-Host "Port: 5432"
