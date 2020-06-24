#
# $Id: quick_ref.tcl,v 1.7 2001/01/02 15:30:06 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

# source edit.tcl

proc instr_init { window path } {

	global INSTR_TEXT_WIN
	global INSTR_MAP_WIN
	global INSTR_MSG_WIN
#	global INSTR_MSG_WIN

	set INSTR_TOP_FRAME	"$window.t"
	set INSTR_BOT_FRAME	"$window.b"
 	set INSTR_L_FRAME	"$INSTR_TOP_FRAME.l"
 	set INSTR_R_FRAME	"$INSTR_TOP_FRAME.r"
 	set INSTR_TEXT_WIN	"$INSTR_L_FRAME.text"
 	set INSTR_MAP_WIN	"$INSTR_R_FRAME.map"
 	set INSTR_MSG_WIN	"$INSTR_R_FRAME.msg"

	frame $INSTR_TOP_FRAME
	frame $INSTR_BOT_FRAME -borderwidth 6
	frame $INSTR_L_FRAME
	frame $INSTR_R_FRAME

	grid config $INSTR_TOP_FRAME -column 0 -row 0 \
 			-columnspan 1 -rowspan 1 -sticky "snew" 
 	grid config $INSTR_BOT_FRAME -column 0 -row 1 \
 			-columnspan 1 -rowspan 1 -sticky "snew" 
 
 	grid config $INSTR_L_FRAME -column 0 -row 0 \
 			-columnspan 1 -rowspan 1 -sticky "snew" 
 	grid config $INSTR_R_FRAME -column 1 -row 0 \
 			-columnspan 1 -rowspan 1 -sticky "snew" 
 
 	text $INSTR_TEXT_WIN -relief sunken -bd 1 \
 			-height 28 -width 70 \
 			-wrap word \
			-yscrollcommand "$INSTR_L_FRAME.yscroll set"

	scrollbar $INSTR_L_FRAME.yscroll \
			-command {$INSTR_TEXT_WIN yview} -orient vertical

	$INSTR_TEXT_WIN insert end ""

	help_define_tags $INSTR_TEXT_WIN

	grid config $INSTR_L_FRAME.yscroll -column 0 -row 0 \
			-columnspan 1 -sticky snew
	grid config $INSTR_TEXT_WIN -column 1 -row 0 \
			-columnspan 1 -rowspan 1 -sticky snew

#	label $INSTR_MAP_WIN -image $icon

   text $INSTR_MAP_WIN -wrap none -height 37 -width 28
 
# text $INSTR_MAP_WIN -relief sunken -bd 1 \
#      -height 32 -width 28 \
#      -wrap none \
#      -yscrollcommand "$INSTR_L_FRAME.yscroll set"

	help_define_tags $INSTR_MAP_WIN
	# help_define_tags $INSTR_MSG_WIN

	instr_msg big "Ant Instructions\n\n"

	#
	# Arithmetic Instructions: add, sub, mul
	#

	write_help_instr2 "add  " "des, src1, src2"	add "add: addition" arith_instr
	write_help_instr2 "sub  " "des, src1, src2"	sub "sub: subtraction" arith_instr
	write_help_instr2 "mul  " "des, src1, src2"	mul "mul: multiplication" arith_instr
	$INSTR_MAP_WIN insert insert "\n"

	write_help_instr2 "and  " "des, src1, src2"	and "and: bitwise logical AND" bit_instr
	write_help_instr2 "nor  " "des, src1, src2"	nor "nor: bitwise logical NOR" bit_instr
	write_help_instr2 "shf  " "des, src1, src2"	shf "mul: multiplication" bit_instr
	$INSTR_MAP_WIN insert insert "\n"

	write_help_instr2 "bgt  " "reg, src1, src2"	bgt "bgt: branch on greater than" branch_instr
	write_help_instr2 "beq  " "reg, src1, src2"	beq "beq: branch on equal" branch_instr
	write_help_instr2 "jmp  " "const8"		jmp "jmp: unconditional branch" branch_instr
	$INSTR_MAP_WIN insert insert "\n"

	write_help_instr2 "ld1  " "des, src1, const4"	ld1 "ld1: load one byte" ldstr_instr
	write_help_instr2 "st1  " "des, src1, const4"	st1 "st1: store one byte" ldstr_instr
	$INSTR_MAP_WIN insert insert "\n"

	write_help_instr2 "lc   " "des, const8"		lc  "lc: load constant" const_instr
	write_help_instr2 "inc  " "des, const8"		inc "inc: increment" const_instr
	$INSTR_MAP_WIN insert insert "\n"

	write_help_instr2 "in   " "des, const4"		in  "in: input" other_instr
	write_help_instr2 "out  " "src1, const4"	out "out: output" other_instr
	write_help_instr2 "hlt  " "const8"		hlt "hlt: halt processor" other_instr

	$INSTR_MAP_WIN config -state disabled

	label $INSTR_MSG_WIN -text " " -borderwidth 4

	button $INSTR_BOT_FRAME.close -text \
			"Close This Window" -command { instr_help_close } \
			-default active

	grid $INSTR_BOT_FRAME.close

	grid config $INSTR_MSG_WIN -column 1 -row 0 \
			-columnspan 1 -rowspan 1 -sticky "news" 
	grid config $INSTR_MAP_WIN -column 1 -row 1 \
			-columnspan 1 -rowspan 1 -sticky "news" 

	grid columnconfigure	$window 0 -weight 1
	grid rowconfigure	$window 0 -weight 1

	grid columnconfigure	$INSTR_TOP_FRAME 0 -weight 1
	grid rowconfigure	$INSTR_TOP_FRAME 0 -weight 1

	grid columnconfigure	$INSTR_L_FRAME 1 -weight 1
	grid rowconfigure	$INSTR_L_FRAME 0 -weight 1

	grid columnconfigure	$INSTR_TEXT_WIN 0 -weight 1
	grid rowconfigure	$INSTR_TEXT_WIN 0 -weight 1



	# grid $window -sticky snew -columnspan 1 -rowspan 1

	global CURR_INSTR_TOPIC
	set CURR_INSTR_TOPIC ""

	instr_overview
}

#
# The Ant Debugger Help Window
#

proc instr_overview { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal

	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg big    "The Ant Instruction Set\n"
	instr_msg plain	"\n"
	instr_msg plain  "Move the mouse over the instructions on the\
		right side of this window, and click on any instruction\
		for further details."

	$INSTR_TEXT_WIN config -state disabled
}

proc arith_instr { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal
	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg bold   "Arithmetic Instructions\n"

	instr_msg bold    "\n"
	instr_msg bold	  "Addition:          add  "
	instr_msg italic  "des, src1, src2"
	instr_msg plain   "\n\n"
	instr_msg plain   "The sum of the contents of registers "
	instr_msg italic  "src1"
	instr_msg plain   " and "
	instr_msg italic  "src2"
	instr_msg plain   " is stored in the "
	instr_msg italic  "des"
	instr_msg plain   " register.\n"
	instr_msg plain   "If the result is greater than 127,\
			then 1 is stored in register "
	instr_msg italic  "r1. "
	instr_msg plain   "If the result is less than -128,\
			then -1 is stored in register "
	instr_msg italic  "r1. "
	instr_msg plain   "Otherwise, 0 is stored in register "
	instr_msg italic  "r1.\n"

	instr_msg bold	  "\n"
	instr_msg bold	  "Subtraction:       sub  "
	instr_msg italic  "des, src1, src2"
	instr_msg plain   "\n\n"
	instr_msg plain   "The difference of the contents of registers "
	instr_msg italic  "src1"
	instr_msg plain   " and "
	instr_msg italic  "src2"
	instr_msg plain   " is stored in the "
	instr_msg italic  "des"
	instr_msg plain   " register.\n"
	instr_msg plain   "If the result is greater than 127,\
			then 1 is stored in register "
	instr_msg italic  "r1. "
	instr_msg plain   "If the result is less than -128,\
			then -1 is stored in register "
	instr_msg italic  "r1. "
	instr_msg plain   "Otherwise, 0 is stored in register "
	instr_msg italic  "r1.\n"

	instr_msg bold	  "\n"
	instr_msg bold	  "Multiplication:    mul  "
	instr_msg italic  "des, src1, src2"
	instr_msg plain   "\n\n"
	instr_msg plain   "Multiply the contents of registers "
	instr_msg italic  "src1"
	instr_msg plain   " and "
	instr_msg italic  "src2"
	instr_msg plain   ".\n"
	instr_msg plain   "The result is a 16-bit quantity. "
	instr_msg plain   "The low-order byte of the result is stored in the "
	instr_msg italic  "des"
	instr_msg plain   " register, and the "
	instr_msg plain   "high-order byte is stored in register "
	instr_msg italic  "r1.\n"


	$INSTR_TEXT_WIN config -state disabled
}

proc const_instr { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal
	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg bold   "Immediate Instructions\n"


	instr_msg plain   "\n"
	instr_msg bold    "Load Constant:     lc   "
	instr_msg italic  "des, const8"
	instr_msg plain   "\n\n"
	instr_msg plain   "Load the constant "
	instr_msg italic  "const8"
	instr_msg plain   " into register "
	instr_msg italic  "des.\n"
	instr_msg plain   "The value in register "
	instr_msg italic  "r1"
	instr_msg plain   " is unchanged.\n"

	instr_msg bold	  "\n"
	instr_msg bold	  "Increment:         inc  "
	instr_msg italic  "des, const8"
	instr_msg plain   "\n\n"
	instr_msg plain   "The sum of register "
	instr_msg italic  "reg"
	instr_msg plain   " and "
	instr_msg italic  "const8"
	instr_msg plain   " is stored in the specified "
	instr_msg italic  "reg.\n"
	instr_msg plain   "If the result is greater than 127,\
			then 1 is stored in register "
	instr_msg italic  "r1. "
	instr_msg plain   "If the result is less than -128,\
			then -1 is stored in register "
	instr_msg italic  "r1. "
	instr_msg plain   "Otherwise, 0 is stored in register "
	instr_msg italic  "r1.\n"

	$INSTR_TEXT_WIN config -state disabled
}

proc bit_instr { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal
	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg bold   "Bitwise Instructions\n"

	instr_msg plain	  "\n"
	instr_msg bold	  "Bitwise AND:       and  "
	instr_msg italic  "des, src1, src2"
	instr_msg plain   "\n\n"
	instr_msg plain   "The bitwise logical AND of the contents of registers "
	instr_msg italic  "src1"
	instr_msg plain   " and "
	instr_msg italic  "src2"
	instr_msg plain   " is stored in the "
	instr_msg italic  "des"
	instr_msg plain   " register. "
	instr_msg plain   "The bitwise negation of "
	instr_msg italic  "src1"
	instr_msg plain   " AND "
	instr_msg italic  "src2"
	instr_msg plain   " is stored in "
	instr_msg italic  "r1.\n"

	instr_msg plain	  "\n"
	instr_msg bold	  "Bitwise NOR:       nor  "
	instr_msg italic  "des, src1, src2"
	instr_msg plain   "\n\n"
	instr_msg plain   "The bitwise logical NOR of the contents of registers "
	instr_msg italic  "src1"
	instr_msg plain   " and "
	instr_msg italic  "src2"
	instr_msg plain   " is stored in the "
	instr_msg italic  "des"
	instr_msg plain   " register. "
	instr_msg plain   "The bitwise negation of "
	instr_msg italic  "src1"
	instr_msg plain   " NOR "
	instr_msg italic  "src2"
	instr_msg plain   " is stored in "
	instr_msg italic  "r1.\n"

	instr_msg plain	  "\n"
	instr_msg bold	  "Bitwise Shift:     shf  "
	instr_msg italic  "des, src1, src2"
	instr_msg plain   "\n\n"
	instr_msg plain   "The bitwise shift of the contents of register "
	instr_msg italic  "src1 "
	instr_msg plain   "by the number of positions given in register "
	instr_msg italic  "src2 "
	instr_msg plain   "positions is stored in the "
	instr_msg italic  "des"
	instr_msg plain   " register.\n"
	instr_msg plain   "If "
	instr_msg italic  "src2 "
	instr_msg plain   "is positive "
	instr_msg italic  "src1 "
	instr_msg plain   "is shifted to the left.\n"
	instr_msg plain   "If "
	instr_msg italic  "src2 "
	instr_msg plain   "is negative "
	instr_msg italic  "src1 "
	instr_msg plain   "is shifted to the right.\n"

	$INSTR_TEXT_WIN config -state disabled
}

proc branch_instr { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal
	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg bold   "Branch Instructions\n"

	instr_msg plain	 "\n"
	instr_msg bold	 "Branch on Equal:              beq  "
	instr_msg italic "reg, src1, src2"
	instr_msg plain  "\n\n"
	instr_msg plain  "If the contents of register "
	instr_msg italic "src1 "
	instr_msg plain  "is equal to the contents of register "
	instr_msg italic "src2, "
	instr_msg plain  "then branch to the address stored in "
	instr_msg italic "reg. "
	instr_msg plain  "The address of the instruction following the beq\
			  instruction is stored in "
	instr_msg italic "r1.\n"

	instr_msg plain	 "\n"
	instr_msg bold   "Branch on Greater Than:       bgt  "
	instr_msg italic "reg, src1, src2"
	instr_msg plain  "\n\n"
	instr_msg plain  "If the contents of register "
	instr_msg italic "src1 "
	instr_msg plain  "is greater than the contents of register "
	instr_msg italic "src2"
	instr_msg plain  ", then branch to the address stored in "
	instr_msg italic "reg. "
	instr_msg plain  "The address of the instruction following the bgt\
			  instruction is stored in "
	instr_msg italic "r1.\n"

	instr_msg plain  "\n"
	instr_msg bold   "Jump (unconditional branch):  jmp  "
	instr_msg italic "uconst8"
	instr_msg plain  "\n\n"
	instr_msg plain  "Branch unconditionally to the address specified by the constant, "
	instr_msg italic "uconst8. "
	instr_msg plain  "The address of the instruction following the jmp\
			  instruction is stored in "
	instr_msg italic "r1.\n"

	$INSTR_TEXT_WIN config -state disabled
}

proc ldstr_instr { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal
	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg bold   "Load/Store Instructions\n"

	instr_msg plain  "\n"
	instr_msg bold	 "Load One Byte:     ld1  "
	instr_msg italic "des, src1, uconst4"
	instr_msg plain  "\n\n"
	instr_msg plain  "Load the byte at memory location "
	instr_msg italic "src1 + uconst4 "
	instr_msg plain  "into "
	instr_msg italic "des.\n"
	instr_msg plain  "The value in register "
	instr_msg italic "r1 "
	instr_msg plain  "is unchanged.\n"

	instr_msg plain  "\n"
	instr_msg bold	 "Store One Byte:    st1  "
	instr_msg italic "reg, src1, uconst4"
	instr_msg plain  "\n\n"
	instr_msg plain  "Store the contents of "
	instr_msg italic "reg "
	instr_msg plain  "into memory location "
	instr_msg italic "src1 + uconst4.\n"
	instr_msg plain  "The value in register "
	instr_msg italic "r1 "
	instr_msg plain  "is unchanged.\n"


	$INSTR_TEXT_WIN config -state disabled
}

proc other_instr { } {
	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN config -state normal
	$INSTR_TEXT_WIN delete 0.0 end

	instr_msg bold   "Input/Output Instructions\n"

	instr_msg plain  "\n"
	instr_msg bold	 "Input One Byte:    in   "
	instr_msg italic "des, const4"
	instr_msg plain  "\n\n"
	instr_msg plain  "Read in a byte from the peripheral specified by "
	instr_msg italic "const4, "
	instr_msg plain  "and store it in "
	instr_msg italic "des. "
	instr_msg plain  "The value of "
	instr_msg italic "const4 "
	instr_msg plain  "must be: binary, hexadecimal, or ASCII.\n"

	instr_msg plain  "\n"
	instr_msg bold	 "Output One Byte:   out  "
	instr_msg italic "src, const4"
	instr_msg plain  "\n\n"
	instr_msg plain  "Write the byte stored in "
	instr_msg italic "src, "
	instr_msg plain  "to the peripheral specified by "
	instr_msg italic "const4. "
	instr_msg plain  "The value of "
	instr_msg italic "const4 "
	instr_msg plain  "must be: binary, hexadecimal, or ASCII.\n"

	instr_msg plain  "\n"
	instr_msg bold	 "Halt Processor:    hlt  "
	instr_msg italic "const8"
	instr_msg plain  "\n\n"
	instr_msg plain  "Halt the processor. The PC is set to the value "
	instr_msg italic "const8, "
	instr_msg plain  "so that if the processor is restarted\
			it will continue from that location."

	$INSTR_TEXT_WIN config -state disabled
}


proc instr_msg {tag text} {

	global INSTR_TEXT_WIN

	$INSTR_TEXT_WIN insert insert $text $tag
}

proc write_help_instr2 { inst args tag desc callback } {

	global INSTR_MAP_WIN
	global INSTR_MSG_WIN

	$INSTR_MAP_WIN insert insert $inst " $tag bold "
	$INSTR_MAP_WIN insert insert $args " $tag italic "
	$INSTR_MAP_WIN insert insert "\n"

	$INSTR_MAP_WIN tag bind $tag \
		<Enter> "$INSTR_MSG_WIN configure -text \"$desc\""
	$INSTR_MAP_WIN tag bind $tag \
		<Leave> "$INSTR_MSG_WIN configure -text {}"

	$INSTR_MAP_WIN tag bind $tag <Button-1> "$callback"
}
   

proc instr_help_close { } {
	global HELP_I_BASENAME
	destroy $HELP_I_BASENAME
}

# instr_init "" "."
