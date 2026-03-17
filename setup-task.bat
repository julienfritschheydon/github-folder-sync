@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Script de creation de la tache planifiee Windows
:: pour la synchronisation GitHub toutes les 4 heures
:: ============================================

echo ============================================
echo CONFIGURATION TACHE PLANIFIEE GITHUB SYNC
echo ============================================
echo.

:: Verification des privileges administrateur
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERREUR: Ce script necessite des privileges administrateur.
    echo Clic droit sur le script et "Executer en tant qu'administrateur".
    pause
    exit /b 1
)

:: Configuration
set "TASK_NAME=GitHub-Sync"
set "SCRIPT_PATH=%~dp0sync-github.bat"
set "DESCRIPTION=Synchronisation automatique du dossier GitHub toutes les 4 heures avec corbeille"

:: Verification que le script principal existe
if not exist "%SCRIPT_PATH%" (
    echo ERREUR: Le script de synchronisation n'existe pas:
    echo %SCRIPT_PATH%
    echo.
    echo Assurez-vous que sync-github.bat est dans le meme repertoire que setup-task.bat
    pause
    exit /b 1
)

echo Creation de la tache planifiee...
echo Nom: %TASK_NAME%
echo Script: %SCRIPT_PATH%
echo Frequence: Toutes les 4 heures
echo.

:: Suppression de la tache existante (si presente)
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo Suppression de la tache existante...
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
    if %errorLevel% equ 0 (
        echo Tache existante supprimee avec succes.
    ) else (
        echo ATTENTION: Erreur lors de la suppression de la tache existante.
    )
)

:: Creation de la nouvelle tache planifiee
echo Creation de la nouvelle tache...

schtasks /create ^
    /tn "%TASK_NAME%" ^
    /tr "\"%SCRIPT_PATH%\"" ^
    /sc hourly ^
    /mo 4 ^
    /f ^
    /ru "SYSTEM" ^
    /rl highest ^
    /st 00:00

if %errorLevel% equ 0 (
    echo.
    echo ============================================
    echo TACHE PLANIFIEE CREEE AVEC SUCCES
    echo ============================================
    echo Nom: %TASK_NAME%
    echo Frequence: Toutes les 4 heures
    echo Heures: 00:00, 04:00, 08:00, 12:00, 16:00, 20:00
    echo Utilisateur: SYSTEM (droits eleves)
    echo.
    echo La premiere synchronisation aura lieu:
    echo - Aujourd'hui a 00:00 si l'heure est depassee
    echo - Sinon demain a 00:00
    echo.
    echo Pour verifier la tache:
    echo - Panneau de configuration > Outils d'administration > Planificateur de taches
    echo - Ou executer: schtasks /query /tn "%TASK_NAME%"
    echo.
    echo Pour supprimer la tache:
    echo schtasks /delete /tn "%TASK_NAME%" /f
    echo.
    echo Pour executer manuellement:
    echo schtasks /run /tn "%TASK_NAME%"
    echo.
    
) else (
    echo.
    echo ============================================
    echo ERREUR LORS DE LA CREATION DE LA TACHE
    echo ============================================
    echo Code erreur: %errorLevel%
    echo.
    echo Causes possibles:
    echo - Privileges administrateur insuffisants
    echo - Service Task Scheduler non demarre
    echo - Chemin du script incorrect
    echo.
    echo Solution:
    echo 1. Executer ce script en tant qu'administrateur
    echo 2. Verifier que le service "Planificateur de taches" est demarre
    echo 3. Verifier que le fichier sync-github.bat existe bien
    echo.
)

echo.
echo Verification de la creation de la tache...
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo SUCCES: La tache a ete creee correctement.
    
    echo.
    echo Prochaines executions:
    schtasks /query /tn "%TASK_NAME%" /fo list | find "Prochaine"
    
) else (
    echo ERREUR: La tache n'a pas pu etre creee.
)

echo.
pause
