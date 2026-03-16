# Synchronisation GitHub avec RoboCopy

Solution complète de synchronisation automatique du dossier GitHub de C: vers D: avec corbeille de 30 jours.

## 📁 Fichiers créés

| Fichier | Description |
|---------|-------------|
| `sync-github.bat` | Script principal de synchronisation avec corbeille intégrée |
| `cleanup-corbeille.bat` | Nettoyage automatique des fichiers de plus de 30 jours |
| `setup-task.bat` | Création de la tâche planifiée Windows (toutes les 4 heures) |
| `sync-config.bat` | Fichier de configuration personnalisable |
| `monitor.bat` | Monitoring et rapports de synchronisation |
| `README.md` | Documentation (ce fichier) |

## 🚀 Installation rapide

### 1. Prérequis
- Windows 10/11 (RoboCopy inclus nativement)
- Disque dur externe D: avec suffisamment d'espace
- Droits administrateur pour la tâche planifiée

### 2. Installation
```cmd
# 1. Placer tous les fichiers dans C:\Scripts\
mkdir C:\Scripts
# Copier tous les fichiers .bat et README.md dans C:\Scripts\

# 2. Créer la tâche planifiée (exécuter en tant qu'administrateur)
C:\Scripts\setup-task.bat

# 3. Vérifier le monitoring
C:\Scripts\monitor.bat
```

### 3. Test manuel
```cmd
# Test immédiat de la synchronisation
C:\Scripts\sync-github.bat
```

## 📋 Fonctionnalités

### ✅ Synchronisation principale
- **Source** : `C:\Users\Julien Fritsch\Documents\GitHub`
- **Destination** : `D:\GitHub`
- **Type** : Copie incrémentielle (ne supprime rien dans la source)
- **Fréquence** : Toutes les 4 heures (00:00, 04:00, 08:00, 12:00, 16:00, 20:00)

### 🗑️ Corbeille intelligente
- **Emplacement** : `D:\GitHub\_Corbeille\YYYY-MM-DD\`
- **Conservation** : 30 jours automatique
- **Structure** : Préserve la hiérarchie des dossiers
- **Nettoyage** : Suppression automatique des anciens dossiers

### 📊 Monitoring et logs
- **Logs quotidiens** : `D:\GitHub\_Logs\sync-YYYYMMDD.log`
- **Monitoring complet** : Statistiques, espace disque, état tâche
- **Rapports détaillés** : Fichiers copiés, déplacés en corbeille, erreurs

### 🔧 Options RoboCopy optimisées
```batch
robocopy "SOURCE" "DEST" /E /COPY:DAT /R:2 /W:5 /LOG+:logfile.log /TEE /NP
```

- `/E` : Sous-dossiers y compris vides
- `/COPY:DAT` : Data, Attributes, Timestamps
- `/R:2 /W:5` : 2 retries, 5 secondes d'attente
- `/LOG+` : Log en mode append
- `/TEE` : Affichage écran + log
- `/NP` : No Progress (plus rapide)

### 🚫 Exclusions automatiques
- **Dossiers** : `.git\objects\pack`, `node_modules\.cache`, `.next\cache`
- **Fichiers** : `*.tmp`, `*.lock`, `*.swp`, `.DS_Store`

## 🛠️ Utilisation

### Exécution manuelle
```cmd
# Synchronisation immédiate
C:\Scripts\sync-github.bat

# Nettoyage manuel de la corbeille
C:\Scripts\cleanup-corbeille.bat

# Monitoring et statistiques
C:\Scripts\monitor.bat
```

### Gestion de la tâche planifiée
```cmd
# Créer la tâche (administrateur requis)
C:\Scripts\setup-task.bat

# Vérifier la tâche
schtasks /query /tn "GitHub-Sync"

# Exécuter manuellement la tâche
schtasks /run /tn "GitHub-Sync"

# Supprimer la tâche
schtasks /delete /tn "GitHub-Sync" /f
```

### Configuration
Éditez `C:\Scripts\sync-config.bat` pour modifier :
- Chemins source/destination
- Durée de conservation corbeille
- Fréquence de synchronisation
- Exclusions personnalisées

## 📁 Structure des dossiers créés

```
D:\
├── GitHub\                    # Destination synchronisée
├── GitHub\_Corbeille\         # Corbeille
│   ├── 2026-03-16\           # Fichiers supprimés ce jour
│   ├── 2026-03-15\           # Fichiers supprimés hier
│   └── ...
└── GitHub\_Logs\              # Logs de synchronisation
    ├── sync-20260316.log     # Log du jour
    ├── cleanup-20260316.log  # Log nettoyage
    └── ...
```

## 🔍 Monitoring

Le script `monitor.bat` affiche :
- **Statistiques des dossiers** : Taille, nombre de fichiers/dossiers
- **Corbeille** : Occupation par date, taille totale
- **Espace disque** : Espace libre sur C: et D:
- **Logs** : Dernières synchronisations avec détails
- **Tâche planifiée** : État et prochaines exécutions

## ⚠️ Sécurité et erreurs

### Gestion des erreurs
- **Fichiers verrouillés** : 2 tentatives avec 5 secondes d'attente
- **Espace insuffisant** : Vérification avant synchronisation (minimum 5GB)
- **Disque externe absent** : Arrêt avec log d'erreur
- **Permissions** : Exécution en tant que SYSTEM pour éviter les conflits

### Codes retour RoboCopy
- **0-7** : Succès (aucune erreur ou warnings mineurs)
- **8+** : Erreur (consultez les logs pour détails)

## 📞 Support et dépannage

### Problèmes courants
1. **"Accès refusé"** : Exécutez `setup-task.bat` en tant qu'administrateur
2. **"Disque plein"** : Vérifiez l'espace disponible avec `monitor.bat`
3. **"Tâche inactive"** : Recréez la tâche avec `setup-task.bat`

### Logs d'erreurs
- Logs principaux : `D:\GitHub\_Logs\sync-YYYYMMDD.log`
- Logs nettoyage : `D:\GitHub\_Logs\cleanup-YYYYMMDD.log`

### Aide
Pour toute question ou problème :
1. Vérifiez les logs dans `D:\GitHub\_Logs\`
2. Exécutez `monitor.bat` pour diagnostic
3. Consultez la configuration dans `sync-config.bat`

## 🔄 Mises à jour

Pour mettre à jour la configuration :
1. Modifiez `sync-config.bat`
2. Recréez la tâche planifiée avec `setup-task.bat`

Pour modifier la fréquence :
1. Modifiez `SYNC_FREQUENCY_HOURS` dans `sync-config.bat`
2. Recréez la tâche planifiée

---

**Version** : 1.0  
**Date** : 16/03/2026  
**Auteur** : Assistant IA  
**Compatible** : Windows 10/11
