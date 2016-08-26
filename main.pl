#!/usr/local/bin/perl
use warnings;
use strict;
use CAX;
CAX::NewLog();
CAX::printl(0,"CAX test");
use Dancer;
set 'address' => 52.88.26.159;
set 'port' => 80;
get '/' => sub {
	return '<html><head><title>Hello World!</title></head><body></body></html>';
};
start;
