#!/usr/bin/perl

require "testlib.pl";

use strict;

#constants
my $true = 1;
my $false = 0;

#how many errors we've found
my $errcount = 0;
my $totalerrors = 0;
my $totalfiles = 0;
my @errorfiles;

#current report
my $thisreport;

#tests we're running
my @ourtests;

my $othertests = 1;

#start script
{
	my %flags;
	my $flag;
	my @startdirs;

	@startdirs = ('.');
	@ourtests = keys(%antstuff::tests);
	$| = 1;

	%flags = scan_flags();

	foreach $flag (keys(%flags)) {
		if ($flag eq 'e') {
			@startdirs = @{$flags{$flag}};
			$othertests = 0;
		} elsif ($flag eq 't') {
			@ourtests = @{$flags{$flag}};
			$othertests = 0;
		} elsif ($flag eq 'c') {
			exit;
		} elsif ($flag eq 'i') {
			print "Scans .core files and associated .asm looking for\n";
			print "discrepancies in expected values.\n";
			print "Usage: scancores.pl (flags) (report file)\n\n";
			print_flags();
			exit;
		}
	}

	#check for output file
	die "$0: USAGE: ./scancores.pl [flags] [report file].\n" if $#ARGV < 0;
	open(REPORT, ">$ARGV[0]") or die "$0: can't open output to file $ARGV[0]: $!\n";
	
	foreach (@startdirs) {
		make_all($_);
	}

	print REPORT "-------------\n";
	print REPORT "Total errors: $totalerrors\nTotal .core files analyzed: $totalfiles\n";
	
	close(REPORT);
	#finish

	print 'Done.';
	if ($#errorfiles > 0) {
		print "\nFiles containing errors:\n";
		foreach (@errorfiles) {
			print "$_\n";
		}
	}
	print "\nTotal errors found: $totalerrors, files scanned: $totalfiles\n";
	
	#`rm $ARGV[0]` unless $errcount;
}
#end script

sub make_all
{
	my @dirs = ();
	my $curdir = shift;
	my $entry;
	my $dir;
	my $type;

	opendir(CURDIR, $curdir) or die "Couldn't open $curdir: $!\n";
	my @contents = readdir(CURDIR);
	closedir(CURDIR);

	print "\nReading $curdir\n";

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
		} elsif (($type == 1 and $othertests) or ($type and grep(/$type/, @ourtests))) {
			$errcount = 0;
			$totalfiles++;
			$entry =~ /(.+)\.asm/;
			#print "file prefix is $1 while entry is $entry\n";
			$thisreport = make_report("$curdir/$1", parse_core("$curdir/$1"));
			if (length($thisreport)) {
				print REPORT "------------------\nfile: $curdir/$1\n------------------\n";
				$thisreport .= "\n";
				print REPORT $thisreport;
				push(@errorfiles, "$curdir/$1");
				print REPORT "errors in this file: $errcount\n\n\n";
			}
			$totalerrors += $errcount;
		}	
	}

	foreach $dir (@dirs) {
		if ($curdir eq '.') {
			make_all($dir);
		} else {
			make_all($curdir . "/$dir");
		}
	}
}

#read in expected state from the .asm file
#arguments: prefix to asm file, reference to hash of actual values received
sub make_report
{
	my $prefix = shift;
	my $actual = pop; 
	my $watching = $false;
	my $tlbinfo;
	my $hex1;
	my $hex2;
	my $act;
	my $repstr;
	my @report;
	my $lastsize;
	my $key;

	my %expected;
	my $temp;

	$expected{'r'} = [];
	$expected{'e'} = [];
	$expected{'k'} = [];
	$expected{'tlb'} = [];
	$expected{'mem'} = {};
	
	if (!$actual) {return 0;}

	if (!open(ASMFILE, $prefix . '.asm')) {
		warn "\n$0: Couldn't open ${prefix}.asm: $!\n";
		return "Unable to open ${prefix}.asm";
	}
	while (<ASMFILE>) {
		$watching = $false if (/^[^\#]/);
		$watching = $true if (/^\#\@expected values/);
		next unless $watching;
		$lastsize = $#report;
		s/^\#\s*//g; #get rid of leading whitespace
		s/0x((\d|a|b|c|d|e|f)+)/sprintf("%u", hex($1))/ge; #interpret values
		if (/^(mode|interrupts|exceptions)\s*=\s*(S|U|on|off)/) {
			$expected{$1} = $2;
				
			if ($2 ne $actual->{$1}) {
				$repstr = "$1: expected: $2, got: ";
				$repstr .= (defined($actual->{$1})) ? $actual->{$1} : "non-existent";
				$repstr .= "\n";
				push(@report, $repstr);
			} 
		} elsif (/^pc\s*=\s*(\d+)/) {
			$expected{'PC'} = $1;
			if ($1 != $actual->{'PC'}) {
				$hex1 = sprintf("%08x", $1);
				$act = sprintf("%08x", $actual->{'PC'});
				$repstr = "PC: expected: 0x$hex1, got: 0x$act\n";
				push(@report, $repstr);
			}
		} elsif (/^([ker])\s*(\d+)\s*=\s*(-?\d+)/) {
			$temp = constrict($3);
			$expected{$1}->[$2] = $temp;
			if ($temp != $actual->{$1}->[$2]) {
				$hex1 = sprintf("%08x", $temp);
				$act = sprintf("%08x", $actual->{$1}->[$2]);
				$repstr = "$1$2: expected: $temp(0x$hex1), ";
				$repstr .= "got: ";
				$repstr .= (defined($actual->{$1}->[$2])) ?
					"$actual->{$1}->[$2](0x$act)\n" : "non-existent\n";
				push(@report, $repstr);
			}
		} elsif (/^mem\s*(\d+)\s*=\s*(-?\d+)/) {
			$temp = constrict($2);
			$hex1 = sprintf("%08x", $1);
			$expected{'mem'}->{$hex1} = $temp;
			if ($temp != $actual->{'mem'}->{$hex1}) {
				$hex2 = sprintf("%08x", $2);
				$act = sprintf("%08x", $actual->{'mem'}->{$hex1});
				$repstr = "mem 0x$hex1: expected: ";
				$repstr .= "$temp(0x$hex2), got: ";
				$repstr .= (defined($actual->{'mem'}->{$hex1})) ?
					"$actual->{'mem'}->{$hex1}(0x$act)\n" : "non-existent\n";
				push (@report, $repstr);
			}
		} elsif (/^tlb\s*(\d+):/) {
			$tlbinfo = load_tlb_expected();
			foreach $key (keys(%{$tlbinfo})) {
				$expected{'tlb'}->[$1]->{$key} = $tlbinfo->{$key};
				if ($tlbinfo->{$key} != $actual->{'tlb'}->[$1]->{$key}) {
					$hex1 = sprintf("%02x", $1);
					if ($key eq 'vpn' or $key eq 'ppn') {
						$hex2 = sprintf("%05x", $tlbinfo->{$key});
						$act = sprintf("%05x", $actual->{'tlb'}->[$1]->{$key});
					} else {
						$hex2 = sprintf("%03x", $tlbinfo->{$key});
						$act = sprintf("%03x", $actual->{'tlb'}->[$1]->{$key});
					}
					$repstr = "TLB $1(0x$hex1) $key: ";
					$repstr .= "expected: $tlbinfo->{$key}(0x$hex2), ";
					$repstr .= "got: ";
					$repstr .= (defined($actual->{'tlb'}->[$1]->{$key})) ?
						"$actual->{'tlb'}->[$1]->{$key}(0x$act)\n" : "non-existent\n";
					push(@report, $repstr);
				}
			}
		}
		$errcount++ if $#report > $lastsize;
	}
	close(ASMFILE);
	@report = sort mysort @report;
	join("", @report);
}

sub mysort
{
	my $letter;
	my $number;
	my $refa;
	my $refb;
	my $multiplier;
	my $A;
	my $B;

	$A = lc $a;
	$B = lc $b;
	if ($B =~ /^\w\d+/ and $A !~ /^\w\d+/) {
		$refa = \$B;
		$refb = \$A;
		$multiplier = -1;
	} else {
		$refa = \$A;
		$refb = \$B;
		$multiplier = 1;
	}

	if (${$refa} =~ /^(\w)(\d+)/) {
		$letter = $1;
		$number = $2;
		if (${$refb} !~ /^(\w)(\d+)/) {
			return $multiplier * -1;
		} else {
			if ($letter ne $1) {
				return $multiplier * ($letter cmp $1);
			} else {
				return $multiplier * ($number <=> $2);
			}
		}
	} else {
		return $A cmp $B;
	}
}

sub load_tlb_expected
{
	my %info;
	my $linelen;

	while(<ASMFILE>) { 
		#print;
		$linelen = length;
		s/0x((\d|a|b|c|d|e|f)+)/sprintf("%u", hex($1))/ge; #interpret values
		last unless (/^\#\s*(ppn|at|vpn|os)\s*=\s*(\d+)/);
		$info{$1} = $2;
	}
	seek(ASMFILE, -$linelen, 1) if defined($_); #rewind if necessary
	\%info;
}

#read in state from the core file
#arguments: prefix to core file
sub parse_core
{
	my @elements;
	my %stats;
	my $filename = shift;

	$filename .= '.core';
	print "Parsing $filename...";
	if (!open(COREFILE, $filename)) {
		warn "$0: Couldn't open $filename: $!\n";
		print "error opening file; skipping...\n";
		return 0;
	}
	while (<COREFILE>) {
		chomp;
		s/\s+/ /g;
		@elements = split(/[ +\t+]/);
		if ($elements[0] eq 'PC') {
			for(my $i = 0; $i <= $#elements; $i+=3) {
				$elements[$i] =~ s/int/interrupts/;
				$elements[$i] =~ s/exc/exceptions/;
				$stats{$elements[$i]} = $elements[$i+2];
				$stats{$elements[$i]} = hex($stats{$elements[$i]}) 
					if $stats{$elements[$i]} =~ /\d+|..\d+/;
				#print "$elements[$i] = ${stats{$elements[$i]}}\n";
			}
		} elsif (/^[ke]/) {
			my $i = 0;
			my $letter = substr($elements[0], 0, 1);
			while($elements[$i] =~ /^$letter/) {
				$elements[$i] = substr($elements[$i], 1); #remove the leading [ke]
				$stats{$letter}->[$elements[$i]] = hex($elements[$i+2]);
				#print "$letter -> $elements[$i] = ${stats{$letter}->[$elements[$i]]}\n";
				$i+=3;
			}
		} elsif (/^Registers:/) {
			$stats{'r'} = load_registers();
		} elsif (/^TLB Entries:/) {
			$stats{'tlb'} = load_tlbs();
		} elsif (/^Memory Contents:/) {
			$stats{'mem'} = load_memory();
		}
	}
	close(COREFILE);
	print "done.\n";
	\%stats;
}

sub load_registers
{
	my $reg = 0;
	my @regvals;
	my $regarray = [];

	while (defined($_ = <COREFILE>) and /^\S/) {
		chomp;
		s/\s+/ /g;
		@regvals = split(/[ +\t+]/);
		shift(@regvals);
		for (my $i = 0; $i < 8; $i++) {
			#print "r[$reg] = ";
			$regarray->[$reg] = hex($regvals[$i]);
			#print "$regarray->[$reg]\n";
			$reg++;
		}
	}
	$regarray;
}

sub load_tlbs
{
	my $tlb = 0;
	my @tlbvals;
	my $tlbarray = [];
	my @props;
	my $prop;
	my $which;
	my $what;

	while (defined($_ = <COREFILE>) and /^\S/) {
		chomp;
		s/\s+/ /g;
		@tlbvals = split(/[ +\t+]/);
		shift(@tlbvals);
		while ($#tlbvals >= 0) {
			@props = splice(@tlbvals, 0, 4);
			foreach $prop (@props) {
				($which, $what) = split(/=/, $prop);
				$tlbarray->[$tlb]->{$which} = hex($what);
				#print "tlb->$tlb->$which = $tlbarray->[$tlb]->{$which}\n";
			}
			$tlb++;
		}
	}
	$tlbarray;
}

sub load_memory
{
	my $address;
	my @memvals;
	my $memhash = {};

	while (defined($_ = <COREFILE>) and /^\S/) {
		chomp;
		s/\s+/ /g;
		@memvals = split(/[ +\t+]/);
		$address = substr(shift(@memvals), 2, 8);
		for (my $i = 0; $i < 16; $i++) {
			$memhash->{$address} = hex($memvals[$i]);
			#print "mem->$address = $memhash->{$address}\n";
			$address = sprintf("%08x", hex($address)+1);
		}
	}
	$memhash;
}

#this func is used to constrict values to 32 bit integers so
#that comparisons can be made on negative numbers as if they
#were unsigned 32-bit integers
#effectively, this reinterprets negative numbers as unsigned integers
sub constrict
{
	$_[0] & 0xffffffff;
}
