#
# $Id: ant.tcl,v 1.4 2002/06/27 17:30:39 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

#
# ant_run
# 	The function that implements the action of simulating the "running"
# 	of an ANT program.  This is really just a wrapper around
# 	ant_run_loop, which does the hard work.  This procedure just sets
# 	the INTERRUPTED flag to false, changes the "Run" button to "Stop",
# 	and invokes ant_run_loop.  When ant_run_loop returns, sets the
# 	"Stop" button to "Run", and we're really to roll again.
#

proc ant_run { } {

	global StepPauseMilliSec
	global INTERRUPTED

	# initially, we assume that the execution hasn't been
	# interrupted.  It might have been in the past, but hasn't
	# been just now.  The user might interrupt this loop, however,
	# so we keep testing it over and over again.

	set INTERRUPTED 0

	reconfig_run_button "Stop"

	set status [ant_run_loop]

	reconfig_run_button "Run"

	return $status
}

#
# If we're waiting for input, and this function is invoked, force the
# input to succeed immediately by just pretending that the user typed
# a newline.
#
# &&& DJE This is not always intuitive.
#

proc force_input { } {

	set InputStr	"Waiting for input"

	if { [string compare [gantGetStatus] $InputStr] == 0 } {
		gantBufferInput "\n"
	}
}


#
# The ant_run_loop -- just runs the program, keeping an eye out for
# breakpoints or the user pressing the "Stop" button, or any bogus
# processor states (i.e.  a fault has been detected).
#

proc ant_run_loop { } {

	global INTERRUPTED
	global StepPauseMilliSec

	while { ! $INTERRUPTED } {

		ant_single_step

		if { $StepPauseMilliSec > 0 } {
			update_everything
			after $StepPauseMilliSec
		}

		set status [gantGetStatus]
		if {[string compare $status "OK"] != 0} {
			update_everything
			return $status
		}

		# We need to check whether we're at a breakpoint AFTER
		# executing the instruction, because otherwise we'll
		# never make any forward progress when we try to
		# restart after hitting a breakpoint.

		if { [gantGetBreakPoint [gantGetPC]] != 0 } {
			update_everything
			set pc [gantGetPC]
			return Break
		}
	}
}

#
# ant_single_step
#

proc ant_single_step { } {

	global HILITE_COLOR

	set iperiph [gantGetInstSrc iperiph]
	set operiph [gantGetInstSrc operiph]
	set ovalue [gantGetInstSrc ovalue]

	highlight_periph in $iperiph

	# click the ant forward one instruction...

	gantExecSingleStep

	# If the instruction produced any output, then push it out to
	# the output channels.  process_output doesn't really do
	# anything unless there was output to process-- but it should
	# only be called ONCE per call to gantExecSingleStep. 
	# Otherwise, things might be copied to the output window more
	# than once, which looks very confusing.

	process_output $operiph $ovalue

	# On the other hand, if the instruction tried to do input,
	# then it probably isn't finished yet.  It's probably paused,
	# waiting for the user to type something.  So, even though
	# gantExecSingleStep has returned, we're not ready for the
	# next instruction until the user supplies some input (OR the
	# user forces the execution to move to the next instruction).

	set InputStr	"Waiting for input"

	if { [string compare [gantGetStatus] $InputStr] == 0 } {
		update_everything

		# Enable the input registers...

		while { [string compare [gantGetStatus] $InputStr] == 0 } {
			after 250
			update
		}
	}
}

#
# process_output
#

proc process_output { operiph ovalue } {

	global out_binary_text
	global out_hex_text
	global out_ascii_text
	global HILITE_COLOR

	highlight_periph out $operiph

	if { $operiph == 0 } {
		set out_hex_text $ovalue
		append_to_output $out_hex_text
	} elseif { $operiph == 1 } {
		set out_binary_text $ovalue
		append_to_output $out_binary_text
	} elseif { $operiph == 2 } {
		set out_ascii_text $ovalue
		append_to_output $out_ascii_text
	} else {
		return
	}

}

#
# append_to_output
#	- append the given string to the console output.
#

proc append_to_output { str } {
	
	global IO_BASENAME

	consoleOutput $IO_BASENAME console $str
}

