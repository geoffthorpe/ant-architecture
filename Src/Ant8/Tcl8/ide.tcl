#!/usr/bin/env wish
#
# $Id: ide.tcl,v 1.21 2003/06/19 20:49:18 sara Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

#if [info exists dirs] { tk_messageBox -message dirs=$dirs }
#if [info exists tcl_library] { tk_messageBox -message tcl_library=$tcl_library }
#tk_messageBox -message nameofexecutable=[info nameofexecutable]
#tk_messageBox -message pwd=[pwd]

global HILITE_COLOR
global UNHILITE_COLOR
global UNHILITE_READ_COLOR
global UNHILITE_WRITE_COLOR
global BREAK_COLOR
global ERROR_COLOR
global INST_TOP
global EDIT_TOP
global SLOW_MILLI_SEC
global MED_MILLI_SEC
global FAST_MILLI_SEC
global DEBUGGER_ON_TOP

set HILITE_COLOR white
set HILITE_READ_COLOR red
set HILITE_WRITE_COLOR white
set UNHILITE_COLOR #d9d9d9
set BREAK_COLOR red
set ERROR_COLOR red
set INST_TOP 0
set EDIT_TOP 0
set SLOW_MILLI_SEC 1000
set MED_MILLI_SEC  250
set FAST_MILLI_SEC 50
set DEBUGGER_ON_TOP 0

# Figure out where we are, so that we can figure out how to load all
# the related libraries of TCL code.

 
# SS commenting next 3 lines:
set argv0 [gantGetArgvElem 0]
regsub {/[^/]*$} $argv0 "" root
set LIBRARY_PATH $root/Tcl8

# load ./libawish.so awish

source $LIBRARY_PATH/edit.tcl
source $LIBRARY_PATH/console.tcl
source $LIBRARY_PATH/debug.tcl
source $LIBRARY_PATH/ant.tcl
source $LIBRARY_PATH/utils.tcl
source $LIBRARY_PATH/help.tcl
source $LIBRARY_PATH/dbg_help.tcl
source $LIBRARY_PATH/quick_ref.tcl

#
# ide
#	The main function for the ant ide
#

proc ide { args } {

	global EDIT_BASENAME

	set EDIT_BASENAME ""

	gantInitialize

	layout_edit
}

# If we're running on Windows, then the defaults aren't what we
# really want.  Coerce them to be more like unix-- set the
# background to the standard grey, and make sure that a
# non-proportional font is being used.


if { [array get tcl_platform platform] == "platform windows" } {
	option add *background $UNHILITE_COLOR
	option add *font { terminal 9 }
	option add *helpd.*font { times 12 }
}

#

# this is where we actually call the main procedure
ide

if { [gantGetArgc] > 1 } {
	set filename [gantGetArgvElem 1]
	set r [load_file $filename]

	if { $r == "ERROR" } {
		puts "ERROR: can't open ($filename)."
	}
}

