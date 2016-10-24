#!/usr/local/bin/perl
use strict;
use warnings;
use Dancer qw(:syntax);
use Template;
use Dumper;
get '/index/:subcommand?' => sub{
	
