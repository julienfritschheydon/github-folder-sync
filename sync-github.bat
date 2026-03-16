@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de synchronisation GitHub avec corbeille
:: Source: C:\Users\Julien Fritsch\Documents\GitHub
:: Destination: D:\GitHub
:: Corbeille: D:\GitHub\_Corbeille\YYYY-MM-DD\
:: ============================================

:: Configuration
set "SOURCE=C:\Users\Julien Fritsch\Documents\GitHub"
set "DEST=D:\GitHub"
set "CORBEILLE=D:\GitHub\_Corbeille"
set "LOGS=D:\GitHub\_Logs"
set "TEMP_LOG=%TEMP%\github-sync-temp.log"

:: Création des dossiers nécessaires
if not exist "%DEST%" mkdir "%DEST%"
if not exist "%CORBEILLE%" mkdir "%CORBEILLE%"
if not exist "%LOGS%" mkdir "%LOGS%"

:: Date du jour pour la corbeille et les logs
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "TODAY=%YYYY%-%MM%-%DD%"
set "LOG_FILE=%LOGS%\sync-%YYYY%%MM%%DD%.log"

:: ============================================
:: 1. Nettoyage de la corbeille (fichiers > 30 jours)
:: ============================================
echo [%DATE% %TIME%] Debut du nettoyage de la corbeille (30 jours) >> "%LOG_FILE%"

:: Calcul de la date limite (30 jours en arriere)
for /f "usebackq" %%d in (`powershell -command "(Get-Date).AddDays(-30).ToString('yyyy-MM-dd')"`) do set "LIMIT_DATE=%%d"

:: Parcours et suppression des anciens dossiers de corbeille
for /d %%d in ("%CORBEILLE%\*") do (
    set "folder_date=%%~nxd"
    if "!folder_date!" LSS "%LIMIT_DATE%" (
        echo [%DATE% %TIME%] Suppression ancienne corbeille: %%d >> "%LOG_FILE%"
        rd /s /q "%%d" 2>> "%LOG_FILE%"
    )
)

:: ============================================
:: 2. Gestion de la corbeille (deplacement fichiers supprimes)
:: ============================================
echo [%DATE% %TIME%] Debut gestion corbeille >> "%LOG_FILE%"
set "CORBEILLE_TODAY=%CORBEILLE%\%TODAY%"

if not exist "%CORBEILLE_TODAY%" mkdir "%CORBEILLE_TODAY%"

:: Comparaison des fichiers pour trouver ceux supprimes dans la source
:: Utilisation de robocopy en mode list pour detecter les differences
robocopy "%DEST%" "%SOURCE%" /L /E /NJH /NJS /NP /R:0 /W:0 > "%TEMP_LOG%" 2>&1

:: Extraction des fichiers qui existent dans DEST mais pas dans SOURCE
for /f "tokens=*" %%f in ('findstr /i "    New File" "%TEMP_LOG%"') do (
    set "file_line=%%f"
    :: Extraction du nom de fichier (apres "New File")
    for /f "tokens=3*" %%a in ("!file_line!") do (
        set "file_to_move=%%a %%b"
        if exist "%DEST%\!file_to_move!" (
            echo [%DATE% %TIME%] Deplacement vers corbeille: !file_to_move! >> "%LOG_FILE%"
            move "%DEST%\!file_to_move!" "%CORBEILLE_TODAY%\" >> "%LOG_FILE%" 2>&1
        )
    )
)

:: ============================================
:: 3. Verification de l'espace disque disponible
:: ============================================
echo [%DATE% %TIME%] Verification espace disque >> "%LOG_FILE%"

:: Verification simple avec WMIC (compare directement les bytes)
:: 5 GB = 5368709120 bytes
wmic LogicalDisk where "DeviceID='D:' and FreeSpace > 5368709120" get DeviceID 2>nul | find /i "D:" >nul
if errorlevel 1 (
    echo [%DATE% %TIME%] ATTENTION: Espace disque insuffisant (moins de 5 GB) >> "%LOG_FILE%"
    echo [%DATE% %TIME%] Minimum requis: 5 GB >> "%LOG_FILE%"
    echo [%DATE% %TIME%] Synchronisation annulee >> "%LOG_FILE%"
    echo.
    echo ============================================
    echo ATTENTION: ESPACE DISQUE INSUFFISANT
    echo Espace libre sur D: moins de 5 GB
    echo Minimum requis: 5 GB
    echo ============================================
    echo.
    goto :end
)

echo [%DATE% %TIME%] Espace disque suffisant (plus de 5 GB) >> "%LOG_FILE%"

:: ============================================
:: 4. Synchronisation principale avec RoboCopy
:: ============================================
echo [%DATE% %TIME%] Debut synchronisation principale >> "%LOG_FILE%"
echo.
echo ============================================
echo Synchronisation GitHub - %TODAY%
echo Source: %SOURCE%
echo Destination: %DEST%
echo ============================================
echo.

:: Options RoboCopy optimisees pour GitHub
:: /E : Sous-dossiers y compris vides
:: /COPY:DAT : Data, Attributes, Timestamps
:: /R:2 /W:5 : 2 retries, 5 secondes d'attente
:: /LOG+ : Log en mode append
:: /TEE : Affichage ecran + log
:: /NP : No Progress (plus rapide)
:: /XD : Exclusion dossiers (temp, cache)
:: /XF : Exclusion fichiers (temp, lock)

robocopy "%SOURCE%" "%DEST%" ^
    /E ^
    /COPY:DAT ^
    /R:2 ^
    /W:5 ^
    /LOG+:"%LOG_FILE%" ^
    /TEE ^
    /NP ^
    /XD ".git\objects\pack" "node_modules\.cache" ".next\cache" ^
    /XF "*.tmp" "*.lock" "*.swp" ".DS_Store"

set "ROBOCOPY_ERROR=%ERRORLEVEL%"

:: ============================================
:: 5. Analyse des resultats
:: ============================================
echo.
echo [%DATE% %TIME%] Analyse des resultats >> "%LOG_FILE%"

if %ROBOCOPY_ERROR% LEQ 7 (
    echo [%DATE% %TIME%] Synchronisation terminee avec succes >> "%LOG_FILE%"
    echo [%DATE% %TIME%] Code retour RoboCopy: %ROBOCOPY_ERROR% >> "%LOG_FILE%"
    
    :: Statistiques de la corbeille
    for /f %%a in ('dir /s /b "%CORBEILLE_TODAY%" 2^>nul ^| find /c /v ""') do set "TRASH_COUNT=%%a"
    echo [%DATE% %TIME%] Fichiers deplaces vers corbeille: !TRASH_COUNT! >> "%LOG_FILE%"
    
    echo.
    echo ============================================
    echo SYNCHRONISATION TERMINEE
    echo Fichiers deplaces vers corbeille: !TRASH_COUNT!
    echo Log: %LOG_FILE%
    echo ============================================
    echo.
    
) else (
    echo [%DATE% %TIME%] Erreur lors de la synchronisation >> "%LOG_FILE%"
    echo [%DATE% %TIME%] Code retour RoboCopy: %ROBOCOPY_ERROR% >> "%LOG_FILE%"
    echo.
    echo ============================================
    echo ERREUR DE SYNCHRONISATION
    echo Code erreur: %ROBOCOPY_ERROR%
    echo Consultez le log: %LOG_FILE%
    echo ============================================
    echo.
)

:: ============================================
:: 6. Nettoyage final
:: ============================================
if exist "%TEMP_LOG%" del "%TEMP_LOG%"

:end
echo [%DATE% %TIME%] Fin du script >> "%LOG_FILE%"
echo.
echo Script termine. Consultez %LOG_FILE% pour les details.
echo.

endlocal
