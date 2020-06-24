#!/usr/bin/perl

use strict;
require "testlib.pl";

my $pwd = `pwd`;
chomp($pwd);

my $ant32 = "$pwd/../../ant32";
my $aa32 = "$pwd/../../aa32";
my $defcore = 'ant32.core';

my @ourtests;
my $othertests = 1;

my $waiting = 0;
my $childpid;
my %failed;
my $execstr;

#start script
{
	my $toclean;
	my %flags;
	my $flag;
	my @startdirs;

	$SIG{'ALRM'} = 
	sub {
		my @ps;
		my $todie;

		#this is a horrible hack, but given that I'm using pipes and such
		#in the exec, I think it's nonetheless probably the best way
		#to go about cleaning up both the spawned shell and the subsequent
		#spawned process in the case where it dies.
		if ($waiting) {
			kill(9, $childpid);
			@ps = split(/\n/, `ps`);
			($todie) = grep(/^.{33,33}$execstr/, @ps);
			$todie =~ /^(\d+)/;
			kill(9, $1);
			$waiting = 0;
		}
	};

	@startdirs = ('.');
	@ourtests = keys(%antstuff::tests);
	$failed{'assemble'} = [];
	$failed{'execute'} = [];

	%flags = scan_flags();

	foreach $flag (keys(%flags)) {
		if ($flag eq 'v') {
			$ant32 = $flags{$flag}->[0];
		} elsif ($flag eq 'a') {
			$aa32 = $flags{$flag}->[0];
		} elsif ($flag eq 'c') {
			print "Cleaning *.a32, *.core, and *.testout...\n";
			clean_files('.', '(a32|core|testout)\Z');
			exit;
		} elsif ($flag eq 't') {
			@ourtests = @{$flags{$flag}};
			$othertests = 0;
		} elsif ($flag eq 'e') {
			@startdirs = @{$flags{$flag}};
			$othertests = 0;
		} elsif ($flag eq 'i') {
			print "Runs any tests it finds and produces associated .core files.\n";
			print "Usage: runtests.pl (flags)\n\n";
			print_flags();
			exit;
		}
	}
	
	die "$ant32 not a valid executable.\n" unless -x $ant32;
	die "$aa32 not a valid executable.\n" unless -x $aa32;

	foreach (@startdirs) {
		run_directory($_);
	}

	if ($#{$failed{'assemble'}} >= 0) {
		print "\nFiles that failed to assemble:\n";
		foreach (@{$failed{'assemble'}}) {
			print "$_\n";
		}
	}
	if ($#{$failed{'execute'}} >= 0) {
		print "\nFiles that failed to execute:\n";
		foreach (@{$failed{'execute'}}) {
			print "$_\n";
		}
	}

	print "\nDone.\n";
	chdir($pwd);
}
#end script

#helper functions
sub run_directory
{
	my $curdir = shift;
	my $fulldir;
	my $core;
	my $out;
	my $a32;
	my $entry;
	my $dir;
	my $type;
	my $cmd;
	my @dirs = ();

	print "\nSearching $curdir\n";

	$fulldir = $pwd . "/$curdir";
	die "$0: couldn't chdir to $fulldir: $!\n" unless chdir($fulldir);

	opendir(CURDIR, '.') or die "Couldn't open $fulldir: $!\n";
	my @contents = readdir(CURDIR);
	closedir(CURDIR);
	foreach $entry (@contents) {
		if ($entry =~ /(.+)-(.+)-(.+)-(.+)-(.+)\.asm\Z/) {
			$type = $4;
#		} elsif ($entry =~ /(.+)\.asm\Z/) {
#			$type = 1;
		} else {
			$type = 0;
		}
		if (-d $entry) {
			push(@dirs, $entry) unless $entry eq '.' or $entry eq '..';
		} elsif (-r $entry and (($type == 1 and $othertests) or ($type and grep(/$type/, @ourtests)))) {
			$| = 1;  #make sure to flush
			$core = $entry;
			$core =~ s/asm\Z/core/;
			$out = $entry;
			$out =~ s/asm\Z/testout/;
			$a32 = $entry;
			$a32 =~ s/asm\Z/a32/;

			print "./$curdir/$entry...";

			# DJE -- adding the -b flag

			$execstr = "$aa32 -b $entry";
			$childpid = fork;
			if (!$childpid) {
				if (!exec $execstr) {
					print "$0: exec failed trying to assemble: $!\n";
					die;
				}
			} elsif (defined $childpid) {
				$waiting = 1;
				alarm 5;
				wait;
				$waiting = 0;
				alarm 0;
				if ($? >> 8 or !-e $a32) {
					print "assembly failed.\n";
					push(@{$failed{'assemble'}}, "./$curdir/$entry");
					next;
				} else {
					print "assembled...";
				}
			} else {
				die "$0: Fork failed miserably: $!\n";
			}

			$execstr = "$ant32 -d $a32";
			$childpid = fork;
			if (!$childpid) {
				if ($a32 =~ /^cin/) {
					$cmd = "/usr/bin/yes | $execstr > $out";
				} else {
					$cmd = "$execstr > $out";
				}
				if (!exec $cmd) {
					print "$0: exec failed trying to execute: $!\n";
					die;
				}
			} elsif (defined $childpid) {
				$waiting = 1;
				alarm 5;
				wait;
				$waiting = 0;
				alarm 0;
				if ($? >> 8 or !-e $defcore) {
					print "execution failed.\n";
					push(@{$failed{'execute'}}, "./$curdir/$entry");
					`rm $out`;
					next;
				} else {
					print "executed.\n";
				}
			} else {
				die "$0: Fork failed miserably: $!\n";
			}

			`mv $defcore $core`;
		}
	}

	foreach $dir (@dirs) {
		if ($curdir eq '.') {
			run_directory("$dir");
		} else {
			run_directory("$curdir/$dir");
		}
	}
}
