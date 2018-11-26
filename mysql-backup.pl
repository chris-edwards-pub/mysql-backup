#!/usr/bin/perl -w
# Chris Edwards - Created 12/16/07
#
# 
# This program does a dump of all databases
# finally it removes all old backups based on the amount of days set.
#
# First we will set the directory locations for our vhosts, mysql dump
# dir and the storage location for the backups.

#Set your mysql username and password in the conf file
$mysqlconf = "mysql-backup.conf";

# Number of days to keep backups.
$backupdays = 7;

$mysqldump = '/var/lib/mysql/dump'; 
$backupdir = '/var/lib/mysql/backup';

# getting current time and date
chomp($now = `date '+%Y-%m-%d-%H%M%S'`);

print "mysql-backup.pl - $now\n";

# Lets check to make sure the directories exsist.

if (!(-d $mysqldump)) {die "$mysqldump does not exist!\n";}
if (!(-d $backupdir)) {die "$backupdir does not exist!\n";}

# This gets the names of the current mysql databases by doing a directory
# listing of data dir and then running each through mysqldump

$cmd = "mysql --defaults-extra-file=$mysqlconf --disable-column-names --batch -e 'show databases;'";
@mysqldatabases = `$cmd`;
chomp(@mysqldatabases);

# Now we dump all of the databases to our mysql dump directory
# Each dump is gziped to save space.
print "\nDumping mysql databases...\n\n";

foreach $mysqldatabase (@mysqldatabases){
        next if $mysqldatabase eq "performance_schema";
	next if $mysqldatabase eq "information_schema";
        print "Dumping $mysqldatabase...\n";
        system "\/usr\/bin\/mysqldump --defaults-extra-file=$mysqlconf --opt $mysqldatabase \| \/bin\/gzip > $mysqldump\/$mysqldatabase.gz";
}

print "\nmysql dump completed. (This script does not delete old mysql dump files)\n";
print "\n$mysqldump directory listing...\n\n";
system "ls -l $mysqldump";

# Making backup of the mysqldump directory.
print "\nMaking backup of all mysql dumps to $backupdir...\n\n";
print "tar -pczf $backupdir\/mysql_backup.$now.tar.gz -C $mysqldump .\n";
system "tar -pczf $backupdir\/mysql_backup.$now.tar.gz -C $mysqldump .";
system "chmod 600 $backupdir\/mysql_backup.$now.tar.gz";

# Now its time to delete the old backups.
print "\nCleaning up backups, deleting everything over $backupdays old...\n\n";
@backups = <$backupdir/*>;
foreach $backup(@backups){
        next if (!($backup =~ /.*mysql_backup.*/)); #only includes files with mysql_backup in there file name.
        if (-M $backup < $backupdays){ # keeps backups less than $backupdays
                print "Keeping... $backup\n";

        }
        elsif (-M $backup >= $backupdays) { # deletes backups older than $backupdays
                print "Deleting... $backup\n";
                print "$backup could not be deleted" if (!(unlink($backup)));
        }
}

