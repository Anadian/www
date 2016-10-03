#!/usr/local/bin/perl
use strict;
use warnings;
use CAX;
CAX::NewLog();
CAX::printl(0,"CAX test");
use Dancer;
use Template;
set 'port' => 80;
get '/' => sub {
	return '<html><head><title>Hello World!</title></head><body></body></html>';
};
start;
