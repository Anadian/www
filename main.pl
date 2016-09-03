#!/usr/bin/perl
use warnings;
use strict;
use CAX;
CAX::NewLog();
CAX::printl(0,"CAX test");
use Dancer;
set 'port' => 80;
get '/' => sub {
	return '<html><head><title>Hello World!</title></head><body></body></html>';
};
start;
