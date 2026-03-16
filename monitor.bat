@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de monitoring et rapports pour la synchronisation GitHub
:: Affiche les statistiques et l'etat du systeme
:: ============================================

set "SOURCE=C:\Users\Julien Fritsch\Documents\GitHub"
set "DEST=D:\GitHub"
set "CORBEILLE=D:\GitHub\_Corbeille"
set "LOGS=D:\GitHub\_Logs"

echo ============================================
echo MONITORING SYNCHRONISATION GITHUB
echo ============================================
echo.

:: Date du jour
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "TODAY=%YYYY%-%MM%-%DD%"

:: ============================================
:: 1. Statistiques des dossiers
:: ============================================
echo [STATISTIQUES DES DOSSIERS]
echo.

:: Dossier source
if exist "%SOURCE%" (
    for /f "tokens=3" %%a in ('dir "%SOURCE%" /s /-c ^| find "bytes"') do set "SOURCE_SIZE=%%a"
    for /f %%a in ('dir "%SOURCE%" /s /b 2^>nul ^| find /c /v ""') do set "SOURCE_FILES=%%a"
    for /f %%a in ('dir "%SOURCE%" /s /ad 2^>nul ^| find /c /v ""') do set "SOURCE_FOLDERS=%%a"
    
    echo Source: %SOURCE%
    echo   - Taille: !SOURCE_SIZE! bytes
    echo   - Fichiers: !SOURCE_FILES!
    echo   - Dossiers: !SOURCE_FOLDERS!
) else (
    echo Source: %SOURCE% - INEXISTANT
)

echo.

:: Dossier destination
if exist "%DEST%" (
    for /f "tokens=3" %%a in ('dir "%DEST%" /s /-c ^| find "bytes"') do set "DEST_SIZE=%%a"
    for /f %%a in ('dir "%DEST%" /s /b 2^>nul ^| find /c /v ""') do set "DEST_FILES=%%a"
    for /f %%a in ('dir "%DEST%" /s /ad 2^>nul ^| find /c /v ""') do set "DEST_FOLDERS=%%a"
    
    echo Destination: %DEST%
    echo   - Taille: !DEST_SIZE! bytes
    echo   - Fichiers: !DEST_FILES!
    echo   - Dossiers: !DEST_FOLDERS!
) else (
    echo Destination: %DEST% - INEXISTANT
)

echo.

:: ============================================
:: 2. Statistiques de la corbeille
:: ============================================
echo [STATISTIQUES CORBEILLE]
echo.

if exist "%CORBEILLE%" (
    set "TRASH_SIZE=0"
    set "TRASH_FILES=0"
    set "TRASH_FOLDERS=0"
    
    for /d %%d in ("%CORBEILLE%\*") do (
        set "folder_date=%%~nxd"
        for /f %%a in ('dir "%%d" /s /b 2^>nul ^| find /c /v ""') do set /a "TRASH_FILES+=%%a"
        for /f %%a in ('dir "%%d" /s /ad 2^>nul ^| find /c /v ""') do set /a "TRASH_FOLDERS+=%%a"
    )
    
    for /f "tokens=3" %%a in ('dir "%CORBEILLE%" /s /-c ^| find "bytes"') do set "TRASH_SIZE=%%a"
    
    echo Corbeille: %CORBEILLE%
    echo   - Taille: !TRASH_SIZE! bytes
    echo   - Fichiers: !TRASH_FILES!
    echo   - Dossiers: !TRASH_FOLDERS!
    
    echo.
    echo Dossiers de corbeille par date:
    for /d %%d in ("%CORBEILLE%\*") do (
        set "folder_date=%%~nxd"
        for /f %%a in ('dir "%%d" /s /b 2^>nul ^| find /c /v ""') do set "folder_files=%%a"
        echo   - !folder_date!: !folder_files! fichiers
    )
) else (
    echo Corbeille: %CORBEILLE% - INEXISTANTE
)

echo.

:: ============================================
:: 3. Espace disque disponible
:: ============================================
echo [ESPACE DISQUE]
echo.

for /f "tokens=3" %%a in ('dir C: /-c ^| find "bytes free"') do set "C_FREE=%%a"
for /f "tokens=3" %%a in ('dir D: /-c ^| find "bytes free"') do set "D_FREE=%%a"

echo Disque C: libre = %C_FREE% bytes
echo Disque D: libre = %D_FREE% bytes

:: Conversion en GB
set /a "C_FREE_GB=%C_FREE:~0,-9%"
set /a "D_FREE_GB=%D_FREE:~0,-9%"

echo Disque C: libre = %C_FREE_GB% GB
echo Disque D: libre = %D_FREE_GB% GB

echo.

:: ============================================
:: 4. Dernieres synchronisations
:: ============================================
echo [DERNIERES SYNCHRONISATIONS]
echo.

if exist "%LOGS%" (
    echo Fichiers de log disponibles:
    for %%f in ("%LOGS%\sync-*.log") do (
        echo   - %%~nxf
    )
    
    echo.
    echo Derniere synchronisation:
    set "LATEST_LOG="
    for %%f in ("%LOGS%\sync-*.log") do (
        set "LATEST_LOG=%%f"
    )
    
    if defined LATEST_LOG (
        echo Fichier: %LATEST_LOG%
        echo.
        echo 10 dernieres lignes:
        powershell "Get-Content '%LATEST_LOG%' | Select-Object -Last 10"
    ) else (
        echo Aucun log de synchronisation trouve.
    )
) else (
    echo Dossier des logs introuvable: %LOGS%
)

echo.

:: ============================================
:: 5. Tache planifiee
:: ============================================
echo [TACHE PLANIFIEE]
echo.

schtasks /query /tn "GitHub-Sync" >nul 2>&1
if %errorLevel% equ 0 (
    echo Tache "GitHub-Sync": ACTIVE
    echo.
    echo Prochaines executions:
    schtasks /query /tn "GitHub-Sync" /fo list | find "Prochaine"
    echo.
    echo Dernieres executions:
    schtasks /query /tn "GitHub-Sync" /fo list | find "Derniere"
) else (
    echo Tache "GitHub-Sync": INACTIVE ou INEXISTANTE
    echo.
    echo Pour creer la tache, executez: C:\Scripts\setup-task.bat
)

echo.

:: ============================================
:: 6. Actions rapides
:: ============================================
echo [ACTIONS RAPIDES]
echo.
echo 1. Executer la synchronisation manuellement:
echo    C:\Scripts\sync-github.bat
echo.
echo 2. Nettoyer la corbeille manuellement:
echo    C:\Scripts\cleanup-corbeille.bat
echo.
echo 3. Creer/modifier la tache planifiee:
echo    C:\Scripts\setup-task.bat
echo.
echo 4. Voir la configuration:
echo    C:\Scripts\sync-config.bat
echo.

echo ============================================
echo FIN DU MONITORING
echo ============================================
echo.

pause
