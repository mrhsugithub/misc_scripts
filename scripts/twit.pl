#! /usr/bin/perl -w
# query words from yahoo-kimo dictionary & send them to twitter
# looping version

use strict;

use Data::Dumper;
use WWW::Plurk;
use Net::Twitter;

my $plurk = WWW::Plurk->new;
   $plurk->login( 'gentleman', 'pxxxx' );


my $twit = Net::Twitter->new(
                username=>"mrhsutwit", 
                password=>"2xxxxxxx" 
           );

my ($word, $dest, $qualifier) = @ARGV;
    $dest      ||= 'tp'; # t=twitter p=plurk tp=both
    $qualifier ||= 'says';
# asks feels gives has hates is likes loves 
# says shares thinks wants was will wishes

exit unless $word;

print "[$word] [$qualifier]\n";

$twit->update("$word") if $dest =~ /t/;

if ($dest =~ /p/) {
    my $msg = $plurk->add_plurk( 
        content   => $word,
        qualifier => $qualifier,    
    )
};

