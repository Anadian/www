#!/usr/local/bin/perl
use strict;
use warnings;
use Tie::IxHash;
use Data::Dumper;

my $th = Tie::IxHash->new({Lets => 'try',
		this => 'again'});
print(Dumper($th));
