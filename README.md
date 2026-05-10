# AIAgents Backup (May 10, 2026)

## Files
- aiagents_backup.sql - Database dump
- aiagents_app_aa, aiagents_app_ab, aiagents_app_ac, aiagents_app_ad - Split app zip

## Restore

Reassemble and extract:
```
cat aiagents_app_aa aiagents_app_ab aiagents_app_ac aiagents_app_ad > aiagents.zip
unzip aiagents.zip
```

Import database:
```
mysql -u root -p aiagents < aiagents_backup.sql
```
