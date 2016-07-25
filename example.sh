#!/bin/bash

function a_sub { # Define a function as a sub-process
	sleep 3
}


tmp_fifofile="/tmp/$$.fifo" # $$ retrieves PID
mkfifo $tmp_fifofile      # Create a FIFO file
exec 6<>$tmp_fifofile      # Binds named pipe fd 6 to tmp_fifofile
rm $tmp_fifofile


thread=15 # Desired thread limit
for ((i=0;i<$thread;i++));do 
	echo
done >&6 # Put 15 empty lines in fd 6


task_count=50
for ((i=0;i<$task_count;i++));do # 50 tasks to run, e.g. 50 files to process

	read -u6 
	# Each 'read -u6' reads one line from fd 6
	# read will hang when there is no '\n' in fd 6

	{ # Start a background sub-process
				a_sub && { # Check if sub-process exit with an error
				 echo "a_sub is finished"
				} || {
				 echo "sub error"
				}
				echo >&6 # Refill a new line to fd 6, so the next task can be executed
	} &

done

wait # Wait until all background processes finish
exec 6>&- # close fd 6


exit 0
