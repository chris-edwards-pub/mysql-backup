# mysql-backup

This is a perl script that dumps every database on your mysql server into individual dumps then tars them all together to create a full daily backup.  It also deletes the backups after specified number of days.

## Getting Started

Your system should be linux with perl and mysql installed.  Just download the files and place them in a directory.  Then edit the conf file to store your username, host and password.  Finally edit the script and change required directories if necessary.

If you want the script to run daily just add it to a cron job.
