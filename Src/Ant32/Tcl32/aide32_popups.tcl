#!/opt/local/bin/wish8.0 -f        
# 
# $Id: aide32_popups.tcl,v 1.15 2003/06/05 20:42:42 sara Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.

    global ROOT

    set IMG_BORD 4

#
#  This file contains the following comment blocks:
#
#  1. Configurations Procs:
#     show_config, reset_config
#  2. Console Procs:
#     proc show_console
#  3. TLB Procs:
#     show_tlb, scroll_tlb, scroll_tlb_sb, show_tlb_page
#  4. Physical Memory Display Procs:
#     show_pmem, start_showaddr, change_showaddr, end_showaddr, start_select,
#     change_select, end_select, show_pmem1, start_select1, change_select1, 
#     end_select1, show_pmem2, start_select2, change_select2, end_select2,
#     show_pmem3.
#  5. Watchpoints Procs:
#     show_watchpts, new_watchpt_win.
#  6. Dec - Hex Conversion Procs:
#     show_dhc, clear_dhc, convert_dhc.
#
#
# ----------------------------------------------------------------------
#  1. Configurations Procs
#
# show_config:  display the configurations window
#    CALLED BY: selecting View > Configurations in the main window's menubar
#    PROCS IT CALLS: window_menu_plus, window_menu_hide, update_display
#    clear_display
# reset_config: reset the values in the config. window to their defaults
#    CALLED BY:  selecting the Reset Configurations button in the 
#    Configurations window
#    PROCS IT CALLS: get_register_label, update_display, clear_display
# ----------------------------------------------------------------------
#
#
proc show_config {} {

global register_label  # what is used to label the registers
global register_choice # what the user selected, can be "default"
global pop_up_exc_reg
global temp_reg

  if [winfo exists .cONFIG] {
    wm deiconify .cONFIG
    raise .cONFIG
  } else {
    toplevel .cONFIG
    wm title .cONFIG  "Configurations"

    frame .cONFIG.conTopF -borderwidth 4 -relief groove
    pack .cONFIG.conTopF -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
    button .cONFIG.conTopF.closeB -padx 9 -pady 3 -text "Close Window" \
      -command  "window_menu_hide .cONFIG"
    pack .cONFIG.conTopF.closeB -padx 0 -pady 4 -side top

    frame .cONFIG.conMidF -borderwidth 4 -relief groove
    pack .cONFIG.conMidF -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top

    frame .cONFIG.conMidF.regF -borderwidth 4 -relief groove
    pack .cONFIG.conMidF.regF -fill x -ipadx 6 -ipady 6 -padx 0 \
      -pady 0 -side top
    label .cONFIG.conMidF.regF.regL -text "Register Display Mode:   "
    pack .cONFIG.conMidF.regF.regL -side left
    radiobutton .cONFIG.conMidF.regF.sRB -text "Source File" \
       -variable  register_choice -value 0 \
       -command "get_register_label; clear_display; update_display"
    pack .cONFIG.conMidF.regF.sRB -side left
    radiobutton .cONFIG.conMidF.regF.gRB -text " 'G' " \
       -variable  register_choice -value 1 \
       -command "get_register_label; clear_display; update_display"
    pack .cONFIG.conMidF.regF.gRB -side left
    radiobutton .cONFIG.conMidF.regF.rRB -text " 'R' " \
       -variable  register_choice -value 2 \
       -command "get_register_label; clear_display; update_display"
    pack .cONFIG.conMidF.regF.rRB -side left
    radiobutton .cONFIG.conMidF.regF.aRB -text "Advanced" \
       -variable  register_choice -value 3 \
       -command "get_register_label; clear_display; update_display"
    pack .cONFIG.conMidF.regF.aRB -side left

    frame .cONFIG.conMidF.tmpF -borderwidth 4 -relief groove
    pack .cONFIG.conMidF.tmpF -fill x -ipadx 6 -ipady 6 -padx 0 \
      -pady 0 -side top
    label .cONFIG.conMidF.tmpF.tmpL -text \
      "Display Temp Registers in Main Window:      "
    pack .cONFIG.conMidF.tmpF.tmpL -side left
    radiobutton .cONFIG.conMidF.tmpF.noRB -text "yes" \
       -variable  temp_reg -value 0 -command temp_reg_yes
    pack .cONFIG.conMidF.tmpF.noRB -side left
    radiobutton .cONFIG.conMidF.tmpF.yesRB -text "no" \
       -variable  temp_reg -value 1 -command temp_reg_no
    pack .cONFIG.conMidF.tmpF.yesRB -side left

    frame .cONFIG.conMidF.excF -borderwidth 4 -relief groove
    pack .cONFIG.conMidF.excF -fill x -ipadx 6 -ipady 6 -padx 0 \
      -pady 0 -side top
    label .cONFIG.conMidF.excF.excL -text \
      "Pop Up Exception Registers Automatically:   "
    pack .cONFIG.conMidF.excF.excL -side left
    radiobutton .cONFIG.conMidF.excF.noRB -text "yes" \
       -variable  pop_up_exc_reg -value 1
    pack .cONFIG.conMidF.excF.noRB -side left
    radiobutton .cONFIG.conMidF.excF.yesRB -text "no" \
       -variable  pop_up_exc_reg -value 0
    pack .cONFIG.conMidF.excF.yesRB -side left

    frame .cONFIG.conBotF -borderwidth 4 -relief groove
    pack .cONFIG.conBotF -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
    button .cONFIG.conBotF.resetB -padx 9 -pady 3 -text "Reset Configurations" \
       -command reset_config
    pack .cONFIG.conBotF.resetB -padx 0 -pady 4 -side top
  }
  window_menu_plus .cONFIG
  wm protocol .cONFIG WM_DELETE_WINDOW "window_menu_hide .cONFIG"
}
#
#
proc reset_config {} {

global register_label  # what is used to label the registers
global register_choice # what the user selected, can be "default"
global pop_up_exc_reg
global temp_reg
global filename

  set register_choice 0
  set pop_up_exc_reg 0
  set temp_reg 0

  if [info exists filename] {
     get_register_label
  }
  clear_display
  update_display
}
#
#
# ----------------------------------------------------------------------
#  2. Console Procs
#
# proc show_console: displays the i/o console
#    CALLED BY: view menu bar view > console, do_run, do_step, handle_output. 
#    PROCS IT CALLS: window_menu_hide, window_menu_plus.
# ----------------------------------------------------------------------
#
#
proc show_console {} {

if [winfo exists .cONSOLE] {
  wm deiconify .cONSOLE
  raise .cONSOLE
} else {
  toplevel .cONSOLE
  wm title .cONSOLE  "Console"

  frame .cONSOLE.conTopF -borderwidth 0
  pack .cONSOLE.conTopF -fill x -padx 0 -pady 0 -side top

  button .cONSOLE.conTopF.button1 -padx 9 -pady 3 -text "Close Window" -command "window_menu_hide .cONSOLE"
  pack .cONSOLE.conTopF.button1 -padx 8 -pady 8 -side top

  frame .cONSOLE.conDataF -borderwidth 4 -relief groove
  pack .cONSOLE.conDataF -fill x -padx 0 -pady 0 -side bottom

  frame .cONSOLE.conDataF.conInF -borderwidth 4 -relief groove
  pack .cONSOLE.conDataF.conInF -fill x -padx 0 -pady 0 -side top -fill x
  label .cONSOLE.conDataF.conInF.conInL -padx 0 -pady 0 -text "Input (ASCII):"
  pack .cONSOLE.conDataF.conInF.conInL -padx 0 -pady 8 -side top
  text .cONSOLE.conDataF.conInF.conInT -width 64 -height 10 \
        -yscrollcommand ".cONSOLE.conDataF.conInF.conInS set"
  pack .cONSOLE.conDataF.conInF.conInT -padx 4 -pady 8 -side left -fill x -expand 1
  scrollbar .cONSOLE.conDataF.conInF.conInS \
        -command ".cONSOLE.conDataF.conInF.conInT yview"
  pack .cONSOLE.conDataF.conInF.conInS -side right -pady 8 -fill y

  frame .cONSOLE.conDataF.conSizerF -relief groove -bd 2 \
        -cursor double_arrow
  pack .cONSOLE.conDataF.conSizerF -fill x
  canvas .cONSOLE.conDataF.conSizerF.conSizerC -width 100 -height 10 \
        -highlightthickness 0
  pack .cONSOLE.conDataF.conSizerF.conSizerC

  frame .cONSOLE.conDataF.conOutF -borderwidth 4 -relief groove
  pack .cONSOLE.conDataF.conOutF -fill x -padx 0 -pady 0 -side bottom -fill x
  label .cONSOLE.conDataF.conOutF.conOutL -padx 0 -pady 0 -text "Output (ASCII):"
  pack .cONSOLE.conDataF.conOutF.conOutL -padx 8 -pady 8 -side top
  text .cONSOLE.conDataF.conOutF.conOutT -width 64 -height 24 -relief groove \
      -state disabled -yscrollcommand ".cONSOLE.conDataF.conOutF.conOutS set"
  pack .cONSOLE.conDataF.conOutF.conOutT -padx 4 -pady 8 -side left -fill x -expand 1
  scrollbar .cONSOLE.conDataF.conOutF.conOutS \
        -command ".cONSOLE.conDataF.conOutF.conOutT yview"
  pack .cONSOLE.conDataF.conOutF.conOutS -side right -pady 8 -fill y

  .cONSOLE.conDataF.conInF.conInT tag config control -background pink
  .cONSOLE.conDataF.conInF.conInT tag config EOF -background red
  .cONSOLE.conDataF.conInF.conInT insert end EOF EOF

  bind .cONSOLE.conDataF.conInF.conInT <Control-Any-Key> {
    %W insert insert %A
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <Meta-Any-Key> {
    scan %A %%c tmpchar
    %W insert insert "[format %%c [expr $tmpchar+128]]"
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <Delete> {
    if [lsearch -exact [%W tag names insert] EOF]>=0 break
    if [lsearch -exact [%W tag names insert] sent]>=0 {
      tk_messageBox -message "This character can not be deleted because it has already been buffered for input." -icon warning -title Warning -type ok
      break
    }
    %W delete insert
    %W see insert
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <BackSpace> {
    if [lsearch -exact [%W tag names insert-1c] EOF]>=0 break
    if [lsearch -exact [%W tag names insert-1c] sent]>=0 {
      tk_messageBox -message "This character can not be deleted because it has already been buffered for input." -icon warning -title Warning -type ok
      break
    }
    %W delete insert-1c
    %W see insert
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <Down> {
    if [%W compare insert+1l < [lindex [%W tag ranges EOF] 0]] {
      %W mark set insert insert+1l
    } else {
      %W mark set insert [lindex [%W tag ranges EOF] 0]
    }
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <Right> {
    if [%W compare insert+1c < [lindex [%W tag ranges EOF] 0]] {
      %W mark set insert insert+1c
    } else {
      %W mark set insert [lindex [%W tag ranges EOF] 0]
    }
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <1> {
    if [%W compare @%x,%y < [lindex [%W tag ranges EOF] 0]] {
      %W mark set insert @%x,%y
    } else {
      %W mark set insert [lindex [%W tag ranges EOF] 0]
    }
    focus %W
    break
  }
  bind .cONSOLE.conDataF.conInF.conInT <B1-Motion> {
    if [%W compare @%x,%y < [lindex [%W tag ranges EOF] 0]] {
      %W mark set insert @%x,%y
    } else {
      %W mark set insert [lindex [%W tag ranges EOF] 0]
    }
    focus %W
    break
  }
  bind .cONSOLE.conDataF.conSizerF <1> "start_console_shift %X %Y"
  bind .cONSOLE.conDataF.conSizerF <B1-Motion> "console_shift %X %Y"
  bind .cONSOLE.conDataF.conSizerF <ButtonRelease-1> "end_console_shift %X %Y"
  bind .cONSOLE.conDataF.conSizerF.conSizerC <1> "start_console_shift %X %Y"
  bind .cONSOLE.conDataF.conSizerF.conSizerC <B1-Motion> "console_shift %X %Y"
  bind .cONSOLE.conDataF.conSizerF.conSizerC <ButtonRelease-1> "end_console_shift %X %Y"
  bind .cONSOLE.conDataF.conSizerF <Enter> "%W config -relief raised"
  bind .cONSOLE.conDataF.conSizerF <Leave> "%W config -relief groove"
  bind .cONSOLE.conDataF.conOutF.conOutT <Expose> "console_resize_init"
}
window_menu_plus .cONSOLE
wm protocol .cONSOLE WM_DELETE_WINDOW "window_menu_hide .cONSOLE"
}

proc console_resize {win h} {
  global consz
  #only answer resize events for the toplevel window
  if [string compare $win .cONSOLE] return
  bind .cONSOLE <Configure> ""
  set h_in [winfo height .cONSOLE.conDataF.conInF.conInT]
  set h_out [winfo height .cONSOLE.conDataF.conOutF.conOutT]
  if ($h<($h_in+$h_out+$consz(filler))) { #if window has shrunk
    #try to shrink just the bottom (Output)
    if (($h-$h_in-$consz(filler))>(4*$consz(lineht)+$consz(winpad))) {
      set newout [expr ($h-$h_in-$consz(filler)-$consz(winpad))/$consz(lineht)]
      .cONSOLE.conDataF.conOutF.conOutT config -height $newout
    } else { #not enough space so set output to four lines and shrink input
      set newin [expr ($h-$consz(filler)-4*$consz(lineht)-2*$consz(winpad))/$consz(lineht)]
      .cONSOLE.conDataF.conInF.conInT config -height $newin
      .cONSOLE.conDataF.conOutF.conOutT config -height 4
    }
  } else { #window has grown, add to bottom (output) window
    set newout [expr ($h-$h_in-$consz(filler)-$consz(winpad))/$consz(lineht)]
    .cONSOLE.conDataF.conOutF.conOutT config -height $newout
  }
  update
  bind .cONSOLE <Configure> "console_resize %W %h"
}

proc console_resize_init {} {
  global consz
  # draw the resizer "grabber"
  set bg [option get . background background]
  set rgblist [winfo rgb . $bg]
  set dimbg [format #%02x%02x%02x [expr int(0.6*[lindex $rgblist 0])] \
                                  [expr int(0.6*[lindex $rgblist 1])] \
                                  [expr int(0.6*[lindex $rgblist 2])]]
  #top ridge
  .cONSOLE.conDataF.conSizerF.conSizerC create line 30 2 70 2 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 30 3 70 3 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 31 3 70 3 -fill $dimbg
  #bottom ridge
  .cONSOLE.conDataF.conSizerF.conSizerC create line 30 6 70 6 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 30 7 70 7 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 31 7 70 7 -fill $dimbg
  #left downward arrow
  .cONSOLE.conDataF.conSizerF.conSizerC create line 0 2 8 2 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 0 2 4 8 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 4 8 8 2 -fill $dimbg
  #left upward arrow
  .cONSOLE.conDataF.conSizerF.conSizerC create line 10 8 18 8 -fill $dimbg
  .cONSOLE.conDataF.conSizerF.conSizerC create line 14 2 18 8 -fill $dimbg
  .cONSOLE.conDataF.conSizerF.conSizerC create line 10 8 14 2 -fill white
  #right downward arrow
  .cONSOLE.conDataF.conSizerF.conSizerC create line 91 2 99 2 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 91 2 95 8 -fill white
  .cONSOLE.conDataF.conSizerF.conSizerC create line 95 8 99 2 -fill $dimbg
  #right upward arrow
  .cONSOLE.conDataF.conSizerF.conSizerC create line 81 8 89 8 -fill $dimbg
  .cONSOLE.conDataF.conSizerF.conSizerC create line 85 2 89 8 -fill $dimbg
  .cONSOLE.conDataF.conSizerF.conSizerC create line 81 8 85 2 -fill white

  # filler is the total height of all non-text widgets
  set consz(filler) [expr [winfo height .cONSOLE]-[winfo height .cONSOLE.conDataF.conInF.conInT]-[winfo height .cONSOLE.conDataF.conOutF.conOutT]]
  # lineht is the pixel height of a single row of text
  set consz(lineht) [lindex [.cONSOLE.conDataF.conOutF.conOutT bbox @0,0] 3]
  # winpad is the extra height of the text widget that is padding
  set consz(winpad) [expr [lindex [.cONSOLE.conDataF.conOutF.conOutT bbox @0,0] 0]*2]
  # constrain the window to its current width, and enough space for four lines
  # in each text widget
  wm minsize .cONSOLE [winfo width .cONSOLE] [expr $consz(lineht)*8+$consz(winpad)*2+$consz(filler)]
  bind .cONSOLE <Configure> {console_resize %W %h}
  # disable the binding that called this init function
  bind .cONSOLE.conDataF.conOutF.conOutT <Expose> ""
}

proc start_console_shift {x y} {
  global consz
  set consz(sx) $x
  set consz(sy) $y
  set consz(inrows) [.cONSOLE.conDataF.conInF.conInT cget -height]
  set consz(outrows) [.cONSOLE.conDataF.conOutF.conOutT cget -height]
  bind .cONSOLE <Configure> ""
}

proc console_shift {x y} {
  global consz
  set pixel_dy [expr $y-$consz(sy)]
  set line_dy [expr ($pixel_dy+$consz(lineht)/2)/$consz(lineht)]
  set newin [expr $consz(inrows)+$line_dy]
  set newout [expr $consz(outrows)-$line_dy]
  if ($newin<4) {
    set newin 4
    set newout [expr $consz(outrows)+$consz(inrows)-4]
  }
  if ($newout<4) {
    set newout 4
    set newin [expr $consz(outrows)+$consz(inrows)-4]
  }
  .cONSOLE.conDataF.conInF.conInT config -height $newin
  .cONSOLE.conDataF.conOutF.conOutT config -height $newout
}

proc end_console_shift {x y} {
  update
  bind .cONSOLE <Configure> "console_resize %W %h"
}

#
#
# ----------------------------------------------------------------------
#  3. TLB Procs
#
# show_tlb:  displays the tlb window
#    CALLED BY: View>TLB menubar in main window
#    PROCS IT CALLS: scroll_tlb, scroll_tlb_sb, update_tlb, show_tlb_page,
#    window_menu_hide, window_menu_plus
# scroll_tlb: scroll tlb entries
#    CALLED BY: show_tlb
#    PROCS IT CALLS: -
# scroll_tlb_sb: adjust scroll bar
#    CALLED BY: show_tlb
#    PROCS IT CALLS: -
# show_tlb_page: displays page of memory which corresponds to TLB entry
#    CALLED BY: show_tlb
#    PROCS IT CALLS: show_pmem3 $tmppagenum
# ----------------------------------------------------------------------
#
#
proc show_tlb {} {

if [winfo exists .tLB] {
  wm deiconify .tLB
  raise .tLB
} else {
  toplevel .tLB
  wm title .tLB  "TLB"

  proc scroll_tlb {args} {
    eval .tLB.tlbDataF.tlbValF.tlbValT yview $args
    eval .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNT yview $args
    eval .tLB.tlbDataF.tlbPpnF.tlbPpnT yview $args
    eval .tLB.tlbDataF.tlbAtribF.tlbAtribT yview $args
    eval .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoT yview $args
  }
  proc scroll_tlb_sb {args} {
    eval .tLB.tlbDataF.tlbDataSB set $args
    .tLB.tlbDataF.tlbValF.tlbValT yview moveto [lindex $args 0]
    .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNT yview moveto [lindex $args 0]
    .tLB.tlbDataF.tlbPpnF.tlbPpnT yview moveto [lindex $args 0]
    .tLB.tlbDataF.tlbAtribF.tlbAtribT yview moveto [lindex $args 0]
    .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoT yview moveto [lindex $args 0]
  }

  frame .tLB.tlbTopF -borderwidth 0
  pack .tLB.tlbTopF -fill x -padx 0 -pady 0 -side top
  label .tLB.tlbTopF.selectL -padx 9 -pady 3 \
    -text "Click an entry to display that page"
  pack .tLB.tlbTopF.selectL -padx 8 -pady 8 -side top
  button .tLB.tlbTopF.closeB -padx 9 -pady 3 -text "Close Window" \
    -command "window_menu_hide .tLB"
  pack .tLB.tlbTopF.closeB -padx 8 -pady 8 -side top

  frame .tLB.tlbDataF -borderwidth 4 -relief groove
  pack .tLB.tlbDataF -fill x -padx 0 -pady 0 -side bottom

  frame .tLB.tlbDataF.tlbValF
  pack .tLB.tlbDataF.tlbValF -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbValF.tlbValL -text "Entry #"
  pack .tLB.tlbDataF.tlbValF.tlbValL -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbValF.tlbValT -height 16 -relief groove -width 2 \
    -yscrollcommand scroll_tlb_sb
  pack .tLB.tlbDataF.tlbValF.tlbValT -padx 0 -pady 0 -side top

  frame .tLB.tlbDataF.tlbVsegPNF
  pack .tLB.tlbDataF.tlbVsegPNF -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNL -text "V Seg PN"
  pack .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNL -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNT -height 16 -relief groove -width 7 \
    -yscrollcommand scroll_tlb_sb
  pack .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNT -padx 8 -pady 0 -side top

  frame .tLB.tlbDataF.tlbPpnF
  pack .tLB.tlbDataF.tlbPpnF -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbPpnF.tlbPpnL -text "Phys PN"
  pack .tLB.tlbDataF.tlbPpnF.tlbPpnL -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbPpnF.tlbPpnT -height 16 -relief groove -width 7\
    -yscrollcommand scroll_tlb_sb
  pack .tLB.tlbDataF.tlbPpnF.tlbPpnT -padx 0 -pady 0 -side top

  frame .tLB.tlbDataF.tlbAtribF
  pack .tLB.tlbDataF.tlbAtribF -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbAtribF.tlbAtribL -text "Attributes"
  pack .tLB.tlbDataF.tlbAtribF.tlbAtribL -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbAtribF.tlbAtribT -height 16 -relief groove -width 12 \
    -yscrollcommand scroll_tlb_sb
  pack .tLB.tlbDataF.tlbAtribF.tlbAtribT -padx 8 -pady 0 -side top
  .tLB.tlbDataF.tlbAtribF.tlbAtribT tag configure bold  -foreground black

  frame .tLB.tlbDataF.tlbOSinfoF
  pack .tLB.tlbDataF.tlbOSinfoF -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoL -text "OSinfo"
  pack .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoL -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoT -height 16 -relief groove -width 7 \
    -yscrollcommand scroll_tlb_sb
  pack .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoT -padx 8 -pady 0 -side top

  scrollbar .tLB.tlbDataF.tlbDataSB -activerelief flat -width 12 -command scroll_tlb
  pack .tLB.tlbDataF.tlbDataSB -expand 1 -fill y -padx 0 -pady 0 -side top

  proc show_tlb_page {win x y} {
    set tmpi [$win index @$x,$y]
    set tmppagenum [expr [.tLB.tlbDataF.tlbPpnF.tlbPpnT get \
                            "$tmpi linestart" "$tmpi lineend"]]
    show_pmem3 $tmppagenum
  }

  bind .tLB.tlbDataF.tlbValF.tlbValT <1> "show_tlb_page %W %x %y"
  bind .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNT <1> "show_tlb_page %W %x %y"
  bind .tLB.tlbDataF.tlbPpnF.tlbPpnT <1> "show_tlb_page %W %x %y"
  bind .tLB.tlbDataF.tlbAtribF.tlbAtribT <1> "show_tlb_page %W %x %y"
  bind .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoT <1> "show_tlb_page %W %x %y"

  .tLB.tlbDataF.tlbValF.tlbValT tag config hit -background white -foreground blue

  update_tlb
}
window_menu_plus .tLB
wm protocol .tLB WM_DELETE_WINDOW "window_menu_hide .tLB"
}
#
#
# ----------------------------------------------------------------------
#  4. Physical Memory Display Procs
#
# show_pmem: display physical memory: all pages
#        CALLED BY: View>Physical Memory menu in main window
#        PROCS IT CALLS: show_pmem1, start_select, change_select, end_select,
#        start_showaddr, change_showaddr, window_menu_plus, 
#        window_menu_hide, window_menu_minus
#     start_showaddr, change_showaddr, end_showaddr: display cursor's address
#          CALLED BY: show_pmem
#          PROCS IT CALLS: -
#     start_select, change_select, end_select: 
#          enable user to select region displayed by show_pmem in greater detail
#          CALLED BY: show_pmem
#          PROCS IT CALLS: -
# show_pmem1: display physical memory: 2046 pages
#        CALLED BY: show_pmem
#        PROCS IT CALLS: show_pmem2, window_menu_hide, window_menu_minus, 
#        window_menu_plus, start_select1, change_select1, end_select1
#     start_select1, change_select1, end_select1:
#          enable user to select region displayed by show_pmem1 in greater detail
#          CALLED BY: show_pmem1 
#          PROCS IT CALLS: -
# show_pmem2: display physical memory: 255 pages
#        CALLED BY: show_pmem1
#        PROCS IT CALLS: show_pmem3, window_menu_hide, window_menu_minus, 
#        window_menu_plus, start_select2, change_select2, end_select2
#     start_select2, change_select2, end_select2: 
#          enable user to select region displayed by show_pmem2 in greater detail
#          CALLED BY: show_pmem2 
#          PROCS IT CALLS: -
# show_pmem3: display physical memory: 1 Readable Page
#        CALLED BY: show_pmem2, show_tlb_page.
#        PROCS IT CALLS: window_menu_hide, window_menu_minus, window_menu_plus, add_line
# ----------------------------------------------------------------------
#
#
proc show_pmem {} {

global pmem_cnt
global pmem_start pmem_select pmem_pages
global pagehit
global IMG_BORD

incr pmem_cnt

set pmem_start(.pMEM$pmem_cnt) 0
set pmem_pages(.pMEM$pmem_cnt) 262144
toplevel .pMEM$pmem_cnt
wm title .pMEM$pmem_cnt  "<Physical Memory $pmem_cnt> All Pages (pixel/page)"

frame .pMEM$pmem_cnt.pmemTopF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF -fill x -side top

frame .pMEM$pmem_cnt.pmemTopF.noF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.noF -fill x -side top

label .pMEM$pmem_cnt.pmemTopF.noF.selPageL -text \
      " Select region with mouse "
pack .pMEM$pmem_cnt.pmemTopF.noF.selPageL -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemTopF.soF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.soF -fill x -side bottom

button .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 9 -pady 3 -text OK \
 -command "show_pmem1 \$pmem_select(.pMEM$pmem_cnt)" 
.pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled

pack .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 8 -pady 8 -side left
button .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 9 -pady 3 -text Cancel \
  -command ".pMEM$pmem_cnt.pmemDataF.pmemDataC delete select;
            .pMEM$pmem_cnt.pmemTopF.noF.selPageL config -text \
            { Select region with mouse };
            .pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled;
            unset pmem_select(.pMEM$pmem_cnt)"
pack .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 9 -pady 3 -text "Close Window" \
 -command  "window_menu_hide .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 9 -pady 3 -text "Delete Window" \
 -command  "window_menu_minus .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemDataF -borderwidth 4 -relief groove
pack .pMEM$pmem_cnt.pmemDataF -fill x -side top

canvas .pMEM$pmem_cnt.pmemDataF.pmemDataC -width 520 -height 520
pack .pMEM$pmem_cnt.pmemDataF.pmemDataC -padx 8 -pady 8 -side top
image create photo page_image$pmem_cnt -width 512 -height 512
page_image$pmem_cnt blank
page_image$pmem_cnt put black   -to   0   0 512 512
.pMEM$pmem_cnt.pmemDataF.pmemDataC create image $IMG_BORD $IMG_BORD -image page_image$pmem_cnt -anchor nw

  set list [array names pagehit]

  foreach hit $list {
    set x [expr $hit%512]
    set y [expr $hit/512]
    page_image$pmem_cnt put white -to $x $y
  }

bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <1> "start_select %W %y"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <ButtonRelease-1> \
"end_select %W %y $pmem_cnt"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <B1-Motion> "change_select %W %y"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <2> "start_showaddr %W %x %y"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <B2-Motion> "change_showaddr %W %x %y"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <ButtonRelease-2> "end_showaddr %W"

window_menu_plus .pMEM$pmem_cnt
wm protocol .pMEM$pmem_cnt WM_DELETE_WINDOW "window_menu_minus .pMEM$pmem_cnt"

}
#
#
proc start_showaddr {win x y} {

  global IMG_BORD
  $win config -cursor cross_reverse
  incr x -$IMG_BORD; if $x<0 {set x 0}; if $x>511 {set x 511}
  incr y -$IMG_BORD; if $y<0 {set y 0}; if $y>511 {set y 511}
  [winfo toplevel $win].pmemTopF.noF.selPageL config -text \
  "Mouse at page [expr $y*512+$x]"
}
#
#
proc change_showaddr {win x y} {

  global IMG_BORD
  incr x -$IMG_BORD; if $x<0 {set x 0}; if $x>511 {set x 511}
  incr y -$IMG_BORD; if $y<0 {set y 0}; if $y>511 {set y 511}
  [winfo toplevel $win].pmemTopF.noF.selPageL config -text \
  "Mouse at page [expr $y*512+$x]"
}
#
#
proc end_showaddr {win} {

  global pmem_select
  $win config -cursor {};
  set topwin [winfo toplevel $win]
  if [info exists pmem_select($topwin)] {
    $topwin.pmemTopF.noF.selPageL config -text \
    "Selected: pages $pmem_select($topwin)-[expr $pmem_select($topwin)+4*512-1]"
  } else {
    $topwin.pmemTopF.noF.selPageL config -text { Select region with mouse };
  }
}
#
#
proc start_select {win y} {

  global IMG_BORD
  $win delete select
  # compensate for window margin
  incr y -$IMG_BORD
  if $y<0 {set y 0}
  if $y>508 {set y 508}
  $win create rectangle $IMG_BORD [expr $y+$IMG_BORD] [expr 511+$IMG_BORD] [expr $y+3+$IMG_BORD] \
     -tags select -outline blue -width 1
  [winfo toplevel $win].pmemTopF.noF.selPageL config -text \
    "Selected: pages [expr $y*512]-[expr ($y+4)*512-1]"
}
#
#
proc change_select {win y} {

  global IMG_BORD
  # compensate for window margin
  incr y -$IMG_BORD
  if $y<0 {set y 0}
  if $y>508 {set y 508}
  $win coords select $IMG_BORD [expr $y+$IMG_BORD] [expr 511+$IMG_BORD] [expr $y+3+$IMG_BORD]
  [winfo toplevel $win].pmemTopF.noF.selPageL config -text \
    "Selected: pages [expr $y*512]-[expr ($y+4)*512-1]"
}
#
#
proc end_select {win y pmem_cnt} {

  global IMG_BORD
  global pmem_select
  # compensate for window margin
  incr y -$IMG_BORD
  if $y<0 {set y 0}
  if $y>508 {set y 508}
  set pmem_select([winfo toplevel $win]) [expr ($y)*512]
  .pMEM$pmem_cnt.pmemTopF.soF.okB config -state normal
}
#
#
proc show_pmem1 {page_start} {

global pmem_cnt
global pagehit
global pmem_start pmem_select pmem_pages

incr pmem_cnt
set pmem_start(.pMEM$pmem_cnt) $page_start
set pmem_pages(.pMEM$pmem_cnt) 2048

toplevel .pMEM$pmem_cnt
wm title .pMEM$pmem_cnt  \
"<Physical Memory $pmem_cnt> Pages $page_start..[expr $page_start+2047] (X/page)"

frame .pMEM$pmem_cnt.pmemTopF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF -fill x -side top

frame .pMEM$pmem_cnt.pmemTopF.noF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.noF -fill x -side top

label .pMEM$pmem_cnt.pmemTopF.noF.selPageL -text \
      " Select region with mouse "
pack .pMEM$pmem_cnt.pmemTopF.noF.selPageL -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemTopF.soF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.soF -fill x -side bottom

button .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 9 -pady 3 -text OK \
 -command "show_pmem2 \$pmem_select(.pMEM$pmem_cnt)"
.pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled
pack .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 9 -pady 3 -text Cancel \
-command ".pMEM$pmem_cnt.pmemDataF.pmemDataT tag remove sel 1.0 end; .pMEM$pmem_cnt.pmemTopF.noF.selPageL config -text { Select region with mouse }; .pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled; unset pmem_select(.pMEM$pmem_cnt)"

pack .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 9 -pady 3 -text "Close Window" -command  "window_menu_hide .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 9 -pady 3 -text "Delete Window" \
 -command  "window_menu_minus .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemDataF -borderwidth 4 -relief groove
pack .pMEM$pmem_cnt.pmemDataF -fill x -side top

text .pMEM$pmem_cnt.pmemDataF.pmemDataT -width 64 -height 32 \
-background blue -foreground black
pack .pMEM$pmem_cnt.pmemDataF.pmemDataT -side top

.pMEM$pmem_cnt.pmemDataF.pmemDataT tag configure hashit \
-background blue -foreground yellow
.pMEM$pmem_cnt.pmemDataF.pmemDataT tag configure latest \
-background red -foreground yellow

  set pagenum $page_start
  for {set i 0} {$i< 32} {incr i} {
    for {set j 0} {$j< 64} {incr j} {
       if [info exists pagehit($pagenum)] {
         .pMEM$pmem_cnt.pmemDataF.pmemDataT insert insert X hashit
       } else {
        .pMEM$pmem_cnt.pmemDataF.pmemDataT insert insert X
      }
      incr pagenum
    }
    .pMEM$pmem_cnt.pmemDataF.pmemDataT insert insert \n
  }

  bind .pMEM$pmem_cnt.pmemDataF.pmemDataT <1> "start_select1 %W %x %y; break"
  bind .pMEM$pmem_cnt.pmemDataF.pmemDataT <ButtonRelease-1> \
    "end_select1 %W %x %y $pmem_cnt; break"
  bind .pMEM$pmem_cnt.pmemDataF.pmemDataT <B1-Motion> \
    "change_select1 %W %x %y; break"

  window_menu_plus .pMEM$pmem_cnt
  wm protocol .pMEM$pmem_cnt WM_DELETE_WINDOW "window_menu_minus .pMEM$pmem_cnt"

}
#
#
proc start_select1 {win x y} {

  global pmem_select pmem_start
  set topwin [winfo toplevel $win]
  set i [$win index @$x,$y]  
  if $i>29 { set i 29.0 }
  $win tag remove sel 0.0 end
  $win tag add sel $i [expr $i+4.0]
  scan $i %d.%d ty tx
  set tmpstart [expr  $pmem_start($topwin)+($ty-1)*64+$tx]
  set tmpend [expr $tmpstart+64*4-1]
  $topwin.pmemTopF.noF.selPageL config -text \
    "Selected: pages $tmpstart-$tmpend"
}
#
#
proc change_select1 {win x y} {

  global pmem_select pmem_start
  set topwin [winfo toplevel $win]
  set i [$win index @$x,$y]  
  if $i>29 { set i 29.0 }
  $win tag remove sel 0.0 end
  $win tag add sel $i [expr $i+4.0]
  scan $i %d.%d ty tx
  set tmpstart [expr $pmem_start($topwin)+($ty-1)*64+$tx]
  set tmpend [expr $tmpstart+64*4-1]
  $topwin.pmemTopF.noF.selPageL config -text \
    "Selected: pages $tmpstart-$tmpend"
}
#
#
proc end_select1 {win x y pmem_cnt} {

  global pmem_select pmem_start
  set topwin [winfo toplevel $win]
  set i [$win index @$x,$y]
  if $i>29 { 
    set i 29.0
    set pmem_select($topwin) [expr $pmem_start($topwin) + 29 * 64]
  } else {
    scan $i %d.%d y1 x1
    set pmem_select($topwin) [expr $pmem_start($topwin) + (($y1-1) * 64) + $x1]
  }
  .pMEM$pmem_cnt.pmemTopF.soF.okB config -state normal
}
#
#
proc show_pmem2 {page_start} {

global pmem_cnt
global wordhit
global IMG_BORD
global pmem_start pmem_select pmem_pages

incr pmem_cnt

set pmem_start(.pMEM$pmem_cnt) $page_start
set pmem_pages(.pMEM$pmem_cnt) 256
toplevel .pMEM$pmem_cnt
wm title .pMEM$pmem_cnt  "<Physical Memory $pmem_cnt> Addresses .. (word/pixel)"

frame .pMEM$pmem_cnt.pmemTopF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF -fill x -side top

frame .pMEM$pmem_cnt.pmemTopF.noF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.noF -fill x -side top

label .pMEM$pmem_cnt.pmemTopF.noF.selPageL -text \
      " Select region with mouse "
pack .pMEM$pmem_cnt.pmemTopF.noF.selPageL -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemTopF.soF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.soF -fill x -side bottom

button .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 9 -pady 3 -text OK \
-command "show_pmem3 \$pmem_select(.pMEM$pmem_cnt)"
.pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled
pack .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 8 -pady 8 -side left 

button .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 9 -pady 3 -text Cancel \
-command ".pMEM$pmem_cnt.pmemDataF.pmemDataC delete select; .pMEM$pmem_cnt.pmemTopF.noF.selPageL config -text { Select region with mouse };  .pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled; unset pmem_select(.pMEM$pmem_cnt)"
pack .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 9 -pady 3 -text "Close Window" -command  "window_menu_hide .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 9 -pady 3 -text "Delete Window" \
 -command  "window_menu_minus .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemDataF -borderwidth 4 -relief groove
pack .pMEM$pmem_cnt.pmemDataF -fill x -side top

canvas .pMEM$pmem_cnt.pmemDataF.pmemDataC -width 520 -height 520
pack .pMEM$pmem_cnt.pmemDataF.pmemDataC -padx 8 -pady 8 -side top
image create photo page_image$pmem_cnt -width 512 -height 512
page_image$pmem_cnt blank
page_image$pmem_cnt put yellow   -to   0   0 512 512
.pMEM$pmem_cnt.pmemDataF.pmemDataC create image $IMG_BORD $IMG_BORD \
  -image page_image$pmem_cnt -anchor nw

  set byte_start [expr $page_start *4096]
  set byte_end [expr $byte_start + 512 * 512 * 4]

  set list [lsort -integer [array names wordhit]]

  foreach hit $list {
    if $hit>$byte_end break
    if $hit<$byte_start continue
    set tmp [expr ($hit-$byte_start)/4]
    set x [expr $tmp%512]
    set y [expr $tmp/512]
    page_image$pmem_cnt put red -to $x $y
  }

bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <1> "start_select2 %W %y"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <ButtonRelease-1> \
"end_select2 %W %y $pmem_cnt"
bind .pMEM$pmem_cnt.pmemDataF.pmemDataC <B1-Motion> "change_select2 %W %y"

window_menu_plus .pMEM$pmem_cnt
wm protocol .pMEM$pmem_cnt WM_DELETE_WINDOW "window_menu_minus .pMEM$pmem_cnt"
}
#
#
proc start_select2 {win y} {

  global IMG_BORD
  global pmem_start pmem_select
  set topwin [winfo toplevel $win]
  $win delete select
  # compensate for window margin
  incr y -$IMG_BORD
  if $y<0 {set y 0}
  if $y>508 {set y 508}
  set y [expr $y-$y%2]
  $win create rectangle $IMG_BORD [expr $y+$IMG_BORD] [expr 511+$IMG_BORD] [expr $y+1+$IMG_BORD] \
     -tags select -outline blue -width 1
  $topwin.pmemTopF.noF.selPageL config -text \
    "Selected: page [expr $pmem_start($topwin)+$y/2]"
}
#
#
proc change_select2 {win y} {

  global IMG_BORD
  global pmem_start pmem_select
  set topwin [winfo toplevel $win]
  # compensate for window margin
  incr y -$IMG_BORD
  if $y<0 {set y 0}
  if $y>508 {set y 508}
  set y [expr $y-$y%2]
  $win coords select $IMG_BORD [expr $y+$IMG_BORD] [expr 511+$IMG_BORD] [expr $y+1+$IMG_BORD]
  $topwin.pmemTopF.noF.selPageL config -text \
    "Selected:  page [expr $pmem_start($topwin)+$y/2]"
}
#
#
proc end_select2 {win y pmem_cnt} {

  global IMG_BORD
  global pmem_start pmem_select
  set topwin [winfo toplevel $win]
  # compensate for window margin
  incr y -$IMG_BORD
  if $y<0 {set y 0}
  if $y>508 {set y 508}
  set y [expr $y-$y%2]
  set pmem_select($topwin) [expr $pmem_start($topwin) + ($y/2)]
  .pMEM$pmem_cnt.pmemTopF.soF.okB config -state normal
}
#
#
proc show_pmem3 {page_start} {

global pmem_cnt
global VM
global pmem_start pmem_select pmem_pages

foreach win [array names pmem_start] {
  if $pmem_start($win)==$page_start {
    window_menu_raise $win
    return
  }
}

set byte_start [expr $page_start*4096]
incr pmem_cnt

set pmem_start(.pMEM$pmem_cnt) $page_start
set pmem_pages(.pMEM$pmem_cnt) 1
toplevel .pMEM$pmem_cnt
wm title .pMEM$pmem_cnt  \
"Readable Page: $page_start   (window $pmem_cnt)"

frame .pMEM$pmem_cnt.pmemTopF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF -fill x -side top

frame .pMEM$pmem_cnt.pmemTopF.noF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.noF -fill x -side top

label .pMEM$pmem_cnt.pmemTopF.noF.selPageL -text \
      " "
pack .pMEM$pmem_cnt.pmemTopF.noF.selPageL -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemTopF.soF -borderwidth 0
pack .pMEM$pmem_cnt.pmemTopF.soF -fill x -side bottom

#button .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 9 -pady 3 -text OK
#.pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled
#pack .pMEM$pmem_cnt.pmemTopF.soF.okB -padx 8 -pady 8 -side left
#button .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 9 -pady 3 -text Cancel \
#-command ".pMEM$pmem_cnt.pmemDataF.pmemDataC delete select; .pMEM$pmem_cnt.pmemTopF.noF.selPageL config -text { Select region with mouse };  .pMEM$pmem_cnt.pmemTopF.soF.okB config -state disabled; unset pmem_select(.pMEM$pmem_cnt)"
#pack .pMEM$pmem_cnt.pmemTopF.soF.cxlB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 9 -pady 3 -text "Close Window" -command  "window_menu_hide .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.closeB -padx 8 -pady 8 -side left

button .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 9 -pady 3 -text "Delete Window" \
 -command  "window_menu_minus .pMEM$pmem_cnt"
 pack .pMEM$pmem_cnt.pmemTopF.soF.deleB -padx 8 -pady 8 -side left

frame .pMEM$pmem_cnt.pmemDataF -borderwidth 4 -relief groove
pack .pMEM$pmem_cnt.pmemDataF -fill x -side top

text .pMEM$pmem_cnt.pmemDataF.pmemDataT -height 36 -relief groove \
-width 53 -yscrollcommand ".pMEM$pmem_cnt.pmemDataF.pmemDataSB set"
.pMEM$pmem_cnt.pmemDataF.pmemDataT tag configure hashit \
-background grey
.pMEM$pmem_cnt.pmemDataF.pmemDataT tag configure latest \
-background yellow -foreground red
pack .pMEM$pmem_cnt.pmemDataF.pmemDataT -side left
scrollbar .pMEM$pmem_cnt.pmemDataF.pmemDataSB -activerelief flat \
-width 12 -command ".pMEM$pmem_cnt.pmemDataF.pmemDataT yview"
pack .pMEM$pmem_cnt.pmemDataF.pmemDataSB -expand 1 -fill y -side top

    #bits to set for accessing physical memory
    set PHYSBITS 0x80000000
    #make sure we show physical addresses
    set byte_start [expr $byte_start | $PHYSBITS]
    # update window (increment by 16 to put 4 words per line)
    for {set ln 0; set i $byte_start} {$ln < 256} {incr ln; incr i 16} {
      add_line .pMEM$pmem_cnt.pmemDataF.pmemDataT [format "0x%08x: " $i]
      for {set j $i} {$j<$i+16} {incr j 4} {
        if [catch "$VM get_mem $j" value] {
          set output " [format  %-8s $value]"
	} else {
          set output " [format  %08x $value]"
	}
        if [winfo exists wordhit($j)] {
          add_line .pMEM$pmem_cnt.pmemDataF.pmemDataT $output hashit
        } else {
          add_line .pMEM$pmem_cnt.pmemDataF.pmemDataT $output
        }
      }
      add_line .pMEM$pmem_cnt.pmemDataF.pmemDataT "\n"
    }
  window_menu_plus .pMEM$pmem_cnt
wm protocol .pMEM$pmem_cnt WM_DELETE_WINDOW "window_menu_minus .pMEM$pmem_cnt"
}
#
#
# ----------------------------------------------------------------------
#  5. Watchpoints Procs
#
# show_watchpts: display watchpoints window
#    CALLED BY: Tools>Watchpoints menu in main window
#    PROCS IT CALLS: new_watchpt_win, window_menu_hide, window_menu_plus
# new_watchpt_win: display window to add a watchpoint
#    CALLED BY: show_watchpts
#    PROCS IT CALLS: window_menu_hide, add_watchpoint, window_menu_plus.
# ----------------------------------------------------------------------
#
#
proc show_watchpts {} {

if [winfo exists .wATCHPT] {
  wm deiconify .wATCHPT
  raise .wATCHPT
} else {
  toplevel .wATCHPT
  wm title .wATCHPT  "Watch Points"

# Buttons
frame .wATCHPT.watTopF -borderwidth 4 -relief groove
pack .wATCHPT.watTopF -fill x -side top
button .wATCHPT.watTopF.newB -padx 9 -pady 3 -text "Add New Watchpoint" -command new_watchpt_win
pack .wATCHPT.watTopF.newB -padx 8 -pady 8 -side left
button .wATCHPT.watTopF.closeB -padx 9 -pady 3 -text "Close Window" -command "window_menu_hide .wATCHPT"
pack .wATCHPT.watTopF.closeB -padx 8 -pady 8 -side left

# Header
frame .wATCHPT.watHdrF -borderwidth 4 -relief groove
pack .wATCHPT.watHdrF -fill x -side top
# Data Type
label .wATCHPT.watHdrF.typeL -text "Data Type" -width 20
pack .wATCHPT.watHdrF.typeL -side left
# When to Stop
label .wATCHPT.watHdrF.stopL -text "Stopping Condition" -width 20
pack .wATCHPT.watHdrF.stopL -side left
# Location
label .wATCHPT.watHdrF.locL -text Location -width 10
pack .wATCHPT.watHdrF.locL -side left
# data
label .wATCHPT.watHdrF.valL -text Value -width 20
pack .wATCHPT.watHdrF.valL -side left

}
window_menu_plus .wATCHPT
wm protocol .wATCHPT WM_DELETE_WINDOW "window_menu_hide .wATCHPT"
}
#
#
proc new_watchpt_win {} {

  global VM register_label

if [winfo exists .nWATCHPT] {
  wm deiconify .nWATCHPT
  raise .nWATCHPT
} else {
toplevel .nWATCHPT
wm title .nWATCHPT  "New Watch Point"

frame .nWATCHPT.nwpMemF -borderwidth 4 -relief groove
pack .nWATCHPT.nwpMemF -anchor n -fill x -ipady 8 -side top
label .nWATCHPT.nwpMemF.nwpVarL -text "Enter Memory Address:"
pack .nWATCHPT.nwpMemF.nwpVarL -padx 8 -pady 8 -side left
entry .nWATCHPT.nwpMemF.nwpVarE -width 12
pack .nWATCHPT.nwpMemF.nwpVarE -padx 8 -pady 8 -side left
button .nWATCHPT.nwpMemF.okB -padx 9 -pady 3 -text OK -command {
  window_menu_hide .nWATCHPT;
  add_watchpoint mem [expr [.nWATCHPT.nwpMemF.nwpVarE get]+0]
}
pack .nWATCHPT.nwpMemF.okB -padx 20 -side right

frame .nWATCHPT.nwpRegF -borderwidth 4 -relief groove
pack .nWATCHPT.nwpRegF -anchor n -fill x -side top
label .nWATCHPT.nwpRegF.nwpVarL -text "Select Register:"
pack .nWATCHPT.nwpRegF.nwpVarL -padx 8 -pady 8 -side left
menubutton .nWATCHPT.nwpRegF.nwpVarM -menu .nWATCHPT.nwpRegF.nwpVarM.m \
    -indicatoron 1 -borderwidth 2 -relief raised
pack .nWATCHPT.nwpRegF.nwpVarM -padx 8 -pady 8 -side left
button .nWATCHPT.nwpRegF.okB -padx 9 -pady 3 -text OK -command {
  window_menu_hide .nWATCHPT;
  add_watchpoint reg $new_watch_point_register
}
pack .nWATCHPT.nwpRegF.okB -padx 20 -side right
menu .nWATCHPT.nwpRegF.nwpVarM.m -tearoff 0

set new_watch_point_register 4
for {set i 0} {$i<[$VM get_num_registers]} {incr i} {
  set cb 0
  if $i%16==0 { set cb 1 }
  if $i==$new_watch_point_register { .nWATCHPT.nwpRegF.nwpVarM config -text [$VM register_name $i $register_label] }
  .nWATCHPT.nwpRegF.nwpVarM.m add command -columnbreak $cb \
      -label [$VM register_name $i $register_label] \
      -command ".nWATCHPT.nwpRegF.nwpVarM config -text [$VM register_name $i $register_label]; set new_watch_point_register $i"
}

frame .nWATCHPT.nwpCxlF -borderwidth 4 -relief groove
pack .nWATCHPT.nwpCxlF -anchor n -fill x -side top
button .nWATCHPT.nwpCxlF.cxlB -padx 9 -pady 3 -text "Cancel" -command "window_menu_hide .nWATCHPT"
pack .nWATCHPT.nwpCxlF.cxlB -side right

window_menu_plus .nWATCHPT
wm protocol .nWATCHPT WM_DELETE_WINDOW "window_menu_hide .nWATCHPT"
}
}
#
#
# ----------------------------------------------------------------------
#  6. Dec - Hex Conversion Procs
#
# show_dhc: displays dec-hex conversion tool window
#    CALLED BY: selecting Tools > Dec-Hex Conversion in the main window menubar
#    PROCS IT CALLS: convert_dhc, clear_dhc, window_menu_hide, window_menu_plus.
# clear_dhc: Clear Dec - Hex Conversion windows 
#    (all windows: bin, oct, hex, dec)
#    CALLED BY: show_dhc
#    PROCS IT CALLS: - 
# convert_dhc: Dec - Hex Conversion accepts any: bin, oct, hex, dec, and 
#    fills in the other 3 windows.
#    CALLED BY: show_dhc
#    PROCS IT CALLS: - 
# ----------------------------------------------------------------------
#
#
proc show_dhc {} {

if [winfo exists .dHCONV] {
  wm deiconify .dHCONV
  raise .dHCONV
} else {
  toplevel .dHCONV
  wm title .dHCONV  "Dec - Hex Conversion"

# Buttons
frame .dHCONV.dhcTopF -borderwidth 4 -relief groove
pack .dHCONV.dhcTopF -fill x -side top
button .dHCONV.dhcTopF.okB -padx 9 -pady 3 -text "OK" -command convert_dhc
pack .dHCONV.dhcTopF.okB -padx 8 -pady 8 -side left
button .dHCONV.dhcTopF.clearB -padx 9 -pady 3 -text "Clear" -command clear_dhc
pack .dHCONV.dhcTopF.clearB -padx 8 -pady 8 -side left
button .dHCONV.dhcTopF.closeB -padx 9 -pady 3 -text "Close Window" -command "window_menu_hide .dHCONV"
pack .dHCONV.dhcTopF.closeB -padx 8 -pady 8 -side left

# Instructions
frame .dHCONV.dhcInstrF -borderwidth 4 -relief groove
pack .dHCONV.dhcInstrF -fill x -side top
label .dHCONV.dhcInstrF.dhcInstrL -text "Enter data in appropriate column, \nthen click OK, or CLEAR to try again"
pack .dHCONV.dhcInstrF.dhcInstrL -fill x -padx 8 -pady 8 -side top

frame .dHCONV.dhcDataF -borderwidth 4 -relief groove
pack .dHCONV.dhcDataF -fill x -side top

# Binary
frame .dHCONV.dhcDataF.dhcBinF -borderwidth 4 -relief groove
pack .dHCONV.dhcDataF.dhcBinF -fill x -side left
label .dHCONV.dhcDataF.dhcBinF.dhcBinL -text Binary
pack .dHCONV.dhcDataF.dhcBinF.dhcBinL -side top
entry .dHCONV.dhcDataF.dhcBinF.dhcBinE -width 32 -font helvetica12
pack .dHCONV.dhcDataF.dhcBinF.dhcBinE -side top
bind .dHCONV.dhcDataF.dhcBinF.dhcBinE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcBinF.dhcBinE <Any-Key> "clear_dhc %W"

# Octal
frame .dHCONV.dhcDataF.dhcOctF -borderwidth 4 -relief groove
pack .dHCONV.dhcDataF.dhcOctF -fill x -side left
label .dHCONV.dhcDataF.dhcOctF.dhcOctL -text Octal
pack .dHCONV.dhcDataF.dhcOctF.dhcOctL -side top
entry .dHCONV.dhcDataF.dhcOctF.dhcOctE -width 11 -font helvetica12
pack .dHCONV.dhcDataF.dhcOctF.dhcOctE -side top
bind .dHCONV.dhcDataF.dhcOctF.dhcOctE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcOctF.dhcOctE <Any-Key> "clear_dhc %W"

# Hex
frame .dHCONV.dhcDataF.dhcHexF -borderwidth 4 -relief groove
pack .dHCONV.dhcDataF.dhcHexF -fill x -side left
label .dHCONV.dhcDataF.dhcHexF.dhcHexL -text Hex
pack .dHCONV.dhcDataF.dhcHexF.dhcHexL -side top
entry .dHCONV.dhcDataF.dhcHexF.dhcHexE -width 8 -font helvetica12 
pack .dHCONV.dhcDataF.dhcHexF.dhcHexE -side top
bind .dHCONV.dhcDataF.dhcHexF.dhcHexE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcHexF.dhcHexE <Any-Key> "clear_dhc %W"

# Decimal
frame .dHCONV.dhcDataF.dhcDecF -borderwidth 4 -relief groove
pack .dHCONV.dhcDataF.dhcDecF -fill x -side left
label .dHCONV.dhcDataF.dhcDecF.dhcDecL -text Decimal
pack .dHCONV.dhcDataF.dhcDecF.dhcDecL -side top
entry .dHCONV.dhcDataF.dhcDecF.dhcDecE -width 10 -font helvetica12
pack .dHCONV.dhcDataF.dhcDecF.dhcDecE -side top
bind .dHCONV.dhcDataF.dhcDecF.dhcDecE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcDecF.dhcDecE <Any-Key> "clear_dhc %W"
}
window_menu_plus .dHCONV
wm protocol .dHCONV WM_DELETE_WINDOW "window_menu_hide .dHCONV"
}

#
#
proc clear_dhc {args} {

 if {"$args" != ".dHCONV.dhcDataF.dhcBinF.dhcBinE" } {
   .dHCONV.dhcDataF.dhcBinF.dhcBinE delete 0 end
 }
 if {"$args" != ".dHCONV.dhcDataF.dhcOctF.dhcOctE" } {
   .dHCONV.dhcDataF.dhcOctF.dhcOctE delete 0 end
 }
 if {"$args" != ".dHCONV.dhcDataF.dhcHexF.dhcHexE" } {
  .dHCONV.dhcDataF.dhcHexF.dhcHexE delete 0 end
 }
 if {"$args" != ".dHCONV.dhcDataF.dhcDecF.dhcDecE" } {
  .dHCONV.dhcDataF.dhcDecF.dhcDecE delete 0 end
 }
}
#
#
proc convert_dhc {} {

  if [string length [.dHCONV.dhcDataF.dhcBinF.dhcBinE get]]!=0 {
    #
    # Convert from binary to octal, hexadecimal, decimal
    #
    set bin 00000000000000000000000000000000[.dHCONV.dhcDataF.dhcBinF.dhcBinE get]
    set len [string length $bin]
    set bin [string range $bin [expr $len-32] end]
    binary scan [binary format B32 $bin] I result
    .dHCONV.dhcDataF.dhcDecF.dhcDecE delete 0 end
    .dHCONV.dhcDataF.dhcDecF.dhcDecE insert 0 $result
    .dHCONV.dhcDataF.dhcOctF.dhcOctE delete 0 end
    .dHCONV.dhcDataF.dhcOctF.dhcOctE insert 0 [format %o $result]
    .dHCONV.dhcDataF.dhcHexF.dhcHexE delete 0 end
    .dHCONV.dhcDataF.dhcHexF.dhcHexE insert 0 [format %x $result]
  } elseif [string length [.dHCONV.dhcDataF.dhcOctF.dhcOctE get]]!=0 {
    #
    # Convert from octal to binary, hexadecimal, decimal
    #
    .dHCONV.dhcDataF.dhcHexF.dhcHexE delete 0 end
    .dHCONV.dhcDataF.dhcHexF.dhcHexE insert 0 [format %x [expr 0[.dHCONV.dhcDataF.dhcOctF.dhcOctE get] ] ]
    .dHCONV.dhcDataF.dhcDecF.dhcDecE delete 0 end
    .dHCONV.dhcDataF.dhcDecF.dhcDecE insert 0 [expr 0[.dHCONV.dhcDataF.dhcOctF.dhcOctE get] ]
    binary scan [binary format I [.dHCONV.dhcDataF.dhcDecF.dhcDecE get]] B32 result
    .dHCONV.dhcDataF.dhcBinF.dhcBinE delete 0 end
    .dHCONV.dhcDataF.dhcBinF.dhcBinE insert 0 $result
  } elseif [string length [.dHCONV.dhcDataF.dhcHexF.dhcHexE get]]!=0 {
    #
    # Convert from hexadecimal to binary, octal, decimal
    #
    .dHCONV.dhcDataF.dhcOctF.dhcOctE delete 0 end
    .dHCONV.dhcDataF.dhcOctF.dhcOctE insert 0 [format %o [expr 0x[.dHCONV.dhcDataF.dhcHexF.dhcHexE get] ] ]
    .dHCONV.dhcDataF.dhcDecF.dhcDecE delete 0 end
    .dHCONV.dhcDataF.dhcDecF.dhcDecE insert 0 [expr 0x[.dHCONV.dhcDataF.dhcHexF.dhcHexE get] ]
    binary scan [binary format I [.dHCONV.dhcDataF.dhcDecF.dhcDecE get]] B32 result
    .dHCONV.dhcDataF.dhcBinF.dhcBinE delete 0 end
    .dHCONV.dhcDataF.dhcBinF.dhcBinE insert 0 $result
  } elseif [string length [.dHCONV.dhcDataF.dhcDecF.dhcDecE get]]!=0 {
    #
    # Convert from decimal to binary, octal, hexadecimal
    #
    binary scan [binary format I [.dHCONV.dhcDataF.dhcDecF.dhcDecE get]] B32 result
    .dHCONV.dhcDataF.dhcBinF.dhcBinE delete 0 end
    .dHCONV.dhcDataF.dhcBinF.dhcBinE insert 0 $result
    .dHCONV.dhcDataF.dhcOctF.dhcOctE delete 0 end
    .dHCONV.dhcDataF.dhcOctF.dhcOctE insert 0 [format %o [.dHCONV.dhcDataF.dhcDecF.dhcDecE get] ]
    .dHCONV.dhcDataF.dhcHexF.dhcHexE delete 0 end
    .dHCONV.dhcDataF.dhcHexF.dhcHexE insert 0 [format %x [.dHCONV.dhcDataF.dhcDecF.dhcDecE get] ] 
  }
}
#
# End of aide32_popups.tcl
#
