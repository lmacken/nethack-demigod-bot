#!/usr/bin/perl
#######################
# Nethack Demigod Bot #
#    lewk@csh.rit.edu #
#######################

use IO::Select;
use IO::Socket;

# Bot Variables
my $version = "v1.2";
my $server = "irc.prison.net";
my $port = "6667";
my $nick = "r0dney";
my $user = "demigod demigod demigod demigod";
my $room = "#bingesoft";

my $sock = IO::Socket::INET->new(PeerAddr => "$server",
				 PeerPort => "$port",
				 Proto => 'tcp') ||
				 die("*** Connection Error: $!\n");

open(LOG, "tail -0f logfile |");

my $sel = new IO::Select();
$sel->add($sock);
$sel->add(\*LOG);

login();
joinrm();

print "****** CONNECTED ******\n";
print "* Nethack Demigod Bot *\n";
print "*                $version *\n";
print "***********************\n";

while (1) {
	my @ready;
	@ready = $sel->can_read();
	foreach my $fd (@ready) {
		if ($fd == $sock) {
		$buffer = <$fd>;

		print $buffer; #output all server messages
            
		#get the name of the person searching
		$buffer =~ /\:([^\!]*?)\!/;
		$name = $1;
            
		# Keep the bot alive	
		if($buffer =~ m/PING/) { $sock->send("PONG $server\n\r") }

		if ($buffer =~ m/\@search ([a-zA-Z0-9 ]*)/){
			$search = $1;
			print ">> Searching database for $search\n";
			open( DBASE, "dbase" ) || print "*** Error: $!\n";
         		@test = <DBASE>;
         		close( DBASE );
        
        		foreach $line ( @test ) {
				$line =~ s/\n//g; #get rid of \n 
        			# Start of block
				if ($bracketFound) {
					if ( $line !~ s/}// ) {
					   $sock->send("NOTICE $name :$line\n");
						# Sleep a bit (INACCURATE)
						sleep(1);
					} else { $bracketFound = 0 }
				} elsif ($line =~ /$search/i) {
					if($line =~ s/{//) {
						$bracketFound = 1;
						$sock->send("NOTICE $name :$line\n");
        				}
        				sleep(1); # Server flood protection
        			}
        		}
            } elsif ($buffer =~ m/\@help/) {
                help();
            } elsif ($buffer =~ m/\@fortune/) {
                fortune();
            } elsif ($buffer =~ m/\@topten/) {
                topten();
        	} elsif ($buffer =~ m/!$nick/) {
                fortune();
        		$sock->send("PRIVMSG $room :$what\n");
        	}
        } elsif ($fd == \*LOG) {
            $line = <$fd>;
            @two = split(/,/, $line);
            @stats = split(/ /, $two[0]);
            $death = $two[1];
            $name = $stats[15];
            $score = $stats[1];

            chomp ($death);

            if ($death =~ m/killed/) {
                $sock->send("PRIVMSG $room :$name was just $death [ $score ]\n");
            } else {
                $sock->send("PRIVMSG $room :$name just $death [ $score ]\n");
            }
        }
    }
}

print "*** DISCONNECTED ***\n";

sub login {
	$sock->send("USER $user\n\r");
	$sock->send("NICK $nick\n\r");
	return;
}

sub joinrm {
	$sock->send("JOIN $room\n\r");
	fortune();
}

sub topten {
    open(RECORD, record) || die("Error: $!\n");
    @log = <RECORD>;
    close(RECORD);

    $head = "   score name [class,race,sex,align] dlvl death";
    $sock->send("PRIVMSG $room :$head\n");

    for($i=0; $i < 10; $i++) {
        @line = split(/ /, $log[$i]);
        @last = split(/,/,$line[15]); # name,death

        chomp($last[1]);

        $stats = $i+1 . "  $line[1] " . substr($last[0],0,7) . 
        " [ $line[11], $line[12], $line[13], $line[14] ] $line[3] $last[1]"; 

        $sock->send("PRIVMSG $room :$stats\n");
        sleep(1);
    }
}

sub help {
    $sock->send("NOTICE $name :Nethack Demigod Bot $version\n");
    $sock->send("NOTICE $name : <COMMANDS>\n");
    $sock->send("NOTICE $name :  \@help - displays this menu\n");
    $sock->send("NOTICE $name :  \@search <string> - searches database for given string\n");
    $sock->send("NOTICE $name :  \@fortune - gets random fortune\n");
    $sock->send("NOTICE $name :  \@topten - displays top ten nethack scores\n");
    $sock->send("NOTICE $name : </COMMANDS>\n");
}

sub fortune {
    srand(time^$$);

    $zeroone = rand();

    if ($zeroone < .5) {
        open(RUMORS, "rumors.fal") || die("Error: $!\n");
        @rumors = <RUMORS>;
        close(RUMORS);
    } else {
        open(RUMORS, "rumors.tru") || die("Error: $!\n");
        @rumors = <RUMORS>;
        close(RUMORS);
    }

    $sock->send("PRIVMSG $room :$rumors[rand(@rumors)]\n");
}
