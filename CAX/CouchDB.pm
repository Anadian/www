#!/usr/local/bin/perl
package CAX::CouchDB;
use strict;
use warnings;

use Data::Dumper;
use CAX::Log;

use LWP;

my $CouchDBUserAgent;
my $CouchDBurl;

sub Set{
	$CouchDBUserAgent = $_[0];
	$CouchDBurl = $_[1];
	return 0;
}
sub GetDocument{
	my $database = $_[0];
	my $documentid = $_[1];
	my $request = HTTP::Request->new(GET => $CouchDBurl.'/'.$database.'/'.$documentid);
	CAX::Log::printl(5, 'Request: '.Dumper($request)."\n");
	my $response = $CouchDBUserAgent->request($request);
	CAX::Log::printl(3, 'Response: '.Dumper($response)."\n");
	if($response->is_success()){
		my $documentref = $response->content();
		return (1,$response->status_line(),$documentref);
	} else{
		return (0,$response->status_line());
	}
}
sub PutDocument{
	my $database = $_[0];
	my $documentid = $_[1];
	my $document = $_[2];
	my $request = HTTP::Request->new(PUT => $CouchDBurl.'/'.$database.'/'.$documentid);
	$request->content_type('application/json');
	$request->content($document);
	CAX::Log::printl(5, 'Request: '.Dumper($request)."\n");
	my $response = $CouchDBUserAgent->request($request);
	CAX::Log::printl(3, 'Response: '.Dumper($response)."\n");
	if($response->is_success()){
		return (1,$response->status_line());
	} else{
		return (0,$response->status_line());
	}
}
sub DeleteDocument{
	my $database = $_[0];
	my $documentid = $_[1];
	my $document = $_[2];
	my $request = HTTP::Request->new(DELETE => $CouchDBurl.'/'.$database.'/'.$documentid);
	$request->content_type('application/json');
	$request->content($document);
	CAX::Log::printl(5, 'Request: '.Dumper($request)."\n");
	my $response = $CouchDBUserAgent->request($request);
	CAX::Log::printl(3, 'Response: '.Dumper($response)."\n");
	if($response->is_success()){
		return (1,$response->status_line());
	} else{
		return (0,$response->status_line());
	}
}
1;