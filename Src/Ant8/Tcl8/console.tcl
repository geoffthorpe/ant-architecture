#
# $Id: console.tcl,v 1.7 2002/08/02 19:35:38 ellard Exp $
#
# Copyright 2002 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

# create a console window with the given parent, name, height and
# width.  (In theory, this allows the creation of multiple consoles,
# although in practice this doesn't work because the "gant" helper
# routines assume that there is one underlying i/o stream.)
#
# The bindings for the console are a subset of the ordinary Text
# widget bindings, plus a new handler for input.
#
# &&& There are still too many bindings.

proc consoleCreate { parent name height width } {

	set root "$parent.$name"

	global consoleBuffer

	set consoleBuffer($parent,$name) ""

	frame $root
	pack $root -side top -fill both -expand true

	scrollbar $root.sy -orient vert \
		-command [list $root.text yview]

	text $root.text -height $height -width $width \
		-wrap char \
		-yscrollcommand [list "$root.sy" set] \

	pack $root.sy -side right -fill y
	pack $root.text -side left -fill both -expand true

	# bindtags is used to control which order the tag bindings are
	# examined.  By removing Text from this list, we remove all of
	# the default text widget bindings.  Then we add a few to our
	# own bindings, to do a few things.  

	bindtags $root.text [list all $root.text]

	bind $root.text <Key> [list consoleHandleInput %A $parent $name]
	bind $root.text <Button-1> [list consoleFocus $parent $name]

	# Fix this...
	bind $root.text <Control-Key> [list consoleControlKey %K %A $parent $name]

	# &&& It would be nice if this pasted the current selection,
	# instead of doing nothing.

	bind $root.text <Button-2> { break }

	return
}

# Append output to the console window.  (Output ALWAYS appears at the
# end of the window.)
#
# Note that we always make sure that the end of the output is visible,
# scrolling if necessary.  Whether or not this is "right" is
# questionable, but people are used to it so we'll go along with the
# crowd.

proc consoleOutput { parent name str } {

	# DJE &&& configuring the state shouldn't be necessary, if
	# everything else is right.

	$parent.$name.text configure -state normal
	$parent.$name.text insert end $str
	$parent.$name.text see end
}

# Clear the console.

proc consoleClear { parent name } {

	# DJE &&& configuring the state shouldn't be necessary, if
	# everything else is right.

	set win $parent.$name.text

	$win configure -state normal
	$win delete 0.0 end
}

# Throw away any pending input.
#
# The arguments are not passed to gantBufferInputFlush right now,
# because of the assumption that there's only one input stream.

proc consoleClearInput { parent name } {

	global consoleBuffer

	set consoleBuffer($parent,$name) ""
	gantBufferInputFlush

}

proc consoleHandleInput { key parent name } {

	global consoleBuffer

	set win $parent.$name.text


	if { $key == "\b" } {

		# Delete anything on the current line, but DO NOT back
		# up and delete previous lines (as is the default).
		#
		# Note that control-keys are drawn as two characters,
		# so to backspace over one of them we need to delete
		# two characters from the window.

		set l [string length $consoleBuffer($parent,$name)]
		if { $l > 0} {

			set last [string range $consoleBuffer($parent,$name) \
						[expr $l - 1] [expr $l - 1]]

			# If it's a control character, then two chars
			# actually need to be erased from the display. 
			# Otherwise, just one.

			binary scan $last "c" v
			if { $v > 26 } {
				$win delete "insert lineend -1 chars"
			} else {
				$win delete "insert lineend -1 chars"
				$win delete "insert lineend -1 chars"
			}

			set consoleBuffer($parent,$name) \
				[string range $consoleBuffer($parent,$name) \
						0 [expr $l - 2]]
		}

		$win see end

	} elseif { $key == "\r" } {

		# OK, now we've seen a whole line (possible empty,
		# but still complete).  Release this line to the
		# buffer of input to the Ant.

		append consoleBuffer($parent,$name) "\n"
		gantBufferInput $consoleBuffer($parent,$name)

		set consoleBuffer($parent,$name) ""

		# Then emit a newline.
		consoleOutput $parent $name "\n"

	} else {

		# NOTE:  doesn't deal well with "funny" characters,
		# like control characters.  Only works with ordinary
		# printable stuff.  This needs work.

		append consoleBuffer($parent,$name) "$key"

		consoleOutput $parent $name "$key"
	}

	# NB:  This little piece of garlic is absolutely necessary in
	# some cases-- otherwise, the event that triggered this call
	# will get passed up through the binding hierarchy to the next
	# layer (probably the default Text bindings).  This needs to
	# be supressed.  returning a "break" code is the way to do
	# that.
	#
	# I've changed the tags associated with this widget so that it
	# shouldn't be necessary, but I want to keep this piece of
	# code (and this comment) in-place because otherwise I'll
	# forget about it and it took a long time to figure this out
	# the first time.

	return -code break
}

# Grab the focus but don't do anything else.  Used to replace the
# button-1 default binding, which moves the insertion point too.

proc consoleFocus { parent name } {

	focus $parent.$name.text

	return -code break
}

# Deal with control keys.  Logically this should be part of the code
# to deal with all other keystrokes, but it's easier to let Tk find
# control keys than it is to pull apart the keysym and figure out what
# it is.  (There's probably a way to do this, but I haven't found
# anything that's less of a hack.)

proc consoleControlKey { key sym parent name } {

	global consoleBuffer

	# Add the sym as-is to the input buffer.  Then take the key
	# and prepend a ^ and add this to the console output.  Note
	# that this has to match up with how back-space is handled.

	append consoleBuffer($parent,$name) "$sym"
	consoleOutput $parent $name "^$key"

	# control-d is special-- at the beginning of input, it
	# indicates that EOI has been seen.

	if { $key == "d" } {
		if { [string length $consoleBuffer($parent,$name)] == 1 } {
			gantBufferInput $consoleBuffer($parent,$name)
			gantConsoleSeenEOI
		}
	}

	return -code break
}

