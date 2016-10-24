#!/usr/local/bin/perl
use strict;
use warnings;
use Dancer;
set port => 80;
set log => 'debug';
set logger => 'file';
use Template;
use Data::Dumper;
use MongoDB;
use Tie::IxHash;
my $template = Template->new({INCLUDE_PATH => 'templates'});
my $databaseclient = MongoDB->connect();
my $database = $databaseclient->get_database('c');
my $collection = $database->get_collection('d');
#load('commands.pl');
get '/add' => sub {
	debug('In add');
	my %allparams = params;
	my $result = $collection->insert_one(\%allparams);
	my $dumpedparams = Dumper(\%allparams);
	my $id = $result->inserted_id;
	my $vars = {
		pagetitle => 'Add',
		pagebody => "Added $dumpedparams to collection d and got $id"};
	my $output = '';
	$template->process('main.tt', $vars, \$output);
	return "$output";
};
get '/see/:id?' => sub {
	debug('In see');
	my $id = param('id');
	my $q = param('q');
	my %result;
	my @otherresult;
	my $dumpedresult;
	if($id){
		%result = %{$collection->find_id($id)};
	} elsif($q){
		%result = %{$collection->find_one({$q})};
	#	@otherresult = $collection->find_one({$q})->result;
	}
	if(%result){
		my @keyarray = keys(%result);
		my $result = %result;
		my @result = %result;
		my $result4 = Dumper(\%result);
		$dumpedresult = "keys: @keyarray, id: $id, q: $q, result1: $result, result2: @result, result4: $result4 result: otherresult";
	}
	my $vars = {
		pagetitle => 'Find',
		pagebody => "Found $dumpedresult from $id $q"
	};
	my $output = '';
	debug("$q $id: $dumpedresult");
	$template->process('main.tt', $vars, \$output);
	return "$output";
};
get '/:name?' => sub {
	my %allparams = params;
	my $vars = {
		pagetitle => 'Title',
		pagedescription => 'Description',
		pagebody => Dumper(\%allparams)};
	my $output = '';
	$template->process('main.tt', $vars, \$output);
	debug("output: $output", Dumper(\%allparams));
	return "$output";
};
start;
