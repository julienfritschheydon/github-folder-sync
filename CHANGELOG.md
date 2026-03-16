# Changelog - GitHub Folder Sync Script

## [1.0.0] - 2026-03-16

### ✨ Nouveautés
- **Script principal** `sync-github.bat` : Synchronisation incrémentielle avec corbeille intégrée
- **Corbeille intelligente** : Conservation 30 jours dans `D:\GitHub\_Corbeille\YYYY-MM-DD\`
- **Nettoyage automatique** : `cleanup-corbeille.bat` pour suppression fichiers > 30 jours
- **Tâche planifiée** : `setup-task.bat` pour exécution toutes les 4 heures
- **Monitoring complet** : `monitor.bat` avec statistiques détaillées
- **Configuration flexible** : `sync-config.bat` avec paramètres modifiables

### 🎯 Fonctionnalités
- Synchronisation de `C:\Users\Julien Fritsch\Documents\GitHub` vers `D:\GitHub`
- Copie incrémentielle (ne supprime rien dans la source)
- Gestion des fichiers supprimés avec corbeille de 30 jours
- Logging détaillé avec horodatage
- Exclusions automatiques (fichiers temporaires, cache, etc.)
- Gestion des erreurs avec retry automatique
- Vérification espace disque disponible

### 🔧 Options RoboCopy
- `/E` : Sous-dossiers y compris vides
- `/COPY:DAT` : Data, Attributes, Timestamps
- `/R:2 /W:5` : 2 retries, 5 secondes d'attente
- `/LOG+` : Log en mode append
- `/TEE` : Affichage écran + log
- `/NP` : No Progress (plus rapide)

### 📁 Structure créée
```
D:\
├── GitHub\                    # Destination synchronisée
├── GitHub\_Corbeille\         # Corbeille (30 jours)
└── GitHub\_Logs\              # Logs quotidiens
```

### 🚀 Installation
- Placement scripts dans `C:\Scripts\`
- Exécution `setup-task.bat` en administrateur
- Test avec `sync-github.bat`
- Monitoring avec `monitor.bat`

### 📊 Métriques initiales
- **Source** : 930,878 fichiers dans 672,628 dossiers
- **Destination** : Vide (première synchronisation)
- **Fréquence** : Toutes les 4 heures (00:00, 04:00, 08:00, 12:00, 16:00, 20:00)

### 🛠️ Prérequis
- Windows 10/11 (RoboCopy natif)
- Disque dur externe D: avec espace suffisant
- Droits administrateur pour tâche planifiée

---

## [Prochaines versions]

### [1.1.0] - Planifié
- [ ] Interface graphique optionnelle
- [ ] Notifications desktop
- [ ] Rapports par email
- [ ] Compression des logs anciens
- [ ] Support multi-sources

### [1.2.0] - Planifié
- [ ] Synchronisation bidirectionnelle
- [ ] Détection de conflits
- [ ] Interface web de monitoring
- [ ] API REST pour intégration

---

**Développé par** : Assistant IA  
**Date de création** : 16/03/2026  
**Version initiale** : 1.0.0
