#
# $Id: utils.tcl,v 1.2 2001/01/02 15:30:06 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.


#
# update_text
#	procedure to change the context of a text widget, then disable it
#

proc update_text { widget new_text } {

	$widget configure -state normal
	$widget delete 0.0 end
	$widget insert end $new_text
	$widget configure -state disabled

}

#
# update_line
#	procedure to change the context of a text widget, then disable it
#

proc update_line { widget new_text line_num } {

	$widget configure -state normal
	$widget delete $line_num.0 $line_num.end
	$widget insert $line_num.0 $new_text
	$widget configure -state disabled

}

#
# bind_yview
#	- set the yview of all of the widgets in 'lists' argument
#	- used as command for vertical scrollbars to tie mutiple text
#	  widgets together
#

proc bind_yview { lists args } {
	foreach l $lists {
		eval {$l yview } $args
	}
}

#
# top_win_name
#

proc top_win_name { win } {

	if {[string length $win] == 0} {
		return .
	} else {
		return $win
	}

}

#
# dotless_win_name
#

proc dotless_win_name { win } {

	if {[string length $win] == 0} {
		return $win
	} else {
		set last [expr [string length $win] - 1]
		if {[string index $win $last] != "."} {
			return $win
		} else {
			return [string range $win 0 [expr $last - 1]]
		}
	}

}
