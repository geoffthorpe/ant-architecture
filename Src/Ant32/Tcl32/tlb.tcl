proc show_tlb {} {

	if [winfo exists .tLB] {
			wm deiconify .tLB
			raise .tLB
	} else {
			toplevel .tLB
			wm title .tLB  "TLB"

			frame .tLB.tlbTopF  -borderwidth 0 -class FakeFrame
			pack .tLB.tlbTopF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top

			frame .tLB.tlbDataF  -borderwidth 4 -class FakeFrame -relief groove
			pack .tLB.tlbDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side bottom

			frame .tLB.tlbDataF.tlbAddrF  -class FakeFrame
			pack .tLB.tlbDataF.tlbAddrF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
			# label .tLB.tlbDataF.tlbAddrF.tlbAddrL  -text "Physical Page Address"
			# pack .tLB.tlbDataF.tlbAddrF.tlbAddrL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
			text .tLB.tlbDataF.tlbAddrF.tlbAddrT  -height 16 -relief groove -width 100 -yscrollcommand ".tLB.tlbDataF.tlbDataSB set"
			pack .tLB.tlbDataF.tlbAddrF.tlbAddrT -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
			proc scroll_tlb {args} {
	 	 		eval .tLB.tlbDataF.tlbAddrF.tlbAddrT yview $args
 		}
			scrollbar .tLB.tlbDataF.tlbDataSB -activerelief flat  -width 12 -command scroll_tlb
			pack .tLB.tlbDataF.tlbDataSB -anchor center -expand 1 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
	}
	# window_menu_plus "TLB" ".tLB"
}
proc show_exc_r {} {
	if [winfo exists .eXCEPTION] {
		wm deiconify .eXCEPTION
		raise .eXCEPTION
	} else {
	toplevel .eXCEPTION
	wm title .eXCEPTION  "Exception Registers"

	frame .eXCEPTION.excTopF  -borderwidth 4 -class FakeFrame -relief groove
	pack .eXCEPTION.excTopF -anchor center -expand 0 -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
	# button .eXCEPTION.excTopF.closeW  -padx 9 -pady 3 -text "Close Window" -command  " window_menu_minus \"Exception Registers\" \".eXCEPTION\" "
	# pack .eXCEPTION.excTopF.closeW -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 4 -side top
	#
	# EPC (exception PC)
	frame .eXCEPTION.excMidF  -borderwidth 4 -class FakeFrame -relief groove
	pack .eXCEPTION.excMidF -anchor center -expand 0 -fill x -ipadx 6 -ipady 6 -padx 0 -pady 0 -side top
	frame .eXCEPTION.excMidF.epcF  -class FakeFrame
	pack .eXCEPTION.excMidF.epcF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excMidF.epcF.epcL  -text "EPC (exception PC):"
	pack .eXCEPTION.excMidF.epcF.epcL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excMidF.epcF.epcDataL  -height 1 -width 8 -relief groove -highlightthickness 2
	pack .eXCEPTION.excMidF.epcF.epcDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
	#
	# EAR (exception address register)
	frame .eXCEPTION.excMidF.earF  -class FakeFrame
	pack .eXCEPTION.excMidF.earF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excMidF.earF.earL  -text "EAR (exception address register):"
	pack .eXCEPTION.excMidF.earF.earL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excMidF.earF.earDataL  -height 1 -width 8 -relief groove -highlightthickness 2
	pack .eXCEPTION.excMidF.earF.earDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
	#
	# ESR (exception status register), Label
	frame .eXCEPTION.excBotF  -borderwidth 4 -class FakeFrame -relief groove
	pack .eXCEPTION.excBotF -anchor center -expand 0 -fill x -ipadx 0 -ipady 6 -padx 0 -pady 0 -side top
	frame .eXCEPTION.excBotF.excF  -borderwidth 4 -class FakeFrame
	pack .eXCEPTION.excBotF.excF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
	label .eXCEPTION.excBotF.excF.label10  -text "ESR (exception status register):"
	pack .eXCEPTION.excBotF.excF.label10 -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	#
	#  ESR (exception status register): B, IE, xxx, KU
	frame .eXCEPTION.excBotF.excDataF  -borderwidth 0 -class FakeFrame -relief groove
	pack .eXCEPTION.excBotF.excDataF -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.bF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.bF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.bF.bL  -text B
	pack .eXCEPTION.excBotF.excDataF.bF.bL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.bF.bDataL  -height 1 -width 1 -relief groove  -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.bF.bDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.ieF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.ieF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.ieF.ieL  -text IE
	pack .eXCEPTION.excBotF.excDataF.ieF.ieL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.ieF.ieDataL  -height 1 -width 3 -relief groove  -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.ieF.ieDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.xF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.xF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.xF.xL  -text " "
	pack .eXCEPTION.excBotF.excDataF.xF.xL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.xF.xDataL  -height 1 -width 1 -relief groove -highlightthickness 2 -text "-"
	pack .eXCEPTION.excBotF.excDataF.xF.xDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.kuF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.kuF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.kuF.kuL  -text KU
	pack .eXCEPTION.excBotF.excDataF.kuF.kuL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.kuF.kuDataL  -height 1 -width 3 -relief groove -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.kuF.kuDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	#
	#  ESR (exception status register): xxx, Cause, Intmask, Interrupt
	frame .eXCEPTION.excBotF.excDataF.xxxF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.xxxF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.xxxF.xxxL  -text " "
 	pack .eXCEPTION.excBotF.excDataF.xxxF.xxxL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.xxxF.xxxDataL  -height 1 -width 3 -relief groove -text "---" -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.xxxF.xxxDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.causeF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.causeF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.causeF.causeL  -text Cause
	pack .eXCEPTION.excBotF.excDataF.causeF.causeL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.causeF.causeDataL  -height 1 -width 5 -relief groove -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.causeF.causeDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.imaskF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.imaskF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.imaskF.imaskL  -text IntMask
	pack .eXCEPTION.excBotF.excDataF.imaskF.imaskL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.imaskF.imaskDataL  -height 1 -width 8 -relief groove -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.imaskF.imaskDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	frame .eXCEPTION.excBotF.excDataF.intrptF  -class FakeFrame -relief raised
	pack .eXCEPTION.excBotF.excDataF.intrptF -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 -side left
	label .eXCEPTION.excBotF.excDataF.intrptF.intrptL  -text Interrupt
	pack .eXCEPTION.excBotF.excDataF.intrptF.intrptL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	label .eXCEPTION.excBotF.excDataF.intrptF.intrptDataL  -height 1 -width 8 -relief groove -highlightthickness 2
	pack .eXCEPTION.excBotF.excDataF.intrptF.intrptDataL -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 8 -pady 0 -side top
	}	      
	# window_menu_plus "Exception Registers" ".eXCEPTION"
	update_everything

}	      

