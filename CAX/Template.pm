#!/usr/my/perl
package CAX::Template;
use strict;
use warnings;

use Data::Dumper;
use CAX::Log;

use Template;
my $TemplateClient;

my %SiteInfo;

sub Set{
	$TemplateClient = $_[0];
	$SiteInfo{'title'} = $_[1];
	$SiteInfo{'description'} = $_[2];
	$SiteInfo{'keywords'} = $_[3];
	$SiteInfo{'finalpage'} = $_[4];
	return 0;
}
sub Partial{
	my $pagename = $_[0];
	my $pagesupplement = $_[1];
	my $output = '';
	$TemplateClient->process($pagename, $pagesupplement, \$output);
	CAX::Log::printl(4,"$pagename: ".$output.'|from|'.$pagesupplement.'|with|'.$TemplateClient->error()."\n");
	return ($output,$TemplateClient->error());
}
sub Complete{
	my $pagetitle = $_[0];
	my $pagedescription = $_[1];
	my $pagekeywords = $_[2];
	my $pagebody = $_[3];
	my $pagevariables = {
		title => $pagetitle.' | '.$SiteInfo{'title'},
		description => $pagedescription.' | '.$SiteInfo{'description'},
		keywords => $pagekeywords.' | '.$SiteInfo{'keywords'},
		body => $pagebody,
	};
	my $output = '';
	$TemplateClient->process($SiteInfo{'finalpage'}, $pagevariables, \$output);
	CAX::Log::printl(4,$output.'|from|'.$pagevariables.'|with|'.$TemplateClient->error()."\n");
	return ($output,$TemplateClient->error());
}
1;