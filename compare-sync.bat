@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de comparaison post-synchronisation GitHub
:: Vérifie l'intégrité de la synchronisation C: -> D:
:: ============================================

echo ============================================
echo COMPARAISON POST-SYNCHRONISATION GITHUB
echo ============================================
echo.

:: Configuration
set "SOURCE=C:\Users\Julien Fritsch\Documents\GitHub"
set "DEST=D:\GitHub"
set "REPORT=%DEST%\_Logs\sync-compare-%YYYY%%MM%%DD%.txt"

:: Date du jour pour le rapport
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "REPORT=%DEST%\_Logs\sync-compare-%YYYY%%MM%%DD%.txt"

echo Source: %SOURCE%
echo Destination: %DEST%
echo Rapport: %REPORT%
echo.

:: Création du dossier de logs si nécessaire
if not exist "%DEST%\_Logs" mkdir "%DEST%\_Logs"

:: ============================================
:: 1. Statistiques de base
:: ============================================
echo [STATISTIQUES DE BASE] >> "%REPORT%"
echo ============================================ >> "%REPORT%"
echo [%DATE% %TIME%] Debut de la comparaison >> "%REPORT%"
echo. >> "%REPORT%"

echo Analyse des statistiques...
echo.

:: Comptage fichiers et dossiers source
set /a "source_files=0"
set /a "source_dirs=0"

for /f %%a in ('dir "%SOURCE%" /s /b /a-d 2^>nul ^| find /c /v ""') do set "source_files=%%a"
for /f %%a in ('dir "%SOURCE%" /s /b /ad 2^>nul ^| find /c /v ""') do set "source_dirs=%%a"

:: Comptage fichiers et dossiers destination
set /a "dest_files=0"
set /a "dest_dirs=0"

for /f %%a in ('dir "%DEST%" /s /b /a-d 2^>nul ^| find /c /v ""') do set "dest_files=%%a"
for /f %%a in ('dir "%DEST%" /s /b /ad 2^>nul ^| find /c /v ""') do set "dest_dirs=%%a"

echo Source: %source_files% fichiers, %source_dirs% dossiers
echo Destination: %dest_files% fichiers, %dest_dirs% dossiers
echo.

echo Source: %source_files% fichiers, %source_dirs% dossiers >> "%REPORT%"
echo Destination: %dest_files% fichiers, %dest_dirs% dossiers >> "%REPORT%"
echo. >> "%REPORT%"

:: ============================================
:: 2. Vérification des différences avec RoboCopy
:: ============================================
echo [VERIFICATION DES DIFFERENCES] >> "%REPORT%"
echo ============================================ >> "%REPORT%"
echo. >> "%REPORT%"

echo Verification des differences avec RoboCopy...
echo.

:: Fichiers manquants dans destination
echo === FICHIERS MANQUANTS DANS DESTINATION === >> "%REPORT%"
robocopy "%SOURCE%" "%DEST%" /L /E /NJH /NJS /NP /R:0 /W:0 /ndl | findstr /i "    New File" >> "%REPORT%"

:: Fichiers plus récents dans source
echo. >> "%REPORT%"
echo === FICHIERS PLUS RECENTS DANS SOURCE === >> "%REPORT%"
robocopy "%SOURCE%" "%DEST%" /L /E /NJH /NJS /NP /R:0 /W:0 /ndl | findstr /i "    Newer" >> "%REPORT%"

:: Fichiers plus volumineux dans source
echo. >> "%REPORT%"
echo === FICHIERS PLUS VOLUMINEUX DANS SOURCE === >> "%REPORT%"
robocopy "%SOURCE%" "%DEST%" /L /E /NJH /NJS /NP /R:0 /W:0 /ndl | findstr /i "    !new" >> "%REPORT%"

echo Verification terminee.
echo.

:: ============================================
:: 3. Analyse des erreurs potentielles
:: ============================================
echo [ANALYSE DES ERREURS] >> "%REPORT%"
echo ============================================ >> "%REPORT%"
echo. >> "%REPORT%"

echo Analyse des erreurs potentielles...
echo.

:: Vérification de l'espace disque
for /f "tokens=3" %%a in ('dir D: /-c ^| find "bytes free"') do set "free_space=%%a"
echo Espace libre sur D: %free_space% bytes
echo Espace libre sur D: %free_space% bytes >> "%REPORT%"

:: Vérification des dossiers système critiques
set "critical_folders=.git node_modules .next .vscode"
for %%f in (%critical_folders%) do (
    if exist "%SOURCE%\%%f" (
        echo Dossier critique trouve: %%f
        echo Dossier critique trouve: %%f >> "%REPORT%"
        
        :: Vérification que le dossier existe dans destination
        if exist "%DEST%\%%f" (
            echo   - Present dans destination: OK
            echo   - Present dans destination: OK >> "%REPORT%"
        ) else (
            echo   - MANQUANT dans destination: ERREUR
            echo   - MANQUANT dans destination: ERREUR >> "%REPORT%"
        )
    )
)

echo. >> "%REPORT%"

:: ============================================
:: 4. Test d'intégrité (échantillonnage)
:: ============================================
echo [TEST D'INTEGRITE] >> "%REPORT%"
echo ============================================ >> "%REPORT%"
echo. >> "%REPORT%"

echo Test d'integrite (echantillonnage)...
echo.

:: Vérification de quelques fichiers aléatoires
set "sample_files=README.md package.json .gitignore"
set "integrity_ok=1"

for %%f in (%sample_files%) do (
    if exist "%SOURCE%\%%f" (
        if exist "%DEST%\%%f" (
            echo Fichier test: %%f - OK
            echo Fichier test: %%f - OK >> "%REPORT%"
        ) else (
            echo Fichier test: %%f - MANQUANT
            echo Fichier test: %%f - MANQUANT >> "%REPORT%"
            set "integrity_ok=0"
        )
    )
)

echo. >> "%REPORT%"

:: ============================================
:: 5. Résumé et recommandations
:: ============================================
echo [RESUME ET RECOMMANDATIONS] >> "%REPORT%"
echo ============================================ >> "%REPORT%"
echo. >> "%REPORT%"

echo Resume de la synchronisation:
echo.

:: Calcul du taux de synchronisation
if %source_files% GTR 0 (
    set /a "sync_rate=(dest_files * 100) / source_files"
    echo Taux de synchronisation: !sync_rate!%% (!dest_files! / !source_files!)
    echo Taux de synchronisation: !sync_rate!%% (!dest_files! / !source_files!) >> "%REPORT%"
) else (
    echo Taux de synchronisation: N/A (source vide)
    echo Taux de synchronisation: N/A (source vide) >> "%REPORT%"
)

echo.

if %integrity_ok% EQU 1 (
    echo ✅ INTEGRITE: OK
    echo ✅ INTEGRITE: OK >> "%REPORT%"
) else (
    echo ❌ INTEGRITE: ERREURS DETECTEES
    echo ❌ INTEGRITE: ERREURS DETECTEES >> "%REPORT%"
)

echo.
echo Recommandations:
if %dest_files% LSS %source_files% (
    echo - Certains fichiers manquent. Verifiez le rapport pour details.
    echo - Lancez sync-github.bat pour resynchroniser.
    echo - Certains fichiers manquent. Verifiez le rapport pour details. >> "%REPORT%"
    echo - Lancez sync-github.bat pour resynchroniser. >> "%REPORT%"
) else (
    echo - Synchronisation apparemment complete.
    echo - Consultez les logs detailles si necessaire.
    echo - Synchronisation apparemment complete. >> "%REPORT%"
    echo - Consultez les logs detailles si necessaire. >> "%REPORT%"
)

echo.
echo [%DATE% %TIME%] Fin de la comparaison >> "%REPORT%"
echo. >> "%REPORT%"

:: ============================================
:: 6. Affichage du rapport
:: ============================================
echo.
echo ============================================
echo RAPPORT COMPLET SAUVEGARDE DANS:
echo %REPORT%
echo ============================================
echo.

pause
echo.
echo Voulez-vous consulter le rapport maintenant? (O/N)
set /p "choice="
if /i "%choice%"=="O" (
    echo.
    echo === CONTENU DU RAPPORT ===
    echo.
    type "%REPORT%"
    echo.
    echo ==========================
)

echo.
echo ============================================
echo COMPARAISON TERMINEE
echo ============================================
echo.

endlocal
