@echo off
setlocal enabledelayedexpansion

:: ============================================
:: Setup de la rotation automatique des logs
:: ============================================

echo ============================================
echo CONFIGURATION ROTATION AUTOMATIQUE DES LOGS
echo ============================================
echo.

:: Configuration
set "SCRIPT_PATH=%~dp0log-rotation.bat"
set "TASK_NAME=GitHub-Log-Rotation"

echo Script: %SCRIPT_PATH%
echo Tache: %TASK_NAME%
echo.

:: Vérification du script
if not exist "%SCRIPT_PATH%" (
    echo ERREUR: Le script de rotation n'existe pas:
    echo %SCRIPT_PATH%
    echo.
    pause
    exit /b 1
)

echo ✅ Script de rotation trouve
echo.

:: Suppression de la tâche existante (si présente)
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% equ 0 (
    echo Suppression de la tache existante...
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
    if %errorLevel% equ 0 (
        echo ✅ Tache existante supprimee avec succes.
    ) else (
        echo ⚠️  Attention: Erreur lors de la suppression de la tache existante.
    )
)

:: Création de la nouvelle tâche planifiée
echo Creation de la nouvelle tache...

schtasks /create ^
    /tn "%TASK_NAME%" ^
    /tr "\"%SCRIPT_PATH%\"" ^
    /sc daily ^
    /st 02:00 ^
    /f ^
    /ru "SYSTEM" ^
    /rl highest

if %errorLevel% equ 0 (
    echo.
    echo ============================================
    echo ✅ TACHE PLANIFIEE CREEE AVEC SUCCES
    echo ============================================
    echo Nom: %TASK_NAME%
    echo Frequence: Quotidienne
    echo Heure: 02:00 (du matin)
    echo Utilisateur: SYSTEM (droits eleves)
    echo.
    echo La rotation des logs s'executera automatiquement:
    echo - Tous les jours a 02:00 du matin
    echo - Rotation des logs > 10 MB
    echo - Suppression des logs > 7 jours
    echo - Maximum 50 fichiers logs
    echo.
    echo Pour verifier la tache:
    echo schtasks /query /tn "%TASK_NAME%"
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
    echo ❌ ERREUR LORS DE LA CREATION DE LA TACHE
    echo ============================================
    echo.
    echo Causes possibles:
    echo - Privileges administrateur insuffisants
    echo - Service Task Scheduler non demarre
    echo - Chemin du script incorrect
    echo.
    echo Solution:
    echo 1. Executer ce script en tant qu'administrateur
    echo 2. Verifier que le service "Planificateur de taches" est demarre
    echo 3. Verifier que le fichier log-rotation.bat existe bien
    echo.
)

:: Test immédiat de la rotation
echo.
echo ============================================
echo TEST DE LA ROTATION
echo ============================================
echo.

echo Lancement d'un test de rotation...
call "%SCRIPT_PATH%"

echo.
echo ============================================
echo CONFIGURATION TERMINEE
echo ============================================
echo.

pause
