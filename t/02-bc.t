
use strict;
use warnings;

use Test::More tests => 1;
use Expect;

subtest raw_pty_bc => sub {
	my $bc = '/usr/bin/bc';
	if ( not -x $bc ) {
		plan skip_all => "Need to have $bc installed to run this test";
	}
	my $bc_version = `$bc -v`;
	diag "--------- bc version on $^O";
	diag $bc_version;
	diag '---------';
	# just some notes:
	# on $^O = 'solaris' I saw that bc does not have any banner (the warranty stuff) and it also does not have a -v flag

	if ($^O =~ /^(openbsd|netbsd|freebsd|solaris|darwin)$/) {
		plan skip_all => "This test fails on \$^O == \$Config{'osname'} == '$^O'";
	}

	#if ($^O =~ /^(darwin)$/) {
	#	diag "This test will almost certainly fail on \$^O == \$Config{'osname'} == '$^O'. You can install the module skipping this test, but please report the failure.";
	#	#plan skip_all => "This test fails on $^O";
	#}


	plan tests => 3;

	#$Expect::Debug = 1;

	my $e = Expect->new;
	$e->raw_pty(1);

	$e->spawn("bc") or die "Cannot run bc\n";
	my $warranty;
	$e->expect( 1, [qr/warranty'\./ => sub { $warranty = 1 } ] );
	ok $warranty, 'warranty found' or do {
		diag $e->before;
		return;
	};
	$e->send("23+7\n");
	my $num;
	$e->expect( 1, [qr/\d+/ => sub { $num = 1 }] );
	ok $num, 'number found' or do {
		diag $e->before;
		return;
	};
	my $match = $e->match;
	is $match, 30, 'the number';
	$e->send("quit\n");
};

