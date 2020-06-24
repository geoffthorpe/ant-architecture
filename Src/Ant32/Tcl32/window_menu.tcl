proc window_menu_plus {window_name window} {
	global ROOT
	# If the item already exists (specifically for non-repeating items, ie TLB, Console)
	#    in the "windows menu" then return
	set end [$DEBUG_BASENAME.menubar.windows.menu index end]

	if {"$end"=="none"} { set end -1 }
  		for {set i 0} {$i<=$end} {incr i} {
    		set label [$DEBUG_BASENAME.menubar.windows.menu entrycget $i -label]
    		if {"$label"=="$window_name"} {
      			return
    		}
  	}
	$DEBUG_BASENAME.menubar.windows.menu add command -label "$window_name" -command "window_menu_raise $window"
}

proc window_menu_minus {window_name window} {
	global DEBUG_BASENAME
	set end [$DEBUG_BASENAME.menubar.windows.menu index end]
	# loop thru until we find the item to be deleted
  	for {set i 0} {$i<=$end} {incr i} {
    		set label [$DEBUG_BASENAME.menubar.windows.menu entrycget $i -label]
    		if {"$label"=="$window_name"} {
      			$DEBUG_BASENAME.menubar.windows.menu delete $i
      			break
    		}
  	}
	wm withdraw "$window"
}

#
# Proc: window_menu_raise, Display Item from "Windows" Menu
#
proc window_menu_raise {window} {
	wm deiconify $window
	raise $window
}

