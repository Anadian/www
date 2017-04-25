#!/usr/local/bin/perl
package CAX::Log;
use strict;
use warnings;

my $LogFileName = 'CAX.log';
my $LogVerbosity = 5;
sub printl{
	my @args = @_;
	open(my $logfilehandle, ">>", $LogFileName);
	if($args[0] < $LogVerbosity){
		print{$logfilehandle}(@args[1..$#args]."\n");
	}
	close($logfilehandle);
}
sub NewLog{
	if($_[0]){
		$LogFileName = $_[0];
	}
	if($_[1]){
		$LogVerbosity = $_[1];
	}
	unlink($LogFileName);
	open(my $logfilehandle, ">", $LogFileName);
	print{$logfilehandle}("Log created ".localtime(time())."\n");
	close($logfilehandle);
}
1;
