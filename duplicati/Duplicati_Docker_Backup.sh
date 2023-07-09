#!/bin/bash
# Output to console, logfile and docker log stdout. # fd/1 for stdout
# | tee /proc/1/fd/1 -a $logfile
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
    printf "<<<=== ${dupopevent}\n" | tee /proc/1/fd/1 -a $logfile
    printf "Script start: $(date)\n" | tee /proc/1/fd/1 -a $logfile
    printf "Duplicati job name: ${dupdocker}\n" | tee /proc/1/fd/1 -a $logfile

    printf "Finding docker container: ${dupdocker}\n" | tee /proc/1/fd/1 -a $logfile
    runcont=$(docker ps -a -f name=${dupdocker} --format '{{.Names}}')

    # Check if duplicati event if BEFORE script
    if [ $dupevent == "BEFORE" ]; then
	printf "Duplicati running BEFORE event script\n" | tee /proc/1/fd/1 -a $logfile

	# Check if docker container was found
	if [ $dupdocker == $runcont ]; then
		printf "Found container: ${runcont}\n" | tee /proc/1/fd/1 -a $logfile
		printf "Stopping container: ${runcont}\n" | tee /proc/1/fd/1 -a $logfile

		# Stop running docker container
		$(docker stop $runcont > /dev/null 2>&1)

		# Check state of docker container
		docstate=$(docker inspect -f {{.State.Running}} $runcont)
		printf "Container ${runcont} running state: ${docstate}\n" | tee /proc/1/fd/1 -a $logfile

		if [ $docstate == "false" ]; then
			printf "Container ${runcont} stopped...\n" | tee /proc/1/fd/1 -a $logfile
		else
			printf "Container ${runcont} still running, should be stopped!!!\n" | tee /proc/1/fd/1 -a $logfile
		fi

	else
		printf "No container found named: ${dupdocker}\n" | tee /proc/1/fd/1 -a $logfile
	fi
    else
	printf "Duplicati running AFTER event script\n" | tee /proc/1/fd/1 -a $logfile

	# Check if docker container was found
	if [ $dupdocker == $runcont ]; then
		printf "Found container: ${runcont}\n" | tee /proc/1/fd/1 -a $logfile
		printf "Starting container: ${runcont}\n" | tee /proc/1/fd/1 -a $logfile
	
		# Start stopped docker container
		$(docker start $runcont > /dev/null 2>&1)
	
		# Check state of docker container
		docstate=$(docker inspect -f {{.State.Running}} $runcont)
		printf "Container ${runcont} running state: ${docstate}\n" | tee /proc/1/fd/1 -a $logfile
	
		if [ "$docstate" == "true" ]; then
			printf "Container ${runcont} started...\n" | tee /proc/1/fd/1 -a $logfile
		else
			printf "Container ${runcont} still not running, should be started!!!\n" | tee /proc/1/fd/1 -a $logfile
		fi
	else
		printf "No container found named: ${dupdocker}\n" | tee /proc/1/fd/1 -a $logfile
	fi
    fi
	printf "Script stopped: $(date)\n" | tee /proc/1/fd/1 -a $logfile
	printf "===>>>\n" | tee /proc/1/fd/1 -a $logfile
fi
