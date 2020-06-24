#!/usr/bin/perl

package antstuff;
my $MAXTOCLEAN = 100;

#which tests we can run
#format: tests{instruction name} -> [array containing modes to run in]
%tests = 
            ('kreg', ['user'],              #read/write to kernel in user mode
             'ereg', ['super', 'user'],     #write to e-registers in either mode
#            'cycle', ['super', 'user'],    #read/write to cycle counters and make sure _doesn't_ generate exception in either mode
             'align', ['super'],            #alignment error (mem instructions)
             'memseg', ['user'],            #priviledged memory segment
             'regpar', ['super'],           #even register
#            'reginv', ['super'],           #invalid register
             'priv', ['user'],              #priviledged opcode
             'bus', ['super'],              #bus error
             'div0', ['super'],             #divide by 0
             'tlb', ['user'],				#tlb test suite
			 'arith', ['super'],			#arithmetic tests
			 'comp', ['super'],				#comparison tests
			 'control', ['super'],			#control tests
			 'mem', ['super'],				#memory instruction tests
			 'constant', ['super'],			#constant loading tests
			 'special', ['super'],			#supervisor mode tests
			 'init', ['super'],				#initialization tests (halt used)
			 'info', ['super']);			#tests info instruction

#cleans a specific set of files matching $matchexp
#arguments: directory to start recursing at, regex expression to match
sub main'clean_files
{
    my @dirs = ();
    my ($curdir, $matchexp) = @_;
    my $todel;
    my $entry;
    my $dir;
	my $cleaned;

    my $toeval;

    return 0 unless $matchexp;
    opendir(CURDIR, $curdir) or die "Couldn't open $curdir: $!\n";
    my @contents = readdir(CURDIR);
    closedir(CURDIR);

    print "Cleaning $curdir ...\n";

	$cleaned = 0;
    foreach $entry (@contents) {
        if (-d $entry) {
            push(@dirs, $entry) unless $entry eq '.' or $entry eq '..';
        } elsif ($entry =~ /$matchexp/) {
            $todel .= "$curdir/$entry ";
			$cleaned++;
        }
		if ($cleaned > $MAXTOCLEAN) {
			`/usr/bin/rm -f $todel`;
			$todel = '';
			$cleaned = 0;
		}
    }

    `/usr/bin/rm -f $todel` if length($todel);

    foreach $dir (@dirs) {
        main::clean_files($curdir . "/$dir", $matchexp);
    }
}

sub main'scan_flags
{
    my %flags;
    my $thisflag;
    my $thisarg;
    my @dirs;

    @dirs = get_dirs();
    
    while ($#ARGV >= 0) {
        if ($ARGV[0] =~ /^-(\w)/) {
            $thisflag = $1;
            shift(@ARGV);
            $flags{$thisflag} = [];
            while ($#ARGV >= 0) {
                if ($ARGV[0] =~ /^-\w/ or 
                    ($thisflag eq 'e' and !grep(/$ARGV[0]/, @dirs)) or 
                    ($thisflag eq 't' and !grep(/$ARGV[0]/, keys(%tests))) or 
                    ($thisflag eq 'c') or
                    ($thisflag eq 'i') or
                    (($flag eq 'a' or $flag eq 'v') and ${$flags{$thisflag}} == 0)) {
                    last;
                } else {
                    push(@{$flags{$thisflag}}, $ARGV[0]);
                    shift(@ARGV);
                }
            }
        } else {
            last;
        }
    }

    %flags;
}

sub main'print_flags
{
    print "Supported flags:\n";
    print "-e (list of one or more directories): \n\tdirectories at which this utility should start recursing\n";
    print "-t (list of tests): list of tests that should be run/checked by this utility\n";
    print "-c: clean files created by this utility\n";
    print "-a (assembler): use program \"assembler\" to assemble programs\n";
    print "-v (virtual machine): use program \"virtual machine\" to run programs\n";
    print "-i: this message\n";
    print "\nException Tests:\n\n";
    print "kreg: read/write to kernel registers in user mode\n";
    print "ereg: write to error registers in either mode\n";
#   print "cycle: read/write to cycle counters in either mode (make sure doesn't generate an exception)\n";
    print "align: alignment error (memory instructions)\n";
    print "memseg: priviledged memory segment\n";
    print "regpar: even register instructions\n";
    print "priv: priviledged opcode\n";
    print "bus: bus error\n";
    print "div0: divide by 0\n";
	print "\ntlb: assortment of tlb tests\n";
	print "\nFunctionality tests:\n\n";
	print "arith: arithmetic operation tests\n";
	print "comp: comparison tests\n";
	print "control: control instruction tests\n";
	print "mem: memory instruction tests\n";
	print "constant: test constant loading instructions\n";
	print "special: supervisor mode instruction tests\n";
	print "init: initialization test (make sure VM has correct init values)\n";
	print "info: tests info instruction\n";
}

sub get_dirs
{
    my @dirs;
    my @items;

    opendir(ANTSTUFFDIR, '.') or return 0;
    @items = readdir(ANTSTUFFDIR);
    foreach (@items) {
        push (@dirs, $_) if -d $_;
    }
    @dirs;
}
1;