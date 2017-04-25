#!/usr/local/bin/perl
use strict;
use warnings;

use Dancer;
#set server => '50.100.208.90';
set port => 80;
set log => 'debug';
set logger => 'file';
set session => 'Simple';

use Data::Dumper;
use CAX::Log;
CAX::Log::NewLog('CAX.log',5);

use Template;
use CAX::Template;
CAX::Template::Set(
	Template->new({INCLUDE_PATH => 'templates'}),
	'Website Name',
	'Description',
	'key words word keys questions',
	'main.tt'
);

use LWP;
my $useragent = LWP::UserAgent->new();

use CAX::CouchDB;
CAX::CouchDB::Set($useragent, $ARGV[0]);

use JSON;

use DateTime;

prefix '/message';
get '/list' => sub {
	my @response = CAX::CouchDB::GetDocument('messages','_all_docs');
	debug(Dumper(@response));
	my $page = '';
	unless(param('JSON') == 1){
		$response[2] = decode_json($response[2]);
		if($response[0] == 1){
			$page = (CAX::Template::Complete(
				'List All Messages',
				'Listing all the messages in alphabetical order',
				'list index all message messages alphabetical order',
				(CAX::Template::Partial('message_list.tt',$response[2]))[0]
			))[0];
		} else{
			$page = (CAX::Template::Complete(
				'Error: List Message',
				'Listing all the messages in alphabetical order',
				'list index all message messages alphabetical order',
				$response[1]
			))[0];
		}
	} else{
		$page = $response[1];
	}
	debug($page);
	return $page;
};
get '/view/:documentid' => sub {
	my @response = CAX::CouchDB::GetDocument('messages',param('documentid'));
	debug(Dumper(@response));
	my $page = '';
	unless(param('JSON') == 1){
		if($response[0] == 1);
	}
};
get '/write' => sub{
	
# get '/view/:documentid' => sub {
# 	my @response = CAX::CouchDB::GetDocument('messages',param('documentid'));
# 	debug(@response);
# 	my $page = '';
# 	if($response[0] == 1){
# 		my $documentref = $response[1];
# 		my $message = {
# 			title => $$documentref{'title'},
# 			author => $$documentref{'author'},
# 			creationdate => $$documentref{'creationdate'},
# 			body => $$documentref{'body'},
# 		};
# 		debug(Dumper($message));
# 		$page = MainPage(
# 			$$message{'title'}.' | Message View',
# 			'By '.$$message{'author'}.' on '.$$message{'creationdate'},
# 			'message view '.$$message{'title'}.' '.$$message{'author'},
# 			ProcessPage('message_view.tt', $message)
# 		);
# 	} else{
# 		$page = MainPage(
# 			'Error | Message View',
# 			'error',
# 			'message view error',
# 			$response[1]
# 		);
# 	}
# 	debug($page);
# 	return $page;
# };
# get '/write' => sub {
# 	my $page = MainPage(
# 		'Write New Message',
# 		'Writing a new message',
# 		'new message write',
# 		ProcessPage('message_write.tt')
# 	);
# 	debug($page);
# 	return $page;
# };
# post '/new' => sub {
# 	debug(Dumper(params()));
# 	my $timedate = DateTime->now();
# 	my $message = {
# 		title => param('messagetitle'),
# 		body => param('messagebody'),
# 		author => param('messageauthor'),
# 		creationtime => time(),
# 		creationdate => $timedate->ymd().'T'.$timedate->hms(),
# 	};
# 	debug(Dumper($message));
# 	my @response = PutDocument('messages',param('messagetitle'),$message);
# 	my $subpage = '';
# 	if($response[0] == 1){
# 		my $result = {
# 			thing => 'Message',
# 			name => param('messagetitle'),
# 			status => $response[1],
# 			url => '/message/view/'.param('messagetitle'),
# 		};
# 		$subpage = ProcessPage('success.tt', $result);
# 	} else{
# 		my $result = {
# 			thing => 'message',
# 			name => param('messagetitle'),
# 			status => $response[1],
# 			url => '/message/write/',
# 		};
# 		$subpage = ProcessPage('failure.tt', $result);
# 	}
# 	my $page = MainPage(
# 		'New Message Result',
# 		'The result of trying to add a new message',
# 		'new message result success failure',
# 		$subpage
# 	);
# 	debug($page);
# 	return $page;
# };
# prefix undef;
# prefix '/user';
# get '/signup' => sub {
# 	my $page = MainPage(
# 		'User Signup',
# 		'New user signup',
# 		'new user signup account create',
# 		ProcessPage('user_signup.tt')
# 	);
# 	debug($page);
# 	return $page;
# };
# post '/signin' => sub {
# 	debug(Dumper(params()));
# 	my $username = param('username');
# 	my $userpassword = param('userpassword');
# 	my @chars = split(//,$userpassword);
#  	my $octetpassword = '';
#  	for(my $i = 0; $i < $#chars; $i++){
#  		$octetpassword=$octetpassword.unpack('C',$chars[$i]);
#  	}
# 	my @response = GetDocument('_users','org.couchdb.user:'.$username);
# 	if($response[0] == 1){
# 		my $user = $response[1];
# 		debug(Dumper($user));
# 		my $derivedkey = $$user{'derived_key'};
# 		my $octetsalt = '';
# 		my @saltchars = split(//,$$user{'salt'});
# 		for(my $i = 0; $i < $#saltchars; $i++){
# 			$octetsalt = $octetsalt.unpack('C',$saltchars[$i]);
# 		}
# #		my $pbkdf2 = Crypt::PBKDF2->new(
# #			iterations => $$user{'iterations'},
# #			output_len => (length($derivedkey) / 2),
# #			salt_len => length($$user{'salt'}),
# #		);
# #		my $enteredkey = $pbkdf2->PBKDF2_hex($octetsalt, $octetpassword);
# 		my $enteredkey = PBKDF2::Tiny::derive_hex('SHA-1', $octetpassword, $octetsalt, $$user{'iterations'});
# 		if($derivedkey eq $enteredkey){
# 			my $datetime = DateTime->now();
# 			my $session = {
# 				creationdate => $datetime->ymd().$datetime->hms(),
# 				creationtime => time(),
# 				username => $$user{'name'},
# 			};
# 			@response = PutDocument('sessions',$$user{'name'}, $session);
# 			if($response[0] == 1){
# 				session signedin => 1;
# 				session id => $$user{'name'};
# 			} else{
# 				debug('Session creation failed: '.Dumper(@response));
# 			}
# 		} else{
# 			debug('User authentication failed: '.$derivedkey.'|versus|'.$enteredkey);
# 		}
# 	} else{
# 		debug('Couldn\'t find user: '.$username.'|from|'.Dumper(@response));
# 	}
# 	
# };
# post '/create' => sub {
# 	debug(Dumper(params()));
# 	my $datetime = DateTime->now();
# 	my @roles = ('none');
# 	my %userinfohash = (
# 		type => 'user',
# 		roles => \@roles,
# 		email => param('useremail'),
# 		name => param('username'),
# 		password => param('userpassword'),
# 		_id => 'org.couchdb.user:'.param('username'),
# 		creationdate => $datetime->ymd().$datetime->hms(),
# 		creationtime => time(),
# 	);
# 	my $userinfo = \%userinfohash;
# 	debug(Dumper($userinfo));
# 	my @returnedarray = PutDocument('_users',$$userinfo{'_id'},$userinfo);
# 	my $subpage = '';
# 	if($returnedarray[0] == 1){
# 		my $result = {
# 			thing => 'User',
# 			name => $$userinfo{'name'},
# 			status => $returnedarray[1],
# 			url => '/user/'.$$userinfo{'name'}.'/profile',
# 		};
# 		$subpage = ProcessPage('success.tt', $result);
# 	} else{
# 		my $result = {
# 			thing => 'new user',
# 			name => $$userinfo{'name'},
# 			status => $returnedarray[1],
# 			url => '/welcome',
# 		};
# 		$subpage = ProcessPage('failure.tt', $result);
# 	}
# 	my $page = MainPage(
# 		'New User Result',
# 		'The result page for creating new user.',
# 		'new user signup result create success failure',
# 		$subpage
# 	);
# 	debug($page);
# 	return $page;
# };
# prefix undef;
# get '/welcome' => sub{
# 	my $page = MainPage(
# 		'Welcome',
# 		'Welcome to the site',
# 		'welcome page home index',
# 		ProcessPage('welcome.tt')
# 	);
# 	debug($page);
# 	return $page;
# };
# get '/' => sub{
# 	forward('/welcome');
# };
start;
