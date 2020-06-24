#
# $Id: help.tcl,v 1.1 2001/02/16 22:41:27 seeve Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#

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

proc show_help_debug {} {
  global HELP_D_BASENAME
  set HELP_D_BASENAME .helpd
        
  #     
  # If the debug window already exists, don't create it, just
  # raise it to the top where it can be seen.
  #     
  if { [winfo exists $HELP_D_BASENAME] != 0} {
    wm deiconify $HELP_D_BASENAME
    raise $HELP_D_BASENAME
    return
  }     
        
  toplevel $HELP_D_BASENAME -borderwidth 6
  wm title $HELP_D_BASENAME "Ant Debugger Help Window"
        
  #     
  # Define frame, text widget, scrollbars, button
  #     
        
  global LIBRARY_PATH
  dbgh_init $HELP_D_BASENAME $LIBRARY_PATH
}       

proc show_help_instr {} {
  global HELP_I_BASENAME
  set HELP_I_BASENAME .helpi
        
  #     
  # If the debug window already exists, don't create it, just
  # raise it to the top where it can be seen.
  #     
  if { [winfo exists $HELP_I_BASENAME] != 0} {
    wm deiconify $HELP_I_BASENAME
    raise $HELP_I_BASENAME
    return
  }     
        
  toplevel $HELP_I_BASENAME -borderwidth 6
  wm title $HELP_I_BASENAME "Ant Debugger Help Window"
        
  #     
  # Define frame, text widget, scrollbars, button
  #     
        
  global LIBRARY_PATH
  instr_init $HELP_I_BASENAME $LIBRARY_PATH
}       

proc show_help_about {} {
  global HELP_A_BASENAME
  set HELP_A_BASENAME .helpa
        
  #     
  # If the debug window already exists, don't create it, just
  # raise it to the top where it can be seen.
  #     
  if { [winfo exists $HELP_A_BASENAME] != 0} {
    wm deiconify $HELP_A_BASENAME
    raise $HELP_A_BASENAME
    return
  }     
        
  toplevel $HELP_A_BASENAME -borderwidth 6
  wm title $HELP_A_BASENAME "About Ant"
        
  #     
  # Define frame, text widget, scrollbars, button
  #     
  frame $HELP_A_BASENAME.text_frame -borderwidth 2
  text $HELP_A_BASENAME.text_frame.txt -wrap word -height 10 -width 40 \
    -yscrollcommand {$HELP_A_BASENAME.text_frame.yscroll set}
        
  scrollbar $HELP_A_BASENAME.text_frame.yscroll \
    -command {$HELP_A_BASENAME.text_frame.txt yview} \
    -orient vertical
        
  button $HELP_A_BASENAME.text_frame.button -text \
     "Close This Window" -command { close_help_about } -default active
        
  #     
  # Grid: layout widgets, allow for resizing
  #     
  grid $HELP_A_BASENAME.text_frame -sticky news
  grid $HELP_A_BASENAME.text_frame.txt $HELP_A_BASENAME.text_frame.yscroll \
    -sticky news
  grid $HELP_A_BASENAME.text_frame.button
        
  grid rowconfigure $HELP_A_BASENAME 0 -weight 1
  grid rowconfigure $HELP_A_BASENAME.text_frame 0 -weight 1
  grid columnconfigure $HELP_A_BASENAME 0 -weight 1
  grid columnconfigure $HELP_A_BASENAME.text_frame 0 -weight 1
        
  #     
  # Define tags
  #     
  help_define_tags $HELP_A_BASENAME.text_frame.txt
        
  write_help_about big    "About Ant:\n\n"
  write_help_about bold   "Release: "
  write_help_about plain  "3.0.1\n"
  write_help_about bold   "Release Date: "
  write_help_about plain  " May 31, 2000\n"
  write_help_about bold   "Contacts: "
  write_help_about plain  "ant-devel@ant.harvard.edu, or\n"
  write_help_about plain  "http://ant.www.harvard.edu/"
        
  $HELP_A_BASENAME.text_frame.txt config -state disabled
}       

proc write_help_edit {tag text} {
  global HELP_E_BASENAME
  $HELP_E_BASENAME.text_frame.txt insert insert $text $tag
}

proc write_help_debug {tag text} {
  global HELP_D_BASENAME          
  $HELP_D_BASENAME.text_frame.txt insert insert $text $tag
}                                                         
                                                          
proc write_help_about {tag text} {
  global HELP_A_BASENAME
  $HELP_A_BASENAME.text_frame.txt insert insert $text $tag
}    

proc close_help_edit {} {
  global HELP_E_BASENAME
  destroy $HELP_E_BASENAME
}
 
proc close_help_debug {} {
  global HELP_D_BASENAME
  destroy $HELP_D_BASENAME
}
 
proc close_help_about {} {
  global HELP_A_BASENAME
  destroy $HELP_A_BASENAME
}

