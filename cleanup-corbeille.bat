@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de nettoyage de la corbeille GitHub
:: Supprime les fichiers de plus de 30 jours
:: ============================================

set "CORBEILLE=D:\GitHub\_Corbeille"
set "LOGS=D:\GitHub\_Logs"

:: Date du jour
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "TODAY=%YYYY%-%MM%-%DD%"
set "LOG_FILE=%LOGS%\cleanup-%YYYY%%MM%%DD%.log"

echo [%DATE% %TIME%] Debut nettoyage corbeille >> "%LOG_FILE%"

:: Verification que le dossier corbeille existe
if not exist "%CORBEILLE%" (
    echo [%DATE% %TIME%] Dossier corbeille introuvable: %CORBEILLE% >> "%LOG_FILE%"
    goto :end
)

:: Calcul de la date limite (30 jours en arriere)
for /f "usebackq" %%d in (`powershell -command "(Get-Date).AddDays(-30).ToString('yyyy-MM-dd')"`) do set "LIMIT_DATE=%%d"

echo [%DATE% %TIME%] Date limite pour suppression: %LIMIT_DATE% >> "%LOG_FILE%"

:: Compteurs
set "FOLDERS_DELETED=0"
set "FILES_DELETED=0"
set "SPACE_FREED=0"

:: Parcours des dossiers de corbeille
for /d %%d in ("%CORBEILLE%\*") do (
    set "folder_date=%%~nxd"
    
    :: Verification si le dossier est plus ancien que 30 jours
    if "!folder_date!" LSS "%LIMIT_DATE%" (
        echo [%DATE% %TIME%] Suppression ancien dossier: %%d >> "%LOG_FILE%"
        
        :: Comptage des fichiers avant suppression
        for /f %%a in ('dir /s /b "%%d" 2^>nul ^| find /c /v ""') do set "folder_files=%%a"
        
        :: Calcul de la taille (approximatif)
        set "folder_size=0"
        for /r "%%d" %%f in (*) do (
            set /a "folder_size+=%%~zf/1024/1024"
        )
        
        :: Suppression du dossier
        rd /s /q "%%d" >> "%LOG_FILE%" 2>&1
        
        if not exist "%%d" (
            set /a "FOLDERS_DELETED+=1"
            set /a "FILES_DELETED+=!folder_files!"
            set /a "SPACE_FREED+=!folder_size!"
            echo [%DATE% %TIME%] Dossier supprime: !folder_files! fichiers, !folder_size! MB >> "%LOG_FILE%"
        ) else (
            echo [%DATE% %TIME%] ERREUR: Impossible de supprimer %%d >> "%LOG_FILE%"
        )
    )
)

:: Rapport final
echo.
echo [%DATE% %TIME%] Nettoyage termine >> "%LOG_FILE%"
echo [%DATE% %TIME%] Dossiers supprimes: %FOLDERS_DELETED% >> "%LOG_FILE%"
echo [%DATE% %TIME%] Fichiers supprimes: %FILES_DELETED% >> "%LOG_FILE%"
echo [%DATE% %TIME%] Espace libere: %SPACE_FREED% MB >> "%LOG_FILE%"

:: Affichage console
echo.
echo ============================================
echo NETTOYAGE CORBEILLE GITHUB
echo ============================================
echo Date: %TODAY%
echo Dossiers supprimes: %FOLDERS_DELETED%
echo Fichiers supprimes: %FILES_DELETED%
echo Espace libere: %SPACE_FREED% MB
echo ============================================
echo.

:end
endlocal
