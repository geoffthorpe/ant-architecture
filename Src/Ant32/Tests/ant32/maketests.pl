#!/usr/bin/perl

#program to generate assembly code to test exception handling in ant32

#note: filename created = op-position replaced-mode-test-testnum.autotest.asm
#where:
#op : instruction
#position replaced : position in the instruction replaced with offending values
#mode : super or user
#test : which test this is (kreg, align, etc.)
#testnum : in cases where multiple values need to be tested (e.g., different
#	segments of memory in the align case), numerically which test this is

# May 6, 2002 
# 
# The following bugs were fixed in this code:
# - Special tests expected ant version 3.1a and now it is 3.1b
# - Unsigned gtu and geu were failing tests because Perl could
#   not evaluate them as unsigned. This was fixed with a character
#   by character comparison
# - Tests were expecting bus errors from physical address ffffe
#   which is valid. This was changed to 20000
# - Instruction ld1 was failing tests because st4 was used to store 
#   values, then loaded with ld1. After aligning and storing, test code
#   was computing the wrong offset and expected value for ld1.
# As far as I know there is one important outstanding test that fails. 
# On little endian machines, Ant memory is little endian.
#
# Salimah Addetia
 
use strict;
use integer;
require "testlib.pl";

#constants
#these are used to access appropriate parts of the inst mapping
my $SYNTAX = "syntax";
my $EXCEPTS = "excepts";
my $CATEGORY = "category";

my $TRUE = 1;
my $FALSE = 0;
my $SCRATCH1 = "r30"; #scratch register 1
my $SCRATCH2 = "r32"; #scratch register 2
my $INVALID = "0x3fffef00";
#some memory location that will generate a bus exception
#(note: this has to be supported by the usermode code)
my $MAX8 = 0x7f;
my $MIN8 = -128;
my $MAX16 = 0x7fff;
my $MIN16 = -32768;

my $EXTENSION = '.autotest.asm';

#globals
my %inst = ();		#instruction descriptions
my $total_created = 0;	#total tests created
my $usermode;		#usermode code
my $exception;		#exception code
my @typeinst;		#categories of instructions to include (e.g., arith, mem...)
my $nextreg = 4;	#next r register
my $nexttlb = 0;	#next tlb entry

#begin script
{
	my @ourtests;
	my %flags;
	my $flag;

	%flags = scan_flags();

	@ourtests = keys(%antstuff::tests);

	@typeinst = ();

	foreach $flag (keys(%flags)) {
		if ($flag eq 'c') {
			clean_files('.', 'autotest\.asm\Z');
			exit;
		} elsif ($flag eq 't') {
			@ourtests = @{$flags{$flag}};
		} elsif ($flag eq 'e') {
			@typeinst = @{$flags{$flag}};
		} elsif ($flag eq 'i') {
			print "Produce auto-generated assembly code tests.\n";
			print "Usage: maketests.pl (flags)\n\n";
			print_flags();
			exit;
		}
	}
	
	load_info(); #load instruction specifications
	
	print "Info loaded.  Making tests...\n";
	
	foreach (@ourtests) {
		print "\nMaking $_ tests...\n";
		if ($_ eq 'tlb') {
			make_tlb_tests();
			next;
		} elsif ($_ eq 'arith') {
			make_arith_tests();
			next;
		} elsif ($_ eq 'comp') {
			make_comp_tests();
			next;
		} elsif ($_ eq 'control') {
			make_control_tests();
			next;
		} elsif ($_ eq 'mem') {
			make_mem_tests();
			next;
		} elsif ($_ eq 'constant') {
			make_constant_tests();
			next;
		} elsif ($_ eq 'special') {
			make_special_tests();
			next;
		} elsif ($_ eq 'init') {
			make_init_tests();
			next;
		} elsif ($_ eq 'info') {
			make_info_tests();
			next;
		} else {
			make_exc_tests($_, "super") if grep(/super/, @{$antstuff::tests{$_}});
			make_exc_tests($_, "user") if grep(/user/, @{$antstuff::tests{$_}});
		}
	}

	print "\nFinished.\nTotal tests created: ${total_created}.\n";
}
#end script

#helper funcs

#loads the info for each instruction into the inst hash.
#arguments: none
#returns: none
sub load_info {
	my $line = 0;
	my $cur_inst = 0;
	my $got_format = $TRUE;
	my $got_excepts = $TRUE;
	my $got_type = $TRUE;

	open(DESCRIPTIONS, "descriptions") or die "Could not open descriptions file: $!\n";

	while (<DESCRIPTIONS>) {
		$line++;
		s/[\s]//g;
		if (/^\#/) {next;} #comment; ignore
		elsif (/^instruction:/) {
			die("Died parsing at line $line: didn't get full definition for last instruction.\n") 
				if !($got_format == $TRUE && $got_excepts == $TRUE && $got_type == $TRUE);
			$cur_inst = substr($_, 12);
			$got_format = $FALSE;
			$got_excepts = $FALSE;
			$got_type = $FALSE;
		} elsif (/^format:/) {
			die("Died parsing at line $line: more than one format.\n") if $got_format == $TRUE;
			$inst{$cur_inst} -> {$SYNTAX} = [split(/,/, substr($_, 7))];
			$got_format = $TRUE;
		} elsif (/^exceptions:/) {
			die("Died parsing at line $line: more than one exception list.\n") if $got_excepts == $TRUE;
			$inst{$cur_inst} -> {$EXCEPTS} = [split(/,/, substr($_, 11))];
			$got_excepts = $TRUE;
		} elsif (/^type:/) {
			die("Died parsing at line $line: more than one type.\n") if $got_type == $TRUE;
			$inst{$cur_inst} -> {$CATEGORY} = substr($_, 5);
			$got_type = $TRUE;
		}
	}

	close(DESCRIPTIONS);
}

#types or argument specification:
#&op, &des, &src[123], 0, &const8, &const16, null

#returns user mode warp code
#arguments: none
sub make_usermodewarp {
	if (length($usermode) < 1) {
		open(USERMODE, "usermode") or die "Couldn't open usermode code: $!\n";
		$usermode = join("", <USERMODE>);
		close(USERMODE);
	}
	$usermode;
}

#returns exception handling code code
#arguments: none
sub make_exception {
	if (length($exception) < 1) {
		open(EXCEPTION, "exception") or die "Couldn't open: $!\n";
		$exception = join("", <EXCEPTION>);
		close(EXCEPTION);
	}
	$exception;
}

#constructs code to test kernel register access violations
#arguments: instruction to test, position to place reg, register to use, read|write, special instructions
sub make_code_reg {
	my $op = shift;
	my $pos = shift;
	my $reg = shift;
	my $mode = shift;
	my $special = shift;
	my @format = @{$inst{$op}->{$SYNTAX}};
	my $position; #position in the syntax
	my $prepend = "    lc  $SCRATCH1, 1\n";
	my $instruction = "    $op";
	my $expected;

	for ($position = 1; $position < 4; $position++) {
		if ($position == $pos) {
			#if not a valid placement, don't return an instruction
			if (($format[$position] !~ /^\&src/ and $format[$position] !~ /^\&des/) or
				($format[$position] =~ /^\&src/ and $mode !~ /read/) or
				($format[$position] =~ /^\&des/ and $mode !~ /write/) or
				($format[$position] !~ /even/ and $special eq "even"))
			{
				return 0;
			} else {
				$instruction .= ", $reg";
			}
		#just fill with something that won't cause an error
		} elsif ($format[$position] =~ /\A\&src|\&des/) {
			$instruction .= ", $SCRATCH1";
		#ditto
		} elsif ($format[$position] =~ /\A\&const/) {
			$instruction .= ", 1";	#1 here to avoid possible divide by zero problems
									#ditto for src|des
		}
	}
	$instruction .= "\n";
	$expected = "\#$SCRATCH1 = 1\n";
	$instruction =~ s/,//; #just replace the first ,
	($prepend . $instruction, $expected, 2);
}

#constructs code in the cases where we only care about the opcode
#arguments: instruction
sub make_code_inst {
	my $op = shift;
	my @format = @{$inst{$op}->{$SYNTAX}};
	my $position;
	my $prepend = "    lc  $SCRATCH1, 1\n";
	my $instruction = "    $op";
	my $expected;

	#fill with stuff that won't cause an error
	for ($position = 1; $position < 4; $position++) {
		if ($format[$position] =~ /\A\&src|\&des/) {
			$instruction .= ", $SCRATCH1";
		} elsif ($format[$position] =~ /\A\&const/) {
			$instruction .= ", 1";	#1 here to avoid possible divide by zero problems
									#ditto for src|des
		}
	}
	$instruction .= "\n";
	$expected = "\#$SCRATCH1 = 1\n";
	$instruction =~ s/,//; #just replace the first ,
	($prepend . $instruction, $expected, 2);
}

#constructs div0 code
#arguments: instruction
sub make_code_div0 {
	my $op = shift;
	my @format = @{$inst{$op}->{$SYNTAX}};
	my $position;
	my $prepend = "    lc  $SCRATCH1, 1\n";
	my $instruction = "    $op";
	my $expected;

	for ($position = 1; $position < 4; $position++) {
		if ($format[$position] =~ /\A\&src|\&des/) {
			if ($format[$position] =~ /zero/) {
				$instruction .= ", r0";
			} else {
				$instruction .= ", $SCRATCH1";
			}
		} elsif ($format[$position] =~ /\A\&const/) {
			if ($format[$position] =~ /zero/) {
				$instruction .= ", 0";
			} else {
				$instruction .= ", 1";
			}
		}
	}
	$instruction .= "\n";
	$expected = "\#$SCRATCH1 = 1\n";
	$instruction =~ s/,//; #just replace the first ,
	($prepend . $instruction, $expected, 2);
}

#constructs code to generate memory instruction errors
#note: this is used for both the align and the mem exception code
#arguments: instruction to test, address to insert

#assume that no more than one memory location shows up in any given instruction
#also assume no need to worry about divide by 0
sub make_code_mem {
	my $op = shift;
	my $address = shift;
	my @format = @{$inst{$op}->{$SYNTAX}};
	my $position;
	my $prepend = "    lc $SCRATCH1, $address\n    lc $SCRATCH2, 0\n";
	my $instruction = "    $op";
	my $expected;

	die "Improperly formed instruction ($op) to test align.\n" if !grep(/mem\Z/, @format);

	for ($position = 1; $position < 4; $position++) {
		if ($format[$position] =~ /mem/) {
			$instruction .= ", $SCRATCH1";
		} elsif ($format[$position] =~ /\A\&src|\&des/) {
			$instruction .= ", $SCRATCH2";	
		} elsif ($format[$position] =~ /\A\&const/) {
			$instruction .= ", 0";	#this should generally be an offset	
		}
	}
	$instruction .= "\n";
	$expected = "\#$SCRATCH1 = $address\n\#$SCRATCH2 = 0\n";
	$instruction =~ s/,//; #just replace the first
	($prepend . $instruction, $expected, 4);
}

#make the tests
#arguments: the type of test to generate, testmode (user or super)

sub make_exc_tests {
	my $type = shift;
	my $mode = shift;
	my $myexception;
	my $code;
	my $testcode;
	my $instruction;
	my @instructions = keys(%inst);
	my $filename;
	my $dir;
	my $temp;
	my $replaced;
	my $subs;
	my $testnum = 1;
	my $finished = $FALSE;

	my $addendum;
	my $added;
	my $exceptionpc;

	@instructions = sort @instructions;

	foreach $instruction (@instructions) {
		next if $inst{$instruction}->{$CATEGORY} =~ /super/ and $mode eq "user" and $type ne "priv";
		$temp = [split(/-/, $type)]->[0];
		next if !grep(/^$temp/, @{$inst{$instruction}->{$EXCEPTS}});
		$finished = $FALSE;
		for (my $i = 1; $i < 4 and !$finished; $i++) {
			if ($type eq "kreg") {
				$subs = "k2";
				($testcode, $addendum, $added) = 
					make_code_reg($instruction, $i, $subs, "readwrite");
				$addendum = 0x000000a0;
				$replaced = $inst{$instruction}->{$SYNTAX}->[$i];
			} elsif ($type eq "ereg") {
				$subs = "e2";
				($testcode, $addendum, $added) = 
					make_code_reg($instruction, $i, $subs, "write");
				$addendum = 0x000000a0;
				$replaced = $inst{$instruction}->{$SYNTAX}->[$i];
			} elsif ($type eq "align") {
				if ($mode eq "super") {$subs = "0x80000001";}
				else {$subs = "0x00000001";}
				($testcode, $addendum, $added) = 
					make_code_mem($instruction, $subs);
				$addendum = 0x00000080;
				($replaced) = grep(/mem/, @{$inst{$instruction}->{$SYNTAX}});
				$finished = $TRUE;

				#set bit values for memory functions
				$addendum += 4 if $instruction =~ /^st[^ei]/;
				$addendum += 8 if $instruction =~ /^ld/ or $instruction eq 'ex4';
			} elsif ($type eq "memseg") {
				if ($i == 1) {$subs = "0x40000004";}
				elsif ($i == 2) {$subs = "0x80000004";}
				elsif ($i == 3) {$subs = "0xc0000004";}
				($testcode, $addendum, $added) = 
					make_code_mem($instruction, $subs);
				$addendum = 0x00000090;
				($replaced) = grep(/mem/, @{$inst{$instruction}->{$SYNTAX}});
				$testnum = $i;

				#set bit values for memory functions
				$addendum += 4 if $instruction =~ /^st[^ei]/;
				$addendum += 8 if $instruction =~ /^ld/ or $instruction eq 'ex4';
			} elsif ($type eq "regpar") {
				$subs = "r1";
				($testcode, $addendum, $added) = 
					make_code_reg($instruction, $i, $subs, "readwrite", "even");
				$addendum = 0x00000040;
				$replaced = $inst{$instruction}->{$SYNTAX}->[$i];
			} elsif ($type eq "reginv") {
				$subs = "r900";
				($testcode, $addendum, $added) = 
					make_code_reg($instruction, $i, $subs, "readwrite");
				$addendum = 0x000000a0;
				$replaced = $inst{$instruction}->{$SYNTAX}->[$i];
			} elsif ($type eq "priv") {
				$subs = "$SCRATCH1";
				($testcode, $addendum, $added) = 
					make_code_inst($instruction);
				$addendum = 0x00000050;
				$replaced = "&null";  #& will be stripped (yeah, it's a hack...)
				$finished = $TRUE;
			} elsif ($type eq "bus") {
				$subs = "$INVALID";
				($testcode, $addendum, $added) = 
					make_code_mem($instruction, $subs);
				$addendum = 0x00000030;
				($replaced) = grep(/mem/, @{$inst{$instruction}->{$SYNTAX}});
				$finished = $TRUE;

				#set bit values for memory functions
				$addendum += 4 if $instruction =~ /^st[^ei]/;
				$addendum += 8 if $instruction =~ /^ld/ or $instruction eq 'ex4';
			} elsif ($type = "div0") {
				$subs = "r0";
				($testcode, $addendum, $added) = 
					make_code_div0($instruction);
				$addendum = 0x00000070;
				$replaced = "&null";
				$finished = $TRUE;
			}

			next unless $testcode;

			#make sure we're making this type of test
			next unless $#typeinst < 0 or grep(/$dir/, @typeinst); 

			$replaced = [split(/-/, $replaced)]->[0];
			$replaced = substr($replaced, 1);
			$dir = [split(/-/, $inst{$instruction}->{$CATEGORY})]->[0];

			`mkdir $dir` unless -d $dir;
			$filename = $dir;
			$filename .= '/';
			$filename .= $instruction . '-';
			$filename .= $replaced . '-';
			$filename .= $mode . '-';
			$filename .= $type . '-';
			$filename .= $testnum;
			$filename .= $EXTENSION;
			if ($mode eq 'user') {
				#attempt to fix the PC we're supposed to see
				$code = make_usermodewarp();
				$code =~ s/\#\s*e0\s*=\s*0x((\d|a|b|c|d|e|f)+)/
					'#e0 = 0x' . sprintf('%08x', hex($1) + ($added - 1) * 4) .
					"\n\#e2 = 0x" . sprintf('%08x', hex($1) + ($added - 1) * 4)/e;
	
				#there's an additional TLB lookup for mem tests
				$code =~ s/\#e2\s*=.*/\#e2 = $subs/ if $type eq 'memseg';
	
				$addendum = sprintf("\#e3 = 0x%08x\n", $addendum);
				$code =~ s/\#<code here>\n/$testcode\n    trap\n\n\#\@expected values\n$addendum/;
			} else {
				$myexception = make_exception();
				$myexception =~ s/\#\s*pc\s*=\s*0x((\d|a|b|c|d|e|f)+)$//;
				$temp = hex($1);
				$code = $myexception;
				$code .= "#actual testcode:\n";
				$code .= $testcode;
				$code .= "    halt\n";
				$code .= "\n#\@expected values\n";
				$code .= "#mode = S\n";
				$code .= "#interrupts = off\n";
				$code .= "#exceptions = off\n";
				$code .= "#generated by make_exc_tests\n";
				$code .= "#pc = ";
				$code .= sprintf("0x%08x", $temp + 4), "\n";
				$code .= "#e0 = ";
				$code .= sprintf("0x%08x", $temp + ($added) * 4), "\n";
				$code .= sprintf("\#e3 = 0x%08x\n", $addendum + 0x1);
			}
			writeout($filename, $code);
		}
	}
}

sub make_tlb_tests
{
	my $vpn;
	my $ppn;
	my $at;
	my $target;
	my $e3;

	my $myusermode;
	my $tlbadded;
	my $otheradded;
	my $tlbcode;
	my $trigger;
	my $expected;
	my $filename;

	my $i;
	my $jumping;

	`mkdir mem` unless -d 'mem';
	
	for ($i = 1; $i <= 8; $i++) {
		$jumping = $FALSE;
		$myusermode = make_usermodewarp();
		$tlbadded = 0;
		$otheradded = 0;
		$tlbcode = '';
		$trigger = '';
		$expected = "#\@expected values\n";
		$filename = '';
		$filename = "mem/ld1-null-user-tlb-$i$EXTENSION";

		if ($i == 1) {
			#vpn in seg 1 that has same vpn as a seg 0 address
			$vpn = '40003';
			$ppn = '00003';
			$at = '01f';
			$target = '0x00003000';
			$e3 = '0x000000b8';
			$trigger .= "    lc r53, $target\n";
			$trigger .= "    ld1 r54, r53, 0\n";
			$otheradded += 2;
			$tlbadded++;
		} elsif ($i == 2) {
			#matching but invalid tlb entry
			$vpn = '00003';
			$ppn = '00003';
			$at = '017';
			$target = '0x00003000';
			$e3 = '0x000000b8';

			$trigger .= "    lc r53, $target\n";
			$trigger .= "    ld1 r54, r53, 0\n";
			$otheradded += 2;
		} elsif ($i == 3) {
			#read from unreadable
			$vpn = '00003';
			$ppn = '00003';
			$at = '01b';
			$target = '0x00003000';
			$e3 = '0x000000c8';

			$trigger .= "    lc r53, $target\n";
			$trigger .= "    ld1 r54, r53, 0\n";
			$otheradded += 2;
		} elsif ($i == 4) {
			#write to unwritable
			$vpn = '00003';
			$ppn = '00003';
			$at = '01d';
			$target = '0x00003000';
			$e3 = '0x000000c4';
	
			$trigger .= "    lc r53, $target\n";
			$trigger .= "    st1 r54, r53, 0\n";
			$otheradded += 2;
		} elsif ($i == 5) {
			#fetch from unfetchable
			$jumping = $TRUE;
			$vpn = '00003';
			$ppn = '00003';
			$at = '01e';
			$target = '0x00003000';
			$e3 = '0x000000c2';
	
			$trigger .= "    lc r53, $target\n";
			$trigger .= "    jez r54, r0, r53\n";

			$tlbcode .= "    lc r50, 0x${vpn}000\n";
			$tlbcode .= "    lc r51, 0x$ppn$at\n";
			$tlbcode .= "    lc r52, 10\n";	
			$tlbcode .= "    tlbse r52, r50\n";	
			$tlbcode .= "\n#warp to user mode\n";
			$tlbadded += 4;

			$expected .= "#r50 = 0x${vpn}000\n";
			$expected .= "#r51 = 0x$ppn$at\n";
			$expected .= "#r52 = 10\n";
			$expected .= "#r53 = $target\n";
			$expected .= "#tlb 10:\n";
			$expected .= "#vpn = 0x$vpn\n";
			$expected .= "#ppn = 0x$ppn\n";
			$expected .= "#os = 0\n";
			$expected .= "#at = 0x$at\n";

			$myusermode =~ /\#\s*e0\s*=\s*0x((\d|a|b|c|d|e|f)+)/;
			$otheradded += 2;
			$expected .= '#r54 = 0x' . sprintf('%08x', hex($1) + ($tlbadded + $otheradded - 1) * 4);
		} elsif ($i == 6) {
			#double match
			$vpn = '00003';
			$ppn = '00003';
			$at = '01f';
			$target = '0x00003000';
			$e3 = '0x000000d8';
	
			$trigger .= "    lc r53, $target\n";
			$trigger .= "    ld1 r54, r53, 0\n";
			$otheradded += 2;

			$tlbcode .= "    lc r50, 0x${vpn}000\n";
			$tlbcode .= "    lc r51, 0x$ppn$at\n";
			$tlbcode .= "    lc r52, 9\n";	
			$tlbcode .= "    tlbse r52, r50\n";	
			$tlbadded += 4;
		} elsif ($i == 7) {
			#double match, but one with wrong permissions
			$vpn = '00003';
			$ppn = '00003';
			$at = '018';
			$target = '0x00003000';
			$e3 = '0x000000d8';
	
			$trigger .= "    lc r53, $target\n";
			$trigger .= "    ld1 r54, r53, 0\n";
			$otheradded += 2;

			$tlbcode .= "    lc r50, 0x${vpn}000\n";
			$tlbcode .= "    lc r51, 0x$ppn$at\n";
			$tlbcode .= "    lc r52, 9\n";	
			$tlbcode .= "    tlbse r52, r50\n";	
			$tlbadded += 4;
		} elsif ($i == 8) {
			#invalid index
			$jumping = $TRUE;
			$vpn = '00003';
			$ppn = '00003';
			$at = '01f';
			$myusermode =~ /\s*lc\s*r40, (\w+)/;
			$target = sprintf('0x%08x', hex($1) + 8);
			$e3 = '0x000000e1';
	
			$trigger .= "    lc r53, $target\n";
			$trigger .= "    ld1 r54, r53, 0\n";
			$otheradded += 2;

			$tlbcode .= "    lc r50, 0x${vpn}000\n";
			$tlbcode .= "    lc r51, 0x$ppn$at\n";
			$tlbcode .= "    lc r52, 500\n";	
			$tlbcode .= "    tlbse r52, r50\n";	
			$tlbadded += 4;

			$expected .= "#r50 = 0x${vpn}000\n";
			$expected .= "#r51 = 0x$ppn$at\n";
			$expected .= "#r52 = 500\n";
		}

		if (!$jumping) {
			$tlbcode .= "    lc r50, 0x${vpn}000\n";
			$tlbcode .= "    lc r51, 0x$ppn$at\n";
			$tlbcode .= "    lc r52, 10\n";	
			$tlbcode .= "    tlbse r52, r50\n";	

			#just check to make sure tlble is working while we're at it
			$tlbcode .= "    tlble r60, r52\n";

			$tlbcode .= "\n#warp to user mode\n";
			$tlbadded += 5;

			$expected .= "#r50 = 0x${vpn}000\n";
			$expected .= "#r51 = 0x$ppn$at\n";
			$expected .= "#r52 = 10\n";
			$expected .= "#r53 = $target\n";
			$expected .= "#r60 = 0x${vpn}000\n";
			$expected .= "#r61 = 0x$ppn$at\n";
			$expected .= "#tlb 10:\n";
			$expected .= "#vpn = 0x$vpn\n";
			$expected .= "#ppn = 0x$ppn\n";
			$expected .= "#os = 0\n";
			$expected .= "#at = 0x$at\n";
		}
	
		$trigger .= "    trap\n\n";
	
		$expected .= "#e3 = $e3\n";

		#we need to fix exception handler and usermode addresses
		$myusermode =~ s/r4([06])(,| =) 0x((\d|a|b|c|d|e|f)+)/"r4$1$2 0x" . 
			sprintf('%08x', hex($3) + $tlbadded * 4)/eg;

		#fix the PC
		$myusermode =~ s/\#\s*pc\s*=\s*0x((\d|a|b|c|d|e|f)+)/
			'#pc = 0x' . sprintf('%08x', hex($1) + ($tlbadded) * 4)/e;

		#attempt to fix the e[02] we're supposed to see
		if ($jumping) {
			$myusermode =~ s/\#\s*e0\s*=\s*0x(?:\d|a|b|c|d|e|f)+/\#e0 = $target\n\#e2 = $target/;
		} else {
			$myusermode =~ s/\#\s*e0\s*=\s*0x((\d|a|b|c|d|e|f)+)/
				'#e0 = 0x' . sprintf('%08x', hex($1) + ($tlbadded + $otheradded - 1) * 4) .
				"\n\#e2 = $target"/e;	
		}

		$myusermode =~ s/\#warp to user mode\n/$tlbcode/;	
		$myusermode =~ s/\#<code here>\n/$trigger.$expected/e;

		writeout($filename, $myusermode);
	}
}

# Somewhat tedious but at least we are certain the right value 
# comes back
sub hexdigit2decdigit
{
        my $inval;

        ($inval) = @_;

        if ($inval eq "a") {
                return 10;
        } elsif ($inval eq "b") {
                return 11;
        } elsif ($inval eq "c") {
                return 12;
        } elsif ($inval eq "d") {
                return 13;
        } elsif ($inval eq "e") {
                return 14;
        } elsif ($inval eq "f") {
                return 15;
        } elsif ($inval eq "0") {
                return 0;
        } elsif ($inval eq "1") {
                return 1;
        } elsif ($inval eq "2") {
                return 2;
        } elsif ($inval eq "3") {
                return 3;
        } elsif ($inval eq "4") {
                return 4;
        } elsif ($inval eq "5") {
                return 5;
        } elsif ($inval eq "6") {
                return 6;
        } elsif ($inval eq "7") {
                return 7;
        } elsif ($inval eq "8") {
                return 8;
        } elsif ($inval eq "9") {
                return 9;
        } else {
                return -1;
	}
}

# compares two hex digits returning -1 if equal, 1 if the first 
# is greater than the second and 0 if the second is greater than
# the first
sub hexcomp
{
        my $inval1; 
	my $inval2;
        my $dval1; 
	my $dval2;

        ($inval1, $inval2) = @_;

        $dval1 = hexdigit2decdigit($inval1);
        $dval2 = hexdigit2decdigit($inval2);

        if ($dval1 == $dval2) {
                return -1;
        } elsif ($dval1 > $dval2) {
                return 1;
        } else {
                return 0;
        }
}


sub compute_arith
{
	my ($op, $val1, $val2) = @_;
	my $evalstr;
	my $reslow;
	my $reshigh;
	my $i;
	my $j; 
	my $res;
	my $tempchar1; 
	my $tempchar2;

	#convert numbers into signed values
	#unless operation is unsigned, in which case make sure the values
	#are interpreted as unsigned
	$val1 = hex(sprintf('%x', $val1)) if $val1 < 0 and 
		($op eq 'gtu' or $op eq 'geu');
	$val2 = hex(sprintf('%x', $val2)) if $val2 < 0 and 
		($op eq 'gtu' or $op eq 'geu');
	$val1 = hex($val1) if $val1 =~ /^0x/ and $op ne 'gtu' and $op ne 'geu';
	$val2 = hex($val2) if $val2 =~ /^0x/ and $op ne 'gtu' and $op ne 'geu';
	$val1 &= 0xffffffff unless $op eq 'gtu' or $op eq 'geu';
	$val2 &= 0xffffffff unless $op eq 'gtu' or $op eq 'geu';

	if ($op =~ /^add/) {
		$evalstr = "($val1)+($val2)";
	} elsif ($op =~ /^sub/) {
		$evalstr = "($val1)-($val2)";
	} elsif ($op =~ /^mul/) {
		$evalstr = "($val1)*($val2)";
	} elsif ($op =~ /^div/) {
		$evalstr = "($val1)/($val2)";
	} elsif ($op =~ /^mod/) {
		$evalstr = "($val1)%($val2)";
	} elsif ($op =~ /^or/) {
		$evalstr = "($val1)|($val2)";
	} elsif ($op =~ /^nor/) {
		$evalstr = "~(($val1)|($val2))";
	} elsif ($op =~ /^xor/) {
		$evalstr = "($val1)^($val2)";
	} elsif ($op =~ /^and/) {
		$evalstr = "($val1)&($val2)";
	} elsif ($op =~ /^shr/) {
		$val2 &= 0x1f;
		$evalstr = "($val1)>>($val2)";
	} elsif ($op =~ /^shl/) {
		$val2 &= 0x1f;
		$evalstr = "($val1)<<($val2)";
	} elsif ($op eq 'eq') {
		$evalstr = "($val1)==($val2)";
	} elsif ($op =~ /gts/) {
		$evalstr = "($val1)>($val2)";
	} elsif ($op =~ /gtu/) {
		# do a character-wise comparison of the strings
	 	for ($j=0; $j<10; $j++) {
			$tempchar1 = substr($val1, $j, 1);
			$tempchar2 = substr($val2, $j, 1);			
			$res = hexcomp($tempchar1, $tempchar2);
			if ($res == 1) {
				$reslow = 1;
				goto end_loop;
			} elsif ($res == 0) {
				$reslow = 0;
				goto end_loop;
			} else {
			}
		}			
		# default: they should be equal
		$reslow = 0;
		goto end_loop;
	} elsif ($op =~ /ges/) {
		$evalstr = "($val1)>=($val2)";
	} elsif ($op =~ /geu/) {
		# do a character-wise comparison of the strings
		for ($j=0; $j<10; $j++) {
                        $tempchar1 = substr($val1, $j, 1);
                        $tempchar2 = substr($val2, $j, 1);
                        $res = hexcomp($tempchar1, $tempchar2);
                        if ($res == 1) {
                                $reslow = 1;
                                goto end_loop;
                        } elsif ($res == 0) {
                                $reslow = 0;
                                goto end_loop;
                        } else {
                        }
                }
                # default: they are equal
                $reslow = 1;
		goto end_loop;
	}
	else {
		print STDERR "unknown OP $op\n";
	}

	$reslow = eval $evalstr;

end_loop:

	$reshigh = $reslow >> 32;
	$reslow &= 0xffffffff;
	if ($op =~ /shr(.?)/) {
		for ($i = 0; $i < $val2; $i++) {
			if ($1 eq 'u' or !($val1 & 0x80000000)) {
				$reslow &= ~(1 << (32 - $i - 1));
			} else {
				$reslow |= 1 << (32 - $i - 1) ;
			}
		}
	}
	(sprintf('0x%08x', $reshigh), sprintf('0x%08x', $reslow));
}

#constructs the code to load some value into a register, and records doing so
#arguments: value to load, reference to code, reference to expected values
#returns: (register loaded, lines added to code)
sub load_reg
{
	my $coderef;
	my $expref;
	my $val;
	my $reg;
	my $added;

	($val, $coderef, $expref) = @_;
	$val = hex($val) if $val =~ /^0x/;
	$val &= 0xffffffff; #this forces perl to interpret the number as signed

	$reg = $nextreg++;

	$added = ($val > $MAX16 or $val < $MIN16) ? 2 : 1;

	$val = sprintf('0x%08x', $val);
	${$coderef} .= "    lc r$reg, $val\n";
	${$expref} .= "#r$reg = $val\n";

	("r$reg", $added);
}

#constructs the code to load  a tlb entry, and records doing so
#arguments: top word, bottom word, reference to code, reference to expected values
#returns: lines added to code
sub load_tlb
{
	my $coderef;
	my $expref;
	my $top;
	my $bottom;
	my $reg;
	my $entry;
	my $tlb;
	my $added;
	my $junk;
	my $totaladded = 0;

	my $vpn;
	my $ppn;
	my $os;
	my $att;

	$tlb = $nexttlb++;

	($top, $bottom, $coderef, $expref) = @_;
	$nextreg++ if $nextreg % 2;

	($reg, $added) = load_reg($top, $coderef, $expref);
	$totaladded += $added;
	($junk, $added) = load_reg($bottom, $coderef, $expref);
	$totaladded += $added;
	($entry, $added) = load_reg($tlb, $coderef, $expref);
	$totaladded += $added;

	$top = hex($top) if $top =~ /^0x/;
	$bottom = hex($bottom) if $bottom =~ /^0x/;
	$vpn = sprintf("0x%05x", ($top & 0xfffff000) >> 12);
	$os = sprintf("0x%03x", $top & 0xfff);
	$ppn = sprintf("0x%05x", ($bottom & 0xfffff000) >> 12);
	$att = sprintf("0x%03x", $bottom & 0xfff);

	${$coderef} .= "    tlbse $entry, $reg\n";
	$totaladded++;

	${$expref} .= "#tlb $tlb:\n";
	${$expref} .= "#    vpn = $vpn\n";
	${$expref} .= "#    os = $os\n";
	${$expref} .= "#    ppn = $ppn\n";
	${$expref} .= "#    at = $att\n";

	$totaladded;
}

sub make_arith_tests
{
	my @instructions = keys(%inst);
	my $instruction;
	my $expval;
	my $code;
	my $reshigh;
	my $reslow;
	my $reg1;
	my $reg2;
	my $added;
	my $totaladded;
	my $val1;
	my $val2;
	my $testnum = 1;
	my $filename;
	my $flags;
	my $temp;
	my $temp1;
	my @valset;

	@instructions = sort @instructions;

	foreach $instruction (@instructions) {
		$testnum = 1;
		next if ($inst{$instruction} -> {$CATEGORY} !~ /^arith/);

		@valset = load_testvals($instruction);
	
		while ($#valset > -1) {
			$code = '';
			$expval = "\n#\@expected values\n";
			$totaladded = 0;
			$nextreg = 4;
			($val1, $val2, $flags) = @{pop(@valset)};
			my $temp2 = ($val2 =~ /^0x/) ? hex($val2) : $val2;

			if (($flags =~ /d/ and $instruction =~ /^div|^mod/) or
				($flags !~ /s/ and $instruction =~ /^sh/) or
				(($temp2 > $MAX8 or $temp2 < $MIN8) and $instruction =~ /io?\Z/)) {
				$testnum++;
				next;
			}
			($reshigh, $reslow) = compute_arith($instruction, $val1, $val2);
			($reg1, $added) = load_reg($val1, \$code, \$expval);
			$totaladded += $added;
			if ($instruction !~ /io?\Z/) {
				($reg2, $added) = load_reg($val2, \$code, \$expval);
				$totaladded += $added;
				$code .= "    $instruction r$nextreg, $reg1, $reg2\n";
				$totaladded++;
				$expval .= "#r$nextreg = $reslow\n";
			} else {
				$nextreg += 1 unless ($nextreg % 2 == 0);
				$code .= "    $instruction r$nextreg, $reg1, $val2\n";
				$totaladded++;
				$expval .= "#r$nextreg = $reslow\n";
			}
			$code .= "    halt\n";
			$nextreg++;
			$totaladded++;
			if ($instruction =~ /o$/ and $instruction !~ /^mul/) {
				$temp1 = ($val1 =~ /^0x/) ? hex($val1) : $val1;
				$temp = hex($reslow);
				$temp2 ^= 0x80000000 if $instruction =~ /^sub/;
				if (($temp1 & 0x80000000) and ($temp2 & 0x80000000) and (!($temp & 0x80000000))) {
					$reshigh = sprintf('0x%08x', -1);
				} elsif ((!($temp1 & 0x80000000)) and (!($temp2 & 0x80000000)) and ($temp & 0x80000000)) {
					$reshigh = sprintf('0x%08x', 1); 
				} else {
					$reshigh = 0;
				}
				$expval .= "#r$nextreg = $reshigh\n";
			}
			$nextreg++;

			$totaladded = 0x80000000 + $totaladded * 4;
			$expval .= "#pc = $totaladded\n";
			$expval .= "#e0 = 0\n";
			$expval .= "#e1 = 0\n";
			$expval .= "#e2 = 0\n";
			$expval .= "#e3 = 0\n";
			$filename = "arith/$instruction-null-super-arith-$testnum\.autotest\.asm";
			writeout($filename, $code.$expval);

			#make sure the operation commutes
			if ($testnum % 2) {
				if ($instruction !~ /^sh/ and $instruction !~ /io?\Z/) {
					push(@valset, [$val2, $val1, $flags]);
				} else {
					$testnum++;
				}
			}

			$testnum++;
		}
	}
}

sub make_comp_tests
{
	my @instructions = keys(%inst);
	my $instruction;
	my @valset;
	my $testnum;
	my $code;
	my $expval;
	my $added;
	my $val1;
	my $val2;
	my $flags;
	my $reg1;
	my $reg2;
	my $added;
	my $totaladded;
	my $reshigh;
	my $reslow;

	foreach $instruction (@instructions) {
		next if ($inst{$instruction} -> {$CATEGORY} !~ /^comp/);
		$testnum = 1;

		if ( ($instruction eq 'gtu') || ($instruction eq 'geu') ) {
			@valset = load_unsigned_testvals($instruction);
		} else {
			@valset = load_testvals($instruction);
		}
	
		while ($#valset > -1) {
			$totaladded = 0;
			$expval = "\n#\@expected values\n";
			$code = '';
			$nextreg = 4;

			($val1, $val2, $flags) = @{pop(@valset)};
			($reg1, $added) = load_reg($val1, \$code, \$expval);
			$totaladded += $added;
			($reg2, $added) = load_reg($val2, \$code, \$expval);
			$totaladded += $added;
			$code .= "    $instruction r$nextreg, $reg1, $reg2\n";
			$totaladded++;
			$code .= "    halt\n";
			$totaladded++;
		
			($reshigh, $reslow) = compute_arith($instruction, $val1, $val2);
			$expval .= "#r$nextreg = $reslow\n";
			$nextreg++;
			$totaladded = 0x80000000 + $totaladded * 4;
			$expval .= "#pc = $totaladded\n";
			$expval .= "#e0 = 0\n";
			$expval .= "#e1 = 0\n";
			$expval .= "#e2 = 0\n";
			$expval .= "#e3 = 0\n";
			writeout("comp/$instruction-null-super-comp-$testnum$EXTENSION", $code.$expval);
			
			#make sure the operation commutes
			if ($testnum % 2) {
				push(@valset, [$val2, $val1, $flags]);
			}
			
			$testnum++;
		}
	}
}

sub make_control_tests
{
	my @instructions = keys(%inst);
	my $instruction;
	my $expval;
	my $code;
	my $added;
	my $totaladded;
	my $testnum = 1;
	my $on_reg;
	my $abs_addr = 0x80000020;
	my $rel_addr = 4;
	my $abs_reg;
	my $rel_reg;
	my $oldpc = 'r10';
	my $oldpcval = 0x80000014;

	my $is_jumping = 0;
	my $is_immediate;
	my $wants_zero;
	my $is_relative;

	foreach $instruction (@instructions) {
		next if ($inst{$instruction} -> {$CATEGORY} !~ /^control/);
		$expval = "\n#\@expected values\n";
		$code = '';
		$nextreg = 4;
		$totaladded = 0;
		$is_jumping = ($is_jumping) ? 0 : 1; #flip is_jumping
		$is_immediate = ($instruction =~ /i$/);
		$wants_zero = ($instruction =~ /^[bj]e/);
		$is_relative = ($instruction =~ /^b/);

		($on_reg, $added) = load_reg(1, \$code, \$expval);
		$totaladded++;
		($rel_reg, $added) = load_reg($rel_addr * 4, \$code, \$expval);
		$totaladded++;
		($abs_reg, $added) = load_reg($abs_addr, \$code, \$expval);
		$totaladded += 2;

		if (($is_jumping and $wants_zero) or (!$is_jumping and !$wants_zero)) {
			if ($is_immediate) {
				$code .= "    $instruction r0, $rel_addr\n";
			} elsif ($is_relative) {
				$code .= "    $instruction $oldpc, r0, $rel_reg\n";
			} else {
				$code .= "    $instruction $oldpc, r0, $abs_reg\n";
			}
		} else {
			if ($is_immediate) {
				$code .= "    $instruction $on_reg, $rel_addr\n";
			} elsif ($is_relative) {
				$code .= "    $instruction $oldpc, $on_reg, $rel_reg\n";
			} else {
				$code .= "    $instruction $oldpc, $on_reg, $abs_reg\n";
			}
		}

		if ($is_jumping) {
			$code .= "    lc r$nextreg, 0xdeadbeef\n";
			$code .= "    halt\n";
			$nextreg++;
			load_reg(0xdeadbeef, \$code, \$expval);
			$code .= "    halt\n";
			$expval .= "#pc = 0x8000002c\n";
			unshift(@instructions, $instruction);
		} else {
			load_reg(0xdeadbeef, \$code, \$expval);
			$code .= "    halt\n";
			$code .= "    lc r$nextreg, 0xdeadbeef\n";
			$code .= "    halt\n";
			$nextreg++;
			$expval .= "#pc = $abs_addr\n";
		}
		writeout("control/$instruction-null-super-control-$testnum$EXTENSION", $code.$expval);
		$testnum = $testnum % 2 + 1;
	}
}

sub make_mem_tests
{
	my @instructions = keys(%inst);
	my $instruction;
	my $expval;
	my $code;
	my $added;
	my $totaladded;
	my $testnum;

	my $storedval;
	my $addr;
	my $offset;
	my $sourcereg;
	my $destreg = 'r30';
	my $addrreg;
	my $realaddrreg;
	my $temp;
	my @vals; 
	my $val_array_index;

	my $is_load;

	foreach $instruction (@instructions) {
		next if ($inst{$instruction} -> {$CATEGORY} !~ /^mem/);
		$is_load = ($instruction !~ /^s/) ;
		$testnum = 1;
		# test values: address, offset
		@vals =
			([0x0, 0],
			[0x1, 0],
			[0x2, 0],
			[0x3, 0],
			[0x40000000, 0],
			[0x40000001, 0],
			[0x40000002, 0],
			[0x40000003, 0],
			[0x80000000, 0],
			[0x80000001, 0],
			[0x80000002, 0],
			[0x80000003, 0],
			[0xc0000000, 0],
			[0xc0000001, 0],
			[0xc0000002, 0],
			[0xc0000003, 0],
			[0x3fffffff, 1],
			[0x3fffffff, 2],
			[0x7fffffff, 1],
			[0x7fffffff, 2],
			[0xbfffffff, 1],
			[0xbfffffff, 2]);
			 

		$val_array_index = 0;
		while ($#vals > -1) {
			$expval = "\n#\@expected values\n";
			$code = '';
			$nextreg = 4;
			$nexttlb = 0;
			$totaladded = 0;
			$storedval = '0xdeadbeef';
			($addr, $offset) = @{pop(@vals)};  

			# If the address is not aligned, generate this test only 
			# for ld1 or st1
			if (($addr + $offset) % 4 and $instruction =~ /^\w\w4/) {
				$testnum++;
				next;
			}

			# Load TLB entries (only used if address falls in seg 0)
			$totaladded += load_tlb(0x0, 0x101f, \$code, \$expval);
			$totaladded += load_tlb(0x40000000, 0x101f, \$code, \$expval);
			($sourcereg, $added) = load_reg($storedval, \$code, \$expval);
			$totaladded += $added;

			# Align if it is not a st1
			if ($instruction ne 'st1') {
				$temp = $addr - ($addr + $offset) % 4;  #align
			} else {
				$temp = $addr;
			}

			# The aligned address to be used for the st4 instruction
			($addrreg, $added) = load_reg($temp, \$code, \$expval);
			$totaladded += $added;

			# The original address to be used for other instruction - only 
			# unaligned if ld1...
			# ($realaddrreg, $added) = load_reg($addr, \$code, \$expval);
			($realaddrreg, $added) = load_reg($temp+$offset, \$code, \$expval);
			$totaladded += $added;
			
			$addr += $offset;
			#either direct map the address
			if ($addr & 0x80000000) {
				$addr &= 0x3fffffff;
			#or interpret it (I set everything to be mapped to physical page 1)
			} else {
				$addr &= 0x00000fff;
				$addr |= 0x00001000;
			}
			#ditto for the aligned address
			$temp += $offset;
			if ($temp & 0x80000000) {
				$temp &= 0x3fffffff;
			#or interpret it (I set everything to be mapped to physical page 1)
			} else {
				$temp &= 0x00000fff;
				$temp |= 0x00001000;
			}

			$addr = sprintf('0x%08x', $addr);

			# For ld and ex instructions, store the value to be loaded / exchanged
			# in memory
			if ($instruction ne 'st1') {
				# Maybe this should be a st1 for ld1 instructions
				$code .= "    st4 $sourcereg, $addrreg, $offset\n";
				expect_mem($temp, $storedval, \$expval) unless $instruction eq 'ex4';
			} else {
				# Otherwise it is a st1 test 
				$code .= "    st1 $sourcereg, $realaddrreg, $offset\n";
				$expval .= "#mem $addr = ";
				$expval .= substr($storedval, 8, 2);
				$expval .= "\n";
			}
			$totaladded++;
		
			# Do a load or exchange of the previously stored item with 
			# the $dest reg.  		
			if ($is_load) {
				if ($instruction eq 'ld1') {
					$code .= "    ld1 $destreg, $realaddrreg, $offset\n";
				} else {
					# This happens for ex4 and ld4
					$code .= "    $instruction $destreg, $addrreg, $offset\n";
				}
				$totaladded++;
			} elsif ($instruction eq 'ex4') {
				# This never happens because code at the beginning classifies
				# ex4 as $is_load
				($temp, $added) = load_reg(0xfadedfad, \$code, \$expval);
				$code .= "    ex4 $temp, $addrreg, $offset\n";
				$totaladded++;
				expect_mem($addr, '0xfadedfad', \$expval);
			}

			
			if ($instruction eq 'ld1') {
			 	$temp = 0xff << (3 - (hex($addr+$offset) % 4)) * 8;
			 	$storedval = hex($storedval) & $temp;
			 	$temp = (3 - (hex($addr+$offset) % 4)) * 8;
			 	$storedval = $storedval >> $temp;
			 	$storedval |= 0xffffff00 if $storedval & 0x80;
			 	$storedval = sprintf("0x%08x", $storedval);
			}
			$expval .= "#$destreg = $storedval\n" if $is_load;
			$code .= "    halt\n";
			$totaladded++;
			$totaladded = sprintf("0x%08x", 0x80000000 + $totaladded * 4);
			$expval .= "#pc = $totaladded\n";
			writeout("mem/$instruction-null-super-mem-$testnum$EXTENSION", $code.$expval);
			$testnum++;
			$val_array_index++;
		}
	}
}

sub make_constant_tests
{
	my $code;

	$code = "    lcl r5, 1\n";
	$code .= "    halt\n\n";
	$code .= "    #\@expected values\n";
	$code .= "#r5 = 1\n";
	$code .= "#pc = 0x80000008\n";
	$code .= "#e0 = 0\n";
	$code .= "#e3 = 0\n";

	writeout("constants/lcl-null-super-constant-1$EXTENSION", $code);

	$code = "    lcl r5, 0xff00\n";
	$code .= "    halt\n\n";
	$code .= "#\@expected values\n";
	$code .= "#r5 = 0xffffff00\n";
	$code .= "#pc = 0x80000008\n";
	$code .= "#e0 = 0\n";
	$code .= "#e3 = 0\n";

	writeout("constants/lcl-null-super-constant-2$EXTENSION", $code);

	$code = "    lcl r5, 0xffff\n";
	$code .= "    lcl r5, 1\n";
	$code .= "    halt\n\n";
	$code .= "#\@expected values\n";
	$code .= "#r5 = 1\n";
	$code .= "#pc = 0x8000000c\n";
	$code .= "#e0 = 0\n";
	$code .= "#e3 = 0\n";

	writeout("constants/lcl-null-super-constant-3$EXTENSION", $code);

	$code = "    lcl r5, 1\n";
	$code .= "    lcl r5, 0xffff\n";
	$code .= "    halt\n\n";
	$code .= "#\@expected values\n";
	$code .= "#r5 = 0xffffffff\n";
	$code .= "#pc = 0x8000000c\n";
	$code .= "#e0 = 0\n";
	$code .= "#e3 = 0\n";

	writeout("constants/lcl-null-super-constant-4$EXTENSION", $code);

	$code = "    lcl r5, 0xffff\n";
	$code .= "    lch r5, 0x1234\n";
	$code .= "    halt\n\n";
	$code .= "#\@expected values\n";
	$code .= "#r5 = 0x1234ffff\n";
	$code .= "#pc = 0x8000000c\n";
	$code .= "#e0 = 0\n";
	$code .= "#e3 = 0\n";

	writeout("constants/lch-null-super-constant-1$EXTENSION", $code);
}

#I'm going to leave it to the exception architecture tests to test rfe
sub make_special_tests
{
	my $expval;
	my $code;
	my $added;
	my $totaladded;
	my $reg;

	$totaladded = 0;
	$nextreg = 4;
	$code = '';
	$expval = "\n#\@expected values\n";

	($reg, $added) = load_reg("0x80000020", \$code, \$expval);
	$totaladded += $added;
	$code .= "    leh $reg\n";
	$code .= "    cle\n";
		
	#this better damn well be an exception
	$code .= "    div r0, r0, r0\n";
		
	$code .= "    lc r$nextreg, 0xdeadbeef\n";
	$nextreg++;
	$code .= "    halt\n";
	($reg, $added) = load_reg("0xdeadbeef", \$code, \$expval);
	$totaladded += $added;
	$code .= "    halt\n";
	$totaladded += 7;
	$expval .= "#pc = " . sprintf("0x%08x", 0x80000000 + $totaladded * 4) . "\n";
	$expval .= "#e0 = 0x80000010\n";
	$expval .= "#e3 = 0x00000071\n";
	writeout("special/leh-null-super-special-1$EXTENSION", $code.$expval);

	$code = "    cli\n";
	$code .= "    halt\n";
	$code .= "\n#\@expected values\n";
	$code .= "#pc = 0x80000008\n";
	$code .= "#interrupts = on\n";
	writeout("special/cli-null-super-special-1$EXTENSION", $code);
	
	$code = "    cli\n";
	$code .= "    sti\n";
	$code .= "    halt\n";
	$code .= "\n#\@expected values\n";
	$code .= "#pc = 0x8000000c\n";
	$code .= "#interrupts = off\n";
	writeout("special/sti-null-super-special-1$EXTENSION", $code);

	$code = "    cle\n";
	$code .= "    halt\n";
	$code .= "\n#\@expected values\n";
	$code .= "#pc = 0x80000008\n";
	$code .= "#exceptions = on\n";
	writeout("special/cle-null-super-special-1$EXTENSION", $code);

	$code = "    cle\n";
	$code .= "    ste\n";
	$code .= "    halt\n";
	$code .= "\n#\@expected values\n";
	$code .= "#pc = 0x8000000c\n";
	$code .= "#exceptions = off\n";
	writeout("special/ste-null-super-special-1$EXTENSION", $code);
}

sub make_init_tests
{
	my $code;
	my $i;
	my $NUM_TLBS = 64;
	my $NUM_REGS = 64;

	$code = "    halt\n";

	$code .= "\n#\@expected values\n";
	$code .= "#mode = super\n";
	$code .= "#exceptions = off\n";
	$code .= "#interrups = off\n";
	
	for ($i = 0; $i < $NUM_TLBS; $i++) {
		$code .= "#tlb $i:\n";
		$code .= "#    att = 0x008\n";
	}
	for ($i = 0; $i < $NUM_REGS; $i++) {
		$code .= "#r$i = 0\n";
	}
	$code .= "#k0 = 0\n";
	$code .= "#k1 = 0\n";
	$code .= "#k2 = 0\n";
	$code .= "#k3 = 0\n";
	
	writeout("special/halt-null-super-init-1$EXTENSION", $code);
}

sub make_info_tests
{
	my $i;
	my $code;

	for ($i = 0; $i < 10; $i++) {
		next if $i == 1 or $i == 4;
		$code = "    info r5, $i\n";
		$code .= "    halt\n";
		$code .= "\n#\@expected values\n";
		$code .= "#pc = 0x80000008\n";
		if ($i == 0) {
			$code .= "#r5 = 64\n";
		} elsif ($i == 2) {
			$code .= "#r5 = 32\n";
		} elsif ($i == 3) {
			$code .= "#r5 = 32\n";
		} elsif ($i == 5) {
			$code .= "#r5 = 0x000\n";
		} elsif ($i == 6) {
			$code .= "#r5 = 0\n";
		} elsif ($i == 7) {
			# CHANGE this one to 0x30100b, the new version
			$code .= "#r5 = 0x301000b\n";
		} elsif ($i == 8) {
			$code .= "#r5 = 0\n";
		} elsif ($i == 9) {
			$code .= "#r5 = 0\n";
		}

		writeout("special/info-null-super-info-$i$EXTENSION", $code);
	}
}

#loads a word into the expected values for memory
#this has to be done a byte at a time
#arguments: address, value, reference to expected values
sub expect_mem
{
	my $addr;
	my $val;
	my @valsplit;
	my $expref;

	($addr, $val, $expref) = @_;

	$val = hex($val) if $val =~ /^0x/;
	$addr = hex($addr) if $addr =~ /^0x/;

	$val = sprintf('%08x', $val);
	push(@valsplit, substr($val, 6, 2));
	push(@valsplit, substr($val, 4, 2));
	push(@valsplit, substr($val, 2, 2));
	push(@valsplit, substr($val, 0, 2));

	$addr = sprintf('0x%08x', $addr);

# changed here to pop instead of shift to generate expected mem contents in 
# other order... apparantly shift sometimes gives same order 
# we pushed them on the array so we get little endian

	while ($val = pop(@valsplit)) {
		${$expref} .= "#mem $addr = 0x$val\n";
		$addr = sprintf('0x%08x', hex($addr) + 1);
	}
}

#returns testvalues to use
#arguments: current instruction
sub load_testvals
{
	my @valset;
	my $instruction = shift;

	#last arg is flags
	#valid flags:
	#d: will create a div0 error
	#s: shiftable (suitable for shift instructions)
	push(@valset, ['0xffffffff', '-2', 0]);
	push(@valset, ['0x7fffffff', '-2', 0]);
	push(@valset, ['0x80000000', '2', 's']);
	push(@valset, ['1', '2', 's']);
	push(@valset, ['2', '-3', 0]);
	push(@valset, ['0xffffffff', '2', 's']);
	push(@valset, ['0x7fffffff', '2', 's']);
	push(@valset, ['0x80000000', '-2', 0]);
	push(@valset, ['1', '-2', 0]);
	push(@valset, ['2', '3', 's']);

	push(@valset, ['0x7ffffffe', '1', 's']);
	push(@valset, ['0x80000001', '-1', 0]);
	push(@valset, ['0x7fffffff', '257', 0]);
	push(@valset, ['0x80000000', '-357', 0]);
	push(@valset, ['0x7fffffff', '32571', 0]);
	push(@valset, ['0x80000000', '-32571', 0]);	
	push(@valset, ['0x7fffffff', '0x80000000', 0]);
	push(@valset, ['0x80000000', '0x7fffffff', 0]);
	push(@valset, ['0x80000000', '0x80000001', 0]);
	push(@valset, ['0x7fffffff', '0', 'ds']);
	push(@valset, ['0x80000000', '0', 'ds']);
	push(@valset, ['4253098', '1', 0]);
	push(@valset, ['81273', '0x00000080', 0]);
	push(@valset, ['109', '0x00008000', 0]);
	push(@valset, ['-12', '0x00800000', 0]);
	push(@valset, ['-243087', '0xffffff80', 0]);
	push(@valset, ['-1782', '0xffff8000', 0]);
	push(@valset, ['61', '0xff800000', 0]);
	push(@valset, ['0', '0', 'd']);
	
	@valset;
}

# Since there seem to be signed / unsigned problems, we have a separate function to
# load the testvals in unsigned hex form. Conversions don't seem to work otherwise
sub load_unsigned_testvals
{
        my @valset;
        my $instruction = shift;

        #last arg is flags
        #valid flags:
        #d: will create a div0 error
        #s: shiftable (suitable for shift instructions)
        push(@valset, ['0xffffffff', '0xfffffffe', 0]);
        push(@valset, ['0x7fffffff', '0xfffffffe', 0]);
        push(@valset, ['0x80000000', '0x00000002', 's']);
        push(@valset, ['0x00000001', '0x00000002', 's']);
        push(@valset, ['0x00000002', '0xfffffffd', 0]);
        push(@valset, ['0xffffffff', '0x00000002', 's']);
        push(@valset, ['0x7fffffff', '0x00000002', 's']);
        push(@valset, ['0x80000000', '0xfffffffe', 0]);
        push(@valset, ['0x00000001', '0xfffffffe', 0]);
        push(@valset, ['0x00000002', '0x00000003', 's']);

        push(@valset, ['0x7ffffffe', '0x00000001', 's']);
        push(@valset, ['0x80000001', '0xffffffff', 0]);
        push(@valset, ['0x7fffffff', '0x00000101', 0]);
        push(@valset, ['0x80000000', '0xfffffe9b', 0]);
        push(@valset, ['0x7fffffff', '0x00007f3b', 0]);
        push(@valset, ['0x80000000', '0xffff80c5', 0]);
        push(@valset, ['0x7fffffff', '0x80000000', 0]);
        push(@valset, ['0x80000000', '0x7fffffff', 0]);
        push(@valset, ['0x80000000', '0x80000001', 0]);
        push(@valset, ['0x7fffffff', '0x00000000', 'ds']);
        push(@valset, ['0x80000000', '0x00000000', 'ds']);
        push(@valset, ['0x0040e5aa', '0x00000001', 0]);
        push(@valset, ['0x00013d79', '0x00000080', 0]);
        push(@valset, ['0x0000006d', '0x00008000', 0]);
        push(@valset, ['0xfffffff4', '0x00800000', 0]);
        push(@valset, ['0xfffc4a71', '0xffffff80', 0]);
        push(@valset, ['0xfffff90a', '0xffff8000', 0]);
        push(@valset, ['0x0000003d', '0xff800000', 0]);
        push(@valset, ['0x00000000', '0x00000000', 'd']);

        @valset;

}

#create output file, record statistics
#arguments: filename, code
sub writeout
{
	my $filename;
	my $code;
	my $expected;

	($filename, $code) = @_;
	open(TESTFILE, ">$filename")
		or die "$0: Can't open $filename for output: $!\n";
	print "Generating file $filename...\n";
	print TESTFILE $code."\n";
	close(TESTFILE);
	$total_created++;
}
