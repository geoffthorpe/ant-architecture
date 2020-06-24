#
# $Id: aide32_edit.tcl,v 1.4 2006/08/31 11:45:21 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#

#
# write_file
#	Try to write a file, named filename.  Return 0 if fails;
#	1 otherwise
#

proc write_file { filename contents } {

	global EDIT_BASENAME

	if { $filename == "" } {
		return 0
	}

	if [catch {open $filename w} fd] {
		puts stderr "ERROR: $filename: $fd"
		return 0
	} else {
		puts $fd $contents
		close $fd
		return 1
	}
}

#
# read_file
#	Try to read a file, named filename.  Returns a list:
#		{ 0 "" } if it fails, { 1 <contents> } otherwise
#

proc read_file { filename } {

	global EDIT_BASENAME

	if [catch {open $filename r} fd] {
		return [list 0 ""]
	} else {
		set contents [read $fd]
		close $fd
		return [list 1 $contents]
	}
}

#
# suggest_save
#	Puts up a dialog asking if user wants to save.
#	Takes a string, such as "exiting" to put into the dialog.
#	Does actual save if they user says to.
#	Returns 1 if user hits cancel, 0 otherwise.
#

proc suggest_save { act } {

	set choice [tk_messageBox -type yesnocancel -default yes \
		-message "Do you want to save \n your changes before \n $act?"\
		-icon question]

	switch -- $choice {
		yes	{do_save}
		no	{return 0}
		cancel	{return 1}
	}

	return 0
}

#
# update_text
#	Replace window contents with new text
#
proc update_text {window newtext} {
	$window delete 0.0 end
	$window insert end $newtext
}

#
# do_new
#	Callback for File/New
#

proc do_new { } {
	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME

	if [info exists EDIT_BASENAME]==0 {
		layout_edit
	}

	set contents [$EDIT_BASENAME.text_frame.txt get 1.0 end]

	set contents [string trimleft $contents]
	set contents [string trimright $contents]
	set last [string trimleft $LAST_WRITTEN]
	set last [string trimright $last]

	if {[string compare $last $contents] != 0} {
		set cancel [suggest_save "opening a new file"]
		if {$cancel} {
			return
		}
	}

	set CURR_FILENAME ""
	set IS_CURR_FILENAME 0
	set LAST_WRITTEN ""

	update_text $EDIT_BASENAME.text_frame.txt ""
	update_text $EDIT_BASENAME.error_frame.txt ""
	$EDIT_BASENAME.text_frame.txt configure -state normal

	set edit_name [winfo toplevel $EDIT_BASENAME]

	wm title $edit_name "Ant Editor: \[New\]"
}

#
# do_open_asm - 
#	Callback for File/Open
#

proc do_open_asm { } {

	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME
	global env
	global oldFileDialog

	if [info exists EDIT_BASENAME]==0 {
		layout_edit
	}

	set contents [$EDIT_BASENAME.text_frame.txt get 1.0 end]

	set contents [string trimleft $contents]
	set contents [string trimright $contents]
	set last [string trimleft $LAST_WRITTEN]
	set last [string trimright $last]

	if {[string compare $last $contents] != 0} {
		set cancel [suggest_save "opening a new file"]
		if {$cancel} {
			return
		}
	}

	set typelist {
		{"ANT Assembly Files" {".asm"}}
		{"All Files" {".*"}}
	}

	#if file dialog already exists, don't specify initialdir
	if [info exists oldFileDialog] {
	  set filename [tk_getOpenFile -title "Open Ant-32 Assembly File" \
	      -filetypes $typelist -parent $EDIT_BASENAME -initialdir $oldFileDialog]
          if [string length $filename] {
            set oldFileDialog [file dirname $filename]
          }
	} else {
	  set sampledir [file dirname [file dirname [info nameofexecutable]]]/examples/ant32
	  if [file isdirectory $sampledir] {
	    set initdir $sampledir
	  } elseif [info exists env(HOME)] {
	    set initdir $env(HOME)
	  } else {
	    set initdir .
	  }

	  set filename [tk_getOpenFile -title "Open ANT Assembly File" \
		-filetypes $typelist -initialdir $initdir \
		-parent $EDIT_BASENAME]
puts "[info globals]"
          if [string length $filename] {
            set oldFileDialog [file dirname $filename]
          }
	}

	if [string length $filename]==0 return

	load_file $filename
}

#

proc load_file { filename } {

	global IS_CURR_FILENAME
	global CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME

	set read_val [read_file $filename]
	if {[lindex $read_val 0] == 0} {
		return ERROR
	}
	set LAST_WRITTEN [lindex $read_val 1]

	update_text $EDIT_BASENAME.text_frame.txt $LAST_WRITTEN
	update_text $EDIT_BASENAME.error_frame.txt ""
	$EDIT_BASENAME.text_frame.txt configure -state normal

	set edit_name [winfo toplevel $EDIT_BASENAME]

	wm title $edit_name "Ant Editor: $filename"
	focus $EDIT_BASENAME.text_frame.txt
	$EDIT_BASENAME.text_frame.txt mark set insert 1.0

	set IS_CURR_FILENAME 1
	set CURR_FILENAME $filename

	return OK
}

#
# do_save
#	Callback for File/Save
#

proc do_save { } {

	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME

	if {$IS_CURR_FILENAME} {
		set contents [$EDIT_BASENAME.text_frame.txt get 1.0 end]
		set contents [string trimright $contents]
		set rc [write_file $CURR_FILENAME $contents]
		if {$rc != 0} {
			set LAST_WRITTEN $contents
		}
	} else {
		do_save_as
	}
}

#
# do_save_as - 
#	Callback for File/Save As...
#

proc do_save_as { } {

	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME
	global env
	global oldFileDialog

	set typelist {
		{"ANT Assembly Files" {".asm"}}
	}

	#if file dialog already exists, don't specify initialdir
	if [info exists oldFileDialog] {
	  set filename [tk_getSaveFile -title "Save ANT Assembly File" \
		-filetypes $typelist -defaultextension .asm -parent $EDIT_BASENAME -initialdir $oldFileDialog]
          if [string length $filename] {
            set oldFileDialog [file dirname $filename]
          }
	} else {
	  if [info exists env(HOME)] {
	    set initdir $env(HOME)
	  } else {
	    set initdir .
	  }
	  set filename [tk_getSaveFile -title "Save ANT Assembly File" \
		-filetypes $typelist -defaultextension .asm \
		-initialdir $initdir -parent $EDIT_BASENAME]
puts "[info globals]"
          if [string length $filename] {
            set oldFileDialog [file dirname $filename]
          }

	}

	set contents [$EDIT_BASENAME.text_frame.txt get 1.0 end]
	set contents [string trimright $contents]
	set rc [write_file $filename $contents]
	if {$rc == 0} {
		return	
	}

	set CURR_FILENAME $filename
	set IS_CURR_FILENAME 1
	set LAST_WRITTEN [$EDIT_BASENAME.text_frame.txt get 1.0 end]
}

#
# do_exit
#     Callback for exit button.
#

proc do_exit { } {

	global LAST_WRITTEN
	global EDIT_BASENAME

	if [info exists EDIT_BASENAME] {

		set contents [$EDIT_BASENAME.text_frame.txt get 1.0 end]

		set contents [string trimleft $contents]
		set contents [string trimright $contents]
		set last [string trimleft $LAST_WRITTEN]
		set last [string trimright $last]

		if {[string compare $last $contents] != 0} {
			set cancel [suggest_save "exiting"]
			if {$cancel} {
				return
			}
		}

	}

	exit

}

#
# do_assemble
#	Callback for Assemble button
#

proc do_assemble { } {

	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME
	global HILITE_COLOR
	global UNHILITE_COLOR
	global ERROR_COLOR
	global VM filename instr_count init_PC
	global errorCode

	set AA32 [file dirname [info nameofexecutable]]/aa32

	set contents [$EDIT_BASENAME.text_frame.txt get 1.0 end]

	set contents [string trimleft $contents]
	set contents [string trimright $contents]
	set last [string trimleft $LAST_WRITTEN]
	set last [string trimright $last]

	if {[string compare $last $contents] != 0} {
		set cancel [suggest_save "assembling"]
		if {$cancel} {
			return
		}
	} elseif ($IS_CURR_FILENAME==0) {
	set choice [tk_messageBox -type ok \
		-message "You must write \n a program before \n assembling!"\
		-icon error -title "No Input"]
		return
	}


	set color $UNHILITE_COLOR
	set line 0

	if [catch "exec $AA32 $CURR_FILENAME" result] {
		#two possibilites: aa32 failed to run, or it ran and
		#assembly failed.  In the latter case, the beginning of
		#$result should be $CURR_FILENAME
		if [string match $CURR_FILENAME:* $result]==0 {
			tk_messageBox -type ok -icon error -title Error \
			-message "aa32 failed to run!\n($AA32)\n$errorCode"
		} else {

		set error $result

		set color $ERROR_COLOR

		# Get the line of the error.  The error string contains
		# the line number of the error, between the first and
		# second :'s in the error string.

		regexp {:line ([0-9]+):} $error whole line

		# Clear old highlighting first, if there is any.

		$EDIT_BASENAME.text_frame.txt tag configure err \
				-background $UNHILITE_COLOR
		$EDIT_BASENAME.text_frame.txt tag delete err

		# Now highlight line with error, scroll and set cursor

		$EDIT_BASENAME.text_frame.txt tag add err $line.0 $line.end
		$EDIT_BASENAME.text_frame.txt tag configure err \
				-background $HILITE_COLOR

		# Scroll Edit window if necessary

		$EDIT_BASENAME.text_frame.txt see $line.0

		# Set the focus and the text cursor position

		focus $EDIT_BASENAME.text_frame.txt
		$EDIT_BASENAME.text_frame.txt mark set insert $line.0
		}

	} else {
		set error ""
		set filename $CURR_FILENAME
		regsub -nocase {\.asm$} $filename "" filename
		append filename .a32

		do_full_reset
		set instr_count [$VM load $filename]
		set init_PC [$VM get_register PC]
		get_register_label
		update_display

		$EDIT_BASENAME.text_frame.txt tag configure err \
				-background $UNHILITE_COLOR
		$EDIT_BASENAME.text_frame.txt tag delete err
	}

	update_text $EDIT_BASENAME.error_frame.txt $error
	$EDIT_BASENAME.error_frame.txt configure -bg $color

	$EDIT_BASENAME.text_frame.txt configure -state normal
}

proc do_debug {} {
	global CURR_FILENAME
	global IS_CURR_FILENAME
	global VM filename instr_count init_PC

	if ($IS_CURR_FILENAME==0) {
		tk_messageBox -type ok -icon error -title Error \
			-message "Program must be Saved\n(and assembled) first!"
		return
	}

	set filename $CURR_FILENAME
	regsub -nocase {\.asm$} $filename "" filename
	append filename .a32
	if ![file exists $filename] {
		tk_messageBox -type ok -icon error -title Error \
			-message "Program must be assembled first!"
		return
	}

	if [file mtime $CURR_FILENAME]>[file mtime $filename] {
		set choice [tk_messageBox -type yesnocancel -default yes \
		-message ".a32 file is out of date!\n Do you want to assemble?"\
		-icon question]
		if {"$choice"=="cancel"} return
		if {"$choice"=="yes"} { do_assemble; return }
	}

	do_full_reset
	set instr_count [$VM load $filename]
	set init_PC [$VM get_register PC]
	get_register_label
	raise .
	update_display
}

#
# edit_menu_bar
#	Layout the menubar of the main window
#

proc edit_menu_bar {} {

	global EDIT_BASENAME

	frame $EDIT_BASENAME.menubar -bd 2 -relief raised

	## File menu

	menubutton $EDIT_BASENAME.menubar.file -text "File" 
	$EDIT_BASENAME.menubar.file \
		configure -menu $EDIT_BASENAME.menubar.file.menu

	menu $EDIT_BASENAME.menubar.file.menu -tearoff 0
	$EDIT_BASENAME.menubar.file.menu add command -label "New" \
		-command { do_new}
	$EDIT_BASENAME.menubar.file.menu add command -label "Open..." \
		-command { do_open_asm }
	$EDIT_BASENAME.menubar.file.menu add separator
	$EDIT_BASENAME.menubar.file.menu add command -label "Save" \
		-command { do_save }
	$EDIT_BASENAME.menubar.file.menu add command -label "Save As..." \
		-command { do_save_as }
	$EDIT_BASENAME.menubar.file.menu add separator
	$EDIT_BASENAME.menubar.file.menu add command -label "Exit" \
		-command { do_exit }

	pack $EDIT_BASENAME.menubar.file -side left

	## Help menu

	menubutton $EDIT_BASENAME.menubar.help -text "Help" 
	$EDIT_BASENAME.menubar.help \
		configure -menu $EDIT_BASENAME.menubar.help.menu

 	menu $EDIT_BASENAME.menubar.help.menu -tearoff 0
	$EDIT_BASENAME.menubar.help.menu add command -label \
          "Editor Help" -command { show_help_edit}
	$EDIT_BASENAME.menubar.help.menu add command -label \
          "Debugger Help" -command { show_help_debug}
	$EDIT_BASENAME.menubar.help.menu add command -label \
          "Instructions (Quick Guide)" -command {show_help_instr}
        $EDIT_BASENAME.menubar.help.menu add separator
	$EDIT_BASENAME.menubar.help.menu add command -label \
          "About Ant" -command { show_help_about}
	#pack $EDIT_BASENAME.menubar.help -side right
}

proc show_help_edit {} {
  global HELP_E_BASENAME
  set HELP_E_BASENAME .helpe

  #
  # If the debug window already exists, don't create it, just
  # raise it to the top where it can be seen.
  #
  if { [winfo exists $HELP_E_BASENAME] != 0} {
    wm deiconify $HELP_E_BASENAME
    raise $HELP_E_BASENAME
    return
  }

  toplevel $HELP_E_BASENAME -borderwidth 6
  wm title $HELP_E_BASENAME "Ant Editor Help Window"

  #
  # Define frame, text widget, scrollbars, button
  #
  frame $HELP_E_BASENAME.text_frame -borderwidth 2
  text $HELP_E_BASENAME.text_frame.txt -wrap none -height 20 -width 50 \
    -yscrollcommand {$HELP_E_BASENAME.text_frame.yscroll set} \
    -xscrollcommand {$HELP_E_BASENAME.text_frame.xscroll set}

  scrollbar $HELP_E_BASENAME.text_frame.yscroll \
    -command {$HELP_E_BASENAME.text_frame.txt yview} \
    -orient vertical
  scrollbar $HELP_E_BASENAME.text_frame.xscroll \
    -command "$HELP_E_BASENAME.text_frame.txt xview" \
    -orient horizontal

  button $HELP_E_BASENAME.text_frame.button -text \
     "Close This Window" -command { close_help_edit } -default active

  #
  # Grid: layout widgets, allow for resizing
  #
  grid $HELP_E_BASENAME.text_frame -sticky news
  grid $HELP_E_BASENAME.text_frame.txt $HELP_E_BASENAME.text_frame.yscroll \
    -sticky news
  grid $HELP_E_BASENAME.text_frame.xscroll -sticky ew
  grid $HELP_E_BASENAME.text_frame.button

  grid rowconfigure $HELP_E_BASENAME 0 -weight 1
  grid rowconfigure $HELP_E_BASENAME.text_frame 0 -weight 1
  grid columnconfigure $HELP_E_BASENAME 0 -weight 1
  grid columnconfigure $HELP_E_BASENAME.text_frame 0 -weight 1

  help_define_tags $HELP_E_BASENAME.text_frame.txt

  write_help_edit big    "The Ant Editor:\n"
  write_help_edit plain  "Edits an Ant assembly language file.\n"
  write_help_edit plain  "Assembles the contents of the Editor window.\n"
  write_help_edit plain  "\n"
  write_help_edit plain  "To run a sample program:\n\n"
  write_help_edit plain  " (1) Select "
  write_help_edit bold   "Open "
  write_help_edit plain  "from the"
  write_help_edit bold   "  File Menu.\n"
  write_help_edit plain  " (2) Open the folder (directory) called"
  write_help_edit bold   " Examples.\n"
  write_help_edit plain  " (3) Double click on any"
  write_help_edit bold   " .asm " 
  write_help_edit plain  "file.\n"
  write_help_edit italic "       This loads it into the Edit window.\n"
  write_help_edit plain  " (4) Click on the"
  write_help_edit bold   " Assemble Button.\n"
  write_help_edit italic "       This assembles the .asm file.\n"
  write_help_edit italic "       If an error occurs, edit the highlighted line.\n"
  write_help_edit plain  " (5) Click on the"
  write_help_edit bold   " Debug Button.\n"
  write_help_edit italic "       This activates the Ant Debugger."

  $HELP_E_BASENAME.text_frame.txt config -state disabled
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

proc old_show_debug_help { } {

  frame $HELP_D_BASENAME.text_frame

  text $HELP_D_BASENAME.text_frame.txt -wrap none -height 45 -width 65 \
    -yscrollcommand {$HELP_D_BASENAME.text_frame.yscroll set} \
    -xscrollcommand {$HELP_D_BASENAME.text_frame.xscroll set}

  scrollbar $HELP_D_BASENAME.text_frame.yscroll \
    -command {$HELP_D_BASENAME.text_frame.txt yview} \
    -orient vertical
  scrollbar $HELP_D_BASENAME.text_frame.xscroll \
    -command "$HELP_D_BASENAME.text_frame.txt xview" \
    -orient horizontal

  button $HELP_D_BASENAME.text_frame.button -text \
     "Close This Window" -command { close_help_debug } -default active

  #
  # Grid: layout widgets, allow for resizing
  #
  grid $HELP_D_BASENAME.text_frame -sticky news
  grid $HELP_D_BASENAME.text_frame.txt $HELP_D_BASENAME.text_frame.yscroll \
    -sticky news
  grid $HELP_D_BASENAME.text_frame.xscroll -sticky ew
  grid $HELP_D_BASENAME.text_frame.button

  grid rowconfigure $HELP_D_BASENAME 0 -weight 1
  grid rowconfigure $HELP_D_BASENAME.text_frame 0 -weight 1
  grid columnconfigure $HELP_D_BASENAME 0 -weight 1
  grid columnconfigure $HELP_D_BASENAME.text_frame 0 -weight 1


  help_define_tags $HELP_D_BASENAME.text_frame.txt 

  #
  # The Ant Debugger Help Window
  #
  write_help_debug big    "The Ant Debugger:\n"
  write_help_debug plain  "Is used to execute an Ant program.\n"
  write_help_debug plain  "After opening a file and assembling it in "
  write_help_debug bold   "The Ant Editor, "
  write_help_debug plain  "click on"
  write_help_debug bold   " Run,\n"
  write_help_debug italic "to simply execute the program.\n\n"


  #
  # Displayed Information Help
  #

  $HELP_D_BASENAME.text_frame.txt config -state disabled
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
  write_help_about plain  "3.1.1b\n"
  write_help_about bold   "Release Date: "   
  write_help_about plain  " May 31, 2002\n"
  write_help_about bold   "Contacts: "   
  write_help_about plain  "ant-help@eecs.harvard.edu, or\n"   
  write_help_about plain  "http://www.ant.harvard.edu/"   

  $HELP_A_BASENAME.text_frame.txt config -state disabled
}

#
# close_help_
#
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

#
# write_help_
#
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

#
# layout_edit
# 	layout the edit window
#

proc layout_edit { } {
	
	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME
	global HILITE_COLOR
	global UNHILITE_COLOR
	global ERROR_COLOR

	set HILITE_COLOR yellow
	set UNHILITE_COLOR [option get . background background]
	set ERROR_COLOR red

	set CURR_FILENAME ""
	set IS_CURR_FILENAME 0
	set LAST_WRITTEN ""

	global EDIT_BASENAME
	set EDIT_BASENAME .edit
	toplevel $EDIT_BASENAME

	set edit_name [winfo toplevel $EDIT_BASENAME]

	edit_menu_bar

	frame $EDIT_BASENAME.text_frame
	frame $EDIT_BASENAME.button_frame
	frame $EDIT_BASENAME.error_frame

	text $EDIT_BASENAME.text_frame.txt -height 30 -width 80 \
		-xscrollcommand "$EDIT_BASENAME.text_frame.xscroll set" \
		-yscrollcommand "$EDIT_BASENAME.text_frame.yscroll set"

	$EDIT_BASENAME.text_frame.txt insert end ""

        scrollbar $EDIT_BASENAME.text_frame.yscroll -orient vertical \
                -command "$EDIT_BASENAME.text_frame.txt yview"
        scrollbar $EDIT_BASENAME.text_frame.xscroll -orient horizontal \
                -command "$EDIT_BASENAME.text_frame.txt xview"


	grid config $EDIT_BASENAME.text_frame.txt -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $EDIT_BASENAME.text_frame.yscroll -column 1 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $EDIT_BASENAME.text_frame.xscroll -column 0 -row 1 \
		-columnspan 1 -rowspan 1 -sticky "snew"

	button $EDIT_BASENAME.button_frame.asm -text "Assemble" \
			-padx 1 -pady 1 -width 8 \
			-command do_assemble
	button $EDIT_BASENAME.button_frame.debug -text "Debug" \
			-padx 1 -pady 1 -width 8 \
			-width 10 -command do_debug

	grid config $EDIT_BASENAME.button_frame.asm -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "sw" -padx 2 -pady 2
	grid config $EDIT_BASENAME.button_frame.debug -column 2 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "sw" -padx 2 -pady 2

	text $EDIT_BASENAME.error_frame.txt -height 4 -width 60 \
		-xscrollcommand "$EDIT_BASENAME.error_frame.xscroll set" \
		-yscrollcommand "$EDIT_BASENAME.error_frame.yscroll set"

        scrollbar $EDIT_BASENAME.error_frame.yscroll -orient vertical \
                -command "$EDIT_BASENAME.error_frame.txt yview"
        scrollbar $EDIT_BASENAME.error_frame.xscroll -orient horizontal \
                -command "$EDIT_BASENAME.error_frame.txt xview"

	grid config $EDIT_BASENAME.error_frame.txt -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $EDIT_BASENAME.error_frame.yscroll -column 1 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $EDIT_BASENAME.error_frame.xscroll -column 0 -row 1 \
		-columnspan 1 -rowspan 1 -sticky "snew"

	grid config $EDIT_BASENAME.menubar -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $EDIT_BASENAME.button_frame -column 0 -row 1 \
		-columnspan 1 -rowspan 1 -sticky "snw"
	grid config $EDIT_BASENAME.text_frame -column 0 -row 2 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $EDIT_BASENAME.error_frame -column 0 -row 3 \
		-columnspan 1 -rowspan 1 -sticky "snew"

	## Set up grid for resizing.
	
	## Column 0 (the only one) gets the extra space.
	grid columnconfigure $edit_name 0 -weight 1
	grid columnconfigure $EDIT_BASENAME.text_frame 0 -weight 1
	grid columnconfigure $EDIT_BASENAME.error_frame 0 -weight 1

	## Row 2 (the program text area) gets the extra space.
	grid rowconfigure $edit_name 2 -weight 1
	grid rowconfigure $EDIT_BASENAME.text_frame 0 -weight 1

	focus $EDIT_BASENAME.text_frame.txt
	$EDIT_BASENAME.text_frame.txt mark set insert 1.0

	wm title $edit_name "Ant32 Editor"
	wm protocol $edit_name WM_DELETE_WINDOW {
			window_menu_hide $EDIT_BASENAME
		}
	window_menu_plus $EDIT_BASENAME
	raise $EDIT_BASENAME

}

