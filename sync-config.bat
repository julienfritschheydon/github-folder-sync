@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Fichier de configuration pour la synchronisation GitHub
:: Modifiez ces variables selon vos besoins
:: ============================================

:: ============================================
:: CHEMINS DES DOSSIERS
:: ============================================
:: Dossier source (GitHub sur C:)
set "SOURCE=C:\Users\Julien Fritsch\Documents\GitHub"

:: Dossier destination (GitHub sur D:)
set "DEST=D:\GitHub"

:: Dossier de corbeille (fichiers supprimes)
set "CORBEILLE=D:\GitHub\_Corbeille"

:: Dossier des logs
set "LOGS=D:\GitHub\_Logs"

:: ============================================
:: PARAMETRES DE SYNCHRONISATION
:: ============================================
:: Nombre de jours de conservation dans la corbeille
set "CORBEILLE_DAYS=30"

:: Frequence de synchronisation (heures)
set "SYNC_FREQUENCY_HOURS=4"

:: Nombre de tentatives en cas d'erreur
set "RETRY_COUNT=2"

:: Attente entre les tentatives (secondes)
set "RETRY_WAIT=5"

:: ============================================
:: EXCLUSIONS (DOSSIERS)
:: ============================================
:: Dossiers a exclure de la synchronisation
:: Separez par des espaces
set "EXCLUDE_DIRS=.git\objects\pack node_modules\.cache .next\cache .vscode\.temp"

:: ============================================
:: EXCLUSIONS (FICHIERS)
:: ============================================
:: Types de fichiers a exclure
:: Separez par des espaces
set "EXCLUDE_FILES=*.tmp *.lock *.swp *.log .DS_Store Thumbs.db"

:: ============================================
:: OPTIONS AVANCEES
:: ============================================
:: Espace minimum requis sur D: (GB)
set "MIN_FREE_SPACE_GB=5"

:: Verification d'integrite (O/N)
set "VERIFY_INTEGRITY=N"

:: Envoi de rapport par email (O/N)
set "EMAIL_REPORTS=N"

:: Email pour les rapports (si EMAIL_REPORTS=O)
set "REPORT_EMAIL="

:: ============================================
:: FONCTIONS DE CONFIGURATION
:: ============================================

:show_config
echo ============================================
echo CONFIGURATION SYNCHRONISATION GITHUB
echo ============================================
echo.
echo [CHEMINS]
echo Source: %SOURCE%
echo Destination: %DEST%
echo Corbeille: %CORBEILLE%
echo Logs: %LOGS%
echo.
echo [PARAMETRES]
echo Conservation corbeille: %CORBEILLE_DAYS% jours
echo Frequence: %SYNC_FREQUENCY_HOURS% heures
echo Tentatives: %RETRY_COUNT% (attente %RETRY_WAIT%s)
echo.
echo [EXCLUSIONS]
echo Dossiers: %EXCLUDE_DIRS%
echo Fichiers: %EXCLUDE_FILES%
echo.
echo [AVANCE]
echo Espace minimum: %MIN_FREE_SPACE_GB% GB
echo Verification integrite: %VERIFY_INTEGRITY%
echo Rapports email: %EMAIL_REPORTS%
if "%EMAIL_REPORTS%"=="O" echo Email: %REPORT_EMAIL%
echo.
echo ============================================
echo.

:validate_config
:: Verification des chemins
if not exist "%SOURCE%" (
    echo ERREUR: Le dossier source n'existe pas: %SOURCE%
    goto :error
)

:: Verification que D: existe
if not exist "D:\" (
    echo ERREUR: Le disque D: n'est pas accessible
    goto :error
)

:: Creation des dossiers necessaires
if not exist "%DEST%" mkdir "%DEST%"
if not exist "%CORBEILLE%" mkdir "%CORBEILLE%"
if not exist "%LOGS%" mkdir "%LOGS%"

echo Configuration valide.
goto :end

:error
echo.
echo Erreur dans la configuration. Corrigez les parametres ci-dessus.
pause
exit /b 1

:end
endlocal
