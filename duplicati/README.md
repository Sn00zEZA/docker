# Duplicati Docker Backup bash script

A single script intended for use with Duplicati that uses the Job Name "DUPLICATI__backup_name" to look for a single docker container name and stop the container during the BEFORE event "DUPLICATI__EVENTNAME" and then allow duplicati to run the backup. Once backup is completed, during the AFTER event "DUPLICATI__EVENTNAME", it will then start the same container.

The script also checks the Operation event "DUPLICATI__OPERATIONNAME" to only run during the BACKUP event. (RESTORE event could be added, but for now keeping this manuel).

Logging is done to the Duplicati docker container in the "/config" location which should be mapped too your duplicati data folder.
UPDATE:
Script now also logs to Duplicati docker log via stdout.

```
<<<=== Backup
Script start: Wed Jun 28 06:37:09 PM CAT 2023
Duplicati job name: speedtest
Finding docker container: speedtest
Duplicati running BEFORE event script
Found container: speedtest
Stopping container: speedtest
Container speedtest running state: false
Container speedtest stopped...
Script stopped: Wed Jun 28 06:37:15 PM CAT 2023
===>>>
<<<=== Backup
Script start: Wed Jun 28 06:38:26 PM CAT 2023
Duplicati job name: speedtest
Finding docker container: speedtest
Duplicati running AFTER event script
Found container: speedtest
Starting container: speedtest
Container speedtest running state: true
Container speedtest started...
Script stopped: Wed Jun 28 06:38:27 PM CAT 2023
===>>>
```

Disclaimer: This is my first bash script, use at own risk.
