#
# $Id: ant.tcl,v 1.9 2001/02/20 21:26:28 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# ant_run
#       The function that implements the action of simulating the "running"
#       of an ANT program.  This is really just a wrapper around
#       ant_run_loop, which does the hard work.  This procedure just sets
#       the INTERRUPTED flag to false, changes the "Run" button to "Stop",
#       and invokes ant_run_loop.  When ant_run_loop returns, sets the
#       "Stop" button to "Run", and we're really to roll again.

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

        reconfig_run_button "Run!"

        return $status
}

#
# If we're waiting for input, and this function is invoked,
# force the input to succeed immediately by just snarfing
# whatever value is sitting in the input channel's register.
#
 
proc force_input { } {

        set InputStr    "Waiting for input"

        if { [string compare [gantGetStatus] $InputStr] == 0 } {
                set iperiph [gantGetInstSrc iperiph]

                global in_hex_text
                global in_binary_text
                global in_ascii_text

                switch -- $iperiph {
                        0 {gantLatchIO $in_hex_text 16}
                        1 {gantLatchIO $in_binary_text 2}
                        2 {gantLatchIO $in_ascii_text ASCII}
                }
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
                           
        # set iperiph [gantGetInstSrc iperiph]
        # set operiph [gantGetInstSrc operiph]
        # set ovalue [gantGetInstSrc ovalue]  
                                            
        # highlight_periph in $iperiph      
                                    
        # click the ant forward one instruction...
                                                  
        gantExecSingleStep                        
                          
        # If the instruction produced any output, then push it out to
        # the output channels.  process_output doesn't really do     
        # anything unless there was output to process-- but it should
        # only be called ONCE per call to gantExecSingleStep.        
        # Otherwise, things might be copied to the output window more
        # than once, which looks very confusing.                     
                                                                     
        # process_output $operiph $ovalue         
                                       
        # On the other hand, if the instruction tried to do input,
        # then it probably isn't finished yet.  It's probably paused,
        # waiting for the user to type something.  So, even though   
        # gantExecSingleStep has returned, we're not ready for the   
        # next instruction until the user supplies some input (OR the
        # user forces the execution to move to the next instruction).
                                                                     
        set InputStr    "Waiting for input"                          
                                           
        if { [string compare [gantGetStatus] $InputStr] == 0 } {
                update_everything                               
                                                                
                # Enable the input registers...

		show_console
                                               
                while { [string compare [gantGetStatus] $InputStr] == 0 } {
                        after 250                                          
                        update                                             
                }                
        }                     
}                

                                                                        



#
# Proc: show_console, Show (I/O) Console
#
proc show_console {} {
	if [winfo exists .cONSOLE] {
  		wm 	deiconify .cONSOLE
  		raise 	.cONSOLE
	} else {
  		toplevel .cONSOLE
  		wm title .cONSOLE  "Console"

  		frame 	.cONSOLE.conTopF  -borderwidth 0 -class FakeFrame
  		pack 	.cONSOLE.conTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
 # 		button 	.cONSOLE.conTopF.button1  -padx 9 -pady 3 -text "Close Window" -command " exit # window_menu_minus \"Console\" \".CONSOLE\"	
 # 		pack 	.cONSOLE.conTopF.button1 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top

  		frame 	.cONSOLE.conDataF  -borderwidth 4 -class FakeFrame -relief groove
  		pack 	.cONSOLE.conDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

  		frame 	.cONSOLE.conDataF.conInF  -borderwidth 4 -class FakeFrame -relief groove
  		pack 	.cONSOLE.conDataF.conInF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  		label 	.cONSOLE.conDataF.conInF.conInL  -padx 0 -pady 0 -text "Input (ASCII):"
  		pack 	.cONSOLE.conDataF.conInF.conInL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 8 -side top
  		entry 	.cONSOLE.conDataF.conInF.conInE  -width 64 -textvariable in_ascii_text 
  		pack 	.cONSOLE.conDataF.conInF.conInE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 8 -side top
  		frame 	.cONSOLE.conDataF.conOutF  -borderwidth 4 -class FakeFrame -relief groove
  		pack 	.cONSOLE.conDataF.conOutF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
  		label 	.cONSOLE.conDataF.conOutF.conOutL  -padx 0 -pady 0 -text "Output (ASCII):"
  		pack 	.cONSOLE.conDataF.conOutF.conOutL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
  		text 	.cONSOLE.conDataF.conOutF.conOutT  -width 54 -height 24 -relief groove
  		pack 	.cONSOLE.conDataF.conOutF.conOutT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top

		bind .cONSOLE.conDataF.conInF.conInE <Return> {
        	        gantLatchIO $in_ascii_text
 	       	}


	}
	# window_menu_plus "Console" ".cONSOLE"
}


#
# append_to_output
#       - append the given string to the Output text box.  Set scrollbar
#                                                                       

proc append_to_output { str } {

        global .cONSOLE

        .cONSOLE.conDataF.conOutF.conOutT configure -state normal
        .cONSOLE.conDataF.conOutF.conOutT insert end $str
        .cONSOLE.conDataF.conOutF.conOutT see end
        .cONSOLE.conDataF.conOutF.conOutT configure -state disabled
}


       


