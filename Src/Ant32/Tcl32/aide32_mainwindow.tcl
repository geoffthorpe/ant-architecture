#!/opt/local/bin/wish8.0 -f
#
# $Id: aide32_mainwindow.tcl,v 1.16 2003/06/27 17:06:58 sara Exp $
#
# Copyright 2000-2003 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# This file contains the follwing procs:
#
# ----------------------------------------------------------------------
#
# aide_window_setup: sets up the main aide32 window including:
#    menus: File, Speed, View (Configurations, Memory, Console, TLB, 
#       Exception Registers), Tools (Watch Points, Dec-Hex Conversion), 
#       Windows menu.
#    buttons: Run, Step, Reset, Clear Breaks, Exit
#    status area: PC, Mode, dedicated registers: (ra,sp,fp)
#       all registers, scratch registers
#    memory: instructions window, hexadecimal data
#    CALLED BY: running aide32 (aide32_ide.tcl):w
#    TCL PROCS CALLED: open_a32, do_assemble, show_config, show_console,
#    show_exc_r, show_tlb, show_pmem, window_menu_hide, show_watchpts,
#    show_dhc, do_run, do_step, do_reset, clear_breakpoints,
#    scroll_regs, scroll_regs_sb, scroll_inst, scroll_inst_sb.
# scroll_regs, scroll_regs_sb:
#    CALLED BY: aide_window_setup
#    TCL PROCS CALLED: -
#    these set up the scroll bars for the registers window
# scroll_inst, scroll_inst_sb:
#    these set up the scroll bars for the instructions window
#    CALLED BY: aide_window_setup
#    TCL PROCS CALLED: -
# ----------------------------------------------------------------------
#
#
proc aide_window_setup {} {

  #
  # Global Variables
  #
  global ROOT
  global VM
  global tcl_platform
  global pmem_cnt
  set pmem_cnt 0
  global watchp_cnt
  set watchp_cnt 0
  global datatype
  global speed
  global window_menu
  set window_menu ""
  global window_count
  set window_count 0

  global old_pc
  set old_pc ""

  # these are config: (register_label,  pop_up_exc_reg, temp_reg)
  global register_label
  set register_label 0
  global register_choice
  set register_choice 0
  global pop_up_exc_reg
  set pop_up_exc_reg 0
  global temp_reg
  set temp_reg 0

  #
  # Root Window
  #
  set ROOT ""
  #option add *background lightblue
  #option add *background #d9d9d9
  if {"$tcl_platform(platform)"=="windows"} {
    option add *background #d9d9d9
    option add *font { terminal 9 }
  }
  #
  # Menubar: File, Speed, View, Tools, Windows, Help
  #
  frame $ROOT.menubar -borderwidth 2 -relief raised
  pack $ROOT.menubar -fill x -side top

  #
  # File Menu Button: New, Open, Save, Save As, Exit
  #
  menubutton $ROOT.menubar.fileMB -padx 4 -pady 3 -relief flat -text File \
       -menu $ROOT.menubar.fileMB.menu1 -width 10
  pack $ROOT.menubar.fileMB -padx 12 -side left
  menu $ROOT.menubar.fileMB.menu1 -tearoff 0
  $ROOT.menubar.fileMB.menu1 add command -label "Open *.asm ..."  \
       -command {do_open_asm}
  $ROOT.menubar.fileMB.menu1 add command -label "Open *.a32 ..."  \
       -command {open_a32}
  $ROOT.menubar.fileMB.menu1 add command -label "Edit new   ..."  \
       -command {do_new}

# move to EDIT WINDOW:
#  $ROOT.menubar.fileMB.menu1 add command -label "Assemble ..." \
#   -state disabled -command {do_assemble}
#  $ROOT.menubar.fileMB.menu1 add separator
#  $ROOT.menubar.fileMB.menu1 add command -label Save  -state disabled
#  $ROOT.menubar.fileMB.menu1 add command -label "Save As ..." -state disabled
  $ROOT.menubar.fileMB.menu1 add separator
  $ROOT.menubar.fileMB.menu1 add command -label Exit -command do_exit

  #
  # Speed Menu Button: Slow, Medium, Fast, Silent
  #
  menubutton $ROOT.menubar.speedMB -padx 4 -pady 3 -relief flat -text Speed \
       -menu $ROOT.menubar.speedMB.menu2 -width 10
  pack $ROOT.menubar.speedMB -padx 12 -side left
  menu $ROOT.menubar.speedMB.menu2 -tearoff 0
  $ROOT.menubar.speedMB.menu2 add radiobutton -label Slow -variable speed
  $ROOT.menubar.speedMB.menu2 add radiobutton -label Medium -variable speed
  $ROOT.menubar.speedMB.menu2 add radiobutton -label Fast -variable speed
  $ROOT.menubar.speedMB.menu2 add radiobutton -label Silent -variable speed
  set speed Medium

  #
  # View Menu Button: 
  # Configurations, Memory, Console, TLB | Exception Registers
  #
  menubutton $ROOT.menubar.viewMB -padx 4 -pady 3 -relief flat -text View \
       -menu $ROOT.menubar.viewMB.menu3 -width 10
  pack $ROOT.menubar.viewMB -padx 12 -side left
  menu $ROOT.menubar.viewMB.menu3 -tearoff 0
  $ROOT.menubar.viewMB.menu3 add command -label "Configurations"  \
       -command { show_config }
  $ROOT.menubar.viewMB.menu3 add command -label Console \
       -command { show_console }
  $ROOT.menubar.viewMB.menu3 add separator

  $ROOT.menubar.viewMB.menu3 add command -label "Exception Registers" \
       -command { show_exc_r }
  $ROOT.menubar.viewMB.menu3 add command -label TLB -command { show_tlb }
  $ROOT.menubar.viewMB.menu3 add separator
  $ROOT.menubar.viewMB.menu3 add command -label "Physical Memory" \
        -command { show_pmem }

  toplevel .eXCEPTION
  wm title .eXCEPTION  "Exception Registers"

  frame .eXCEPTION.excTopF -borderwidth 4 -relief groove
  pack .eXCEPTION.excTopF -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
  button .eXCEPTION.excTopF.closeW -padx 9 -pady 3 -text "Close Window" \
    -command  "window_menu_hide .eXCEPTION"
  pack .eXCEPTION.excTopF.closeW -padx 0 -pady 4 -side top

  frame .eXCEPTION.excMidF -borderwidth 4 -relief groove
  pack .eXCEPTION.excMidF -fill x -ipady 6 -padx 0 -pady 0 -side top

  frame .eXCEPTION.excMidF.excF -borderwidth 4
  pack .eXCEPTION.excMidF.excF -fill x -padx 0 -pady 0 -side top
  label .eXCEPTION.excMidF.excF.excL -text "Exception Registers:"
  pack .eXCEPTION.excMidF.excF.excL -side top
  text .eXCEPTION.excMidF.excF.excD -height 8 -relief groove -width 24
  pack .eXCEPTION.excMidF.excF.excD -side top

  wm withdraw .eXCEPTION

  #
  # Tools Menu Button: Watch Points, Dec-Hex Conversion
  #
  menubutton $ROOT.menubar.toolsMB -padx 4 -pady 3 -relief flat -text Tools \
       -menu $ROOT.menubar.toolsMB.menu4 -width 10
  pack $ROOT.menubar.toolsMB -padx 12 -side left
  menu $ROOT.menubar.toolsMB.menu4 -tearoff 0
  $ROOT.menubar.toolsMB.menu4 add command -label "Watch Points" \
       -command { show_watchpts } -state disabled
  $ROOT.menubar.toolsMB.menu4 add command -label "Dec-Hex Conversion" \
       -command { show_dhc }

  #
  # "Windows" Menu Button
  #
  menubutton $ROOT.menubar.windoMB -padx 4 -pady 3 -relief flat \
       -text Windows -menu $ROOT.menubar.windoMB.menu5 -width 10 \
       -state disabled
  menu $ROOT.menubar.windoMB.menu5 -tearoff 0
  pack $ROOT.menubar.windoMB -padx 12 -side left

  #
  # Help Menu Button
  #

#
# This is NOT IMPLEMENTED YET:
#
#   menubutton $ROOT.menubar.helpMB -padx 4 -pady 3 -relief flat -text Help
#   menu $ROOT.menubar.helpMB.menu6 -tearoff 0
#   pack $ROOT.menubar.helpMB -padx 12 -side right

  #
  # Buttonbar, Buttons: Run, Step, Reset, Clear Breaks, Exit
  #
  frame $ROOT.buttonbar -borderwidth 4 -relief flat
  pack $ROOT.buttonbar -fill x -side top
  button $ROOT.buttonbar.runB -padx 9 -pady 3 -text Run -command {do_run} \
     -width 14 -state disabled
  pack $ROOT.buttonbar.runB -padx 8 -side left
  button $ROOT.buttonbar.stepB -padx 9 -pady 3 -text Step -command \
     {do_step}  -width 14 -state disabled
  pack $ROOT.buttonbar.stepB -padx 8 -side left
  button $ROOT.buttonbar.resetB -padx 9 -pady 3 -text Reload/Reset \
     -command {do_reset} -width 14 -state disabled
  pack $ROOT.buttonbar.resetB -padx 8 -side left
  button $ROOT.buttonbar.clearB -padx 9 -pady 3 -text "Clear Breaks" \
  -command {clear_breakpoints} -width 14 -state disabled
  pack $ROOT.buttonbar.clearB -padx 8 -side left
#
# This is NOT IMPLEMENTED YET:
#
#  button $ROOT.buttonbar.editB -padx 9 -pady 3 -text Edit
#  pack $ROOT.buttonbar.editB -padx 8 -side left

  #
  # Status Area (Left Frame): PC, Mode, r1-3, (ra,sp,fp)
  #
  frame $ROOT.leftF -borderwidth 0
  pack $ROOT.leftF -fill both -side left
  frame $ROOT.leftF.stateF -borderwidth 4 -relief groove
  pack $ROOT.leftF.stateF -fill x -ipady 0 -side top

  frame $ROOT.leftF.stateF.pcF -borderwidth 4
  pack $ROOT.leftF.stateF.pcF -side top -ipady 4
  label $ROOT.leftF.stateF.pcF.pcL -text "PC:     "
  pack $ROOT.leftF.stateF.pcF.pcL -padx 8 -side left
  text $ROOT.leftF.stateF.pcF.pcT -height 1 -width 12 -relief flat
  pack $ROOT.leftF.stateF.pcF.pcT -padx 8 -side left

  frame $ROOT.leftF.stateF.modeF -borderwidth 4
  pack $ROOT.leftF.stateF.modeF -side top
  label $ROOT.leftF.stateF.modeF.modeL -text "Mode:   "
  pack $ROOT.leftF.stateF.modeF.modeL -padx 8 -side left
  text $ROOT.leftF.stateF.modeF.modeT -height 1 -width 12 -relief flat
  pack $ROOT.leftF.stateF.modeF.modeT -padx 8 -side left

  frame $ROOT.leftF.stateF.memmodeF -borderwidth 4
  pack $ROOT.leftF.stateF.memmodeF -side top
  label $ROOT.leftF.stateF.memmodeF.memmodeL -text "Memory: "
  pack $ROOT.leftF.stateF.memmodeF.memmodeL -padx 8 -side left
  text $ROOT.leftF.stateF.memmodeF.memmodeT -height 1 -width 12 -relief flat
  pack $ROOT.leftF.stateF.memmodeF.memmodeT -padx 8 -side left


  #
  # Registers:
  #
  frame $ROOT.leftF.regF -borderwidth 4 -relief groove
  pack $ROOT.leftF.regF -fill y -expand 1 -ipady 8 -side top
  frame $ROOT.leftF.regF.reg1F -borderwidth 0
  pack $ROOT.leftF.regF.reg1F  -side top -pady 6 -padx 2 -anchor w
  frame $ROOT.leftF.regF.reg2F -borderwidth 0
  pack $ROOT.leftF.regF.reg2F  -side top -fill y -expand 1
  frame $ROOT.leftF.regF.reg3F -borderwidth 0
  pack $ROOT.leftF.regF.reg3F  -side top -pady 6 -padx 2 -anchor w

  # Special (Dedicated) Registers
  frame $ROOT.leftF.regF.reg1F.regSrcF
  pack $ROOT.leftF.regF.reg1F.regSrcF -side left -anchor s
  label $ROOT.leftF.regF.reg1F.regSrcF.regSrcL -text Src -width 4
  pack $ROOT.leftF.regF.reg1F.regSrcF.regSrcL -padx 8 -side top
  text $ROOT.leftF.regF.reg1F.regSrcF.regSrcT -height 4 -relief groove \
  -width 4 -state disabled 
  pack $ROOT.leftF.regF.reg1F.regSrcF.regSrcT -side top

  frame $ROOT.leftF.regF.reg1F.sp-regF -borderwidth 0 
  pack $ROOT.leftF.regF.reg1F.sp-regF -side left -anchor s
  label $ROOT.leftF.regF.reg1F.sp-regF.excL -text "Dedicated \nRegisters:"
  pack $ROOT.leftF.regF.reg1F.sp-regF.excL -side top
  text $ROOT.leftF.regF.reg1F.sp-regF.excD -height 4 -relief groove -width 15
  pack $ROOT.leftF.regF.reg1F.sp-regF.excD -side top

  frame $ROOT.leftF.regF.reg1F.regDesF
  pack $ROOT.leftF.regF.reg1F.regDesF -side left -anchor s
  label $ROOT.leftF.regF.reg1F.regDesF.regDesL -text Des -width 4
  pack $ROOT.leftF.regF.reg1F.regDesF.regDesL -padx 8 -side top
  text $ROOT.leftF.regF.reg1F.regDesF.regDesT -height 4 -relief groove \
  -width 4 -state disabled 
  pack $ROOT.leftF.regF.reg1F.regDesF.regDesT -side top

  # General Purpose Registers
  frame $ROOT.leftF.regF.reg2F.regSrcF
  pack $ROOT.leftF.regF.reg2F.regSrcF -side left -fill y -expand 1
  label $ROOT.leftF.regF.reg2F.regSrcF.regSrcL -text Src -width 4
  pack $ROOT.leftF.regF.reg2F.regSrcF.regSrcL -padx 8 -side top
    #
    #
    proc scroll_regs {args} {
      global ROOT
      eval $ROOT.leftF.regF.reg2F.regSrcF.regSrcT yview $args
      eval $ROOT.leftF.regF.reg2F.regDataF.regDataT yview $args
      eval $ROOT.leftF.regF.reg2F.regDesF.regDesT yview $args
    }
    #
    #
    proc scroll_regs_sb {args} {

      global ROOT
      eval $ROOT.leftF.regF.reg2F.regScrllF.regSB set $args
      $ROOT.leftF.regF.reg2F.regSrcF.regSrcT yview moveto [lindex $args 0]
      $ROOT.leftF.regF.reg2F.regDataF.regDataT yview moveto [lindex $args 0]
      $ROOT.leftF.regF.reg2F.regDesF.regDesT yview moveto [lindex $args 0]
    }

  text $ROOT.leftF.regF.reg2F.regSrcF.regSrcT -height 16 -relief groove \
  -width 4 -state disabled -yscrollcommand scroll_regs_sb
  pack $ROOT.leftF.regF.reg2F.regSrcF.regSrcT -side top -fill y -expand 1
  frame $ROOT.leftF.regF.reg2F.regDataF
  pack $ROOT.leftF.regF.reg2F.regDataF -side left -fill y -expand 1
  label $ROOT.leftF.regF.reg2F.regDataF.regDataL -text "Registers:"
  pack $ROOT.leftF.regF.reg2F.regDataF.regDataL -padx 8 -side top
  text $ROOT.leftF.regF.reg2F.regDataF.regDataT -height 16 -relief groove \
       -width 15 -yscrollcommand scroll_regs_sb
  pack $ROOT.leftF.regF.reg2F.regDataF.regDataT -side top -fill y -expand 1
  frame $ROOT.leftF.regF.reg2F.regDesF
  pack $ROOT.leftF.regF.reg2F.regDesF -side left -fill y -expand 1
  label $ROOT.leftF.regF.reg2F.regDesF.regDesL -text Des -width 4
  pack $ROOT.leftF.regF.reg2F.regDesF.regDesL -padx 8 -side top
  text $ROOT.leftF.regF.reg2F.regDesF.regDesT -height 16 -relief groove \
      -width 4 -state disabled -yscrollcommand scroll_regs_sb
  pack $ROOT.leftF.regF.reg2F.regDesF.regDesT -side top -fill y -expand 1
  frame $ROOT.leftF.regF.reg2F.regScrllF
  pack $ROOT.leftF.regF.reg2F.regScrllF -fill y -side right -pady 8
  label $ROOT.leftF.regF.reg2F.regScrllF.fillerL -width 1
  pack $ROOT.leftF.regF.reg2F.regScrllF.fillerL -side top
  scrollbar $ROOT.leftF.regF.reg2F.regScrllF.regSB -activerelief flat \
       -width 12 -command scroll_regs
  pack $ROOT.leftF.regF.reg2F.regScrllF.regSB -expand 1 -fill y -side top

  # Temp (Scratch) Registers
  frame $ROOT.leftF.regF.reg3F.regSrcF
  pack $ROOT.leftF.regF.reg3F.regSrcF -side left -anchor s
  label $ROOT.leftF.regF.reg3F.regSrcF.regSrcL -text Src -width 4
  pack $ROOT.leftF.regF.reg3F.regSrcF.regSrcL -padx 8 -side top
  text $ROOT.leftF.regF.reg3F.regSrcF.regSrcT -height 4 -relief groove \
  -width 4 -state disabled 
  pack $ROOT.leftF.regF.reg3F.regSrcF.regSrcT -side top

  frame $ROOT.leftF.regF.reg3F.sc-regF -borderwidth 0
  pack $ROOT.leftF.regF.reg3F.sc-regF -side left -anchor s
  label $ROOT.leftF.regF.reg3F.sc-regF.regL -text "Scratch \nRegisters:"
  pack $ROOT.leftF.regF.reg3F.sc-regF.regL -side top
  text $ROOT.leftF.regF.reg3F.sc-regF.regD -height 4 -relief groove -width 15
  pack $ROOT.leftF.regF.reg3F.sc-regF.regD -side top

  frame $ROOT.leftF.regF.reg3F.regDesF
  pack $ROOT.leftF.regF.reg3F.regDesF -side left -anchor s
  label $ROOT.leftF.regF.reg3F.regDesF.regDesL -text Des -width 4
  pack $ROOT.leftF.regF.reg3F.regDesF.regDesL -padx 8 -side top
  text $ROOT.leftF.regF.reg3F.regDesF.regDesT -height 4 -relief groove \
  -width 4 -state disabled 
  pack $ROOT.leftF.regF.reg3F.regDesF.regDesT -side top
  #
  # Memory (Right Frame)
  #
  frame $ROOT.rightF
  pack $ROOT.rightF -side right -expand 1 -fill both

  #
  # Memory (Instructions)
  #
  frame $ROOT.rightF.memInstF -borderwidth 4 -relief groove
  pack $ROOT.rightF.memInstF -side top -expand 1 -fill both

  frame $ROOT.rightF.memInstF.labelF -borderwidth 0 -relief groove
  pack $ROOT.rightF.memInstF.labelF -fill x -side top

  label $ROOT.rightF.memInstF.labelF.memBrkL -text "BRK"
  pack $ROOT.rightF.memInstF.labelF.memBrkL -padx 0 -side left

  label $ROOT.rightF.memInstF.labelF.memInstL -text \
        "    Address:     Disassembly:         Source Code:"
  pack $ROOT.rightF.memInstF.labelF.memInstL -side left

  proc scroll_inst {args} {
    global ROOT
    eval $ROOT.rightF.memInstF.memInstT yview $args
    eval $ROOT.rightF.memInstF.memBrkT yview $args
  }
  #
  #
  proc scroll_inst_sb {args} {

    global ROOT
    eval $ROOT.rightF.memInstF.memInstSB set $args
    $ROOT.rightF.memInstF.memInstT yview moveto [lindex $args 0]
    $ROOT.rightF.memInstF.memBrkT yview moveto [lindex $args 0]
  }

  text $ROOT.rightF.memInstF.memBrkT -height 16 -relief groove -width 4 \
       -yscrollcommand scroll_inst_sb
  pack $ROOT.rightF.memInstF.memBrkT -side left -expand 1 -fill y

  text $ROOT.rightF.memInstF.memInstT -height 16 -relief groove -width 60 \
       -yscrollcommand scroll_inst_sb -wrap none
  pack $ROOT.rightF.memInstF.memInstT -side left -expand 1 -fill both
  $ROOT.rightF.memInstF.memInstT tag configure hilited \
  -background white -foreground blue
  $ROOT.rightF.memInstF.memInstT tag configure pc -background green
  scrollbar $ROOT.rightF.memInstF.memInstSB -activerelief flat -width 12 \
       -width 12 -command "$ROOT.rightF.memInstF.memInstT yview" \
       -command scroll_inst
  pack $ROOT.rightF.memInstF.memInstSB -expand 1 -fill y -side top

  bind $ROOT.rightF.memInstF.memBrkT <1> "toggle_breakpoint %W %y; break"
  bind $ROOT.rightF.memInstF.memBrkT <B1-Motion> break
  bind $ROOT.rightF.memInstF.memBrkT <ButtonRelease-1> break
  bind $ROOT.rightF.memInstF.memInstT <B1-Motion> break

  #
  # Memory (Hexadecimal), Current Page Number
  #
  frame $ROOT.rightF.memHexF -borderwidth 4 -relief groove
  pack $ROOT.rightF.memHexF -side top

  frame $ROOT.rightF.memHexF.memHdrF -borderwidth 4
  pack $ROOT.rightF.memHexF.memHdrF -fill x -padx 28 -side top
  label $ROOT.rightF.memHexF.memHdrF.memHdrL -height 1 -text \
       "Memory (Hexadecimal)"  -width 0
  pack $ROOT.rightF.memHexF.memHdrF.memHdrL -side left
  text $ROOT.rightF.memHexF.memHdrF.memHdrT -height 1 -width 9 -relief flat
  pack $ROOT.rightF.memHexF.memHdrF.memHdrT -side right
  label $ROOT.rightF.memHexF.memHdrF.memHdr2L -height 1 -text \
       "Page Number: " -width 0
  pack $ROOT.rightF.memHexF.memHdrF.memHdr2L -side right
  frame $ROOT.rightF.memHexF.memDataF -borderwidth 4 -relief groove
  pack $ROOT.rightF.memHexF.memDataF -padx 8 -side top
  text $ROOT.rightF.memHexF.memDataF.memDataT -height 16 -relief groove \
       -width 53 -yscrollcommand "$ROOT.rightF.memHexF.memDataF.memDataSB set"
  $ROOT.rightF.memHexF.memDataF.memDataT tag configure hilited -background white -foreground red
  pack $ROOT.rightF.memHexF.memDataF.memDataT -side left
  scrollbar $ROOT.rightF.memHexF.memDataF.memDataSB -activerelief flat \
       -width 12 -command "$ROOT.rightF.memHexF.memDataF.memDataT yview"
  pack $ROOT.rightF.memHexF.memDataF.memDataSB -expand 1 -fill y -side top

}
#
# End of aide32_mainwindow.tcl
#

