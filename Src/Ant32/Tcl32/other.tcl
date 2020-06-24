#
# Proc: show_page_r, Show Readable Page
#
proc show_page_r {} {
global r_page_cnt
incr r_page_cnt +1

toplevel .rPAGE$r_page_cnt
wm title .rPAGE$r_page_cnt  "Readable Page $r_page_cnt"

frame .rPAGE$r_page_cnt.rpageTopF  -borderwidth 0 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
frame .rPAGE$r_page_cnt.rpageTopF.nwF  -borderwidth 0 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.nwF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
frame .rPAGE$r_page_cnt.rpageTopF.nwF.swF  -borderwidth 4 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.nwF.swF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

label .rPAGE$r_page_cnt.rpageTopF.nwF.selPageL  -text " Select Page Number: "
pack .rPAGE$r_page_cnt.rpageTopF.nwF.selPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .rPAGE$r_page_cnt.rpageTopF.nwF.selPageE  -width 12
pack .rPAGE$r_page_cnt.rpageTopF.nwF.selPageE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageL  -text "Current Page Number:"
pack .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageDataL  -width 12 -height 1 -relief flat -highlightthickness 2
pack .rPAGE$r_page_cnt.rpageTopF.nwF.swF.curPageDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .rPAGE$r_page_cnt.rpageTopF.neF  -borderwidth 0 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.neF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right
frame .rPAGE$r_page_cnt.rpageTopF.neF.seF  -borderwidth 4 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageTopF.neF.seF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom
button .rPAGE$r_page_cnt.rpageTopF.neF.okB  -padx 9 -pady 3 -text OK
pack .rPAGE$r_page_cnt.rpageTopF.neF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .rPAGE$r_page_cnt.rpageTopF.neF.cxlB  -padx 9 -pady 3 -text Cancel
pack .rPAGE$r_page_cnt.rpageTopF.neF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .rPAGE$r_page_cnt.rpageTopF.neF.seF.closeB  -padx 9 -pady 3 -text "Close Window" -command  " window_menu_minus \"Readable Page $r_page_cnt\" \".rPAGE$r_page_cnt\" "
pack .rPAGE$r_page_cnt.rpageTopF.neF.seF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .rPAGE$r_page_cnt.rpageDataF  -borderwidth 2 -class FakeFrame
pack .rPAGE$r_page_cnt.rpageDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

text .rPAGE$r_page_cnt.rpageDataF.rpageDataT  -height 32 -relief groove -width 53 -yscrollcommand ".rPAGE$r_page_cnt.rpageDataF.rpageDataSB set"
pack .rPAGE$r_page_cnt.rpageDataF.rpageDataT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
scrollbar .rPAGE$r_page_cnt.rpageDataF.rpageDataSB -activerelief flat  -width 12 -command ".rPAGE$r_page_cnt.rpageDataF.rpageDataT yview"
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

frame .wPAGE$w_page_cnt.wpageTopF  -borderwidth 0 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

frame .wPAGE$w_page_cnt.wpageTopF.nwF  -borderwidth 0 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.nwF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

frame .wPAGE$w_page_cnt.wpageTopF.nwF.swF  -borderwidth 4 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.nwF.swF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

label .wPAGE$w_page_cnt.wpageTopF.nwF.selPageL  -text " Select Page Number: "
pack .wPAGE$w_page_cnt.wpageTopF.nwF.selPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .wPAGE$w_page_cnt.wpageTopF.nwF.selPageE  -width 12
pack .wPAGE$w_page_cnt.wpageTopF.nwF.selPageE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

label .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageL  -text "Current Page Number:"
pack .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageDataL  -width 12 -height 1 -relief flat -highlightthickness 2
pack .wPAGE$w_page_cnt.wpageTopF.nwF.swF.curPageDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .wPAGE$w_page_cnt.wpageTopF.neF  -borderwidth 0 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.neF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side right

frame .wPAGE$w_page_cnt.wpageTopF.neF.seF  -borderwidth 4 -class FakeFrame
pack .wPAGE$w_page_cnt.wpageTopF.neF.seF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

button .wPAGE$w_page_cnt.wpageTopF.neF.okB  -padx 9 -pady 3 -text OK
pack .wPAGE$w_page_cnt.wpageTopF.neF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .wPAGE$w_page_cnt.wpageTopF.neF.cxlB  -padx 9 -pady 3 -text Cancel
pack .wPAGE$w_page_cnt.wpageTopF.neF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

button .wPAGE$w_page_cnt.wpageTopF.neF.seF.closeB  -padx 9 -pady 3 -text "Close Window" -command  " window_menu_minus \"Whole Page $w_page_cnt\" \".wPAGE$w_page_cnt\" "
pack .wPAGE$w_page_cnt.wpageTopF.neF.seF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

frame .wPAGE$w_page_cnt.wpageDataF  -borderwidth 4 -class FakeFrame -relief groove
pack .wPAGE$w_page_cnt.wpageDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

label .wPAGE$w_page_cnt.wpageDataF.wpageDataL 
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

frame .sEGMENT$segment_cnt.segTopF  -borderwidth 4 -class FakeFrame
pack .sEGMENT$segment_cnt.segTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
 
label .sEGMENT$segment_cnt.segTopF.selSegL  -text "Select Segment Number:"
pack .sEGMENT$segment_cnt.segTopF.selSegL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .sEGMENT$segment_cnt.segTopF.selSegE  -width 3
pack .sEGMENT$segment_cnt.segTopF.selSegE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
label .sEGMENT$segment_cnt.segTopF.segLocL  -width 5 -height 1 -relief flat -highlightthickness 2
pack .sEGMENT$segment_cnt.segTopF.segLocL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .sEGMENT$segment_cnt.segTopF.closeB  -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Segment $segment_cnt\" \".sEGMENT$segment_cnt\" "
pack .sEGMENT$segment_cnt.segTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side right
button .sEGMENT$segment_cnt.segTopF.cxlB  -padx 9 -pady 3 -text Cancel
pack .sEGMENT$segment_cnt.segTopF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side right
button .sEGMENT$segment_cnt.segTopF.okB  -padx 9 -pady 3 -text OK
pack .sEGMENT$segment_cnt.segTopF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side right

frame .sEGMENT$segment_cnt.segDataF  -borderwidth 2 -class FakeFrame
pack .sEGMENT$segment_cnt.segDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

label .sEGMENT$segment_cnt.segDataF.segDataL  -text "Segment 0"
pack .sEGMENT$segment_cnt.segDataF.segDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
frame .sEGMENT$segment_cnt.segDataF.dataF  -borderwidth 4 -class FakeFrame -relief groove
pack .sEGMENT$segment_cnt.segDataF.dataF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
label .sEGMENT$segment_cnt.segDataF.dataF.segDataL 
pack .sEGMENT$segment_cnt.segDataF.dataF.segDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
image create photo segment_image -width 512 -height 512
segment_image blank
segment_image put white -to 0 0 512 512

dummy_segment

.sEGMENT$segment_cnt.segDataF.dataF.segDataL config -image segment_image
window_menu_plus "Segment $segment_cnt" ".sEGMENT$segment_cnt"
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
frame .wATCHPT.watTopF  -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.watTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
button .wATCHPT.watTopF.newB  -padx 9 -pady 3 -text "Add New Watchpoint" -command add_watchpt
pack .wATCHPT.watTopF.newB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .wATCHPT.watTopF.closeB  -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Watch Points\" \".wATCHPT\" "
pack .wATCHPT.watTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

# Header
frame .wATCHPT.watHdrF  -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.watHdrF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
# var name
label .wATCHPT.watHdrF.nameL  -text Name -width 8
pack .wATCHPT.watHdrF.nameL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Data Type
label .wATCHPT.watHdrF.typeL  -text Type -width 4
pack .wATCHPT.watHdrF.typeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# data
label .wATCHPT.watHdrF.valL  -text Value -width 8
pack .wATCHPT.watHdrF.valL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Line in code Line
label .wATCHPT.watHdrF.codeL  -text "Line of Code" -width 25
pack .wATCHPT.watHdrF.codeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left

# Sample Data: Row 1
frame .wATCHPT.frame3  -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.frame3 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
# var name
label .wATCHPT.frame3.label1  -text R06 -width 8 -font helvetica12
pack .wATCHPT.frame3.label1 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Data Type
label .wATCHPT.frame3.label2  -text Asc -width 4 -font helvetica12
pack .wATCHPT.frame3.label2 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# data
label .wATCHPT.frame3.label3  -text HELLO -width 8 -font helvetica12 
pack .wATCHPT.frame3.label3 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Line in code Line
label .wATCHPT.frame3.label5  -text "ld1 r008, r005, 0x001a" -width 25 -font helvetica12
pack .wATCHPT.frame3.label5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Remove
button .wATCHPT.frame3.button5  -padx 9 -pady 3 -text Remove -font helvetica12
pack .wATCHPT.frame3.button5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

# Sample Data: Row 2
frame .wATCHPT.frame4  -borderwidth 4 -class FakeFrame -relief groove
pack .wATCHPT.frame4 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
# var name
label .wATCHPT.frame4.label1  -text R1a -width 8 -font helvetica12
pack .wATCHPT.frame4.label1 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Data Type
label .wATCHPT.frame4.label2  -text Hex -width 4 -font helvetica12
pack .wATCHPT.frame4.label2 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# data
label .wATCHPT.frame4.label3  -text 0001ab -width 8 -font helvetica12 
pack .wATCHPT.frame4.label3 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Line in code Line
label .wATCHPT.frame4.label5  -text "st1 r008, r005, 0x001a" -width 25 -font helvetica12
pack .wATCHPT.frame4.label5 -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
# Remove
button .wATCHPT.frame4.button5  -padx 9 -pady 3 -text Remove -font helvetica12
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

frame .nWATCHPT$n_watch_cnt.nwpTopF  -borderwidth 4 -class FakeFrame -relief groove
pack .nWATCHPT$n_watch_cnt.nwpTopF -anchor n -expand 0 -fill x -ipadx 0 -ipady 8 -padx 0 -pady 0 -side top

button .nWATCHPT$n_watch_cnt.nwpTopF.okB  -padx 9 -pady 3 -text OK -command " window_menu_minus \"New Watch Point $n_watch_cnt\" \".nWATCHPT$n_watch_cnt\" "
pack .nWATCHPT$n_watch_cnt.nwpTopF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 20 -pady 0 -side left
button .nWATCHPT$n_watch_cnt.nwpTopF.cxlB  -padx 9 -pady 3 -text Cancel -command " window_menu_minus \"New Watch Point $n_watch_cnt\" \".nWATCHPT$n_watch_cnt\" "
pack .nWATCHPT$n_watch_cnt.nwpTopF.cxlB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 20 -pady 0 -side left

frame .nWATCHPT$n_watch_cnt.nwpBotF  -borderwidth 4 -class FakeFrame -relief groove
pack .nWATCHPT$n_watch_cnt.nwpBotF -anchor n -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

frame .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF  -borderwidth 4 -class FakeFrame -relief flat
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF -anchor n -expand 0 -fill both -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top
label .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarL  -text "Enter Variable Name:"
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
entry .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarE  -width 12
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpVarF.nwpVarE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

label .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeL  -text "Select Data Type:"
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeL -anchor n -expand 0 -fill none -ipadx 0 -ipady 0 -padx 10 -pady 2 -side top

frame .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF  -borderwidth 4 -class FakeFrame -relief flat
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF -anchor n -expand 0 -fill none -ipadx 0 -ipady 0 -padx 10 -pady 2 -side top

radiobutton .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpHexRB  -text Hexadecimal -variable datatype -value h
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpHexRB -anchor w -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
radiobutton .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpDecRB  -text Decimal -variable datatype -value d
pack .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpDecRB -anchor w -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
radiobutton .nWATCHPT$n_watch_cnt.nwpBotF.nwpTypeF.nwpAscRB  -text ASCII -variable datatype -value a
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
frame .dHCONV.dhcTopF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
button .dHCONV.dhcTopF.okB  -padx 9 -pady 3 -text "OK" -command convert_dhc
pack .dHCONV.dhcTopF.okB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left
button .dHCONV.dhcTopF.clearB  -padx 9 -pady 3 -text "Clear" -command clear_dhc
pack .dHCONV.dhcTopF.clearB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

#button .dHCONV.dhcTopF.closeB  -padx 9 -pady 3 -text "Close Window" -command " window_menu_minus \"Dec - Hex Conversion\" \".dHCONV\" "
#pack .dHCONV.dhcTopF.closeB -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 8 -side left

# Instructions
frame .dHCONV.dhcInstrF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcInstrF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
label .dHCONV.dhcInstrF.dhcInstrL  -text "Enter data in appropriate column, \nthen click OK, or CLEAR to try again"
pack .dHCONV.dhcInstrF.dhcInstrL -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 8 -pady 8 -side top

frame .dHCONV.dhcDataF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

# Binary
frame .dHCONV.dhcDataF.dhcBinF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcBinF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcBinF.dhcBinL  -text Binary
pack .dHCONV.dhcDataF.dhcBinF.dhcBinL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcBinF.dhcBinE  -width 32 -font helvetica12
pack .dHCONV.dhcDataF.dhcBinF.dhcBinE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcBinF.dhcBinE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcBinF.dhcBinE <Any-Key> "clear_dhc %W"

# Octal
frame .dHCONV.dhcDataF.dhcOctF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcOctF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcOctF.dhcOctL  -text Octal
pack .dHCONV.dhcDataF.dhcOctF.dhcOctL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcOctF.dhcOctE  -width 11 -font helvetica12
pack .dHCONV.dhcDataF.dhcOctF.dhcOctE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcOctF.dhcOctE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcOctF.dhcOctE <Any-Key> "clear_dhc %W"

# Hex
frame .dHCONV.dhcDataF.dhcHexF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcHexF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcHexF.dhcHexL  -text Hex
pack .dHCONV.dhcDataF.dhcHexF.dhcHexL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcHexF.dhcHexE  -width 8 -font helvetica12 
pack .dHCONV.dhcDataF.dhcHexF.dhcHexE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcHexF.dhcHexE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcHexF.dhcHexE <Any-Key> "clear_dhc %W"

# Decimal
frame .dHCONV.dhcDataF.dhcDecF  -borderwidth 4 -class FakeFrame -relief groove
pack .dHCONV.dhcDataF.dhcDecF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
label .dHCONV.dhcDataF.dhcDecF.dhcDecL  -text Decimal
pack .dHCONV.dhcDataF.dhcDecF.dhcDecL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
entry .dHCONV.dhcDataF.dhcDecF.dhcDecE  -width 10 -font helvetica12
pack .dHCONV.dhcDataF.dhcDecF.dhcDecE -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
bind .dHCONV.dhcDataF.dhcDecF.dhcDecE <Return> convert_dhc
bind .dHCONV.dhcDataF.dhcDecF.dhcDecE <Any-Key> "clear_dhc %W"
}
window_menu_plus "Dec - Hex Conversion" ".dHCONV"
}


proc window_menu_plus { dummy dummy1} {}
proc window_menu_minus { dummy dummy1} {}

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
