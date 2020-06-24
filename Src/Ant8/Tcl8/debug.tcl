#
# $Id: debug.tcl,v 1.17 2002/06/27 17:30:39 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.


#
# do_reset
#	Callback for "Reset" button
#

proc do_reset {} {

	global IO_BASENAME

	global out_binary_text
	global out_hex_text
	global out_ascii_text

	# &&& If we're operating in standalone mode (and so we're
	# debugging a .ant file) then reload the .ant file. 
	# Otherwise, if we're part of the full IDE, then what we need
	# to do is reload the last assembled version.

	gantLoadLastGoodAnt

	consoleClearInput $IO_BASENAME console

	# DJE &&& Need to flush pending input

	set out_binary_text ""
	set out_hex_text ""
	set out_ascii_text ""

	update_everything
}

#
# tool_bar
#	Layout the toolbar of the main window
#

proc tool_bar {} {

	global StepPauseMilliSec
	global DEBUG_BASENAME

	set dtool $DEBUG_BASENAME.toolbar
	frame $dtool -bd 2 -relief groove

	## The buttons on the left-hand side of the toolbar
	## are 'Run', 'Step' and 'Continue'

	button $dtool.run \
		-padx 1 -pady 1 -width 8

	reconfig_run_button "Run"
	
	button $dtool.step -text "Step" \
		-padx 1 -pady 1 -width 8 \
		-command { force_step }

	button $dtool.reset -text "Reset" \
		-padx 1 -pady 1 -width 8 \
		-command { do_reset }

	button $dtool.clr_brks -text "Clear Breaks" \
		-padx 1 -pady 1 -width 16 \
		-command { clear_breaks }

	button $dtool.edit -text "Edit" \
		-padx 1 -pady 1 -width 8 \
		-command { show_edit }

	pack $dtool.run -side left -padx 2 -pady 2
	pack $dtool.step -side left -padx 2 -pady 2
	pack $dtool.reset -side left -padx 2 -pady 2
	pack $dtool.clr_brks -side left -padx 2 -pady 2
	pack $dtool.edit -side left -padx 2 -pady 2
}

#
# show_edit
#	show edit dialog
#

proc show_edit { } {

	global EDIT_BASENAME

	global DEBUGGER_ON_TOP
	set DEBUGGER_ON_TOP 0

	set edit_name [top_win_name $EDIT_BASENAME]


	if { [winfo exists $edit_name] != 0} {

		wm deiconify $edit_name
		raise $edit_name
		return

	}

	layout_edit
}

#
# force_step
#

proc force_step {} {

	# If the status is that we're waiting for input, don't wait
	# any more.  Just take whatever is sitting in the input box
	# and move forward.  (if we're not waiting for input, then
	# force_input doesn't do anything).

	force_input
	ant_single_step
	update_everything
}

#
# ir_frame
#	- Create the ir_frame.
#

proc ir_frame { } {

	global IR_BASENAME

	frame $IR_BASENAME

	##
	## Program counter frame
	##

	label $IR_BASENAME.pc_lab -text "PC:"

	text $IR_BASENAME.pc_text -relief sunken -bd 1 \
		-height 1 -width 4 -wrap none 

	##
	## Instruction frame
	##

	label $IR_BASENAME.inst_lab -text "IR:"

	text $IR_BASENAME.inst_text -relief sunken -bd 1 \
		-height 1 -width 20 -wrap none

	##
	## Status frame
	##

	label $IR_BASENAME.status_lab -text "Status:"

	text $IR_BASENAME.status_text -relief sunken -bd 1 \
		-height 1 -width 20 -wrap none



	grid config $IR_BASENAME.pc_lab -column 0 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "w" 
	grid config $IR_BASENAME.pc_text -column 1 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "w" 

	grid config $IR_BASENAME.inst_lab -column 0 -row 1 \
			-columnspan 1 -rowspan 1 -sticky "w" 
	grid config $IR_BASENAME.inst_text -column 1 -row 1 \
			-columnspan 1 -rowspan 1 -sticky "w" 

	grid config $IR_BASENAME.status_lab -column 0 -row 2 \
			-columnspan 1 -rowspan 1 -sticky "w" 
	grid config $IR_BASENAME.status_text -column 1 -row 2 \
			-columnspan 1 -rowspan 1 -sticky "w" 

}

#
# toggleBreakByTag
#	callback for the left mouse button over the "Breakpoints" area
#
# We've got a problem here; the mapping between the tag names and the
# the instruction addresses is a pain in the neck.  Sometimes we refer
# to one, sometimes the other.
#

proc toggleBreakByTag { tag_name } {

	global PROG_BASENAME
	global UNHILITE_COLOR
	global BREAK_COLOR

	set i [string range $tag_name 2 end]

	set addr [expr $i - 1]
	set addr [expr $addr * 2]

	set val [gantGetBreakPoint $addr]

	gantToggleBreakPoint $addr

	if {$val == 0} {
		update_line $PROG_BASENAME.breaks ">>" $i
		$PROG_BASENAME.breaks tag add br$i $i.0 $i.end
		$PROG_BASENAME.breaks tag configure $tag_name \
				-background $BREAK_COLOR
	} else {
		update_line $PROG_BASENAME.breaks "  " $i
		$PROG_BASENAME.breaks tag add br$i $i.0 $i.end
		$PROG_BASENAME.breaks tag configure $tag_name \
				-background $UNHILITE_COLOR
	}
}

proc setBreakByTag { tag_name val } {

	global PROG_BASENAME
	global UNHILITE_COLOR
	global BREAK_COLOR

	set i [string range $tag_name 2 end]

	set addr [expr $i - 1]
	set addr [expr $addr * 2]

	set cval [gantGetBreakPoint $addr]

	if { $val != $cval } {
		gantToggleBreakPoint $addr
	}

	# Whether or not the breakpoint needed toggling, just assume
	# the display is wrong and make it right.

	if {$val != 0} {
		update_line $PROG_BASENAME.breaks ">>" $i
		$PROG_BASENAME.breaks tag add br$i $i.0 $i.end
		$PROG_BASENAME.breaks tag configure $tag_name \
				-background $BREAK_COLOR
	} else {
		update_line $PROG_BASENAME.breaks "  " $i
		$PROG_BASENAME.breaks tag add br$i $i.0 $i.end
		$PROG_BASENAME.breaks tag configure $tag_name \
				-background $UNHILITE_COLOR
	}
}

#
# toggleBreakByAddr
#	toggle breakpoint at address
#

proc toggleBreakByAddr { addr } {

	set addr [expr  ($addr / 2) + 1]

	set tag [format "br%d" $addr]

	toggleBreakByTag $tag
}

proc setBreakByAddr { addr val } {

	set addr [expr  ($addr / 2) + 1]

	set tag [format "br%d" $addr]

	setBreakByTag $tag $val
}

#
# prog_frame
#	Layout the frame containing the ant code 
#

proc prog_frame { } {

	global PROG_BASENAME

	frame $PROG_BASENAME

	label $PROG_BASENAME.lab -text "Memory (values as instructions):"

	scrollbar $PROG_BASENAME.yscroll -orient vertical \
		-command [list bind_yview \
			[list $PROG_BASENAME.text $PROG_BASENAME.breaks]]


	text $PROG_BASENAME.breaks -relief sunken -bd 2 \
		-height 16 -width 2 -wrap none \
		-yscrollcommand [list $PROG_BASENAME.yscroll set ]
	text $PROG_BASENAME.text -relief sunken -bd 2 \
		-height 16 -width 50 -wrap none \
		-yscrollcommand [list $PROG_BASENAME.yscroll set ]

	set len [gantGetInstCount]

	for {set i 1} {$i <= $len} {incr i} {
		$PROG_BASENAME.breaks insert $i.0 "  "
		$PROG_BASENAME.breaks insert $i.end \n
		$PROG_BASENAME.breaks tag add br$i $i.0 $i.end

		$PROG_BASENAME.breaks tag bind br$i <Button-1> \
			"toggleBreakByTag br$i"
	} 

	$PROG_BASENAME.breaks configure -state disabled

	grid config $PROG_BASENAME.lab -column 0 -row 0 \
        	-columnspan 3 -rowspan 1 -sticky "snew" 
	grid config $PROG_BASENAME.breaks -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $PROG_BASENAME.text -column 1 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $PROG_BASENAME.yscroll -column 2 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 

}

#
# reg_frame
#	Layout the frame for the registers, PC and current instruction
#

proc reg_frame { } {
	
	global REG_BASENAME

	frame $REG_BASENAME

	##
	## Registers frame
	##

	label $REG_BASENAME.lab -text "Registers:"
	label $REG_BASENAME.src_lab -text "src:"
	label $REG_BASENAME.des_lab -text "des:"

	text $REG_BASENAME.src -relief sunken -bd 1 -height 16 \
		-width 4 -wrap none 
	text $REG_BASENAME.content -relief sunken -bd 2 -height 16 \
		-width 25 -wrap none 
	text $REG_BASENAME.des -relief sunken -bd 1 -height 16 \
		-width 4 -wrap none 

	for {set i 1} {$i <= 16} {incr i} {
		$REG_BASENAME.src insert $i.0 "    "
		$REG_BASENAME.src insert $i.end \n
		$REG_BASENAME.src tag add src$i $i.0 $i.end

		$REG_BASENAME.des insert $i.0 "    "
		$REG_BASENAME.des insert $i.end \n
		$REG_BASENAME.des tag add des$i $i.0 $i.end
	} 

	$REG_BASENAME.src configure -state disabled
	$REG_BASENAME.des configure -state disabled

	grid config $REG_BASENAME.src_lab -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $REG_BASENAME.lab -column 1 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $REG_BASENAME.des_lab -column 2 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew"

	grid config $REG_BASENAME.src -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $REG_BASENAME.content -column 1 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $REG_BASENAME.des -column 2 -row 1 \
        	-columnspan 3 -rowspan 1 -sticky "snew"

}

#
# periph_frame
# 	Layout the PERIPH frame
#

proc periph_frame { } {

	global PERIPH_BASENAME

	frame $PERIPH_BASENAME

	label $PERIPH_BASENAME.input_lab -text "Input"
	label $PERIPH_BASENAME.output_lab -text "Output"
	label $PERIPH_BASENAME.hex_lab -text "Hex"
	label $PERIPH_BASENAME.bin_lab -text "Binary"
	label $PERIPH_BASENAME.ascii_lab -text "ASCII"

	label $PERIPH_BASENAME.in_hex -relief sunken -width 8
	label $PERIPH_BASENAME.in_binary -relief sunken -width 8
	label $PERIPH_BASENAME.in_ascii -relief sunken -width 8

	global out_hex_text
	global out_binary_text
	global out_ascii_text

	entry $PERIPH_BASENAME.out_hex -relief sunken -width 8
	entry $PERIPH_BASENAME.out_binary -relief sunken -width 8
	entry $PERIPH_BASENAME.out_ascii -relief sunken -width 8

	grid config $PERIPH_BASENAME.input_lab -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.output_lab -column 0 -row 2 \
        	-columnspan 1 -rowspan 1 -sticky "snew"

	grid config $PERIPH_BASENAME.hex_lab -column 1 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.bin_lab -column 2 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.ascii_lab -column 3 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew"

	grid config $PERIPH_BASENAME.in_hex -column 1 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.in_binary -column 2 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.in_ascii -column 3 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew"

	grid config $PERIPH_BASENAME.out_hex -column 1 -row 2 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.out_binary -column 2 -row 2 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $PERIPH_BASENAME.out_ascii -column 3 -row 2 \
        	-columnspan 1 -rowspan 1 -sticky "snew"
}

#
# output_frame
# 	Layout the output frame
#

proc output_frame { } {

	global IO_BASENAME

	frame $IO_BASENAME

	label $IO_BASENAME.lab -text "Console:"

	consoleCreate $IO_BASENAME console 10 40

	grid config $IO_BASENAME.lab -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $IO_BASENAME.console -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 


}

#
# mem_frame
#	Layout the Memory frame of the main window
#

proc mem_frame { } {

	global MEM_BASENAME

	frame $MEM_BASENAME

	label $MEM_BASENAME.lab -text "Memory (values as hexadecimal):"

	text $MEM_BASENAME.mem -relief sunken -bd 2 \
		-height 16 -width 56 \
		-wrap none

	grid config $MEM_BASENAME.lab -column 0 -row 0 \
        	-columnspan 2 -rowspan 1 -sticky "snew" 
	grid config $MEM_BASENAME.mem -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 

	grid config $MEM_BASENAME -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 

}

#
# debug_frame
#	Layout the debug frame of the main window
#


proc debug_frame { } {

	global PROG_BASENAME
	global IR_BASENAME
	global REG_BASENAME
	global IO_BASENAME
	global MEM_BASENAME
	global PERIPH_BASENAME
	global DEBUG_BASENAME


	frame $DEBUG_BASENAME.main -bd 2 -relief groove

	frame $DEBUG_BASENAME.main.left
	frame $DEBUG_BASENAME.main.right

	set IR_BASENAME		$DEBUG_BASENAME.main.left.ir
	set REG_BASENAME	$DEBUG_BASENAME.main.left.reg
	set IO_BASENAME		$DEBUG_BASENAME.main.left.io
	set PERIPH_BASENAME	$DEBUG_BASENAME.main.left.periph
	set PROG_BASENAME	$DEBUG_BASENAME.main.right.prog
	set MEM_BASENAME	$DEBUG_BASENAME.main.right.memory

	prog_frame
	ir_frame
	reg_frame
	output_frame
	periph_frame
	mem_frame

	## Grid for the 2 main areas-- the left and right columns

	grid config $DEBUG_BASENAME.main.left -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "nw" -padx 10 -pady 3
	grid config $DEBUG_BASENAME.main.right -column 1 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "nw" -padx 10 -pady 3

	## The Grid for the left column.

	grid config $IR_BASENAME -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "nw" -pady 10
	grid config $REG_BASENAME -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "nw" 
	grid config $PERIPH_BASENAME -column 0 -row 2 \
        	-columnspan 1 -rowspan 1 -sticky "nw" 
	grid config $IO_BASENAME -column 0 -row 3 \
        	-columnspan 1 -rowspan 1 -sticky "nw" 

	## Grid for the rightmost columns

	grid config $PROG_BASENAME -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "nw" -padx 4 -pady 10
	grid config $MEM_BASENAME -column 0 -row 1 \
        	-columnspan 2 -rowspan 1 -sticky "nw" -padx 4 -pady 10

	## Set up grid for resizing.
	
	## Column 0 gets the extra space.
	grid columnconfigure $DEBUG_BASENAME.main 0 -weight 1

	## Row 2 (the main debug area) gets the extra space.
	grid rowconfigure $DEBUG_BASENAME.main 0 -weight 1

}

#
# debug_menu_bar
#	layout the menu bar on the debug window
#

proc debug_menu_bar { } {

	global DEBUG_BASENAME
	global SLOW_MILLI_SEC
	global MED_MILLI_SEC
	global FAST_MILLI_SEC
	global StepPauseMilliSec

	set dmenu $DEBUG_BASENAME.menubar
	frame $dmenu -bd 2 -relief raised

	## File menu

	menubutton $dmenu.file -text "File" 
	$dmenu.file \
		configure -menu $dmenu.file.menu

	menu $dmenu.file.menu -tearoff 0
	$dmenu.file.menu add command -label "New" \
		-command { do_dbg_new}
	$dmenu.file.menu add command -label "Open..." \
		-command { do_dbg_open }
	$dmenu.file.menu add separator
	$dmenu.file.menu add command -label "Save" \
		-command { do_save }
	$dmenu.file.menu add command -label "Save As..." \
		-command { do_save_as }
	$dmenu.file.menu add separator
	$dmenu.file.menu add command -label "Exit" \
		-command { do_exit }

	pack $dmenu.file -side left

	## Speed menu

	menubutton $dmenu.speed -text "Speed" -menu $dmenu.speed.menu
	set m [menu $dmenu.speed.menu -tearoff 0]

	$m add radio -label Slow -variable StepPauseMilliSec \
		-value $SLOW_MILLI_SEC
	$m add radio -label Medium -variable StepPauseMilliSec \
		-value $MED_MILLI_SEC
	$m add radio -label Fast -variable StepPauseMilliSec \
		-value $FAST_MILLI_SEC
	$m add radio -label Instantaneous -variable StepPauseMilliSec \
		-value 0

	set StepPauseMilliSec	$MED_MILLI_SEC

	pack $dmenu.speed -side left

	## Help menu

	menubutton $dmenu.help -text "Help" 
	$dmenu.help configure -menu $dmenu.help.menu

	menu $dmenu.help.menu -tearoff 0

        $dmenu.help.menu add command -label \
          "Editor Help" -command { show_help_edit}
        $dmenu.help.menu add command -label \
          "Debugger Help" -command { show_help_debug}
        $dmenu.help.menu add command -label \
          "Instructions (Quick Guide)" -command {show_help_instr}
        $dmenu.help.menu add separator
        $dmenu.help.menu add command -label \
          "About Ant" -command { show_help_about}



	pack $dmenu.help -side right

}

proc do_dbg_new { } {
	do_new
	show_edit
}

proc do_dbg_open { } {
	do_open
	do_assemble
}

#
# show_debug
#	Layout the entire window: menu_bar, tool_Bar, main area and 
#		status bar
#	Put everything in a grid
#

proc show_debug {} {

	global DEBUG_BASENAME

	global DEBUGGER_ON_TOP
	set DEBUGGER_ON_TOP 1

	set DEBUG_BASENAME .debug

	# If the debug window already exists, don't create it, just
	# raise it to the top where it can be seen.

	if { [winfo exists $DEBUG_BASENAME] != 0} {

		wm deiconify $DEBUG_BASENAME
		raise $DEBUG_BASENAME
		return
	}

	toplevel $DEBUG_BASENAME
	wm title $DEBUG_BASENAME "Ant Debugger"
	wm protocol $DEBUG_BASENAME WM_DELETE_WINDOW {
			do_exit
			exit
		}

	debug_menu_bar

	## Toolbar procedure
	
	tool_bar

	## Main Area

	debug_frame

	## Status Area
	
	# status_bar

	## Grid layout. All widgets are in the same column; and each
	## take up one row.
	##
	## Each widget is sticky to all four edges so that it expands to fit.

	grid config $DEBUG_BASENAME.menubar -column 0 -row 0 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $DEBUG_BASENAME.toolbar -column 0 -row 1 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $DEBUG_BASENAME.main    -column 0 -row 2 \
        	-columnspan 1 -rowspan 1 -sticky "snew" 

	## Set up grid for resizing.
	
	## Column 0 (the only one) gets the extra space.
	grid columnconfigure $DEBUG_BASENAME 0 -weight 1

	## Row 2 (the main debug area) gets the extra space.
	grid rowconfigure $DEBUG_BASENAME 2 -weight 1

	$DEBUG_BASENAME configure -height 550

	update_everything
}

#
# ant_stop
# 	The callback that is executed when the user presses the "Stop"
# 	button.
#

proc ant_stop { } {

	global INTERRUPTED

	set INTERRUPTED 1

	# If we were waiting for input, force the input to
	# succeed immediately.  (Otherwise, force_input has
	# no effect).

	force_input

}

#
# reconfig_run_button
# 	The "run/stop" button is either labelled "run" (if the processor is
# 	stopped) or "stop" (if the processor is running).  The callbacks for
# 	each label must agree...
#

proc reconfig_run_button { state } {

	global StepPauseMilliSec
	global INTERRUPTED
	global DEBUG_BASENAME

	set dtool $DEBUG_BASENAME.toolbar

	if { [string compare $state "Stop"] == 0 } {
		$dtool.run config -text "Stop"
		$dtool.run config -command { ant_stop }
	} else {
		$dtool.run config -text "Run "
		$dtool.run config -command { ant_run }
	}
}

#
# set_step_pause
# 	The callback for setting the execution speed.
#

proc set_step_pause { pause } {

	global StepPauseMilliSec

	set StepPauseMilliSec $pause
}


#
# clear_breaks
#	Clear the breakpoints.  Clear it on the gui, and call
#	to 'ad' to clear it in the debugger
#

proc clear_breaks {} {
	
	set bp_list [gantGetBreakPoints]

	foreach bp $bp_list {
		toggleBreakByAddr $bp
	}

	update_everything
}

#
# update_everything - update the entire screen; make sure that what is
# displayed accurately reflects what the ANT is up to.
#

proc update_everything {} {

	global IR_BASENAME
	global REG_BASENAME
	global PROG_BASENAME
	global DEBUG_BASENAME

	if { [info exists REG_BASENAME] == 0 } {
		return
	}

	## Update the content of the registers

	$REG_BASENAME.content configure -state normal
	$REG_BASENAME.content delete 0.0 end
	for {set i 0} {$i < 16} {incr i} {
		set new_regs [gantGetReg r$i]
		$REG_BASENAME.content insert end $new_regs
		$REG_BASENAME.content insert end \n
	}
	$REG_BASENAME.content configure -state disabled

	## Update the PC

	set new_pc [gantGetPC]
	set line [expr ($new_pc / 2) + 1]
	set new_inst [gantGetInst $new_pc]

	update_text $IR_BASENAME.pc_text [format "0x%.2x" $new_pc]
	update_text $IR_BASENAME.inst_text $new_inst

	set status [gantGetStatus]

	update_text $IR_BASENAME.status_text $status

	global PROG_BASENAME
	global MEM_BASENAME

	## Update dis-assembled memory

	set all_inst [gantDisasmInst]
	# chop off any extraneous newline
	regsub "\n$" $all_inst "" all_inst
	$PROG_BASENAME.text configure -state normal
	$PROG_BASENAME.text delete 0.0 end
	$PROG_BASENAME.text insert 1.0 $all_inst
	$PROG_BASENAME.text configure -state disabled

        set len [gantGetInstCount]

        for {set i 1} {$i <= $len} {incr i} {
                $PROG_BASENAME.text tag add inst$i $i.0 $i.end
        }

	# See ab entry 35 for information about this hack. -DJE

	$PROG_BASENAME.breaks configure -state normal
	$PROG_BASENAME.breaks delete 0.0 end

	for {set i 1} {$i <= $len} {incr i} {
		$PROG_BASENAME.breaks insert $i.0 "  "
		if {$i != $len} {
			$PROG_BASENAME.breaks insert $i.end \n
		}
		$PROG_BASENAME.breaks tag add br$i $i.0 $i.end

		$PROG_BASENAME.breaks tag bind br$i <Button-1> \
			"toggleBreakByTag br$i"
	} 

	$PROG_BASENAME.breaks configure -state disabled

	set bp_list [gantGetBreakPoints]

	foreach bp $bp_list {
		setBreakByAddr $bp 1
	}

	## Update memory

	set all_data [gantDisasmData]

	$MEM_BASENAME.mem configure -state normal
	$MEM_BASENAME.mem delete 0.0 end
	$MEM_BASENAME.mem insert end $all_data
	$MEM_BASENAME.mem configure -state disabled

	update_highlights

	## Scroll Instruction window if necessary

	global INST_TOP

	if {$line <= $INST_TOP} {
		set INST_TOP [expr $line - 1]
	} elseif {$line >= [expr $INST_TOP + 16]} {
		set INST_TOP [expr $line - 16]
	}
	$PROG_BASENAME.text yview $INST_TOP
	$PROG_BASENAME.breaks yview $INST_TOP

	# If we're on windows, deal with the strange problem
	# of mysteriously raising and lowering screens by making
	# sure the right window is on top, no matter what else
	# happens.  This is a hack!  &&&

	global tcl_platform
	global DEBUGGER_ON_TOP
	if { [array get tcl_platform platform] == "platform windows" } {

		if { $DEBUGGER_ON_TOP != 0 } {
			raise $DEBUG_BASENAME
		}
	}

	# Flush tk; make the screen look right.
	update

}


#
# unhighlight_highlights
#	- unhighlights src, des, read mem addr, write mem addr,
#	  periph i/o
#	- inefficient, but easy first pass
#

proc unhighlight_highlights {} {

	global UNHILITE_COLOR

	for {set i 1} {$i <= 16} {incr i} {
		update_src_des_highlights src $i $UNHILITE_COLOR "    "
		update_src_des_highlights des $i $UNHILITE_COLOR "    "
	}

	update_mem_highlights 0 0 0 $UNHILITE_COLOR off
}

#
# update_src_des_highlights
#	- updates highlights of src and des areas
#

proc update_src_des_highlights { place line color str} {

	global REG_BASENAME

	$REG_BASENAME.$place configure -state normal
	update_line $REG_BASENAME.$place $str $line
	$REG_BASENAME.$place tag add $place$line $line.0 $line.end
	$REG_BASENAME.$place tag configure $place$line -background $color
	$REG_BASENAME.$place configure -state disabled
}

#
# update_mem_highlights
#	- updates highlights in memory
#

proc update_mem_highlights { line st_col end_col color state } {

	global MEM_BASENAME

	$MEM_BASENAME.mem configure -state normal
	if {[string compare $state on] == 0} {
		$MEM_BASENAME.mem tag add highlights $line.$st_col $line.$end_col
		$MEM_BASENAME.mem tag configure highlights -background $color
	} else {
		$MEM_BASENAME.mem tag configure highlights -background $color
		$MEM_BASENAME.mem tag delete highlights
	}
	$MEM_BASENAME.mem configure -state disabled
}

#
# update_periph
#	- highlights input and output periph area.
#

proc update_periph { io box color state } {

	global PERIPH_BASENAME

	set b _hex

	switch -- $box {
		0 {eval {set b _hex}}
		1 {eval {set b _binary}}
		2 {eval {set b _ascii}}
	}
	$PERIPH_BASENAME.$io$b configure -background $color
}

#
# update_highlights
#	- highlights src, des, read mem addr, write mem addr,
#	  periph i/o
#

proc update_highlights {} {

	global MEM_BASENAME
	global REG_BASENAME
	global HILITE_COLOR
	global HILITE_READ_COLOR
	global HILITE_WRITE_COLOR

	unhighlight_highlights

	set highlight_str "<<--"

	set src1  [gantGetInstSrc src1]
	set src2  [gantGetInstSrc src2]
	set src3  [gantGetInstSrc src3]
	set des   [gantGetInstSrc des]
	set waddr [gantGetInstSrc waddr]
	set raddr [gantGetInstSrc raddr]

	if {[expr $src1] != -1} {
		set line [expr $src1 + 1]
		update_src_des_highlights src $line $HILITE_COLOR $highlight_str
	}
	if {[expr $src2] != -1} {
		set line [expr $src2 + 1]
		update_src_des_highlights src $line $HILITE_COLOR $highlight_str
	}
	if {[expr $src3] != -1} {
		set line [expr $src3 + 1]
		update_src_des_highlights src $line $HILITE_COLOR $highlight_str
	}
	if {[expr $des] != -1} {
		set line [expr $des + 1]
		update_src_des_highlights des $line $HILITE_COLOR $highlight_str
	}
	if {[expr $waddr] != -1} {
		set line [expr $waddr / 16 + 1]
		set st_col [expr (($waddr % 16) * 3) + 7]
		set en_col [expr $st_col + 2]
		update_mem_highlights $line $st_col $en_col $HILITE_WRITE_COLOR on
	}
	if {[expr $raddr] != -1} {
		set line [expr $raddr / 16 + 1]
		set st_col [expr (($raddr % 16) * 3) + 7]
		set en_col [expr $st_col + 2]
		update_mem_highlights $line $st_col $en_col $HILITE_READ_COLOR on
	}

	set new_pc [gantGetPC]
	set line [expr ($new_pc / 2) + 1]

	unhighlight_inst
	highlight_inst $line
}

#
# highlight_periph
#	highlight the given periph
#

proc highlight_periph { direction periph } {

	global UNHILITE_COLOR
	global HILITE_COLOR

	update_periph $direction 0 $UNHILITE_COLOR idle
	update_periph $direction 1 $UNHILITE_COLOR idle
	update_periph $direction 2 $UNHILITE_COLOR idle

	if { $periph != -1} {
		if { [string compare $direction "in"] == 0 } {
			update_periph in $periph $HILITE_COLOR active
		} else {
			update_periph out $periph $HILITE_COLOR idle
		}
	}
}

#
# unhighlight_inst
#	- unhighlights all the instruction lines
#	- inefficient, but easy first pass
#

proc unhighlight_inst {} {

	global PROG_BASENAME
	global UNHILITE_COLOR

	set len [gantGetInstCount]

	for {set i 1} {$i <= $len} {incr i} {
		$PROG_BASENAME.text tag configure inst$i \
				-background $UNHILITE_COLOR
	} 
}

#
# highlight_inst
#	- highlights the instruction line passed to it
#

proc highlight_inst {line} {

	global PROG_BASENAME

	$PROG_BASENAME.text tag configure inst$line -background white
}

