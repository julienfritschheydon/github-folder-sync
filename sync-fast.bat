@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de synchronisation GitHub FAST MODE
:: Optimisé pour les changements minimes
:: ============================================

echo ============================================
echo SYNCHRONISATION RAPIDE GITHUB
echo ============================================
echo.

:: Configuration
set "SOURCE=C:\Users\Julien Fritsch\Documents\GitHub"
set "DEST=D:\GitHub"
set "LOGS=D:\GitHub\_Logs"

:: Date du jour pour les logs
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YYYY=%dt:~0,4%"
set "MM=%dt:~4,2%"
set "DD=%dt:~6,2%"
set "LOG_FILE=%LOGS%\sync-fast-%YYYY%%MM%%DD%.log"

:: Création du dossier de logs
if not exist "%LOGS%" mkdir "%LOGS%"

echo [%DATE% %TIME%] Debut synchronisation rapide >> "%LOG_FILE%"
echo Source: %SOURCE%
echo Destination: %DEST%
echo Log: %LOG_FILE%
echo.

:: Synchronisation rapide avec RoboCopy
echo Synchronisation en cours...
echo.

:: Options optimisées:
:: /MIR : Miroir (plus rapide que /E)
:: /COPY:DAT : Copie seulement Date+Attributs+Taille (pas les timestamps NTFS)
:: /R:1 : 1 retry au lieu de 1M
:: /W:2 : 2 secondes wait au lieu de 30
:: /NP : No Progress (plus rapide d'affichage)
:: /NFL : No File List (plus rapide)
:: /NDL : No Directory List (plus rapide)
:: /TEE : Affiche les stats en temps réel

robocopy "%SOURCE%" "%DEST%" /MIR /COPY:DAT /R:1 /W:2 /NP /NFL /NDL /TEE

if %errorLevel% leq 7 (
    echo.
    echo ============================================
    echo SYNCHRONISATION TERMINEE AVEC SUCCES
    echo ============================================
    echo.
    echo Pour verifier le resultat:
    echo compare-sync.bat
    echo.
    
    echo [%DATE% %TIME%] Synchronisation terminee avec succes >> "%LOG_FILE%"
) else (
    echo.
    echo ============================================
    echo ERREUR DE SYNCHRONISATION
    echo Code erreur: %errorLevel%
    echo ============================================
    echo.
    
    echo [%DATE% %TIME%] Erreur de synchronisation: %errorLevel% >> "%LOG_FILE%"
)

echo.
echo ============================================
echo SYNCHRONISATION RAPIDE TERMINEE
echo ============================================
echo.

pause
