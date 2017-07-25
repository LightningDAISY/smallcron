#! /usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Mojo::UserAgent;
use Mojo::JSON qw{ encode_json decode_json };
use feature qw{ say };

my $baseURI  = 'https://api.chatwork.com/v2';

sub cwRequest
{
	my($method, $path, $apiToken, $body) = @_;
	my $ua = Mojo::UserAgent->new;
	my $tx;
	if(defined $body)
	{
		utf8::is_utf8 $body or utf8::decode $body;
		$tx = $ua->build_tx(
			uc($method) => $baseURI . $path, form => { body => $body }
		);
	}
	else
	{
		$tx = $ua->build_tx(
			uc($method) => $baseURI . $path
		);
	}
	$tx->req->headers->user_agent('mojolicious cw-client');
	$tx->req->headers->header('X-ChatWorkToken' => $apiToken);

	$tx = $ua->start($tx);

	if(my $res = $tx->success)
	{
		return decode_json($res->body);
	}
	else
   	{
		my($err, $code) = $tx->error;
		die $code ? "$code response: $err\n" : "Connection error: " . Dumper($err);
	}
}

sub params
{
	my %params = (@ARGV, '');
	my $body;
	for my $key(keys %params)
	{
		if($key !~ /^--/) { delete $params{$key}; $body = $key; }
	}
	$body =~ s/<br>/\n/;
	($body, \%params)
}

sub main
{
	my($body, $options) = params;
	my $array = cwRequest(
		POST => '/rooms/' . $options->{'--room_id'} . '/messages',
		$options->{'--api_token'},
	   	$body
	);
}

main;
1

__END__

あまり関係のないchatwork投稿スクリプトです。
スケジューラに登録してポストできます。

ex. 
	./chatwork.pl --api_token tokenxxx --room_id ridxxx 'あ<br>い<br>う'

		--api_token 

