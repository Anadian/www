#!/usrbin/perl
package CAX;
use strict;
use warnings;
open(my $CAX_log, ">>", "CAX.log");
my $CAX_debug_verbosity = 1;
sub printl{
	my @args = @_;
	if($args[0] < $CAX_debug_verbosity){
		print{$CAX_log}(@args[1..$#args]."\n");
	}
}
sub NewLog{
	close($CAX_log);
	open($CAX_log, ">", "CAX.log");
	printl(0,"Log created ".localtime(time()));
}
close($CAX_log);
1;
