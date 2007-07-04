#!/usr/bin/perl
####################################
# This script monitors the nethack #
# bot, and restarts it on crash.   #
#                 lewk@csh.rit.edu #
####################################
my $var;

for (;;) {
	$var = `ps -A|grep bot`;
	if ( $var !~ m/nhbot.pl/ ) {
		`perl nhbot.pl`;
	}
}
