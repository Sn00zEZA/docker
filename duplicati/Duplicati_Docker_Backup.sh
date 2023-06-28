#!/bin/bash
logfile=/config/docker_backup.log # /cofig is the location within duplicati docker _data directory

# Get duplicati job name which should be same as docker container name for script to work
dupdocker=${DUPLICATI__backup_name}
#dupdocker=ombi

# Get duplicati script event: BEFORE/AFTER
dupevent=${DUPLICATI__EVENTNAME}
#dupevent=BEFORE

# Get duplicati operation event: "Backup", "Cleanup", "Restore", or "DeleteAllButN"
dupopevent=${DUPLICATI__OPERATIONNAME}

if [ $dupopevent == "Backup" ]; then
    printf "<<<=== ${dupopevent}\n" | tee -a $logfile
    printf "Script start: $(date)\n" | tee -a $logfile
    printf "Duplicati job name: ${dupdocker}\n" | tee -a $logfile

    printf "Finding docker container: ${dupdocker}\n" | tee -a $logfile
    runcont=$(docker ps -a -f name=${dupdocker} --format '{{.Names}}')

    # Check if duplicati event if BEFORE script
    if [ $dupevent == "BEFORE" ]; then
        printf "Duplicati running BEFORE event script\n" | tee -a $logfile
    
        # Check if docker container was found
        if [ $dupdocker == $runcont ]; then
            printf "Found container: ${runcont}\n" | tee -a $logfile
            printf "Stopping container: ${runcont}\n" | tee -a $logfile
    
            # Stop running docker container
            $(docker stop $runcont > /dev/null 2>&1)
    
            # Check state of docker container
            docstate=$(docker inspect -f {{.State.Running}} $runcont)
            printf "Container ${runcont} running state: ${docstate}\n" | tee -a $logfile
    
            if [ $docstate == "false" ]; then
                printf "Container ${runcont} stopped...\n" | tee -a $logfile
            else
                printf "Container ${runcont} still running, should be stopped!!!\n" | tee -a $logfile
            fi
    
        else
            printf "No container found named: ${dupdocker}\n" | tee -a $logfile
        fi
    else
        printf "Duplicati running AFTER event script\n" | tee -a $logfile
    
        # Check if docker container was found
        if [ $dupdocker == $runcont ]; then
            printf "Found container: ${runcont}\n" | tee -a $logfile
            printf "Starting container: ${runcont}\n" | tee -a $logfile
    
            # Start stopped docker container
            $(docker start $runcont > /dev/null 2>&1)
    
            # Check state of docker container
            docstate=$(docker inspect -f {{.State.Running}} $runcont)
            printf "Container ${runcont} running state: ${docstate}\n" | tee -a $logfile
    
            if [ "$docstate" == "true" ]; then
                printf "Container ${runcont} started...\n" | tee -a $logfile
            else
                printf "Container ${runcont} still not running, should be started!!!\n" | tee -a $logfile
            fi
        else
            printf "No container found named: ${dupdocker}\n" | tee -a $logfile
        fi
    fi
    printf "Script stopped: $(date)\n" | tee -a $logfile
    printf "===>>>\n" | tee -a $logfile
fi
