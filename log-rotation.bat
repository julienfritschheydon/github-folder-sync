@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de rotation des logs de synchronisation GitHub
:: Gère la taille des logs, les découpe, et nettoie automatiquement
:: ============================================

echo ============================================
echo ROTATION DES LOGS DE SYNCHRONISATION
echo ============================================
echo.

:: Configuration
set "LOG_DIR=D:\GitHub\_Logs"
set "MAX_LOG_SIZE_MB=10"
set "MAX_LOG_AGE_DAYS=7"
set "MAX_LOG_FILES=50"

:: Conversion en bytes
set /a "MAX_LOG_SIZE_BYTES=%MAX_LOG_SIZE_MB% * 1024 * 1024"

echo Dossier des logs: %LOG_DIR%
echo Taille max par log: %MAX_LOG_SIZE_MB% MB
echo Anciennete max: %MAX_LOG_AGE_DAYS% jours
echo Max fichiers logs: %MAX_LOG_FILES%
echo.

:: Vérification du dossier de logs
if not exist "%LOG_DIR%" (
    echo Creation du dossier de logs...
    mkdir "%LOG_DIR%"
)

:: ============================================
:: 1. Rotation des logs trop volumineux
:: ============================================
echo [1/4] Verification des logs trop volumineux...
echo.

set /a "rotated_count=0"

for %%f in ("%LOG_DIR%\*.log") do (
    :: Obtenir la taille du fichier
    for %%s in ("%%~zf") do set "file_size=%%~s"
    
    :: Vérifier si le fichier dépasse la taille limite
    if !file_size! GTR %MAX_LOG_SIZE_BYTES% (
        echo Rotation de: %%~nxf (!file_size! bytes)
        
        :: Timestamp pour le nouveau nom
        for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
        set "timestamp=!dt:~0,8!_!dt:~8,6!"
        
        :: Renommer l'ancien log
        set "old_file=%LOG_DIR%\%%~nxf"
        set "archived_file=%LOG_DIR%\%%~nf_!timestamp!.log"
        
        rename "!old_file!" "%%~nf_!timestamp!.log"
        set /a "rotated_count+=1"
        
        echo   -> Archive: %%~nf_!timestamp!.log
    )
)

echo.
echo Logs rotates: !rotated_count!
echo.

:: ============================================
:: 2. Nettoyage des logs anciens
:: ============================================
echo [2/4] Nettoyage des logs de plus de %MAX_LOG_AGE_DAYS% jours...
echo.

set /a "deleted_count=0"

:: Calculer la date limite
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "current_date=!dt:~0,8!"
set /a "current_yyyy=!dt:~0,4!"
set /a "current_mm=!dt:~4,2!"
set /a "current_dd=!dt:~6,2!"

for %%f in ("%LOG_DIR%\*.log") do (
    :: Obtenir la date de modification du fichier
    for %%d in ("%%~tf") do set "file_date=%%~d"
    
    :: Parser la date (format AAAAMMJJ)
    set "file_yyyy=!file_date:~6,4!"
    set "file_mm=!file_date:~3,2!"
    set "file_dd=!file_date:~0,2!"
    
    :: Calculer l'âge en jours (simplifié)
    set /a "file_days=!file_yyyy! * 365 + !file_mm! * 30 + !file_dd!"
    set /a "current_days=!current_yyyy! * 365 + !current_mm! * 30 + !current_dd!"
    set /a "age_days=!current_days! - !file_days!"
    
    :: Supprimer si trop ancien
    if !age_days! GTR %MAX_LOG_AGE_DAYS% (
        echo Suppression: %%~nxf (!age_days! jours)
        del "%%f" /q
        set /a "deleted_count+=1"
    )
)

echo.
echo Logs supprimes: !deleted_count!
echo.

:: ============================================
:: 3. Limitation du nombre de fichiers
:: ============================================
echo [3/4] Limitation a %MAX_LOG_FILES% fichiers maximum...
echo.

:: Compter les fichiers logs
set /a "file_count=0"
for %%f in ("%LOG_DIR%\*.log") do set /a "file_count+=1"

if !file_count! GTR %MAX_LOG_FILES% (
    set /a "files_to_delete=!file_count! - %MAX_LOG_FILES%"
    echo Suppression des !files_to_delete! logs les plus anciens...
    
    :: Lister les fichiers par date et supprimer les plus anciens
    dir "%LOG_DIR%\*.log" /b /o-d > "%TEMP%\log_files.txt"
    
    set /a "counter=0"
    for /f "usebackq" %%f in ("%TEMP%\log_files.txt") do (
        set /a "counter+=1"
        if !counter! GTR %MAX_LOG_FILES% (
            echo Suppression: %%f
            del "%LOG_DIR%\%%f" /q
        )
    )
    
    del "%TEMP%\log_files.txt" /q
) else (
    echo Nombre de logs acceptable: !file_count! / %MAX_LOG_FILES%
)

echo.

:: ============================================
:: 4. Statistiques actuelles
:: ============================================
echo [4/4] Statistiques des logs...
echo.

set /a "total_size=0"
set /a "total_files=0"

for %%f in ("%LOG_DIR%\*.log") do (
    set /a "total_files+=1"
    for %%s in ("%%~zf") do set /a "total_size+=%%~s"
)

:: Convertir en MB
set /a "total_size_mb=!total_size! / 1024 / 1024"

echo Fichiers logs: !total_files!
echo Taille totale: !total_size_mb! MB
echo Moyenne par fichier: 
if !total_files! GTR 0 (
    set /a "avg_size=!total_size! / !total_files! / 1024"
    echo !avg_size! KB
) else (
    echo 0 KB
)

echo.

:: ============================================
:: 5. Configuration du script de synchronisation
:: ============================================
echo [5/5] Verification de la configuration...
echo.

set "sync_script=%~dp0sync-github.bat"
if exist "%sync_script%" (
    echo Script de synchronisation trouve: %sync_script%
    
    :: Vérifier si le script utilise déjà la rotation
    findstr /i "log_rotation" "%sync_script%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ Le script inclut deja la rotation des logs
    ) else (
        echo ⚠️  Le script n'inclut pas encore la rotation automatique
        echo.
        echo Pour activer la rotation automatique:
        echo 1. Ajoutez au debut de sync-github.bat:
        echo    call "%~dp0log-rotation.bat"
        echo 2. Ou creez une tache planifiee pour ce script
    )
) else (
    echo ⚠️  Script de synchronisation non trouve: %sync_script%
)

echo.

:: ============================================
:: Résumé
:: ============================================
echo ============================================
echo RESUME DE LA ROTATION
echo ============================================
echo Logs rotates: !rotated_count!
echo Logs supprimes: !deleted_count!
echo Fichiers actuels: !total_files!
echo Taille totale: !total_size_mb! MB
echo.
echo Configuration:
echo - Taille max: %MAX_LOG_SIZE_MB% MB par log
echo - Anciennete max: %MAX_LOG_AGE_DAYS% jours
echo - Max fichiers: %MAX_LOG_FILES%
echo.
echo Prochaine execution recommandee: Quotidienne
echo.

echo Pour creer une tache planifiee:
echo schtasks /create /tn "GitHub-Log-Rotation" /tr "\"%~dp0log-rotation.bat\"" /sc daily /st 02:00
echo.

pause
