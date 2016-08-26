#!/usr/local/bin/perl
use CAX;
CAX::NewLog();
CAX::printl(0,"CAX test");
use Dancer;

get '/' => sub {
	return '<html><head><title>Hello World!</title></head><body></body></html>';
};
start;
