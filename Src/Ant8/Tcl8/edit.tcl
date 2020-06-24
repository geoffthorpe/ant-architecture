#
# $Id: edit.tcl,v 1.28 2006/08/31 11:45:22 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

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
# do_new
#	Callback for File/New
#

proc do_new { } {
	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	set contents [$edit_dotless.text_frame.txt get 1.0 end]

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

	update_text $edit_dotless.text_frame.txt ""
	update_text $edit_dotless.error_frame.txt ""
	$edit_dotless.text_frame.txt configure -state normal

	set edit_name [top_win_name $EDIT_BASENAME]

	wm title $edit_name "Ant Editor: \[New\]"
}

#
# do_open - 
#	Callback for File/Open
#

proc do_open { } {

	global CURR_FILENAME
	global IS_CURR_FILENAME
	global LAST_WRITTEN
	global EDIT_BASENAME
	global env
	global oldFileDialog

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	set contents [$edit_dotless.text_frame.txt get 1.0 end]

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
              -filetypes $typelist -initialdir $oldFileDialog]
          if [string length $filename] {
            set oldFileDialog [file dirname $filename]
          }
        } else {
	  set sampledir [file dirname [file dirname [info nameofexecutable]]]/examples/ant8
	  if [file isdirectory $sampledir] {
	    set initdir $sampledir
	  } elseif [info exists env(HOME)] {
	    set initdir $env(HOME)
	  } else {
	    set initdir .
	  }

	  set filename [tk_getOpenFile -title "Open ANT Assembly File" \
		-filetypes $typelist -initialdir $initdir]
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

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	set read_val [read_file $filename]
	if {[lindex $read_val 0] == 0} {
		return ERROR
	}
	set LAST_WRITTEN [lindex $read_val 1]

	update_text $edit_dotless.text_frame.txt $LAST_WRITTEN
	update_text $edit_dotless.error_frame.txt ""
	$edit_dotless.text_frame.txt configure -state normal

	set edit_name [top_win_name $EDIT_BASENAME]

	wm title $edit_name "Ant Editor: $filename"
	focus $edit_dotless.text_frame.txt
	$edit_dotless.text_frame.txt mark set insert 1.0

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

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	if {$IS_CURR_FILENAME} {
		set contents [$edit_dotless.text_frame.txt get 1.0 end]
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

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	set typelist {
		{"ANT Assembly Files" {".asm"}}
	}

	if [info exists oldFileDialog] {
	  set filename [tk_getSaveFile -title "Save ANT Assembly File" \
		-filetypes $typelist -initialdir $oldFileDialog]
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
                -filetypes $typelist -initialdir $initdir]
          if [string length $filename] {
            set oldFileDialog [file dirname $filename]
          }
        }


	set contents [$edit_dotless.text_frame.txt get 1.0 end]
	set contents [string trimright $contents]
	set rc [write_file $filename $contents]
	if {$rc == 0} {
		return	
	}

	set CURR_FILENAME $filename
	set IS_CURR_FILENAME 1
	set LAST_WRITTEN [$edit_dotless.text_frame.txt get 1.0 end]
}

#
# do_exit
#     Callback for exit button.
#

proc do_exit { } {

	global LAST_WRITTEN
	global EDIT_BASENAME

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	set contents [$edit_dotless.text_frame.txt get 1.0 end]

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

	exit

}

#
# do_assemble
#	Callback for Assemble button
#

proc do_assemble { } {

	global CURR_FILENAME
	global EDIT_BASENAME
	global HILITE_COLOR
	global UNHILITE_COLOR
	global ERROR_COLOR

	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	set contents [$edit_dotless.text_frame.txt get 1.0 end]
	set color $UNHILITE_COLOR
	set line 0

	set rc [gantAssemble $contents]

	if { [string compare $rc "OK"] != 0 } {
		set error [gantGetAntErrorStr]

		set color $ERROR_COLOR

		# Get the line of the error.  The error string contains
		# the line number of the error, between the first and
		# second :'s in the error string.

		regexp {:line ([0-9]+):} $error whole line

		# Clear old highlighting first, if there is any.

		$edit_dotless.text_frame.txt tag configure err \
				-background $UNHILITE_COLOR
		$edit_dotless.text_frame.txt tag delete err

		# Now highlight line with error, scroll and set cursor

		$edit_dotless.text_frame.txt tag add err $line.0 $line.end
		$edit_dotless.text_frame.txt tag configure err \
				-background $HILITE_COLOR

		# Scroll Edit window if necessary

		$edit_dotless.text_frame.txt see $line.0

		# Set the focus and the text cursor position

		focus $edit_dotless.text_frame.txt
		$edit_dotless.text_frame.txt mark set insert $line.0

	} else {
		set error ""
		gantLoadFromAssembler $CURR_FILENAME

		$edit_dotless.text_frame.txt tag configure err \
				-background $UNHILITE_COLOR
		$edit_dotless.text_frame.txt tag delete err
	}

	update_text $edit_dotless.error_frame.txt $error
	$edit_dotless.error_frame.txt configure -bg $color

	$edit_dotless.text_frame.txt configure -state normal

	update_everything
}

#
# edit_menu_bar
#	Layout the menubar of the main window
#

proc edit_menu_bar {} {

	global EDIT_BASENAME
	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	frame $edit_dotless.menubar -bd 2 -relief raised

	## File menu

	menubutton $edit_dotless.menubar.file -text "File" 
	$edit_dotless.menubar.file \
		configure -menu $edit_dotless.menubar.file.menu

	menu $edit_dotless.menubar.file.menu -tearoff 0
	$edit_dotless.menubar.file.menu add command -label "New" \
		-command { do_new}
	$edit_dotless.menubar.file.menu add command -label "Open..." \
		-command { do_open }
	$edit_dotless.menubar.file.menu add separator
	$edit_dotless.menubar.file.menu add command -label "Save" \
		-command { do_save }
	$edit_dotless.menubar.file.menu add command -label "Save As..." \
		-command { do_save_as }
	$edit_dotless.menubar.file.menu add separator
	$edit_dotless.menubar.file.menu add command -label "Exit" \
		-command { do_exit }

	pack $edit_dotless.menubar.file -side left

	## Help menu

	menubutton $edit_dotless.menubar.help -text "Help" 
	$edit_dotless.menubar.help \
		configure -menu $edit_dotless.menubar.help.menu

 	menu $edit_dotless.menubar.help.menu -tearoff 0
	$edit_dotless.menubar.help.menu add command -label \
          "Editor Help" -command { show_help_edit}
	$edit_dotless.menubar.help.menu add command -label \
          "Debugger Help" -command { show_help_debug}
	$edit_dotless.menubar.help.menu add command -label \
          "Instructions (Quick Guide)" -command {show_help_instr}
        $edit_dotless.menubar.help.menu add separator
	$edit_dotless.menubar.help.menu add command -label \
          "About Ant" -command { show_help_about}
	pack $edit_dotless.menubar.help -side right
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

	set CURR_FILENAME ""
	set IS_CURR_FILENAME 0
	set LAST_WRITTEN ""

	global EDIT_BASENAME
	set edit_name [top_win_name $EDIT_BASENAME]
	set edit_dotless [dotless_win_name $EDIT_BASENAME]

	edit_menu_bar

	frame $edit_dotless.text_frame
	frame $edit_dotless.button_frame
	frame $edit_dotless.error_frame

	text $edit_dotless.text_frame.txt -height 30 -width 80 \
		-xscrollcommand ".text_frame.xscroll set" \
		-yscrollcommand ".text_frame.yscroll set"

	$edit_dotless.text_frame.txt insert end ""

        scrollbar $edit_dotless.text_frame.yscroll -orient vertical \
                -command "$edit_dotless.text_frame.txt yview"
        scrollbar $edit_dotless.text_frame.xscroll -orient horizontal \
                -command "$edit_dotless.text_frame.txt xview"


	grid config $edit_dotless.text_frame.txt -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $edit_dotless.text_frame.yscroll -column 1 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $edit_dotless.text_frame.xscroll -column 0 -row 1 \
		-columnspan 1 -rowspan 1 -sticky "snew"

	button $edit_dotless.button_frame.asm -text "Assemble" \
			-padx 1 -pady 1 -width 8 \
			-command do_assemble
	button $edit_dotless.button_frame.debug -text "Debug" \
			-padx 1 -pady 1 -width 8 \
			-width 10 -command show_debug

	grid config $edit_dotless.button_frame.asm -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "sw" -padx 2 -pady 2
	grid config $edit_dotless.button_frame.debug -column 2 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "sw" -padx 2 -pady 2

	text $edit_dotless.error_frame.txt -height 4 -width 60 \
		-xscrollcommand "$EDIT_BASENAME.error_frame.xscroll set" \
		-yscrollcommand "$EDIT_BASENAME.error_frame.yscroll set"

        scrollbar $edit_dotless.error_frame.yscroll -orient vertical \
                -command "$EDIT_BASENAME.error_frame.txt yview"
        scrollbar $edit_dotless.error_frame.xscroll -orient horizontal \
                -command "$EDIT_BASENAME.error_frame.txt xview"

	grid config $edit_dotless.error_frame.txt -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $edit_dotless.error_frame.yscroll -column 1 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $edit_dotless.error_frame.xscroll -column 0 -row 1 \
		-columnspan 1 -rowspan 1 -sticky "snew"

	grid config $edit_dotless.menubar -column 0 -row 0 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $edit_dotless.button_frame -column 0 -row 1 \
		-columnspan 1 -rowspan 1 -sticky "snw"
	grid config $edit_dotless.text_frame -column 0 -row 2 \
		-columnspan 1 -rowspan 1 -sticky "snew"
	grid config $edit_dotless.error_frame -column 0 -row 3 \
		-columnspan 1 -rowspan 1 -sticky "snew"

	## Set up grid for resizing.
	
	## Column 0 (the only one) gets the extra space.
	grid columnconfigure $edit_name 0 -weight 1
	grid columnconfigure $edit_dotless.text_frame 0 -weight 1
	grid columnconfigure $edit_dotless.error_frame 0 -weight 1

	## Row 2 (the program text area) gets the extra space.
	grid rowconfigure $edit_name 2 -weight 1
	grid rowconfigure $edit_dotless.text_frame 0 -weight 1

	focus $edit_dotless.text_frame.txt
	$edit_dotless.text_frame.txt mark set insert 1.0

	wm title $edit_name "Ant Editor"
	wm protocol $edit_name WM_DELETE_WINDOW {
			do_exit
		}

}

