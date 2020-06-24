#!/usr/local/bin/wish8.0 -f        
#
# $Id: aide32-test.tcl,v 1.10 2001/02/17 19:49:13 ellard Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#

proc start_here {} {
  global EDIT_BASENAME
  set EDIT_BASENAME ""
  gantInitialize
}
#
# Global Variables
#
global ROOT
global r_page_cnt
set r_page_cnt 0
global w_page_cnt
set w_page_cnt 0
global segment_cnt
set segment_cnt 0
global n_watch_cnt
set n_watch_cnt 0
global datatype
#
# Root Window
#
set ROOT ""
option add *background lightblue
#
# Menubar: File, Speed, View, Tools, Windows, Help
#
frame $ROOT.menubar -background lightblue -borderwidth 2 -class FakeFrame -relief raised
pack $ROOT.menubar -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

#
# File Menu Button: New, Open, Save, Save As, Exit
#
menubutton $ROOT.menubar.fileMB -background lightblue -padx 4 -pady 3 -relief flat -text File -menu $ROOT.menubar.fileMB.menu1
pack $ROOT.menubar.fileMB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 12 -pady 0 -side left
menu $ROOT.menubar.fileMB.menu1 -background lightblue -tearoff 0
$ROOT.menubar.fileMB.menu1 add command -label New  -state disabled
$ROOT.menubar.fileMB.menu1 add command -label "Open ..."  -state disabled
$ROOT.menubar.fileMB.menu1 add command -label "Assemble ..." -command {assemble_display}
$ROOT.menubar.fileMB.menu1 add separator
$ROOT.menubar.fileMB.menu1 add command -label Save  -state disabled
$ROOT.menubar.fileMB.menu1 add command -label "Save As ..." -state disabled
$ROOT.menubar.fileMB.menu1 add separator
$ROOT.menubar.fileMB.menu1 add command -label Exit -command exit

#
# Speed Menu Button: Slow, Medium, Fast, Silent
#
menubutton $ROOT.menubar.speedMB -background lightblue -padx 4 -pady 3 -relief flat -text Speed -menu $ROOT.menubar.speedMB.menu2
pack $ROOT.menubar.speedMB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 12 -pady 0 -side left
menu $ROOT.menubar.speedMB.menu2 -background lightblue -tearoff 0
$ROOT.menubar.speedMB.menu2 add radiobutton -label Slow -variable speed
$ROOT.menubar.speedMB.menu2 add radiobutton -label Medium -variable speed
$ROOT.menubar.speedMB.menu2 add radiobutton -label Fast -variable speed
$ROOT.menubar.speedMB.menu2 add radiobutton -label Silent -variable speed
set speed Medium

#
# View Menu Button: Page (Readable), Page (Whole), Segment | Console, TLB | Exception Registers
#
menubutton $ROOT.menubar.viewMB -background lightblue -padx 4 -pady 3 -relief flat -text View -menu $ROOT.menubar.viewMB.menu3 
pack $ROOT.menubar.viewMB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 12 -pady 0 -side left
menu $ROOT.menubar.viewMB.menu3 -background lightblue -tearoff 0
$ROOT.menubar.viewMB.menu3 add command -label "Page (Readable)" -command { show_page_r }
$ROOT.menubar.viewMB.menu3 add command -label "Page (Whole)" -command { show_page_w }
$ROOT.menubar.viewMB.menu3 add command -label Segment -command { show_segment }
$ROOT.menubar.viewMB.menu3 add separator
$ROOT.menubar.viewMB.menu3 add command -label Console -command { show_console }
$ROOT.menubar.viewMB.menu3 add command -label TLB -command { show_tlb }
$ROOT.menubar.viewMB.menu3 add separator
$ROOT.menubar.viewMB.menu3 add command -label "Exception Registers" -command { show_exc_r }

#
# Tools Menu Button: Watch Points, Dec-Hex Conversion
#
menubutton $ROOT.menubar.toolsMB -background lightblue -padx 4 -pady 3 -relief flat -text Tools -menu $ROOT.menubar.toolsMB.menu4
pack $ROOT.menubar.toolsMB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 12 -pady 0 -side left
menu $ROOT.menubar.toolsMB.menu4 -background lightblue -tearoff 0
$ROOT.menubar.toolsMB.menu4 add command -label "Watch Points" -command { show_watchpts }
$ROOT.menubar.toolsMB.menu4 add command -label "Dec-Hex Conversion" -command { show_dhc }

#
# "Windows" Menu Button
#
menubutton $ROOT.menubar.windoMB -background lightblue -padx 4 -pady 3 -relief flat -text Windows -menu $ROOT.menubar.windoMB.menu5
menu $ROOT.menubar.windoMB.menu5 -background lightblue -tearoff 0
pack $ROOT.menubar.windoMB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 12 -pady 0 -side left

#
# Help Menu Button
#
menubutton $ROOT.menubar.helpMB -background lightblue -padx 4 -pady 3 -relief flat -text Help
menu $ROOT.menubar.helpMB.menu6 -background lightblue -tearoff 0
pack $ROOT.menubar.helpMB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 12 -pady 0 -side right

#
# Buttonbar, Buttons: Run, Step, Reset, Clear Breaks, Exit
#
frame $ROOT.buttonbar -background lightblue -borderwidth 4 -class FakeFrame -relief flat
pack $ROOT.buttonbar -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
button $ROOT.buttonbar.runB -background lightblue -padx 9 -pady 3 -text Run
pack $ROOT.buttonbar.runB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
button $ROOT.buttonbar.stepB -background lightblue -padx 9 -pady 3 -text Step
pack $ROOT.buttonbar.stepB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
button $ROOT.buttonbar.resetB -background lightblue -padx 9 -pady 3 -text Reset
pack $ROOT.buttonbar.resetB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
button $ROOT.buttonbar.clearB -background lightblue -padx 9 -pady 3 -text "Clear Breaks"
pack $ROOT.buttonbar.clearB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
button $ROOT.buttonbar.editB -background lightblue -padx 9 -pady 3 -text Edit
pack $ROOT.buttonbar.editB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left

#
# Status Area (Left Frame): PC, Inst R, Status, Mode
#
frame $ROOT.leftF -background lightblue -borderwidth 4 -class FakeFrame
pack $ROOT.leftF -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
frame $ROOT.leftF.stateF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack $ROOT.leftF.stateF -anchor center -expand 0 -fill x -ipadx 0 -ipady 8 -padx 0 -pady 0 -side top
frame $ROOT.leftF.stateF.pcF -background lightblue -borderwidth 4 -class FakeFrame
pack $ROOT.leftF.stateF.pcF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label $ROOT.leftF.stateF.pcF.pcL -background lightblue -text "PC    "
pack $ROOT.leftF.stateF.pcF.pcL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
text $ROOT.leftF.stateF.pcF.pcT -background lightblue -height 1 -width 22 -relief flat
pack $ROOT.leftF.stateF.pcF.pcT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
frame $ROOT.leftF.stateF.instrF -background lightblue -borderwidth 4 -class FakeFrame
pack $ROOT.leftF.stateF.instrF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label $ROOT.leftF.stateF.instrF.instrL -background lightblue -text "Inst R"
pack $ROOT.leftF.stateF.instrF.instrL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
text $ROOT.leftF.stateF.instrF.instrT -background lightblue -height 1 -width 22 -relief flat
pack $ROOT.leftF.stateF.instrF.instrT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
frame $ROOT.leftF.stateF.statusF -background lightblue -borderwidth 4 -class FakeFrame
pack $ROOT.leftF.stateF.statusF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label $ROOT.leftF.stateF.statusF.statusL -background lightblue -text Status
pack $ROOT.leftF.stateF.statusF.statusL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
text $ROOT.leftF.stateF.statusF.statusT -background lightblue -height 1 -width 22 -relief flat
pack $ROOT.leftF.stateF.statusF.statusT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
frame $ROOT.leftF.stateF.modeF -background lightblue -borderwidth 4 -class FakeFrame
pack $ROOT.leftF.stateF.modeF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label $ROOT.leftF.stateF.modeF.modeL -background lightblue -text "Mode  "
pack $ROOT.leftF.stateF.modeF.modeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side left
text $ROOT.leftF.stateF.modeF.modeT -background lightblue -height 1 -width 22 -relief flat
pack $ROOT.leftF.stateF.modeF.modeT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top

#
# Register Info: Src, Data, Des
#
frame $ROOT.leftF.regF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack $ROOT.leftF.regF -anchor center -expand 0 -fill y -ipadx 0 -ipady 8 -padx 0 -pady 0 -side top
frame $ROOT.leftF.regF.regSrcF -background lightblue -class FakeFrame
pack $ROOT.leftF.regF.regSrcF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label $ROOT.leftF.regF.regSrcF.regSrcL -background lightblue -text Src -width 4
pack $ROOT.leftF.regF.regSrcF.regSrcL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
proc scroll_regs {args} {
  global ROOT
  eval $ROOT.leftF.regF.regSrcF.regSrcT yview $args
  eval $ROOT.leftF.regF.regDataF.regDataT yview $args
  eval $ROOT.leftF.regF.regDesF.regDesT yview $args
}
text $ROOT.leftF.regF.regSrcF.regSrcT -background lightblue -height 16 -relief groove -width 4
pack $ROOT.leftF.regF.regSrcF.regSrcT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
frame $ROOT.leftF.regF.regDataF -background lightblue -class FakeFrame
pack $ROOT.leftF.regF.regDataF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label $ROOT.leftF.regF.regDataF.regDataL -background lightblue -text "Registers:"
pack $ROOT.leftF.regF.regDataF.regDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
text $ROOT.leftF.regF.regDataF.regDataT -background lightblue -height 16 -relief groove -width 20 -yscrollcommand "$ROOT.leftF.regF.regSB set"
pack $ROOT.leftF.regF.regDataF.regDataT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
frame $ROOT.leftF.regF.regDesF -background lightblue -class FakeFrame
pack $ROOT.leftF.regF.regDesF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label $ROOT.leftF.regF.regDesF.regDesL -background lightblue -text Des -width 4
pack $ROOT.leftF.regF.regDesF.regDesL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
text $ROOT.leftF.regF.regDesF.regDesT -background lightblue -height 16 -relief groove -width 4
pack $ROOT.leftF.regF.regDesF.regDesT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
scrollbar $ROOT.leftF.regF.regSB -activerelief flat -background lightblue -width 12 -command scroll_regs
pack $ROOT.leftF.regF.regSB -anchor center -expand 1 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

#
# Memory (Right Frame)
#
frame $ROOT.rightF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack $ROOT.rightF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right

#
# Memory (Instructions)
#
frame $ROOT.rightF.memInstF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack $ROOT.rightF.memInstF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label $ROOT.rightF.memInstF.memInstL -background lightblue -text "Memory (Instructions)"
pack $ROOT.rightF.memInstF.memInstL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
text $ROOT.rightF.memInstF.memBrkT -background lightblue -height 12 -relief groove -width 4
pack $ROOT.rightF.memInstF.memBrkT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
text $ROOT.rightF.memInstF.memInstT -background lightblue -height 12 -relief groove -width 48
pack $ROOT.rightF.memInstF.memInstT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
scrollbar $ROOT.rightF.memInstF.memInstSB -activerelief flat -background lightblue -width 12
pack $ROOT.rightF.memInstF.memInstSB -anchor center -expand 1 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

#
# Memory (Hexadecimal), Current Page Number
#
frame $ROOT.rightF.memHexF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack $ROOT.rightF.memHexF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

frame $ROOT.rightF.memHexF.memHdrF -background lightblue -borderwidth 4 -class FakeFrame
pack $ROOT.rightF.memHexF.memHdrF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 28 -pady 0 -side top
label $ROOT.rightF.memHexF.memHdrF.memHdrL -background lightblue -height 1 -text "Memory (Hexadecimal)"  -width 0
pack $ROOT.rightF.memHexF.memHdrF.memHdrL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
text $ROOT.rightF.memHexF.memHdrF.memHdrT -background lightblue -height 1 -width 9 -relief flat
pack $ROOT.rightF.memHexF.memHdrF.memHdrT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
label $ROOT.rightF.memHexF.memHdrF.memHdr2L -background lightblue -height 1 -text "Page Number: " -width 0
pack $ROOT.rightF.memHexF.memHdrF.memHdr2L -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
frame $ROOT.rightF.memHexF.memDataF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack $ROOT.rightF.memHexF.memDataF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
text $ROOT.rightF.memHexF.memDataF.memDataT -background lightblue -height 16 -relief groove -width 53 -yscrollcommand "$ROOT.rightF.memHexF.memDataF.memDataSB set"
pack $ROOT.rightF.memHexF.memDataF.memDataT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
scrollbar $ROOT.rightF.memHexF.memDataF.memDataSB -activerelief flat -background lightblue -width 12 -command "$ROOT.rightF.memHexF.memDataF.memDataT yview"
pack $ROOT.rightF.memHexF.memDataF.memDataSB -anchor center -expand 1 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

# Dummy Data, Status Area:
$ROOT.leftF.stateF.pcF.pcT insert insert "0x00000000"
$ROOT.leftF.stateF.instrF.instrT insert insert "st1 r008, r005, 0x001a"
$ROOT.leftF.stateF.statusF.statusT insert insert "OK"
$ROOT.leftF.stateF.modeF.modeT insert insert "User"

# Dummy Data, Registers:

$ROOT.leftF.regF.regSrcF.regSrcT insert insert "\n\n\n\n\n\n\n\n\n\--->\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
$ROOT.leftF.regF.regDesF.regDesT insert insert "\n\n\n\n\n\<---\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r000 0x00 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r001 0x01 0x00000a00\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r003 0x03 0x00000010\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r004 0x04 0x00003000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r005 0x05 0x00000011\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r006 0x06 0x0000001a\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r007 0x07 0x0000000f\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r008 0x08 0x0000000c\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r009 0x09 0x00000020\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r010 0x0a 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r011 0x0b 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r012 0x0c 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r013 0x0d 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r014 0x0e 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r015 0x0f 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r016 0x10 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r017 0x11 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r018 0x12 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r019 0x13 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r020 0x14 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r021 0x15 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r022 0x16 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r023 0x17 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r024 0x18 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r025 0x19 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r026 0x1a 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r027 0x1b 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r028 0x1c 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r029 0x1d 0x00000000\n"
$ROOT.leftF.regF.regDataF.regDataT insert insert "r030 0x1e 0x00000000\n"

# Dummy Data, Page Number, Hex Memory: 

$ROOT.rightF.memHexF.memHdrF.memHdrT insert insert " 0x00000 "
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x000:  00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0f\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x001:  10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1f\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x002:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x003:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x004:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x005:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x006:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x007:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x008:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x009:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x00a:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x00b:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x00c:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x00d:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x00e:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x00f:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x010:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x011:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x012:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x013:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x014:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x015:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x016:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x017:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x018:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x019:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
$ROOT.rightF.memHexF.memDataF.memDataT insert insert "0x01a:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"

#
#
# Procs ...
#
#

#
# Proc: assemble_display, Assemble an .asm file and display it in the 
#       "Memory (Instructions)" window (upper RHS)
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
# Proc: show_page_r, Show Readable Page
#
proc show_page_r {} {
global r_page_cnt
incr r_page_cnt +1

toplevel .rPAGE$r_page_cnt
wm title .rPAGE$r_page_cnt  "Readable Page $r_page_cnt"

frame .rPAGE$r_page_cnt.rpageTopF -background lightblue -borderwidth 0 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
frame .rPAGE$r_page_cnt.rpageTopF.nwF -background lightblue -borderwidth 0 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.nwF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
frame .rPAGE$r_page_cnt.rpageTopF.nwF.swF -background lightblue -borderwidth 4 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.nwF.swF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

label .rPAGE$r_page_cnt.rpageTopF.nwF.selPageL -background lightblue -text " Select Page Number: "
pack .rPAGE$r_page_cnt.rpageTopF.nwF.selPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .rPAGE$r_page_cnt.rpageTopF.nwF.selPageE -background lightblue -width 12
pack .rPAGE$r_page_cnt.rpageTopF.nwF.selPageE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageL -background lightblue -text "Current Page Number:"
pack .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageDataL -background lightblue -width 12 -height 1 -relief flat -highlightthickness 2
pack .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .rPAGE$r_page_cnt.rpageTopF.neF -background lightblue -borderwidth 0 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.neF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
frame .rPAGE$r_page_cnt.rpageTopF.neF.seF -background lightblue -borderwidth 4 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.neF.seF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
button .rPAGE$r_page_cnt.rpageTopF.neF.okB -background lightblue -padx 9 -pady 3 -text OK
pack .rPAGE$r_page_cnt.rpageTopF.neF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .rPAGE$r_page_cnt.rpageTopF.neF.cxlB -background lightblue -padx 9 -pady 3 -text Cancel
pack .rPAGE$r_page_cnt.rpageTopF.neF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .rPAGE$r_page_cnt.rpageTopF.neF.seF.closeB -background lightblue -padx 9 -pady 3 -text "Close Window" -command  " window_menu_minus \"Readable Page $r_page_cnt\" \".rPAGE$r_page_cnt\" "
pack .rPAGE$r_page_cnt.rpageTopF.neF.seF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .rPAGE$r_page_cnt.rpageDataF -background lightblue -borderwidth 2 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

text .rPAGE$r_page_cnt.rpageDataF.rpageDataT -background lightblue -height 32 -relief groove -width 53 -yscrollcommand ".rPAGE$r_page_cnt.rpageDataF.rpageDataSB set"
pack .rPAGE$r_page_cnt.rpageDataF.rpageDataT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
scrollbar .rPAGE$r_page_cnt.rpageDataF.rpageDataSB -activerelief flat -background lightblue -width 12 -command ".rPAGE$r_page_cnt.rpageDataF.rpageDataT yview"
pack .rPAGE$r_page_cnt.rpageDataF.rpageDataSB -anchor center -expand 1 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

dummy_page_r
window_menu_plus "Readable Page $r_page_cnt" ".rPAGE$r_page_cnt"
}

#
# Proc: show_page_w, Show Whole Page
#
proc show_page_w {} {

global w_page_cnt
incr w_page_cnt

toplevel .wPAGE$w_page_cnt
wm title .wPAGE$w_page_cnt  "Whole Page $w_page_cnt"

frame .wPAGE$w_page_cnt.wpageTopF -background lightblue -borderwidth 0 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

frame .wPAGE$w_page_cnt.wpageTopF.nwF -background lightblue -borderwidth 0 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.nwF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

frame .wPAGE$w_page_cnt.wpageTopF.nwF.swF -background lightblue -borderwidth 4 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.nwF.swF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

label .wPAGE$w_page_cnt.wpageTopF.nwF.selPageL -background lightblue -text " Select Page Number: "
pack .wPAGE$w_page_cnt.wpageTopF.nwF.selPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .wPAGE$w_page_cnt.wpageTopF.nwF.selPageE -background lightblue -width 12
pack .wPAGE$w_page_cnt.wpageTopF.nwF.selPageE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

label .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageL -background lightblue -text "Current Page Number:"
pack .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageDataL -background lightblue -width 12 -height 1 -relief flat -highlightthickness 2
pack .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .wPAGE$w_page_cnt.wpageTopF.neF -background lightblue -borderwidth 0 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.neF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right

frame .wPAGE$w_page_cnt.wpageTopF.neF.seF -background lightblue -borderwidth 4 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.neF.seF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

button .wPAGE$w_page_cnt.wpageTopF.neF.okB -background lightblue -padx 9 -pady 3 -text OK
pack .wPAGE$w_page_cnt.wpageTopF.neF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .wPAGE$w_page_cnt.wpageTopF.neF.cxlB -background lightblue -padx 9 -pady 3 -text Cancel
pack .wPAGE$w_page_cnt.wpageTopF.neF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

button .wPAGE$w_page_cnt.wpageTopF.neF.seF.closeB -background lightblue -padx 9 -pady 3 -text "Close Window" -command  " window_menu_minus \"Whole Page $w_page_cnt\" \".wPAGE$w_page_cnt\" "
pack .wPAGE$w_page_cnt.wpageTopF.neF.seF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .wPAGE$w_page_cnt.wpageDataF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .wPAGE$w_page_cnt.wpageDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

label .wPAGE$w_page_cnt.wpageDataF.wpageDataL -background lightblue
pack .wPAGE$w_page_cnt.wpageDataF.wpageDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
image create photo page_image -width 384 -height 384
page_image blank
page_image put white -to 0 0 384 384
.wPAGE$w_page_cnt.wpageDataF.wpageDataL config -image page_image
window_menu_plus "Whole Page $w_page_cnt" ".wPAGE$w_page_cnt"
}

#
# Proc: show_segment, Show Segment
#
proc show_segment {} {
global segment_cnt
incr segment_cnt
toplevel .sEGMENT$segment_cnt
wm title .sEGMENT$segment_cnt  "Segment $segment_cnt"

frame .sEGMENT$segment_cnt.segTopF -background lightblue -borderwidth 4 -class FakeFrame
pack .sEGMENT$segment_cnt.segTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
 
label .sEGMENT$segment_cnt.segTopF.selSegL -background lightblue -text "Select Segment Number:"
pack .sEGMENT$segment_cnt.segTopF.selSegL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .sEGMENT$segment_cnt.segTopF.selSegE -background lightblue -width 3
pack .sEGMENT$segment_cnt.segTopF.selSegE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .sEGMENT$segment_cnt.segTopF.segLocL -background lightblue -width 5 -height 1 -relief flat -highlightthickness 2
pack .sEGMENT$segment_cnt.segTopF.segLocL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .sEGMENT$segment_cnt.segTopF.closeB -background lightblue -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Segment $segment_cnt\" \".sEGMENT$segment_cnt\" "
pack .sEGMENT$segment_cnt.segTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side right
button .sEGMENT$segment_cnt.segTopF.cxlB -background lightblue -padx 9 -pady 3 -text Cancel
pack .sEGMENT$segment_cnt.segTopF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side right
button .sEGMENT$segment_cnt.segTopF.okB -background lightblue -padx 9 -pady 3 -text OK
pack .sEGMENT$segment_cnt.segTopF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side right

frame .sEGMENT$segment_cnt.segDataF -background lightblue -borderwidth 2 -class FakeFrame
pack .sEGMENT$segment_cnt.segDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

label .sEGMENT$segment_cnt.segDataF.segDataL -background lightblue -text "Segment 0"
pack .sEGMENT$segment_cnt.segDataF.segDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
frame .sEGMENT$segment_cnt.segDataF.dataF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .sEGMENT$segment_cnt.segDataF.dataF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
label .sEGMENT$segment_cnt.segDataF.dataF.segDataL -background lightblue
pack .sEGMENT$segment_cnt.segDataF.dataF.segDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
image create photo segment_image -width 512 -height 512
segment_image blank
segment_image put white -to 0 0 512 512

dummy_segment

.sEGMENT$segment_cnt.segDataF.dataF.segDataL config -image segment_image
window_menu_plus "Segment $segment_cnt" ".sEGMENT$segment_cnt"
}

#
# Proc: show_console, Show (I/O) Console
#
proc show_console {} {
if [winfo exists .cONSOLE] {
  wm deiconify .cONSOLE
  raise .cONSOLE
} else {
  toplevel .cONSOLE
  wm title .cONSOLE  "Console"

  frame .cONSOLE.conTopF -background lightblue -borderwidth 0 -class FakeFrame
  pack .cONSOLE.conTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

  button .cONSOLE.conTopF.button1 -background lightblue -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Console\" \".cONSOLE\" "
  pack .cONSOLE.conTopF.button1 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top

  frame .cONSOLE.conDataF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .cONSOLE.conDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

  frame .cONSOLE.conDataF.conInF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .cONSOLE.conDataF.conInF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  label .cONSOLE.conDataF.conInF.conInL -background lightblue -padx 0 -pady 0 -text "Input (ASCII):"
  pack .cONSOLE.conDataF.conInF.conInL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 8 -side top
  entry .cONSOLE.conDataF.conInF.conInE -background lightblue -width 64
  pack .cONSOLE.conDataF.conInF.conInE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 8 -side top
  frame .cONSOLE.conDataF.conOutF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .cONSOLE.conDataF.conOutF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
  label .cONSOLE.conDataF.conOutF.conOutL -background lightblue -padx 0 -pady 0 -text "Output (ASCII):"
  pack .cONSOLE.conDataF.conOutF.conOutL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
  text .cONSOLE.conDataF.conOutF.conOutT -background lightblue -width 54 -height 24 -relief groove
  pack .cONSOLE.conDataF.conOutF.conOutT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
}
window_menu_plus "Console" ".cONSOLE"
}

#
# Proc: show_tlb, Show TLB
#
proc show_tlb {} {

if [winfo exists .tLB] {
  wm deiconify .tLB
  raise .tLB
} else {
  toplevel .tLB
  wm title .tLB  "TLB"

  frame .tLB.tlbTopF -background lightblue -borderwidth 0 -class FakeFrame
  pack .tLB.tlbTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  button .tLB.tlbTopF.closeB -background lightblue -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"TLB\" \".tLB\" "
  pack .tLB.tlbTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top

  frame .tLB.tlbDataF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .tLB.tlbDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

  frame .tLB.tlbDataF.tlbValF -background lightblue -class FakeFrame
  pack .tLB.tlbDataF.tlbValF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbValF.tlbValL -background lightblue -text Valid -width 4
  pack .tLB.tlbDataF.tlbValF.tlbValL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbValF.tlbValT -background lightblue -height 16 -relief groove -width 4
  pack .tLB.tlbDataF.tlbValF.tlbValT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  frame .tLB.tlbDataF.tlbAddrF -background lightblue -class FakeFrame
  pack .tLB.tlbDataF.tlbAddrF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .tLB.tlbDataF.tlbAddrF.tlbAddrL -background lightblue -text "Physical Page Address"
  pack .tLB.tlbDataF.tlbAddrF.tlbAddrL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  text .tLB.tlbDataF.tlbAddrF.tlbAddrT -background lightblue -height 16 -relief groove -width 20 -yscrollcommand ".tLB.tlbDataF.tlbDataSB set"
  pack .tLB.tlbDataF.tlbAddrF.tlbAddrT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  proc scroll_tlb {args} {
    eval .tLB.tlbDataF.tlbValF.tlbValT yview $args
    eval .tLB.tlbDataF.tlbAddrF.tlbAddrT yview $args
  }
  scrollbar .tLB.tlbDataF.tlbDataSB -activerelief flat -background lightblue -width 12 -command scroll_tlb
  pack .tLB.tlbDataF.tlbDataSB -anchor center -expand 1 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
}
window_menu_plus "TLB" ".tLB"
dummy_tlb
}

#
# Proc: show_exc_r, Show Exception Registers
#
proc show_exc_r {} {
if [winfo exists .eXCEPTION] {
  wm deiconify .eXCEPTION
  raise .eXCEPTION
} else {
  toplevel .eXCEPTION
  wm title .eXCEPTION  "Exception Registers"
  
  frame .eXCEPTION.excTopF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .eXCEPTION.excTopF -anchor center -expand 0 -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
  button .eXCEPTION.excTopF.closeW -background lightblue -padx 9 -pady 3 -text "Close Window" -command  " window_menu_minus \"Exception Registers\" \".eXCEPTION\" "
  pack .eXCEPTION.excTopF.closeW -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 4 -side top
  #
  # EPC (exception PC)
  frame .eXCEPTION.excMidF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .eXCEPTION.excMidF -anchor center -expand 0 -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
  frame .eXCEPTION.excMidF.epcF -background lightblue -class FakeFrame
  pack .eXCEPTION.excMidF.epcF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excMidF.epcF.epcL -background lightblue -text "EPC (exception PC):"
  pack .eXCEPTION.excMidF.epcF.epcL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excMidF.epcF.epcDataL -background lightblue -height 1 -width 8 -relief groove -highlightthickness 2
  pack .eXCEPTION.excMidF.epcF.epcDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  #
  # EAR (exception address register)
  frame .eXCEPTION.excMidF.earF -background lightblue -class FakeFrame
  pack .eXCEPTION.excMidF.earF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excMidF.earF.earL -background lightblue -text "EAR (exception address register):"
  pack .eXCEPTION.excMidF.earF.earL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excMidF.earF.earDataL -background lightblue -height 1 -width 8 -relief groove -highlightthickness 2
  pack .eXCEPTION.excMidF.earF.earDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  #
  # ESR (exception status register), Label
  frame .eXCEPTION.excBotF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
  pack .eXCEPTION.excBotF -anchor center -expand 0 -fill x -ipadx 0 -ipady 6 -padx 0 -pady 0 -side top
  frame .eXCEPTION.excBotF.excF -background lightblue -borderwidth 4 -class FakeFrame
  pack .eXCEPTION.excBotF.excF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  label .eXCEPTION.excBotF.excF.label10 -background lightblue -text "ESR (exception status register):"
  pack .eXCEPTION.excBotF.excF.label10 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  #
  #  ESR (exception status register): B, IE, xxx, KU
  frame .eXCEPTION.excBotF.excDataF -background lightblue -borderwidth 0 -class FakeFrame -relief groove
  pack .eXCEPTION.excBotF.excDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.bF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.bF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.bF.bL -background lightblue -text B
  pack .eXCEPTION.excBotF.excDataF.bF.bL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.bF.bDataL -background lightblue -height 1 -width 1 -relief groove  -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.bF.bDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.ieF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.ieF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.ieF.ieL -background lightblue -text IE
  pack .eXCEPTION.excBotF.excDataF.ieF.ieL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.ieF.ieDataL -background lightblue -height 1 -width 3 -relief groove  -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.ieF.ieDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.xF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.xF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.xF.xL -background lightblue -text " "
  pack .eXCEPTION.excBotF.excDataF.xF.xL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.xF.xDataL -background lightblue -height 1 -width 1 -relief groove -highlightthickness 2 -text "-"
  pack .eXCEPTION.excBotF.excDataF.xF.xDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.kuF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.kuF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.kuF.kuL -background lightblue -text KU
  pack .eXCEPTION.excBotF.excDataF.kuF.kuL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.kuF.kuDataL -background lightblue -height 1 -width 3 -relief groove -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.kuF.kuDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  #
  #  ESR (exception status register): xxx, Cause, Intmask, Interrupt
  frame .eXCEPTION.excBotF.excDataF.xxxF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.xxxF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.xxxF.xxxL -background lightblue -text " "
  pack .eXCEPTION.excBotF.excDataF.xxxF.xxxL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.xxxF.xxxDataL -background lightblue -height 1 -width 3 -relief groove -text "---" -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.xxxF.xxxDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.causeF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.causeF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.causeF.causeL -background lightblue -text Cause
  pack .eXCEPTION.excBotF.excDataF.causeF.causeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.causeF.causeDataL -background lightblue -height 1 -width 5 -relief groove -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.causeF.causeDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.imaskF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.imaskF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.imaskF.imaskL -background lightblue -text IntMask
  pack .eXCEPTION.excBotF.excDataF.imaskF.imaskL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.imaskF.imaskDataL -background lightblue -height 1 -width 8 -relief groove -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.imaskF.imaskDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  frame .eXCEPTION.excBotF.excDataF.intrptF -background lightblue -class FakeFrame -relief raised
  pack .eXCEPTION.excBotF.excDataF.intrptF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
  label .eXCEPTION.excBotF.excDataF.intrptF.intrptL -background lightblue -text Interrupt
  pack .eXCEPTION.excBotF.excDataF.intrptF.intrptL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
  label .eXCEPTION.excBotF.excDataF.intrptF.intrptDataL -background lightblue -height 1 -width 8 -relief groove -highlightthickness 2
  pack .eXCEPTION.excBotF.excDataF.intrptF.intrptDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
}
window_menu_plus "Exception Registers" ".eXCEPTION"
}

#
# Proc: show_watchpts, Show Watch Points
#
proc show_watchpts {} {
if [winfo exists .wATCHPT] {
  wm deiconify .wATCHPT
  raise .wATCHPT
} else {
  toplevel .wATCHPT
  wm title .wATCHPT  "Watch Points"

# Buttons
frame .wATCHPT.watTopF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.watTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
button .wATCHPT.watTopF.newB -background lightblue -padx 9 -pady 3 -text "Add New Watchpoint" -command add_watchpt
pack .wATCHPT.watTopF.newB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .wATCHPT.watTopF.closeB -background lightblue -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Watch Points\" \".wATCHPT\" "
pack .wATCHPT.watTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

# Header
frame .wATCHPT.watHdrF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.watHdrF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
# var name
label .wATCHPT.watHdrF.nameL -background lightblue -text Name -width 8
pack .wATCHPT.watHdrF.nameL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Data Type
label .wATCHPT.watHdrF.typeL -background lightblue -text Type -width 4
pack .wATCHPT.watHdrF.typeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# data
label .wATCHPT.watHdrF.valL -background lightblue -text Value -width 8
pack .wATCHPT.watHdrF.valL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Line in code Line
label .wATCHPT.watHdrF.codeL -background lightblue -text "Line of Code" -width 25
pack .wATCHPT.watHdrF.codeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

# Sample Data: Row 1
frame .wATCHPT.frame3 -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.frame3 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
# var name
label .wATCHPT.frame3.label1 -background lightblue -text R06 -width 8 -font helvetica12
pack .wATCHPT.frame3.label1 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Data Type
label .wATCHPT.frame3.label2 -background lightblue -text Asc -width 4 -font helvetica12
pack .wATCHPT.frame3.label2 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# data
label .wATCHPT.frame3.label3 -background lightblue -text HELLO -width 8 -font helvetica12 
pack .wATCHPT.frame3.label3 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Line in code Line
label .wATCHPT.frame3.label5 -background lightblue -text "ld1 r008, r005, 0x001a" -width 25 -font helvetica12
pack .wATCHPT.frame3.label5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Remove
button .wATCHPT.frame3.button5 -background lightblue -padx 9 -pady 3 -text Remove -font helvetica12
pack .wATCHPT.frame3.button5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

# Sample Data: Row 2
frame .wATCHPT.frame4 -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.frame4 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
# var name
label .wATCHPT.frame4.label1 -background lightblue -text R1a -width 8 -font helvetica12
pack .wATCHPT.frame4.label1 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Data Type
label .wATCHPT.frame4.label2 -background lightblue -text Hex -width 4 -font helvetica12
pack .wATCHPT.frame4.label2 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# data
label .wATCHPT.frame4.label3 -background lightblue -text 0001ab -width 8 -font helvetica12 
pack .wATCHPT.frame4.label3 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Line in code Line
label .wATCHPT.frame4.label5 -background lightblue -text "st1 r008, r005, 0x001a" -width 25 -font helvetica12
pack .wATCHPT.frame4.label5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Remove
button .wATCHPT.frame4.button5 -background lightblue -padx 9 -pady 3 -text Remove -font helvetica12
pack .wATCHPT.frame4.button5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
}
window_menu_plus "Watch Points" ".wATCHPT"
}

#
# Proc: add_watchpt, Add Watchpoint
#
proc add_watchpt {} {

global n_watch_cnt
incr n_watch_cnt

toplevel .nWATCHPT$n_watch_cnt
wm title .nWATCHPT$n_watch_cnt  "New Watch Point $n_watch_cnt"

frame .nWATCHPT$n_watch_cnt.nwpTopF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .nWATCHPT$n_watch_cnt.nwpTopF -anchor n -expand 0 -fill x -ipadx 0 -ipady 8 -padx 0 -pady 0 -side top

button .nWATCHPT$n_watch_cnt.nwpTopF.okB -background lightblue -padx 9 -pady 3 -text OK -command " window_menu_minus \"New Watch Point $n_watch_cnt\" \".nWATCHPT$n_watch_cnt\" "
pack .nWATCHPT$n_watch_cnt.nwpTopF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 20 -pady 0 -side left
button .nWATCHPT$n_watch_cnt.nwpTopF.cxlB -background lightblue -padx 9 -pady 3 -text Cancel -command " window_menu_minus \"New Watch Point $n_watch_cnt\" \".nWATCHPT$n_watch_cnt\" "
pack .nWATCHPT$n_watch_cnt.nwpTopF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 20 -pady 0 -side left

frame .nWATCHPT$n_watch_cnt.nwpBotF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .nWATCHPT$n_watch_cnt.nwpBotF -anchor n -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

frame .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF -background lightblue -borderwidth 4 -class FakeFrame -relief flat
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF -anchor n -expand 0 -fill both -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
label .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarL -background lightblue -text "Enter Variable Name:"
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarE -background lightblue -width 12
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

label .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeL -background lightblue -text "Select Data Type:"
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeL -anchor n -expand 0 -fill none -ipadx 0 -ipady 0 -padx 10 -pady 2 -side top

frame .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF -background lightblue -borderwidth 4 -class FakeFrame -relief flat
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF -anchor n -expand 0 -fill none -ipadx 0 -ipady 0 -padx 10 -pady 2 -side top

radiobutton .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpHexRB -background lightblue -text Hexadecimal -variable datatype -value h
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpHexRB -anchor w -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
radiobutton .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpDecRB -background lightblue -text Decimal -variable datatype -value d
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpDecRB -anchor w -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
radiobutton .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpAscRB -background lightblue -text ASCII -variable datatype -value a
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpAscRB -anchor w -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
set datatype d
window_menu_plus "New Watch Point $n_watch_cnt" ".nWATCHPT$n_watch_cnt"
}

#
# Proc: show_dhc, Show Dec - Hex Conversion
#
proc show_dhc {} {
if [winfo exists .dHCONV] {
  wm deiconify .dHCONV
  raise .dHCONV
} else {
  toplevel .dHCONV
  wm title .dHCONV  "Dec - Hex Conversion"

# Buttons
frame .dHCONV.dhcTopF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
button .dHCONV.dhcTopF.okB -background lightblue -padx 9 -pady 3 -text "OK" -command convert_dhc
pack .dHCONV.dhcTopF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .dHCONV.dhcTopF.clearB -background lightblue -padx 9 -pady 3 -text "Clear" -command clear_dhc
pack .dHCONV.dhcTopF.clearB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .dHCONV.dhcTopF.closeB -background lightblue -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Dec - Hex Conversion\" \".dHCONV\" "
pack .dHCONV.dhcTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

# Instructions
frame .dHCONV.dhcInstrF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcInstrF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label .dHCONV.dhcInstrF.dhcInstrL -background lightblue -text "Enter data in appropriate column, \nthen click OK, or CLEAR to try again"
pack .dHCONV.dhcInstrF.dhcInstrL -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top

frame .dHCONV.dhcDataF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

# Binary
frame .dHCONV.dhcDataF.dhcBinF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcBinF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcBinF.dhcBinL -background lightblue -text Binary
pack .dHCONV.dhcDataF.dhcBinF.dhcBinL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcBinF.dhcBinE -background lightblue -width 32 -font helvetica12
pack .dHCONV.dhcDataF.dhcBinF.dhcBinE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcBinF.dhcBinE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcBinF.dhcBinE <Any-Key> "clear_dhc %W"

# Octal
frame .dHCONV.dhcDataF.dhcOctF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcOctF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcOctF.dhcOctL -background lightblue -text Octal
pack .dHCONV.dhcDataF.dhcOctF.dhcOctL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcOctF.dhcOctE -background lightblue -width 11 -font helvetica12
pack .dHCONV.dhcDataF.dhcOctF.dhcOctE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcOctF.dhcOctE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcOctF.dhcOctE <Any-Key> "clear_dhc %W"

# Hex
frame .dHCONV.dhcDataF.dhcHexF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcHexF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcHexF.dhcHexL -background lightblue -text Hex
pack .dHCONV.dhcDataF.dhcHexF.dhcHexL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcHexF.dhcHexE -background lightblue -width 8 -font helvetica12 
pack .dHCONV.dhcDataF.dhcHexF.dhcHexE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcHexF.dhcHexE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcHexF.dhcHexE <Any-Key> "clear_dhc %W"

# Decimal
frame .dHCONV.dhcDataF.dhcDecF -background lightblue -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcDecF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcDecF.dhcDecL -background lightblue -text Decimal
pack .dHCONV.dhcDataF.dhcDecF.dhcDecL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcDecF.dhcDecE -background lightblue -width 10 -font helvetica12
pack .dHCONV.dhcDataF.dhcDecF.dhcDecE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcDecF.dhcDecE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcDecF.dhcDecE <Any-Key> "clear_dhc %W"
}
window_menu_plus "Dec - Hex Conversion" ".dHCONV"
}

#
# Proc: clear_dhc, Clear Dec - Hex Conversion windows (all windows: bin, oct, hex, dec)
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
# Proc: convert_dhc, Convert Dec - Hex Conversion
#       accepts any of: bin, oct, hex, dec, and fills in the other 3 windows.
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
# Proc: window_menu_plus, Add Item to "Windows" Menu
#
proc window_menu_plus {window_name window} {
global ROOT
# If the item already exists (specifically for non-repeating items, ie TLB, Console) 
#    in the "windows menu" then return
set end [$ROOT.menubar.windoMB.menu5 index end]
if {"$end"=="none"} { set end -1 }
  for {set i 0} {$i<=$end} {incr i} {
    set label [$ROOT.menubar.windoMB.menu5 entrycget $i -label]
    if {"$label"=="$window_name"} {
      return
    }
  }
$ROOT.menubar.windoMB.menu5 add command -label "$window_name" -command "window_menu_raise $window"
}

#
# Proc: window_menu_minus, Remove Item from "Windows" Menu
#
proc window_menu_minus {window_name window} {
global ROOT
# get the index of the last current entry in the menu
set end [$ROOT.menubar.windoMB.menu5 index end]
# loop thru until we find the item to be deleted
  for {set i 0} {$i<=$end} {incr i} {
    set label [$ROOT.menubar.windoMB.menu5 entrycget $i -label]
    if {"$label"=="$window_name"} {
      $ROOT.menubar.windoMB.menu5 delete $i
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

#
# Proc: dummy_page_r
#
proc dummy_page_r {} {
global r_page_cnt
# Readable Page Data
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x000:  00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0f\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x001:  10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1f\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x002:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x003:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x004:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x005:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x006:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x007:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x008:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x009:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x00a:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x00b:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x00c:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x00d:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x00e:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x00f:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x010:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x011:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x012:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x013:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x014:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x015:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x016:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x017:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x018:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x019:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x01a:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x01b:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x01c:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x01d:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x01e:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x01f:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x020:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x021:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x022:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x023:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x024:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x025:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x026:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x027:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x028:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x029:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x02a:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x02b:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x02c:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x02d:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
 .rPAGE$r_page_cnt.rpageDataF.rpageDataT insert insert "0x02e:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00\n"
}

#
# Proc: dummy_segment
#
proc dummy_segment {} {
#
segment_image put black -to 410 110
segment_image put black -to 410 111
segment_image put black -to 410 112
segment_image put black -to 410 113
segment_image put black -to 410 114
segment_image put black -to 410 115
segment_image put black -to 411 110
segment_image put black -to 411 111
segment_image put black -to 411 112
segment_image put black -to 411 113
segment_image put black -to 411 114
segment_image put black -to 411 115
segment_image put black -to 412 110
segment_image put black -to 412 111
segment_image put black -to 412 112
segment_image put black -to 412 113
segment_image put black -to 412 114
segment_image put black -to 412 115
segment_image put black -to 413 110
segment_image put black -to 413 111
segment_image put black -to 413 112
segment_image put black -to 413 113
segment_image put black -to 413 114
segment_image put black -to 413 115
segment_image put black -to 414 110
segment_image put black -to 414 111
segment_image put black -to 414 112
segment_image put black -to 414 113
segment_image put black -to 414 114
segment_image put black -to 414 115
segment_image put black -to 415 110
segment_image put black -to 415 111
segment_image put black -to 415 112
segment_image put black -to 415 113
segment_image put black -to 415 114
segment_image put black -to 415 115
#
segment_image put red -to 232 242
segment_image put red -to 232 243
segment_image put red -to 232 244
segment_image put red -to 232 245
segment_image put red -to 233 242
segment_image put red -to 233 243
segment_image put red -to 233 244
segment_image put red -to 233 245
segment_image put red -to 234 242
segment_image put red -to 234 243
segment_image put red -to 234 244
segment_image put red -to 234 245
}
proc dummy_tlb {} {
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  1\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  1\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  1\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  1\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  1\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  1\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbValF.tlbValT insert insert "  0\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00000\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00001\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x000a2\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00100\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x000b1\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x02002\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00c00\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x000d1\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00102\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00f00\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00021\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00d02\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00400\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00201\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x010a2\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00130\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x070b1\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x02902\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00c80\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x020d1\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x00102\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0xa0f00\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x03021\n"
.tLB.tlbDataF.tlbAddrF.tlbAddrT insert insert "0x03d02\n"
}
