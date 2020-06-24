#!/opt/local/bin/wish8.0 -f        
#
# $Id: aide32_control.tcl,v 1.14 2003/06/26 20:28:53 sara Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#  This file contains the following comment blocks:
#
#  1. Program Level Control, I/O Procs:
#     open_a32, do_reset, do_full_reset, do_stop, do_run, do_step, do_assemble
#  2. Register Procs:
#     temp_reg_yes, temp_reg_no, get_register_label, show_exc_r
#  3. Windows-Menu Management Procs:
#     window_menu_plus, window_menu_minus, window_menu_hide, window_menu_raise
#  4. Breakpoint and Watchpoint Management Procs:
#     toggle_breakpoint, clear_breakpoints, add_watchpoint, 
#     check_mem_watchpoint, remove_watchpoint
#  5. Console I/O Controls:
#     handle_output, prepare_input
#  6. Instructions Window Menus Procs: Currently these procs are NOT used 
#     because they allow the user to select a number that is NOT an ADDRESS.
#     (SSS, 03/28/03)
#     inst_context_menu_post, inst_context_menu_UNpost, 
#     inst_context_menu_invoke, instrmem_context_menu, phsymem_context_menu, 
#     registers_context_menu
#
#
# ----------------------------------------------------------------------
#  1. Program Level Control, I/O Procs
#
# open_a32: opens -.a32 file and displays the program in the main window
#    CALLED BY: selecting File > Open in the main window's menubar
#    TCL PROCS CALLED: get_register_label, update_display, do_full_reset
#    C FUNCTIONS CALLED: $VM load $filename, $VM get_register PC
# do_reset: reopen -.a32 file and reinitilize main window
#    CALLED BY: Clicking on the Reset button 
#    TCL PROCS CALLED: clear_console, clear_all_memory_hits, clear_display, 
#    update_display
#    C FUNCTIONS CALLED: $VM load $filename
# do_full_reset: open new -.a32 file and initilize main window
#    CALLED BY: File>Open menu item in main window
#    TCL PROCS CALLED: clear_console, clear_all_memory_hits, 
#    window_menu_minus, clear_display
#    C FUNCTIONS CALLED: -
# do_stop:
#    CALLED BY: update_watchpoint, do_run.
#    TCL PROCS CALLED: do_run
#    C FUNCTIONS CALLED: -
# do_run:
#    CALLED BY: Clicking on the Run button in the main window's menubar, do_stop
#    TCL PROCS CALLED: do_stop, show_console, update_line, show_exc_r, 
#    clear_display, update_display, handle_output redraw_physical_memory. 
#    C FUNCTIONS CALLED: $VM get_register.
# do_step: execute the next instruction
#    CALLED BY: Clicking on the Step button
#    TCL PROCS CALLED: show_console, update_line, show_exc_r, handle_output, 
#    clear_display, update_display, add_watchpoint
#    C FUNCTIONS CALLED: $VM get_register, $VM step, $VM get_mem, 
#    $VM find_tlb_entry
# do_assemble: assemble an .asm file, create an .a32 file (INCOMPLETE)
#    CALLED BY: selecting File > Assemble in the main window's menubar
#    TCL PROCS CALLED: gantLoadFromAssembler $filename
#    C FUNCTIONS CALLED: -
# ----------------------------------------------------------------------
#
#
proc open_a32 {} {

global VM 
global filename
global instr_count
global init_PC
global register_label  # what is used to label the registers
global register_choice # what the user selected, can be "default"
global env
global oldFileDialog

    set typelist { 
      {"Ant-32 assembled objects" {".a32"}}
    }

    #if file dialog already exists, don't specify initialdir
    if [info exists oldFileDialog] {
      set filename [tk_getOpenFile -title "Open Ant-32 Assembled File" \
          -filetypes $typelist -initialdir $oldFileDialog]
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
      set filename [tk_getOpenFile -title "Open Ant-32 Assembled File" \
          -filetypes $typelist -initialdir $initdir]
      if [string length $filename] {
        set oldFileDialog [file dirname $filename]
      }
    }

    if [string length $filename]==0 return

    set basename [file tail $filename]
    wm title . "aide32,  file: $basename"
    do_full_reset
    set instr_count [$VM load $filename]
    set init_PC [$VM get_register PC]

    # if user selected default register label (register_choice==0), 
    # determine which one is used in their code

    get_register_label
    update_display
}
#
#
proc do_reset {} {

  global VM
  global filename
  global old_pc
  global pagehit wordhit

  set old_pc ""

  if [info exists wordhit] { unset wordhit }
  if [info exists pagehit] { unset pagehit }

  clear_console
  clear_all_memory_hits

  clear_display
  $VM load $filename
  .buttonbar.runB  config -state normal
  .buttonbar.stepB config -state normal
  set running 0
  update_display
}
#
#
proc do_full_reset {} {

  global VM
  global filename
  global old_pc
  global pagehit wordhit
  global breakpoints watchpoints
  global pmem_start pmem_pages pmem_select

  set old_pc ""

  if [info exists wordhit] { unset wordhit }
  if [info exists pagehit] { unset pagehit }

  clear_console
  clear_all_memory_hits

  if [info exists breakpoints] { unset breakpoints }

  if [info exists watchpoints] {
    foreach key [array names watchpoints] {
      eval remove_watchpoint [split $key ,]
    }
    unset watchpoints
  }

  if [info exists pmem_start] {
    foreach win [array names pmem_start] {
      window_menu_minus $win
      destroy $win
    }
    unset pmem_start
  }
  if [info exists pmem_pages] { unset pmem_pages }
  if [info exists pmem_select] { unset pmem_select }

  .buttonbar.runB  config -state normal
  .buttonbar.stepB config -state normal
  .buttonbar.resetB config -state normal
  .menubar.toolsMB.menu4 entryconfig "Watch Points" -state normal

  clear_display
}
#
#
proc do_stop {} {

  global running
  .buttonbar.runB  config -text Run -command {do_run}
  set running 0
}
#
#
proc do_run {} {

  global VM
  global pop_up_exc_reg
  global old_pc
  global breakpoints speed speedtimes running
  global pmem_start
  set speedtimes(Slow) 1000
  set speedtimes(Medium) 250
  set speedtimes(Fast) 0
  .buttonbar.runB config -text Stop -command {do_stop}
  set running 1
  while {$running} {
    if [prepare_input]==0 {  #user requested opportunity to enter input
      do_stop
      show_console
      break
    }
    set old_pc [$VM get_register pc]
    if [catch "$VM step" result] {
      # update exception registers
      for {set i 0} {$i< 4} {incr i} {
        # k0 - k3: 
        set output [format "           %2s 0x%08x"  k$i \
          [$VM get_register k$i] ]
        update_line .eXCEPTION.excMidF.excF.excD [expr $i+1] $output
      }

      # e0 - e3:
      set output [format "Shadow PC  e0 0x%08x" [$VM get_register e0] ]
      update_line .eXCEPTION.excMidF.excF.excD [expr 1] $output

      set output [format "INT Mask   e1 0x%08x" [$VM get_register e1] ]
      update_line .eXCEPTION.excMidF.excF.excD [expr 2] $output

      set output [format "Fault Addr e2 0x%08x" [$VM get_register e2] ]
      update_line .eXCEPTION.excMidF.excF.excD [expr 3] $output

      set output [format "Exception  e3 0x%08x" [$VM get_register e3] ]
      update_line .eXCEPTION.excMidF.excF.excD [expr 4] $output

      # if pop_up_exc_reg==1, then pop up exc register
      if { $pop_up_exc_reg==1 } {
        if { ! [winfo ismapped .eXCEPTION.excMidF.excF.excD] } {
          show_exc_r
        }
      }
      break
    } elseif {"$result"=="halted"} {
      .buttonbar.runB  config -state disabled
      .buttonbar.stepB config -state disabled
      do_stop
    } elseif [info exists breakpoints([expr [$VM get_register pc]])] {
      do_stop
    } elseif {"$speed"=="Fast"} {
      clear_display
      update_display
      update
    } elseif {"$speed"!="Silent"} {
      clear_display
      update_display
      set waiting 0
      after $speedtimes($speed) { set waiting 1 }
      tkwait variable waiting
    }
    handle_output
  }
  foreach win [array names pmem_start] {
    redraw_physical_memory $win
  }
  clear_display
  update_display
}
#
#
proc do_step {} {

global VM
global pop_up_exc_reg
global old_pc
global watchpoints wp_phys
    if [prepare_input]==0 {  #user requested opportunity to enter input
      show_console
      return
    }
    set old_pc [$VM get_register pc]
    if [catch "$VM step" result] {
      # update exception registers
      for {set i 0} {$i< 4} {incr i} {
        # k0 - k3: 
        set output [format "           %2s 0x%08x"  k$i \
          [$VM get_register k$i] ]
        update_line .eXCEPTION.excMidF.excF.excD [expr $i+1] $output
      }

        # e0 - e3:
        set output [format "Shadow PC  e0 0x%08x" [$VM get_register e0] ]
        update_line .eXCEPTION.excMidF.excF.excD [expr 1] $output

        set output [format "INT Mask   e1 0x%08x" [$VM get_register e1] ]
        update_line .eXCEPTION.excMidF.excF.excD [expr 2] $output

        set output [format "Fault Addr e2 0x%08x" [$VM get_register e2] ]
        update_line .eXCEPTION.excMidF.excF.excD [expr 3] $output

        set output [format "Exception  e3 0x%08x" [$VM get_register e3] ]
        update_line .eXCEPTION.excMidF.excF.excD [expr 4] $output

      # if pop_up_exc_reg==1, then pop up exc register
      if { $pop_up_exc_reg==1 } {
        if { ! [winfo ismapped .eXCEPTION.excMidF.excF.excD] } {
          show_exc_r
        }
      }
    } elseif {"$result"=="halted"} {
      .buttonbar.runB  config -state disabled
      .buttonbar.stepB config -state disabled
      tk_messageBox -message "The CPU is halted" -icon warning -title Warning -type ok
    }
    # check if last instruct was tlbse:
    # (there is an unlikely error condtion that is not checked here:
    # suppose the tlb change made the $old_pc unnavailable?  Odds are this
    # will show up as an error on the next do_step, unless $old_pc was the
    # last address on a page)
    set val [$VM get_mem $old_pc]
    if [expr ($val & 0xff000000) == 0x42000000] {
       # check if there are watchpoints on this page
       foreach wp [array names watchpoints] {
          set type [lindex [split $wp ,] 0]
          set location [lindex [split $wp ,] 1]
          if {"$type"=="mem"} {
            #don't check physical address watchpoints
            if [expr $location&0x80000000] {
               continue
            }
            if [$VM find_tlb_entry $location]==-1 {
              set mess [format "TLB entry used by watchpoint 0x%08x is no longer valid.  Would you like to monitor the physical address, or remove the watchpoint?" $location]
              set action [tk_dialog .wpdeldialog "Invalid Watchpoint" \
                          $mess question 0 "Monitor Physical Address" Remove]
              if $action==0 {
                add_watchpoint mem $wp_phys($location)
              }
              remove_watchpoint mem $location
            }
          }
       }
    }
    handle_output
    clear_display
    update_display
}
#
#
proc do_assemble {} {

set typelist { 
  {"Ant-32 Assembly Files" {".asm"}} 
  {"All Files" {".*"}} 
  }
  set filename [tk_getOpenFile -title "Open Ant-32 Assembly File" \
  -filetypes $typelist]

  # Fixed open file bug
  if { [string compare $filename "" ] == 0} {
	return
  }

  if [catch "open $filename r" fh] {
    tk_messageBox -message "Couldn't open $filename: $fh"
    return
  }
  set contents ""
  while {[gets $fh line]>-1} {
    set contents "$contents$line"
  }
  close $fh

  set rc [gantAssemble $contents]
  if { [string compare $rc "OK"] != 0 } {
    puts "error"
  } else {
    set error ""
    gantLoadFromAssembler $filename
  }
}
#
#
# ----------------------------------------------------------------------
#  2. Register Procs
# 
# temp_reg_yes: displays temporary register information in main window
#    CALLED BY: selecting the display temp register "yes" radiobutton
#    PROCS CALLED: update_display
#    C FUNCTIONS CALLED: -
# temp_reg_no: hides temporary register information in main window
#    CALLED BY: selecting the display temp register "no" radiobutton
#    PROCS CALLED: -
#    C FUNCTIONS CALLED: -
# get_register_label: identify which register labels (r0..., g0..., etc) 
#    are used
#    CALLED BY: open_a32, reset_config
#    PROCS CALLED: -
#    C FUNCTIONS CALLED: $VM codeline
# show_exc_r: display the exception register window
#    CALLED BY: do_step
#    PROCS CALLED: window_menu_plus
#    C FUNCTIONS CALLED: -
# ----------------------------------------------------------------------
#
#
proc temp_reg_yes {} {

  global ROOT
  #pack $ROOT.leftF.state2F.regL -side top
  #pack $ROOT.leftF.state2F.regD -side top
  pack $ROOT.leftF.state2F -side bottom -fill x
  update_display
}
#
#
proc temp_reg_no {} {

global ROOT
  #pack forget $ROOT.leftF.state2F.regL -side top
  #pack forget $ROOT.leftF.state2F.regD -side top
  pack forget $ROOT.leftF.state2F
}
#
#
proc get_register_label {} {

global VM 
global init_PC
global instr_count
global register_label  # what is used to label the registers
global register_choice # what the user selected, can be "default"

  set register_label $register_choice
  if {$register_choice == 0} {
    for {set count 0; set i $init_PC} {$count<$instr_count} \
      {incr count; incr i 4} {
      set line [$VM codeline $i]
      if [regexp {[ \t,]g[0-9]} $line] {
        set register_label 1
        break
      } elseif [regexp {[ \t,]r[0-9]} $line] {
        set register_label 2
        break
      } elseif [regexp {[ \t,]s[0-9]} $line] {
        set register_label 3
        break
      } elseif [regexp {[ \t,]t[0-9]} $line] {
        set register_label 3
        break
      }
    }
  }
}
#
#
proc show_exc_r {} {

  wm deiconify .eXCEPTION
  window_menu_plus .eXCEPTION
}
#
#
# ----------------------------------------------------------------------
#  3. Windows-Menu Management Procs
# 
# window_menu_plus: add new item to the windows menu in the main window 
#    CALLED BY: opening a new pop up window: show_config, show_console, 
#    show_tlb, show_pmem, show_pmem1, show_pmem2, show_pmem3, show_watchpts, 
#    new_watchpt_win, show_exc_r. 
#    PROCS CALLED: -
# window_menu_minus: remove item from the windows menu in the main window 
#    CALLED BY: destroying a pop up window: do_full_reset, show_pmem, 
#    show_pmem1, show_pmem2, show_pmem3. 
#    PROCS CALLED: -
# window_menu_hide: iconify pop-up-window
#    CALLED BY: closing a pop up window: show_config, show_console, show_tlb,
#    show_pmem(1,2,3), show_watchpts, new_watchpt_win, show_dhc, 
#    aide_window_setup 
#    PROCS CALLED: -
# window_menu_raise:  raise/de-iconify pop-up-window
#    CALLED BY: show_pmem3. 
#    PROCS CALLED: -
# ----------------------------------------------------------------------
#
#
proc window_menu_plus {window} {

  global ROOT window_menu
  global window_count

  # If the item already exists (specifically for non-repeating items, ie TLB, 
  # Console)
  #    in the "windows menu" then return
  if [lsearch -exact $window_menu $window]>=0 return
  lappend window_menu $window
  $ROOT.menubar.windoMB.menu5 add command -label [wm title $window] \
     -command  "window_menu_raise $window"
  incr window_count
  $ROOT.menubar.windoMB configure -state normal
}
#
#
proc window_menu_minus {window} {

  global ROOT window_menu
  global window_count

  # get the index of the last current entry in the menu
  set i [lsearch -exact $window_menu $window]
  set window_menu [lreplace $window_menu $i $i]
  $ROOT.menubar.windoMB.menu5 delete $i

  destroy $window
  incr window_count -1
  if ($window_count==0) {
    $ROOT.menubar.windoMB configure -state disabled
  }
}
#
#
proc window_menu_hide {window} {

  global ROOT window_menu
  wm withdraw "$window"
}
#
#
proc window_menu_raise {window} {

wm deiconify $window
raise $window
}
#
#
# ----------------------------------------------------------------------
#  4. Breakpoint and Watchpoint Management Procs
# 
# toggle_breakpoint: turn on and off breakpoints based on mouse click
#    CALLED BY: inst_context_menu_post, Tools > Watchpoints in main window
#    PROCS CALLED: -
# clear_breakpoints: delete all breakpoints
#    CALLED BY: Clear Breakpoints button in main window
#    PROCS CALLED: -
# add_watchpoint: add a new watchpoint
#    CALLED BY: new_watchpt_win, do_step, inst_context_menu_post.
#    PROCS CALLED: show_watchpts, update_watchpoint.
#    C CALLS: $VM find_tlb_entry, $VM get_mem, $VM register_name.
# check_mem_watchpoint: check if this address hits a watchpoint
#    CALLED BY: memory_hit.
#    PROCS CALLED: -
# remove_watchpoint: remove a watchpoint
#    CALLED BY: do_full_reset, do_step, add_watchpoint, remove_watchpoint_win.
#    PROCS CALLED: -
# ----------------------------------------------------------------------
#
#
proc toggle_breakpoint {win y} {

  global init_PC
  global breakpoints
  set i [expr int([$win index @1,$y])]
  set addr [expr $init_PC+4*($i-1)]
  if [info exists breakpoints($addr)] {
    $win config -state normal
    $win delete $i.0 $i.end
    $win config -state disabled
    unset breakpoints($addr)
    if [llength [array names breakpoints]]==0 {
      .buttonbar.clearB config -state disabled
    }
  } else {
    $win config -state normal
    $win insert $i.0 "BRK>"
    $win config -state disabled
    set breakpoints($addr) 1
    .buttonbar.clearB config -state normal
  }
}
#
#
proc clear_breakpoints {} {

  global init_PC
  global breakpoints
  set win .rightF.memInstF.memBrkT
  foreach addr [array names breakpoints] {
    set i [expr ($addr-$init_PC)/4+1]
    if [info exists breakpoints($addr)] {
      $win config -state normal
      $win delete $i.0 $i.end
      $win config -state disabled
      unset breakpoints($addr)
    }
  }
  .buttonbar.clearB config -state disabled
}
#
#
proc add_watchpoint {type location} {

  global VM watchp_cnt watchpoints register_label wp_phys

  # create/raise the watchpoints window
  show_watchpts

  if {"$type"=="mem"} {
    #make sure location is on word boundary in physical segment
    set location [expr ($location-($location%4))]
    if [info exists watchpoints($type,$location)] {
      tk_messageBox -message "This watchpoint already exists" \
           -icon warning -title Warning
      return 0
    }
    if [expr !($location&0x80000000)] {
      if [$VM find_tlb_entry $location]==-1 {
        set mess [format "This virtual address (0x%08x) is not currently valid!" $location]
        tk_messageBox -message $mess -icon warning -title Warning
        return $mess
      } else {
        set wp_phys($location) [$VM virt_to_phys $location]
      }
    }
    if [catch "$VM get_mem $location" value] {
      set value [format %-8s $value]
    } else {
      set value [format 0x%08x $value]
    }
    set locname [format 0x%08x $location]
  } else {
    if [info exists watchpoints($type,$location)] { return 0 }
    set value [format 0x%08x [$VM get_register $location]]
    set locname [$VM register_name $location $register_label]
  }
  
  set win .wATCHPT.frame$watchp_cnt
  frame $win -borderwidth 0
  pack $win -fill x -side top
  menubutton $win.showM -indicatoron 1 -relief raised -pady 0 \
      -menu $win.showM.m -text Hexadecimal -width 16
  pack $win.showM -side left
  menubutton $win.stopM -indicatoron 1 -relief raised -pady 0 \
      -menu $win.stopM.m -text "Read/Write" -width 16
  pack $win.stopM -side left
  label $win.locationL -text $locname -width 10 -font helvetica12
  pack $win.locationL -side left
  label $win.valueL -text $value -width 32 -font helvetica12
  pack $win.valueL -side left
  button $win.removeB -padx 9 -pady 0 -text Remove -font helvetica12 \
      -command "remove_watchpoint $type $location"
  pack $win.removeB -side left

  menu $win.showM.m
  $win.showM.m add command -label Hexadecimal \
        -command "$win.showM config -text Hexadecimal; update_watchpoint $type $location"
  $win.showM.m add command -label "Signed Decimal" \
        -command "$win.showM config -text {Signed Decimal}; update_watchpoint $type $location"
  $win.showM.m add command -label "Unsigned Decimal" \
        -command "$win.showM config -text {Unsigned Decimal}; update_watchpoint $type $location"
  $win.showM.m add command -label Octal \
        -command "$win.showM config -text Octal; update_watchpoint $type $location"
  $win.showM.m add command -label Binary \
        -command "$win.showM config -text Binary; update_watchpoint $type $location"
  $win.showM.m add command -label ASCII \
        -command "$win.showM config -text ASCII; update_watchpoint $type $location"

  menu $win.stopM.m
  $win.stopM.m add command -label "Read/Write" \
        -command "$win.stopM config -text {Read/Write}; update_watchpoint $type $location"
  $win.stopM.m add command -label "Read Only" \
        -command "$win.stopM config -text {Read Only}; update_watchpoint $type $location"
  $win.stopM.m add command -label "Write Only"\
        -command "$win.stopM config -text {Write Only}; update_watchpoint $type $location"
  $win.stopM.m add command -label None \
        -command "$win.stopM config -text None; update_watchpoint $type $location"

  set watchpoints($type,$location) $win
  incr watchp_cnt
  return ""
}
#
#
proc check_mem_watchpoint {address} {

  global watchpoints
  set tmp [expr ($address-($address%4))]
  if [info exists watchpoints(mem,$tmp)] {
    return 1
  } else {
    return 0
  }
}
#
#
proc remove_watchpoint {type location} {

  global watchpoints wp_phys
  if [info exists watchpoints($type,$location)] {
    destroy $watchpoints($type,$location)
    unset watchpoints($type,$location)
    if [info exists wp_phys($location)] { unset wp_phys($location) }
  }
}
#
#
# ----------------------------------------------------------------------
#  5. Console I/O Controls
#
# handle_output: check for ANT output; if found, write it to console window
#    CALLED BY: do_run, do_step.
#    PROCS CALLED: -
#    C CALLS: $VM console.
# prepare_input: send one input charater to ANT (if input available 
# and ANT is ready)
#    CALLED BY: do_run, do_step.
#    PROCS CALLED: -
#    C CALLS: $VM console, $VM get_mem, $VM get_register.
# ----------------------------------------------------------------------
#
#
proc handle_output {} {

  global VM

  # Proc: handle_output - see if the CPU has produced output
  # this is run just after a CPU step
  if [$VM console canget] {
    if ![winfo exists .cONSOLE] {
      show_console
    }
    set val [$VM console get]
    .cONSOLE.conDataF.conOutF.conOutT config -state normal
    .cONSOLE.conDataF.conOutF.conOutT insert end [format %c $val]
    .cONSOLE.conDataF.conOutF.conOutT config -state disabled
  }

  #while we're here, see if the input prepared by prepare_input was
  #taken, and if so delete it from input (we do this here so that console
  #updates immediately after a cin)
  if [$VM console canput] {
    if [winfo exists .cONSOLE] {
      #delete last data we sent from the input window
      if [llength [.cONSOLE.conDataF.conInF.conInT tag ranges sent]] {
        set ranges [.cONSOLE.conDataF.conInF.conInT tag ranges sent]
        eval .cONSOLE.conDataF.conInF.conInT delete $ranges
      }
    }
  }
}
#
#
proc prepare_input {} {

  global VM

  # Proc: prepare_input - if ready, send more data to CPU
  # if there is no data and next instruction is CIN, warn user
  # returns zero to indicate user wants to stop here, 1 otherwise
  # this is run just before a CPU step
  if [$VM console canput] {
    if [winfo exists .cONSOLE] {
      set eofi [lindex [.cONSOLE.conDataF.conInF.conInT tag ranges EOF] 0]
      if [.cONSOLE.conDataF.conInF.conInT compare 1.0 < $eofi] {
        scan [.cONSOLE.conDataF.conInF.conInT get 1.0] "%c" value
        $VM console put $value
        .cONSOLE.conDataF.conInF.conInT tag add sent 1.0
#this is just for debugging, user doesn't need to know when GUI prepares input
.cONSOLE.conDataF.conInF.conInT tag config sent -background red
      }
    }
  }
  
  #if we can STILL send input (i.e. there was nothing to buffer)...
  if [$VM console canput] {
    if [catch "$VM get_mem [$VM get_register pc]" val] {
      #error accessing memory at pc
      #just pretend like things are normal, let the error condition occur
      #naturally at the next do_step.
      return 1
    }
    # if next instruct is cin :
    if [expr ($val & 0xff000000) == 0x24000000] {
        return 0
    }
  }
  return 1
}
#
#
# ----------------------------------------------------------------------
#  6. Instructions Window Menus Procs
# 
#     Currently these procs are NOT being used because they allow the user
#     to select a number that is NOT an ADDRESS. 
# 
# inst_context_menu_post: bring up a menu in the instructions view, 
#    based on what was clicked on.
#    CALLED BY:
#    PROCS CALLED: inst_context_menu_invoke, toggle_breakpoint
#    add_watchpoint, 
#    C CALLS: $VM virt_to_phys
# inst_context_menu_UNpost: get rid of a menu created by inst_context_menu_post
#    CALLED BY:
#    PROCS CALLED: -
# inst_context_menu_invoke: active an entry in a menu created by 
#    CALLED BY:
#    PROCS CALLED: -
# instrmem_context_menu: currently unused; planned for context menus 
#    in instruction memory view (lower right mainwindow panel)
#    CALLED BY:
#    PROCS CALLED: -
# phsymem_context_menu: currently unused; planned for context menus 
# in readable phys mem windows
#    CALLED BY:
#    PROCS CALLED: -
# registers_context_menu: currently unused; planned for context menus 
# in register area of mainwindow
#    CALLED BY:
#    PROCS CALLED: -
# ----------------------------------------------------------------------
#
#
proc inst_context_menu_post {win x y} {

  global VM breakpoints

  if ![winfo exists $win.context_menu] {
    menu $win.context_menu -tearoff 0 -disabledforeground black \
       -foreground #0000c0
    bind $win.context_menu <ButtonRelease> "inst_context_menu_invoke %W; break"
  }
  set i [$win index @$x,$y]
  set line [lindex [split $i .] 0]
  set column [lindex [split $i .] 1]
  $win.context_menu delete 0 end
  if ($column<12) {
    set hexloc [$win get $line.0 $line.10]
    if ![regexp {^0x[0-9a-fA-F]*$} $hexloc] {
      return
    }
    set loc [expr $hexloc]
    $win.context_menu add command -label "Location: $hexloc" -state disabled
    if [expr $loc&0x80000000] {
      $win.context_menu add command -label "  Virtual Address:" -state disabled
    } else {
      set paddr [$VM virt_to_phys $loc]
      if {"$paddr"=="-1"} {
        set txt "TLB miss"
      } else {
        set txt [format 0x%08x $paddr]
      }
      $win.context_menu add command -label "  Physical Address: $txt" \
         -state disabled
    }
    if [info exists breakpoints($loc)] {
      $win.context_menu add command -label "  Clear Breakpoint" \
        -command "toggle_breakpoint .rightF.memInstF.memBrkT $y; $win tag remove sel 1.0 end"
    } else {
      $win.context_menu add command -label "  Set Breakpoint" \
        -command "toggle_breakpoint .rightF.memInstF.memBrkT $y; $win tag remove sel 1.0 end"
    }
    $win tag add sel $line.0 $line.10
    set bbx [$win bbox $line.0]
    set mx [expr [winfo rootx $win]+[lindex $bbx 0]]
    set my [expr [winfo rooty $win]+[lindex $bbx 1]+[lindex $bbx 3]]
    $win.context_menu post $mx $my
    focus $win.context_menu
    tkSaveGrabInfo $win
    grab -global $win
  } else {
    set word [$win get "$i wordstart" "$i wordend"]
    if [regexp {^0x[0-9a-fA-F]*$} $word] {
      set hexval $word
      set val [expr $word]
    } elseif [regexp {^[0-9]*$} $word] {
      set val $word
      set hexval [format 0x%x $word]
    } else {
      return
    }
    $win.context_menu add command -label "Value: $hexval" -state disabled
    $win.context_menu add command -label "  Decimal: $val" -state disabled
    if [expr $val&0x80000000] {
      $win.context_menu add command -label "  Virtual Address:" -state disabled
    } else {
      set paddr [$VM virt_to_phys $val]
      if {"$paddr"=="-1"} {
        set txt "TLB miss"
      } else {
        set txt [format 0x%08x $paddr]
      }
      $win.context_menu add command -label "  Physical Address: $txt" \
         -state disabled
    }
    $win.context_menu add command -label "  Add Watchpoint" \
      -command "add_watchpoint mem $val"
    $win tag add sel "$i wordstart" "$i wordend"
    set bbx [$win bbox "$i wordstart"]
    set mx [expr [winfo rootx $win]+[lindex $bbx 0]]
    set my [expr [winfo rooty $win]+[lindex $bbx 1]+[lindex $bbx 3]]
    $win.context_menu post $mx $my
    focus $win.context_menu
    tkSaveGrabInfo $win
    grab -global $win
  }
}
#
#
proc inst_context_menu_UNpost {win} {

  $win tag remove sel 1.0 end
  $win.context_menu unpost
  tkRestoreOldGrab
  set grab [grab current $win.context_menu]
  if [string compare $grab ""] { grab release $grab }
}
#
#
proc inst_context_menu_invoke {win} {

  [winfo parent $win] tag remove sel 1.0 end
  $win unpost
  tkRestoreOldGrab
  set grab [grab current $win]
  if [string compare $grab ""] { grab release $grab }
  uplevel #0 [list $win invoke active]
}

proc instrmem_context_menu {win x y} { }
proc phsymem_context_menu {win x y} { }
proc registers_context_menu {win x y} { }
#
# End of aide32_control.tcl
#

