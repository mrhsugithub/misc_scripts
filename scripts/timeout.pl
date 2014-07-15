#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: timeout.pl
#
#        USAGE: ./timeout.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 西元2014年07月15日 17時06分53秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use POSIX qw(strftime WNOHANG);

#check input
my $timeout = shift @ARGV;
my ($secs) = $timeout =~ /--timeout=(\d+)$/;
unless($secs)
{
    print "Usage: ./timeout --timeout=[SECONDS] [COMMAND] \n";
    exit -1;
}

#fork and exec
my $status = 0;
$SIG{CHLD} = sub { while(waitpid(-1,WNOHANG)>0){ $status = -1 unless $? == 0; exit $status;} };
$0 = 'timeout hacked ' . $ARGV[0];
defined (my $child = fork);
if($child == 0)
{
    my $cmd = join ' ', @ARGV;
    exec($cmd);
}
$SIG{TERM} = sub { kill TERM => $child };
$SIG{INT} = sub { kill INT => $child };


#kill when timeout
sleep $secs;
$status = -1;
kill TERM => $child;
sleep 1 and kill INT => $child if kill 0 => $child;
sleep 1 and kill KILL => $child if kill 0 => $child;
exit $status;
