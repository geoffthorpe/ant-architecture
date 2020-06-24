#
# $Id: help.tcl,v 1.3 2001/01/02 15:30:06 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

#
# Define tags used in the help screens.
#

proc help_define_tags { win } {

	$win tag configure big -font {courier 18 bold}
	$win tag configure plain -font {courier 12}
	$win tag configure bold -font {courier 12 bold}
	$win tag configure italic -font {courier 12 italic}
	$win tag configure med -font {courier 15 bold}
}

