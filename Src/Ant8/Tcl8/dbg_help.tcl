#
# $Id: dbg_help.tcl,v 1.12 2001/01/02 15:30:05 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

# source edit.tcl

proc dbgh_init { window path } {

	set icon [image create photo -format GIF -file "$path/dbg2.gif"]

	global DBGH_TEXT_WIN
	global DBGH_MAP_WIN
	global DBGH_MSG_WIN
	global DBGH_MSG_WIN

	set DBGH_TOP_FRAME	"$window.t"
	set DBGH_BOT_FRAME	"$window.b"
	set DBGH_L_FRAME	"$DBGH_TOP_FRAME.l"
	set DBGH_R_FRAME	"$DBGH_TOP_FRAME.r"
	set DBGH_TEXT_WIN	"$DBGH_L_FRAME.text"
	set DBGH_MAP_WIN	"$DBGH_R_FRAME.map"
	set DBGH_MSG_WIN	"$DBGH_R_FRAME.msg"

	frame $DBGH_TOP_FRAME
	frame $DBGH_BOT_FRAME -borderwidth 6
	frame $DBGH_L_FRAME
	frame $DBGH_R_FRAME

	grid config $DBGH_TOP_FRAME -column 0 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $DBGH_BOT_FRAME -column 0 -row 1 \
			-columnspan 1 -rowspan 1 -sticky "snew" 

	grid config $DBGH_L_FRAME -column 0 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "snew" 
	grid config $DBGH_R_FRAME -column 1 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "snew" 

	text $DBGH_TEXT_WIN -relief sunken -bd 1 \
			-height 28 -width 50 \
			-wrap word \
			-yscrollcommand "$DBGH_L_FRAME.yscroll set"

	scrollbar $DBGH_L_FRAME.yscroll \
			-command {$DBGH_TEXT_WIN yview} -orient vertical

	$DBGH_TEXT_WIN insert end ""

	help_define_tags $DBGH_TEXT_WIN

	grid config $DBGH_L_FRAME.yscroll -column 0 -row 0 \
			-columnspan 1 -sticky snew
	grid config $DBGH_TEXT_WIN -column 1 -row 0 \
			-columnspan 1 -rowspan 1 -sticky snew

	label $DBGH_MAP_WIN -image $icon
	label $DBGH_MSG_WIN -text " " -borderwidth 4

	button $DBGH_BOT_FRAME.close -text \
			"Close This Window" -command { dbgh_help_close } \
			-default active

	grid $DBGH_BOT_FRAME.close

	grid config $DBGH_MSG_WIN -column 1 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "new" 
	grid config $DBGH_MAP_WIN -column 1 -row 1 \
			-columnspan 1 -rowspan 1 -sticky "new" 

	grid columnconfigure	$window 0 -weight 1
	grid rowconfigure	$window 0 -weight 1

	grid columnconfigure	$DBGH_TOP_FRAME 0 -weight 1
	grid rowconfigure	$DBGH_TOP_FRAME 0 -weight 1

	grid columnconfigure	$DBGH_L_FRAME 1 -weight 1
	grid rowconfigure	$DBGH_L_FRAME 0 -weight 1

	grid columnconfigure	$DBGH_TEXT_WIN 0 -weight 1
	grid rowconfigure	$DBGH_TEXT_WIN 0 -weight 1

	bind $DBGH_MAP_WIN <Motion>   { dbgh_balloon $DBGH_MAP_WIN %x %y in }
	bind $DBGH_MAP_WIN <Button-1> { dbgh_balloon $DBGH_MAP_WIN %x %y sel }

	# grid $window -sticky snew -columnspan 1 -rowspan 1

	global CURR_DBGH_TOPIC
	set CURR_DBGH_TOPIC ""

	dbgh_overview
}

proc dbgh_balloon { win x y mode } {

	global CURR_DBGH_TOPIC
	global DBGH_MSG_WIN

	# Print out the location, just for debugging purposes.
	# if { $mode == "sel" } {
	#	puts "$x  $y"
	# }

	set PREV_DBGH_TOPIC $CURR_DBGH_TOPIC

	if { 		[dbgh_inside $x $y   4   4  18  14 "File"] } {
	} elseif { 	[dbgh_inside $x $y  18   4  42  14 "Speed"] } {
	} elseif { 	[dbgh_inside $x $y 334   4 354  14 "Help"] } {

	} elseif { 	[dbgh_inside $x $y   4  20  36  30 "RunStop"] } {
	} elseif { 	[dbgh_inside $x $y  40  20  72  30 "Step"] } {
	} elseif { 	[dbgh_inside $x $y  76  20 108  30 "Reset"] } {
	} elseif { 	[dbgh_inside $x $y 112  20 170  30 "ClearBreaks"] } {
	} elseif { 	[dbgh_inside $x $y 174  20 204  30 "Edit"] } {

	} elseif { 	[dbgh_inside $x $y   8  40  48  49 "PC"] } {
	} elseif { 	[dbgh_inside $x $y   8  50 106  59 "IR"] } {
	} elseif { 	[dbgh_inside $x $y   8  60 106  69 "Status"] } {

	} elseif { 	[dbgh_inside $x $y   8  80  25 192 "SrcReg"] } {
	} elseif { 	[dbgh_inside $x $y  28  80 115 192 "Reg"] } {
	} elseif { 	[dbgh_inside $x $y 117  80 133 192 "DesReg"] } {

	} elseif { 	[dbgh_inside $x $y 158  52 345 158 "Inst"] } {
	} elseif { 	[dbgh_inside $x $y 141  50 156 158 "BreakPoints"] } {

	} elseif { 	[dbgh_inside $x $y 148 173 345 283 "Memory"] } {

	} elseif { 	[dbgh_inside $x $y   8 197 132 223 "Input"] } {
	} elseif { 	[dbgh_inside $x $y   8 228 132 285 "Output"] } {
	} else {
		set CURR_DBGH_TOPIC ""
	}

	set blurb [dbgh_getBlurb $CURR_DBGH_TOPIC $mode]

	if { $PREV_DBGH_TOPIC != $CURR_DBGH_TOPIC } {
		$DBGH_MSG_WIN configure -text $blurb
	}

}

proc dbgh_inside { x y ulx uly lrx lry msg } {

	global CURR_DBGH_TOPIC

	if { [expr $x >= $ulx] && [expr $x <= $lrx] && \
			[expr $y >= $uly] && [expr $y <= $lry] } {
		set CURR_DBGH_TOPIC $msg
		return true
	} else {
		return false
	}
}

proc dbgh_getBlurb { topic mode } {


	if	 { $topic == "File" } {
		dbgh_menubar $mode true
		return "File: Opens the File menu"
	} elseif { $topic == "Speed" } {
		dbgh_menubar $mode true
		return "Speed: Select the running speed"
	} elseif { $topic == "Help" } {
		dbgh_menubar $mode true
		return "Help: Opens the Help menu"
	} elseif { $topic == "RunStop" } {
		dbgh_buttonbar $mode true
		return "Run/Stop: Run the program (or stop a running program)"
	} elseif { $topic == "Step" } {
		dbgh_buttonbar $mode true
		return "Step: Execute a single instruction"
	} elseif { $topic == "Reset" } {
		dbgh_buttonbar $mode true
		return "Reset: Reset the Ant to its initial state"
	} elseif { $topic == "ClearBreaks" } {
		dbgh_buttonbar $mode true
		return "Clear Breaks: Clear all breakpoints"
	} elseif { $topic == "Edit" } {
		dbgh_buttonbar $mode true
		return "Edit: Bring up the editing window"
	} elseif { $topic == "PC" } {
		dbgh_status $mode true
		return "PC: Displays the current value of the program counter"
	} elseif { $topic == "IR" } {
		dbgh_status $mode true
		return "IR: Displays the current instruction"
	} elseif { $topic == "Status" } {
		dbgh_status $mode true
		return "Status: Displays the current processor status"
	} elseif { $topic == "SrcReg" } {
		dbgh_status $mode true
		return "Src: the source register(s) for the next instruction"
	} elseif { $topic == "Reg" } {
		dbgh_status $mode true
		return "Registers: displays the value of all the registers"
	} elseif { $topic == "DesReg" } {
		dbgh_status $mode true
		return "Des: the des register(s) for the next instruction"
	} elseif { $topic == "Inst" } {
		dbgh_memory $mode true
		return "Displays the instructions of the program."
	} elseif { $topic == "BreakPoints" } {
		dbgh_memory $mode true
		return "Breakpoints: add, remove and display breakpoints"
	} elseif { $topic == "Memory" } {
		dbgh_memory $mode true
		return "Displays the contents of memory, in Hex"
	} elseif { $topic == "Input" } {
		dbgh_input_output $mode true
		return "Input: the input channels"
	} elseif { $topic == "Output" } {
		dbgh_input_output $mode true
		return "Output: the output channels"
	} else	 {
		return ""
	}
}

#
# The Ant Debugger Help Window
#

proc dbgh_overview { } {
global DBGH_TEXT_WIN

$DBGH_TEXT_WIN config -state normal

$DBGH_TEXT_WIN delete 0.0 end

dbgh_msg big    "The Ant Debugger\n"
dbgh_msg plain	"\n"
dbgh_msg plain  "The Ant debugger is used to run or debug an Ant\
		program.  It displays the entire state of the\
		Ant machine, including the text of the program,\
		the contents of registers and memory, and I/O."
dbgh_msg plain  "\n\n"
dbgh_msg plain  "For more information about the debugger, move the\
		mouse over the screen map on the right side of\
		the screen, and click on any area for more\
		information."

$DBGH_TEXT_WIN config -state disabled

}

proc dbgh_menubar { mode clear } {
global DBGH_TEXT_WIN

if { $mode != "sel" } {
	return
}

$DBGH_TEXT_WIN config -state normal

if { $clear } {
	$DBGH_TEXT_WIN delete 0.0 end
}

dbgh_msg big    "Menus:\n"
dbgh_msg plain	"\n"

dbgh_msg plain	"The "
dbgh_msg bold	"File"
dbgh_msg plain	" menu is used to open, close, or save\
		a file, or exit the program."
dbgh_msg plain	"\n\n"

dbgh_msg plain	"The "
dbgh_msg bold   "Speed"
dbgh_msg plain  " menu controls the speed that the\
		display is updated when the program is running. \
		When the "
dbgh_msg bold	"Instantaneous"
dbgh_msg plain	" option is selected, the display is "
dbgh_msg italic	"not"
dbgh_msg plain	" updated when the processor is running."
dbgh_msg plain	"\n\n"

dbgh_msg plain	"The "
dbgh_msg bold	"Help"
dbgh_msg plain	" menu allows the user to choose a help screen."

$DBGH_TEXT_WIN config -state disabled

}

proc dbgh_buttonbar { mode clear } {
global DBGH_TEXT_WIN

if { $mode != "sel" } {
	return
}

$DBGH_TEXT_WIN config -state normal

if { $clear } {
	$DBGH_TEXT_WIN delete 0.0 end
}

dbgh_msg big    "Buttons:\n"
dbgh_msg plain	"\n"

dbgh_msg bold   "Run "
dbgh_msg plain  "executes the program without stopping. \
		Execution stops when the processor executes\
		a hlt instruction, an error occurs, or a\
		breakpoint is reached."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Step"
dbgh_msg plain  " executes the program one instruction\
		at a time.  The user must click the "
dbgh_msg bold	"Step"
dbgh_msg plain	" button in order to go to the next instruction."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Reset"
dbgh_msg plain  " brings the Program Counter back to zero\
		and clears memory so the program can be executed again."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Clear Breaks"
dbgh_msg plain  " is used to remove all breakpoints."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Edit "
dbgh_msg plain  "is used to raise or open the Ant Editor window."

$DBGH_TEXT_WIN config -state disabled

}

proc dbgh_status { mode clear } {
global DBGH_TEXT_WIN

if { $mode != "sel" } {
	return
}

$DBGH_TEXT_WIN config -state normal

if { $clear } {
	$DBGH_TEXT_WIN delete 0.0 end
}

dbgh_msg big    "Processor Status Display:\n"
dbgh_msg plain	"\n"
dbgh_msg italic "All information displayed in this area is read-only."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "PC"
dbgh_msg plain  " - the program counter."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "IR"
dbgh_msg plain  " - the instruction register."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Status"
dbgh_msg plain  " - the processor  status.  The process status \
		is either OK, Waiting for input, or Halted."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Registers"
dbgh_msg plain  " - shows the values of all the registers.\
		The values are displayed in hexadecimal, binary, and ASCII."
dbgh_msg plain	"\n\n"

dbgh_msg italic "The areas in the register window labeled "
dbgh_msg bold   "src:"
dbgh_msg italic " and "
dbgh_msg bold   "des:"
dbgh_msg italic " are highlighted when a register is used as a\
		source or destination for the next Ant instruction."

$DBGH_TEXT_WIN config -state disabled

}

proc dbgh_input_output { mode clear } {
global DBGH_TEXT_WIN

if { $mode != "sel" } {
	return
}

$DBGH_TEXT_WIN config -state normal

if { $clear } {
	$DBGH_TEXT_WIN delete 0.0 end
}

dbgh_msg big	"Input and Output:\n"
dbgh_msg plain	"\n"
dbgh_msg bold	"Input: "
dbgh_msg plain	"accepts user input in any of three modes: "
dbgh_msg bold   "hexadecimal, binary"
dbgh_msg plain  " or "
dbgh_msg bold   "ASCII."
dbgh_msg plain	"\n\n"
dbgh_msg italic "When an input value is required, the program\
		stops and waits for the user to type in a\
		value, followed by a <return>."
dbgh_msg plain	"\n\n"

dbgh_msg bold   "Output: "
dbgh_msg plain  "the output window displays the output from the program."

$DBGH_TEXT_WIN config -state disabled

}

proc dbgh_memory { mode clear } {
global DBGH_TEXT_WIN

if { $mode != "sel" } {
	return
}

$DBGH_TEXT_WIN config -state normal

if { $clear } {
	$DBGH_TEXT_WIN delete 0.0 end
}

dbgh_msg big	"Memory:\n"
dbgh_msg plain	"\n"
dbgh_msg bold   "Memory (values as instructions): "
dbgh_msg plain	"\n\n"
dbgh_msg plain  "A human-readable display of the program\
		currently loaded into the Ant.  Only the\
		instructions are shown in this window."
dbgh_msg plain	"\n\n"
dbgh_msg italic "Each instruction is highlighted when executed."
dbgh_msg plain	"\n\n"
dbgh_msg plain  "The column to the left is used to set or remove "
dbgh_msg bold	"breakpoints."
dbgh_msg plain  " Click in this column to set or remove a breakpoint."
dbgh_msg plain	"\n\n"
dbgh_msg bold   "Memory (values as hexadecimal): "
dbgh_msg plain	"\n\n"
dbgh_msg plain  "The complete contents of the Ant machines'\
		memory, displayed as hexadecimal, including\
		a copy of the Ant program and its data."
dbgh_msg plain	"\n\n"
dbgh_msg italic "Each memory location is highlighted in red\
		when it is read, and white when it is written."

$DBGH_TEXT_WIN config -state disabled

}


proc dbgh_msg {tag text} {

	global DBGH_TEXT_WIN

	$DBGH_TEXT_WIN insert insert $text $tag
}

proc dbgh_help_close { } {
	global HELP_D_BASENAME
	destroy $HELP_D_BASENAME
}

# dbgh_init "" "."
