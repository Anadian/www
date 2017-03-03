#!/usr/local/bin/perl
#message.pl

use Data::Dumper;

prefix '/message';

get '/yo' => sub{
	debug(Dumper(params()));
	return 'yo';
};
get '/view/:documentid' => sub{
	my $document = GetDocument('messages',param('documentid'));
	Dumper($document);
	return $document;
};
prefix undef;