#!/usr/local/bin/perl
use strict;
use warnings;

my %site = (
	name => 'Website',
	description => 'Placeholder description',
	keywords => 'cool website',
	icon => undef,
);

use Dancer;
#set server => '50.100.208.90';
set port => 80;
set log => 'debug';
set logger => 'file';
set session => 'Simple';

use Template;
my $template = Template->new({INCLUDE_PATH => 'templates'});

use Data::Dumper;

my $couchdburl = $ARGV[0];

use PBKDF2::Tiny;
use Crypt::PBKDF2;

use LWP;
my $useragent = LWP::UserAgent->new();

use JSON;

use DateTime;

sub GetDocument{
	my $database = $_[0];
	my $documentid = $_[1];
	my $request = HTTP::Request->new(GET => $couchdburl.'/'.$database.'/'.$documentid);
	#$request->content_type('application/json');
	my $response = $useragent->request($request);
	if($response->is_success()){
		my $documentref = decode_json($response->content());
		debug($database.'/'.$documentid.' found: '.Dumper($documentref).'|from|'.Dumper($response));
		return (1,$documentref);
	} else{
		debug($database.'/'.$documentid.' not found: '.$response->status_line().'|from|'.Dumper($response));
		return (0,$response->status_line());
	}
}
sub PutDocument{
	my $database = $_[0];
	my $documentid = $_[1];
	my $document = $_[2];
	my $request = HTTP::Request->new(PUT => $couchdburl.'/'.$database.'/'.$documentid);
	$request->content_type('application/json');
	$request->content(encode_json($document));
	my $response = $useragent->request($request);
	if($response->is_success()){
		debug($database.'/'.$documentid.' added/updated successfully: '.Dumper($document).'|with|'.Dumper($response));
		return (1,$response->status_line());
	} else{
		debug($database.'/'.$documentid.' not added/updated successfully: '.$response->status_line().'|with|'.Dumper($response));
		return (0,$response->status_line());
	}
}
sub DeleteDocument{
	my $database = $_[0];
	my $documentid = $_[1];
	my $document = $_[2];
	my $returndocument = '';
	my $request = HTTP::Request->new(DELETE => $couchdburl.'/'.$database.'/'.$documentid);
	$request->content_type('application/json');
	$request->content(encode_json($document));
	my $response = $useragent->request($request);
	if($response->is_success()){
		debug($database.'/'.$documentid.' deleted successfully: '.Dumper($document).'|with|'.Dumper($response));
		forward('/welcome');
	} else{
		debug($database.'/'.$documentid.' not deleted successfully: '.$response->status_line().'|with|'.Dumper($response));
		$returndocument = $response->status_line();
	}
	return $returndocument;
}

sub ProcessPage{
	my $pagename = $_[0];
	my $pagesupplement = $_[1];
	my $output = '';
	debug($pagename.':'.Dumper($pagesupplement));
	$template->process($pagename, $pagesupplement, \$output);
	debug($output."|".$template->error());
	return $output;
}
sub MainPage{
	my $title = $_[0];
	my $description = $_[1];
	my $keywords = $_[2];
	my $body = $_[3];
	my $page = {
		title => $title,
		description => $description,
		keywords => $keywords,
		body => $body,
		site => \%site,
		signedin => session('signedin'),
		username => session('id'),
	};
	my $pagename = 'main.tt';
	my $output = '';
	debug($pagename.':'.Dumper($page));
	$template->process($pagename, $page, \$output);
	debug($output.'|'.$template->error());
	return $output;
}

prefix '/message';
get '/list' => sub {
	my @response = GetDocument('messages','_all_docs');
	debug(Dumper(@response));
	my $page = '';
	if($response[0] == 1){
		$page = MainPage(
			'List Message',
			'Listing all the messages in alphabetical order',
			'list index all message messages alphabetical order',
			ProcessPage('message_list.tt',$response[1])
		);
	} else{
		$page = MainPage(
			'Error: List Message',
			'Listing all the messages in alphabetical order',
			'list index all message messages alphabetical order',
			$response[1]
		);
	}
	debug($page);
	return $page;
};
get '/view/:documentid' => sub {
	my @response = GetDocument('messages',param('documentid'));
	debug(@response);
	my $page = '';
	if($response[0] == 1){
		my $documentref = $response[1];
		my $message = {
			title => $$documentref{'title'},
			author => $$documentref{'author'},
			creationdate => $$documentref{'creationdate'},
			body => $$documentref{'body'},
		};
		debug(Dumper($message));
		$page = MainPage(
			$$message{'title'}.' | Message View',
			'By '.$$message{'author'}.' on '.$$message{'creationdate'},
			'message view '.$$message{'title'}.' '.$$message{'author'},
			ProcessPage('message_view.tt', $message)
		);
	} else{
		$page = MainPage(
			'Error | Message View',
			'error',
			'message view error',
			$response[1]
		);
	}
	debug($page);
	return $page;
};
get '/write' => sub {
	my $page = MainPage(
		'Write New Message',
		'Writing a new message',
		'new message write',
		ProcessPage('message_write.tt')
	);
	debug($page);
	return $page;
};
post '/new' => sub {
	debug(Dumper(params()));
	my $timedate = DateTime->now();
	my $message = {
		title => param('messagetitle'),
		body => param('messagebody'),
		author => param('messageauthor'),
		creationtime => time(),
		creationdate => $timedate->ymd().'T'.$timedate->hms(),
	};
	debug(Dumper($message));
	my @response = PutDocument('messages',param('messagetitle'),$message);
	my $subpage = '';
	if($response[0] == 1){
		my $result = {
			thing => 'Message',
			name => param('messagetitle'),
			status => $response[1],
			url => '/message/view/'.param('messagetitle'),
		};
		$subpage = ProcessPage('success.tt', $result);
	} else{
		my $result = {
			thing => 'message',
			name => param('messagetitle'),
			status => $response[1],
			url => '/message/write/',
		};
		$subpage = ProcessPage('failure.tt', $result);
	}
	my $page = MainPage(
		'New Message Result',
		'The result of trying to add a new message',
		'new message result success failure',
		$subpage
	);
	debug($page);
	return $page;
};
prefix undef;
prefix '/user';
get '/signup' => sub {
	my $page = MainPage(
		'User Signup',
		'New user signup',
		'new user signup account create',
		ProcessPage('user_signup.tt')
	);
	debug($page);
	return $page;
};
post '/signin' => sub {
	debug(Dumper(params()));
	my $username = param('username');
	my $userpassword = param('userpassword');
	my @chars = split(//,$userpassword);
 	my $octetpassword = '';
 	for(my $i = 0; $i < $#chars; $i++){
 		$octetpassword=$octetpassword.unpack('C',$chars[$i]);
 	}
	my @response = GetDocument('_users','org.couchdb.user:'.$username);
	if($response[0] == 1){
		my $user = $response[1];
		debug(Dumper($user));
		my $derivedkey = $$user{'derived_key'};
		my $octetsalt = '';
		my @saltchars = split(//,$$user{'salt'});
		for(my $i = 0; $i < $#saltchars; $i++){
			$octetsalt = $octetsalt.unpack('C',$saltchars[$i]);
		}
#		my $pbkdf2 = Crypt::PBKDF2->new(
#			iterations => $$user{'iterations'},
#			output_len => (length($derivedkey) / 2),
#			salt_len => length($$user{'salt'}),
#		);
#		my $enteredkey = $pbkdf2->PBKDF2_hex($octetsalt, $octetpassword);
		my $enteredkey = PBKDF2::Tiny::derive_hex('SHA-1', $octetpassword, $octetsalt, $$user{'iterations'});
		if($derivedkey eq $enteredkey){
			my $datetime = DateTime->now();
			my $session = {
				creationdate => $datetime->ymd().$datetime->hms(),
				creationtime => time(),
				username => $$user{'name'},
			};
			@response = PutDocument('sessions',$$user{'name'}, $session);
			if($response[0] == 1){
				session signedin => 1;
				session id => $$user{'name'};
			} else{
				debug('Session creation failed: '.Dumper(@response));
			}
		} else{
			debug('User authentication failed: '.$derivedkey.'|versus|'.$enteredkey);
		}
	} else{
		debug('Couldn\'t find user: '.$username.'|from|'.Dumper(@response));
	}
	
};
post '/create' => sub {
	debug(Dumper(params()));
	my $datetime = DateTime->now();
	my @roles = ('none');
	my %userinfohash = (
		type => 'user',
		roles => \@roles,
		email => param('useremail'),
		name => param('username'),
		password => param('userpassword'),
		_id => 'org.couchdb.user:'.param('username'),
		creationdate => $datetime->ymd().$datetime->hms(),
		creationtime => time(),
	);
	my $userinfo = \%userinfohash;
	debug(Dumper($userinfo));
	my @returnedarray = PutDocument('_users',$$userinfo{'_id'},$userinfo);
	my $subpage = '';
	if($returnedarray[0] == 1){
		my $result = {
			thing => 'User',
			name => $$userinfo{'name'},
			status => $returnedarray[1],
			url => '/user/'.$$userinfo{'name'}.'/profile',
		};
		$subpage = ProcessPage('success.tt', $result);
	} else{
		my $result = {
			thing => 'new user',
			name => $$userinfo{'name'},
			status => $returnedarray[1],
			url => '/welcome',
		};
		$subpage = ProcessPage('failure.tt', $result);
	}
	my $page = MainPage(
		'New User Result',
		'The result page for creating new user.',
		'new user signup result create success failure',
		$subpage
	);
	debug($page);
	return $page;
};
prefix undef;
get '/welcome' => sub{
	my $page = MainPage(
		'Welcome',
		'Welcome to the site',
		'welcome page home index',
		ProcessPage('welcome.tt')
	);
	debug($page);
	return $page;
};
get '/' => sub{
	forward('/welcome');
};
start;
