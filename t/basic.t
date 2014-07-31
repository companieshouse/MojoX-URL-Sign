#!/usr/bin/env perl

use strict;
use warnings;
use v5.16;

use Test::More;

# Basic tests
require_ok('MojoX::URL::Sign');
require_ok('MojoX::URL::Sign::Plugin');

my $sign = new MojoX::URL::Sign;
my $salt = 1234;
my $url;
my $original_url;

isa_ok($sign, 'MojoX::URL::Sign');

can_ok($sign, qw/
    new
    sign_url
    verify_url
    _sign
/);

# URL with 1 path part
$original_url = 'http://example.com/page';
$url = $sign->sign_url($original_url, $salt);
is($url, "$original_url?signature=XMCmEKN-lF7ORIISlJ-iN3upOsLUX1nPcGNfEaD56S0", 'URL with 1 path part');
is($sign->verify_url($url, $salt), $original_url);

# URL with 1 path part + 1 key/value in querystring
$original_url = 'http://example.com/page?foo=bar';
$url = $sign->sign_url($original_url, $salt);
is($url, "$original_url&signature=Q-l885BbPgxRUgsVKrHv6CdwNEAlTXY4fgmfHdDCv8k", 'URL with 1 path part + 1 key/value in querystring');
is($sign->verify_url($url, $salt), $original_url);

# URL with 1 path part + multiple key/value in querystring
$original_url = 'http://example.com/page?foo=bar&this=that&hello=world';
$url = $sign->sign_url($original_url, $salt);
is($url, "$original_url&signature=QvDM7g1FVClXO4wBSGHOkdJWHVEX0QkGwoR01BqLxD0", 'URL with 1 path part + multiple key/value in querystring');
is($sign->verify_url($url, $salt), $original_url);

# URL with 1 path part + multiple key/value in querystring with duplicate keys
$original_url = 'http://example.com/page?foo=bar&foo=baz&this=that&this=other&hello=world';
$url = $sign->sign_url($original_url, $salt);
is($url, "$original_url&signature=A3RrWcnxMa3fSM9pMimE4imSXXSIjUKso17A9pAICnw", 'URL with 1 path part + multiple key/value in querystring with duplicate keys');
is($sign->verify_url($url, $salt), $original_url);

# URL with 1 path part + multiple key/value in querystring with keys NOT in alphabetical order
$original_url = 'http://example.com/page?ccc=xxx&bbb=xxx&aaa=xxx&ddd=xxx';
$url = $sign->sign_url($original_url, $salt);
is($url, "$original_url&signature=1V2Qcg3vMWW8cil8Sbnv7f-LUtmb7Z3DKpG3o7tg31A", 'URL with 1 path part + multiple key/value in querystring with keys NOT in alphabetical order');
is($sign->verify_url($url, $salt), $original_url);

# Finished
done_testing();
