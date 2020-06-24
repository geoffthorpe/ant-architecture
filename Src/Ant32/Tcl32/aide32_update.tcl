#!/opt/local/bin/wish8.0 -f        
# 
# $Id: aide32_update.tcl,v 1.8 2003/06/05 20:42:46 sara Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#

    global ROOT
    global GEN_REG_START
    global TEMP_REG_START
    set GEN_REG_START 4
    set TEMP_REG_START 60

#
#  This file contains the following comment blocks:
#
# 1. Update Main Window windows :
#    update_display
# 2. Update Popup Windows:
#    update_tlb, update_watchpoint, int2ascii.
# 3. Utilities Used to Update Main and Popup Windows:
#    update_line, add_line.
# 4. Update Memory Procs:
#    memory_hit, redraw_physical_memory.
#
#
# ----------------------------------------------------------------------
# 1. Update Mainwindow Display Procs 
#
# update_display: update all the fields in the main window
#    CALLED BY: open_a32, do_reset, do_run, do_step, temp_reg_yes,
#    aide_window_setup, reset_config, show_config.
#    PROCS IT CALLS: update_line, add_line, update_watchpoint, update_tlb,
#    memory_hit
#    C FUNCTIONS CALLED: $VM register_name, $VM get_register, 
#    $VM get_num_registers, $VM get_src[1,2,3]_reg, $VM get_dest[1,2]_reg,
#    $VM disassemble, $VM codeline
# ----------------------------------------------------------------------
#
#
proc update_display {} {

global VM
global ROOT
global instr_count
global init_PC
global register_label  # what is used to label the registers
global register_choice # what the user selected, can be "default"
global pop_up_exc_reg
global old_pc
global temp_reg
global pmem_cnt
global pagehit wordhit
global breakpoints
global watchpoints
global GEN_REG_START
global TEMP_REG_START

    # update upper left hand area of window:
    #        program counter, instruction register, status, mode

    # update program counter:
    set pc [$VM get_register PC]
    # update mode:
    set mode [$VM get_mode]
     if {$mode} {set output "supervisor"} else {set output "user"}
     update_line $ROOT.leftF.stateF.modeF.modeT 1 $output

    # update memory mode:
     if {[expr $pc&0x80000000]}  {
       set output "physical"
     } else {
       set output "virtual"
     }
     update_line $ROOT.leftF.stateF.memmodeF.memmodeT 1 $output

    # update PC display
    update_line $ROOT.leftF.stateF.pcF.pcT 1 [format 0x%08x $pc]

    # update dedicated registers:
    for {set i 0} {$i< $GEN_REG_START} {incr i} {
      set output [format "%3s 0x%08x" \
        [$VM register_name $i $register_label] [$VM get_register $i] ]
      update_line $ROOT.leftF.regF.reg1F.sp-regF.excD [expr $i+1] $output
      update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT [expr $i+1] ""
      update_line $ROOT.leftF.regF.reg1F.regDesF.regDesT [expr $i+1] ""
    }

    # update general purpose registers:
    for {set i $GEN_REG_START} {$i<$TEMP_REG_START} {incr i} {
        set output [format "%3s 0x%08x" \
                   [$VM register_name $i $register_label] \
                   [$VM get_register $i] ]
        update_line $ROOT.leftF.regF.reg2F.regDataF.regDataT \
           [expr $i+1-$GEN_REG_START] $output
        update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
           [expr $i+1-$GEN_REG_START] ""
        update_line $ROOT.leftF.regF.reg2F.regDesF.regDesT \
           [expr $i+1-$GEN_REG_START] ""
    }

    # update temp registers:
    for {set i 0} {$i< 4} {incr i} {
      set output [format "%3s 0x%08x" \
        [$VM register_name [expr $i+$TEMP_REG_START] $register_label] \
        [$VM get_register [expr $i+$TEMP_REG_START] ] ]
      update_line $ROOT.leftF.regF.reg3F.sc-regF.regD [expr $i+1] $output
      update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT [expr $i+1] ""
      update_line $ROOT.leftF.regF.reg3F.regDesF.regDesT [expr $i+1] ""
    }

    # update watchpoints:   
    # (since values are updated below, this only serves to clear highlighting)
    foreach wp [array names watchpoints] {
      eval update_watchpoint [split $wp ,]
    }

    #
    # update tlb:
    # this needs to come before the section that calls memory_hit, otherwise
    # it will clear the tags that memory_hit sets
    if [winfo exists .tLB] {
      update_tlb
    }

    # show the effects of the last instruction that was executed, if any
    set min_reg [expr $TEMP_REG_START-$GEN_REG_START]
    if [string length $old_pc] {
      if { [$VM get_src1_reg $old_pc] >= 0 } {
        set src1 [$VM get_src1_reg $old_pc]
        if ($src1<4) {
           update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
             [expr $src1+1] "-1->"
        } elseif ($src1>=60) {
           update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
             [expr $src1-59] "-1->"
        } else {
           update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
             [expr $src1-3] "-1->"
           if { $src1 < $min_reg} { set min_reg $src1 }
        }
        if [info exists watchpoints(reg,$src1)] {
          update_watchpoint reg $src1 src
        }
      }
      if { [$VM get_src2_reg $old_pc] >= 0 } {
        set src2 [$VM get_src2_reg $old_pc]
        if { $src2 == $src1 } {
          if ($src2<4) {
             update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
               [expr $src2+1] "1,2>"
          } elseif ($src2>=60) {
             update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
               [expr $src2-59] "1,2>"
          } else {
             update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
               [expr $src2-3] "1,2>"
             if { $src2 < $min_reg} { set min_reg $src2 }
          }
        } else {
          if ($src2<4) {
             update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
               [expr $src2+1] "-2->"
          } elseif ($src2>=60) {
             update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
               [expr $src2-59] "-2->"
          } else {
             update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
               [expr $src2-3] "-2->"
             if { $src2 < $min_reg} { set min_reg $src2 }
          }
        }
        if [info exists watchpoints(reg,$src2)] {
          update_watchpoint reg $src2 src
        }
      }
      if { [$VM get_src3_reg $old_pc] >= 0 } {
        set src3 [$VM get_src3_reg $old_pc]
        if { $src3 == $src1 } {
          if { $src3 == $src2 } {
            if ($src3<4) {
               update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
                 [expr $src3+1] "123>"
            } elseif ($src3>=60) {
               update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
                 [expr $src3-59] "123>"
            } else {
               update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
                 [expr $src3-3] "123>"
               if { $src3 < $min_reg} { set min_reg $src3 }
            }
          } else {
            if ($src3<4) {
               update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
                 [expr $src3+1] "1,3>"
            } elseif ($src3>=60) {
               update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
                 [expr $src3-59] "1,3>"
            } else {
               update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
                 [expr $src3-3] "1,3>"
               if { $src3 < $min_reg} { set min_reg $src3 }
            }
          }
        } elseif { $src3 == $src2 } {
            if ($src3<4) {
               update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
                 [expr $src3+1] "2,3>"
            } elseif ($src3>=60) {
               update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
                 [expr $src3-59] "2,3>"
            } else {
               update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
                 [expr $src3-3] "2,3>"
               if { $src3 < $min_reg} { set min_reg $src3 }
            }
        } else {
            if ($src3<4) {
               update_line $ROOT.leftF.regF.reg1F.regSrcF.regSrcT \
                 [expr $src3+1] "-3->"
            } elseif ($src3>=60) {
               update_line $ROOT.leftF.regF.reg3F.regSrcF.regSrcT \
                 [expr $src3-59] "-3->"
            } else {
               update_line $ROOT.leftF.regF.reg2F.regSrcF.regSrcT \
                 [expr $src3-3] "-3->"
               if { $src3 < $min_reg} { set min_reg $src3 }
            }
        }
        if [info exists watchpoints(reg,$src3)] {
          update_watchpoint reg $src3 src
        }
      }
      if { [$VM get_dest1_reg $old_pc] >= 0 } {
        set dest1 [$VM get_dest1_reg $old_pc]
        if ($dest1<4) {
           update_line $ROOT.leftF.regF.reg1F.regDesF.regDesT \
             [expr $dest1+1] "<-1-"
        } elseif ($dest1>=60) {
           update_line $ROOT.leftF.regF.reg3F.regDesF.regDesT \
             [expr $dest1-59] "<-1-"
        } else {
           update_line $ROOT.leftF.regF.reg2F.regDesF.regDesT \
             [expr $dest1-3] "<-1-"
           if { $dest1 < $min_reg} { set min_reg $dest1 }
        }
        if [info exists watchpoints(reg,$dest1)] {
          update_watchpoint reg $dest1 dst
        }
      }
      if { [$VM get_dest2_reg $old_pc] >= 0 } {
        set dest2 [$VM get_dest2_reg $old_pc]
        if { $dest2 == $dest1 } {
          if ($dest2<4) {
             update_line $ROOT.leftF.regF.reg1F.regDesF.regDesT \
               [expr $dest2+1] "<1,2"
          } elseif ($dest2>=60) {
             update_line $ROOT.leftF.regF.reg3F.regDesF.regDesT \
               [expr $dest2-59] "<1,2"
          } else {
             update_line $ROOT.leftF.regF.reg2F.regDesF.regDesT \
               [expr $dest2-3] "<1,2"
             if { $dest2 < $min_reg} { set min_reg $dest2 }
          }
        } else {
        if ($dest2<4) {
           update_line $ROOT.leftF.regF.reg1F.regDesF.regDesT \
             [expr $dest2+1] "<-2-"
        } elseif ($dest2>=60) {
           update_line $ROOT.leftF.regF.reg3F.regDesF.regDesT \
             [expr $dest2-59] "<-2-"
        } else {
           update_line $ROOT.leftF.regF.reg2F.regDesF.regDesT \
             [expr $dest2-3] "<-2-"
           if { $dest2 < $min_reg} { set min_reg $dest2 }
        }
        }
        if [info exists watchpoints(reg,$dest2)] {
          update_watchpoint reg $dest2 dst
        }
      }
      $ROOT.leftF.regF.reg2F.regDataF.regDataT yview \
         [expr $min_reg-$GEN_REG_START]

      set saddress [$VM get_src_mem $old_pc] 
      set daddress [$VM get_dest_mem $old_pc] 
      if { $saddress != -1 } {
        memory_hit $saddress src
      } 
      if { $daddress != -1 } {
        memory_hit $daddress dst
      } 
    }

    # update instructions window
    for {set ln 0; set i $init_PC} {$ln<$instr_count} {incr ln; incr i 4} {
      set output [format "0x%x: %-20s %s\n" $i [$VM disassemble $i] [$VM codeline $i]]
      if {"$i"=="$old_pc"} {
        add_line $ROOT.rightF.memInstF.memInstT $output hilited
      } else {
        add_line $ROOT.rightF.memInstF.memInstT $output
      }
      if ($i==$pc) {
        set ind [$ROOT.rightF.memInstF.memInstT index end-2l]
        $ROOT.rightF.memInstF.memInstT tag add pc $ind $ind+10c
      }
      if ([info exists breakpoints($i)]) {
        add_line $ROOT.rightF.memInstF.memBrkT "BRK>\n"
      } else {
        add_line $ROOT.rightF.memInstF.memBrkT "\n"
      }
    }
    #set tabs in Instruction window
    #(doesn't really belong here, but we know the window exists by now)
    set pitch [expr [winfo width $ROOT.rightF.memInstF.memInstT]/[$ROOT.rightF.memInstF.memInstT cget -width]]
    set tab1 [expr 18*$pitch]
    set tab2 [expr 35*$pitch]
    set tab3 [expr 42*$pitch]
    $ROOT.rightF.memInstF.memInstT config -tabs [list $tab1 $tab2 $tab3]

    # make sure highlighted line is visible:
    if [llength [$ROOT.rightF.memInstF.memInstT tag ranges pc]] {
      $ROOT.rightF.memInstF.memInstT see [lindex [$ROOT.rightF.memInstF.memInstT tag ranges pc] 0]
    }
    if [llength [$ROOT.rightF.memInstF.memInstT tag ranges hilited]] {
      $ROOT.rightF.memInstF.memInstT see [lindex [$ROOT.rightF.memInstF.memInstT tag ranges hilited] 0]
    }

    # update memory window (increment by 16 to put 4 words per line)
    for {set ln 0; set i $init_PC} {$ln<$instr_count} {incr ln; incr i 16} {
      add_line $ROOT.rightF.memHexF.memDataF.memDataT [format "0x%x: " $i]
      for {set j $i} {$j<$i+16} {incr j 4} {
        if [catch "$VM get_mem $j" value] {
          set output " [format %-8s $value]" 
        } else {
          set output " [format %08x $value]" 
        }
        if {"$j"=="$old_pc"} {
          add_line $ROOT.rightF.memHexF.memDataF.memDataT $output hilited
        } else {
          add_line $ROOT.rightF.memHexF.memDataF.memDataT $output
        }
      }
      add_line $ROOT.rightF.memHexF.memDataF.memDataT "\n"
    }
    # make sure highlighted data is visible:
    if [llength [$ROOT.rightF.memHexF.memDataF.memDataT tag ranges hilited]] {
      $ROOT.rightF.memHexF.memDataF.memDataT see \
        [lindex [$ROOT.rightF.memHexF.memDataF.memDataT tag ranges hilited] 0]
    }
}
#
#
# ----------------------------------------------------------------------
# 2. Update Popup Windows
#
# update_tlb: redraws the entire tlb window
#    CALLED BY: update_display, show_tlb.
#    PROCS IT CALLS: update_line 
# update_watchpoint: change a watchpoint entry (called in a loop for ea. one)
#    CALLED BY: update_display, add_watchpoint. 
#    PROCS IT CALLS: int2ascii, do_stop 
# int2ascii: convert integer to ascii
#    CALLED BY: update_watchpoint
#    PROCS IT CALLS: -
# ----------------------------------------------------------------------
#
#
proc update_tlb {} {

  global VM

  .tLB.tlbDataF.tlbValF.tlbValT tag remove hit 1.0 end

  for {set i 0} {$i<[$VM get_num_tlbs]} {incr i} {
    set tlb_entry [$VM get_tlb_entry $i] 

    set output [format %2d $i]
    set atrib  [lindex $tlb_entry 0]
    set ppn    [format 0x%05x [lindex $tlb_entry 1]]
    set vsegpn [format 0x%05x [lindex $tlb_entry 4]]
    set osinf  [format 0x%05x [lindex $tlb_entry 5]]

    update_line .tLB.tlbDataF.tlbValF.tlbValT       [expr $i+1] $output
    update_line .tLB.tlbDataF.tlbPpnF.tlbPpnT       [expr $i+1] $ppn

    update_line .tLB.tlbDataF.tlbAtribF.tlbAtribT   [expr $i+1] \
      "ExWrRdVaDyUc" 
    .tLB.tlbDataF.tlbAtribF.tlbAtribT config -foreground gray 
    set bit1 [expr $atrib&1]
    set bit2 [expr $atrib&(1<<1)]
    set bit3 [expr $atrib&(1<<2)]
    set bit4 [expr $atrib&(1<<3)]
    set bit5 [expr $atrib&(1<<4)]
    set bit6 [expr $atrib&(1<<5)]
    if $bit1 { .tLB.tlbDataF.tlbAtribF.tlbAtribT tag add bold \
       [expr $i+1].0 [expr $i+1].2 }
    if $bit2 { .tLB.tlbDataF.tlbAtribF.tlbAtribT tag add bold \
       [expr $i+1].2 [expr $i+1].4 }
    if $bit3 { .tLB.tlbDataF.tlbAtribF.tlbAtribT tag add bold \
       [expr $i+1].4 [expr $i+1].6 }
    if $bit4 { .tLB.tlbDataF.tlbAtribF.tlbAtribT tag add bold \
       [expr $i+1].6 [expr $i+1].8 }
    if $bit5 { .tLB.tlbDataF.tlbAtribF.tlbAtribT tag add bold \
       [expr $i+1].8 [expr $i+1].10 }
    if $bit6 { .tLB.tlbDataF.tlbAtribF.tlbAtribT tag add bold \
       [expr $i+1].10 [expr $i+1].12 }

    update_line .tLB.tlbDataF.tlbVsegPNF.tlbVsegPNT [expr $i+1] $vsegpn
    update_line .tLB.tlbDataF.tlbOSinfoF.tlbOSinfoT [expr $i+1] $osinf
  }
}
#
#
proc update_watchpoint {type location args} {

  global watchpoints VM

  set stopONread 0
  set stopONwrite 0
  switch -exact [$watchpoints($type,$location).stopM cget -text] {
      "Read Only" { set stopONread 1 }
      "Read/Write" { set stopONread 1 ; set stopONwrite 1 }
      "Write Only" { set stopONwrite 1 }
  }

  if {"$type"=="mem"} {
    set location [expr ($location-($location%4))]
  }

  if {"$args"=="src"} {
    if {$stopONread} {
      do_stop
    }
    #just highlight it
    $watchpoints($type,$location).locationL config -bg white -fg blue
    $watchpoints($type,$location).valueL config -bg white -fg blue
  } else {
    if {"$args"=="dst"} {
      if {$stopONwrite} {
        do_stop
      }
      $watchpoints($type,$location).locationL config -bg yellow -fg red
      $watchpoints($type,$location).valueL config -bg yellow -fg red
    } else {
      $watchpoints($type,$location).locationL config -bg [option get $watchpoints($type,$location).valueL background background] -fg black
      $watchpoints($type,$location).valueL config -bg [option get $watchpoints($type,$location).valueL background background] -fg black
    }
    # show the new value, and highlight it
    set ok 1
    if {"$type"=="reg"} {
      set value [$VM get_register $location]
    } else {
      if [catch "$VM get_mem $physwordaddress" value] { set ok 0 }
    }
    if ($ok) {
      switch -exact [$watchpoints($type,$location).showM cget -text] {
        Hexadecimal { set value [format 0x%08x $value] }
        "Signed Decimal" { set value [expr $value+0] }
        "Unsigned Decimal" { # do nothing }
        Octal { set value [format 0%010o $value] }
        Binary { binary scan [binary format I $value] B32 value }
        ASCII { set value [int2ascii $value] }
      }
    }
    $watchpoints($type,$location).valueL config -text $value
  }
}
#
#
proc int2ascii {value} {

  set c0 [expr ($value&0x7f000000)>>24]
  if ($value<0) { set c0 [expr $c0|0x80] }
  set c1 [expr ($value&0x00ff0000)>>16]
  set c2 [expr ($value&0x0000ff00)>>8]
  set c3 [expr ($value&0x000000ff)]
  set result ""
  foreach num [list $c0 $c1 $c2 $c3] {
    if ($num==0) {
      set show [format \\%03o $num]
    } elseif ($num<32) {
      set show [format ^%c [expr $num+64]]
    } elseif ($num==32) {
      set show {" "}
    } elseif ($num==127) {
      set show "^?"
    } elseif ($num==128) {
      set show [format \\%03o $num]
    } elseif ($num>128&&$num<=160) {
      set show [format \\%03o $num]
    } elseif ($num==255) {
      set show [format \\%03o $num]
    } else {
      set show [format %c $num]
    }
    set result "$result $show"
  }
  return $result
}
#
#
# ----------------------------------------------------------------------
# 3. Utilities Used to Update Main and Popup Windows
#
# update_line: replace an existing line of text in the main window
#    CALLED BY: do_step, do_run, update_display
#    PROCS IT CALLS: -
# add_line:  append a new line of text in the main window
#    CALLED BY: clear_page_data, update_display, view_page_r, show_pmem3.
#    PROCS IT CALLS: -
# ----------------------------------------------------------------------
#
#
proc update_line {win line value} {

  $win config -state normal
  while {[$win index end]<=$line} {
    $win insert end \n
    update
  }
  $win delete $line.0 $line.end
  $win insert $line.0 $value
  $win config -state disabled
}
#
#
proc add_line {win value args} {

  $win config -state normal
  if [string length $args] {
    $win insert end $value $args
  } else {
    $win insert end $value
  }
  $win config -state disabled
}
#
#
# ----------------------------------------------------------------------
# 4. Update Memory Procs
#
# memory_hit: called each time an instruction reads or writes memory --
#    updates watchpoints, physical memory displays, etc.
#    CALLED BY: update_display,  redraw_physical_memory, 
#    PROCS IT CALLS: check_mem_watchpoint, update_watchpoint.
# redraw_physical_memory: completely redraws a specified window
#    CALLED BY: do_run  
#    PROCS IT CALLS: clear_latest_memory_hits, add_line 
# ----------------------------------------------------------------------
#
#
proc memory_hit {address access} {

  global VM
  global IMG_BORD
  global pagehit wordhit
  global pmem_start pmem_pages
  global watchpoints

  set physaddress [$VM virt_to_phys $address]
  set physwordaddress [expr $physaddress-$physaddress%4]
  #wordaddress is the physical address of the word, but with segment bits gone
  set wordaddress [expr $physwordaddress & 0x3fffffff]
  #pagenum is the page number of physical memory
  set pagenum [expr $physaddress>>12 & 0x3ffff]
  set pagehit($pagenum) 1
  set wordhit([expr $wordaddress]) 1

  #update all active memory views
  foreach win [array names pmem_start] {
    set num $pmem_pages($win)
    set first $pmem_start($win)
    set last [expr $first+$num-1]
    if ($pagenum>=$first&&$pagenum<=$last) {
      if ($num==262144) {
	scan $win .pMEM%d id
        set x [expr $pagenum%512]
        set y [expr $pagenum/512]
        page_image$id put white  -to $x $y
        $win.pmemDataF.pmemDataC delete latest
        # this red outline highlights the hits in the full view of p.memory
        $win.pmemDataF.pmemDataC create rectangle \
            [expr $x-3+$IMG_BORD] [expr $y-3+$IMG_BORD] \
            [expr $x+3+$IMG_BORD] [expr $y+3+$IMG_BORD] \
            -outline red -tags latest

      } elseif ($num==2048) {
	set y [expr ($pagenum-$first)/64+1]
	set x [expr ($pagenum-$first)%64]
	$win.pmemDataF.pmemDataT tag remove latest 0.0 end
	$win.pmemDataF.pmemDataT tag add hashit $y.$x $y.$x+1c
	$win.pmemDataF.pmemDataT tag add latest $y.$x $y.$x+1c
	$win.pmemDataF.pmemDataT see $y.$x
      } elseif ($num==256) {
	scan $win .pMEM%d id
	set y [expr (($wordaddress-($first*4096))/4)/512]
	set x [expr (($wordaddress-($first*4096))/4)%512]
	page_image$id put red -to $x $y
	$win.pmemDataF.pmemDataC delete latest
        # this blue outline highlights the hits in the page view of p.memory
	$win.pmemDataF.pmemDataC create rectangle \
	    [expr $x-3+$IMG_BORD] [expr $y-3+$IMG_BORD] \
	    [expr $x+3+$IMG_BORD] [expr $y+3+$IMG_BORD] \
	    -outline blue -tags latest
      } elseif ($num==1) {
	set y [expr ($wordaddress-($first*4096))/16+1]
	set x [expr ($wordaddress-($first*4096))%16]
	if ($x==0) {
	  set x 13
	} elseif ($x==4) {
	  set x 22
	} elseif ($x==8) {
	  set x 31
	} elseif ($x==12) {
	  set x 40
	}
        $win.pmemDataF.pmemDataT config -state normal
        $win.pmemDataF.pmemDataT delete $y.$x $y.$x+8c
        if [catch "$VM get_mem $physwordaddress" value] {
          set hex [format %-8s $value]
	} else {
          set hex [format %08x $value]
	}
        $win.pmemDataF.pmemDataT insert $y.$x $hex
        $win.pmemDataF.pmemDataT config -state disabled
	$win.pmemDataF.pmemDataT tag remove latest 0.0 end
	$win.pmemDataF.pmemDataT tag add hashit $y.$x $y.$x+8c
	$win.pmemDataF.pmemDataT tag add latest $y.$x $y.$x+8c
	$win.pmemDataF.pmemDataT see $y.$x
      }
    }
  }
  #update watchpoints
  if [check_mem_watchpoint $address] {
    update_watchpoint mem $address $access
  }
  #highlight TLB entry if needed
  if [winfo exists .tLB] {
    if $address!=$physaddress {
      set tlbnum [$VM find_tlb_entry $address]
      if $tlbnum>=0 {   #this should always be true
        incr tlbnum
        .tLB.tlbDataF.tlbValF.tlbValT tag add hit $tlbnum.0 $tlbnum.end
      }
    }
  }
}
#
#
proc redraw_physical_memory {win} {

  global pmem_start pmem_select pmem_pages
  global pagehit wordhit
  global IMG_BORD

  scan $win .pMEM%d id
  clear_latest_memory_hits

  if ($pmem_pages($win)==262144) {
    page_image$id put black -to 0 0 512 512
    set list [array names pagehit]
    foreach hit $list {
      set x [expr $hit%512]
      set y [expr $hit/512]
      page_image$id put white -to $x $y
    }
  } elseif ($pmem_pages($win)==2048) {
    set pagenum $pmem_start($win)
    for {set i 0} {$i< 32} {incr i} {
      for {set j 0} {$j< 64} {incr j} {
        if [info exists pagehit($pagenum)] {
          $win.pmemDataF.pmemDataT insert insert X hashit
        } else {
          $win.pmemDataF.pmemDataT insert insert X
        }
        incr pagenum
      }
      $win.pmemDataF.pmemDataT insert insert \n
    }
  } elseif ($pmem_pages($win)==256) {
    set byte_start [expr $pmem_start($win) *4096]
    set byte_end [expr $byte_start + 512 * 512 * 4]
  
    set list [lsort -integer [array names wordhit]]
  
    page_image$id put yellow -to 0 0 512 512
    foreach hit $list {
      if $hit>$byte_end break
      if $hit<$byte_start continue
      set tmp [expr ($hit-$byte_start)/4]
      set x [expr $tmp%512]
      set y [expr $tmp/512]
      page_image$id put red -to $x $y
    }
  } elseif ($pmem_pages($win)==1) {
    #bits to set for accessing physical memory
    set PHYSBITS 0x80000000
    #make sure we show physical addresses
    set byte_start [expr $pmem_start($win)*4096]
    set byte_start [expr $byte_start | $PHYSBITS]
    # update window (increment by 16 to put 4 words per line)
    for {set ln 0; set i $byte_start} {$ln < 256} {incr ln; incr i 16} {
      add_line $win.pmemDataF.pmemDataT [format "0x%08x: " $i]
      for {set j $i} {$j<$i+16} {incr j 4} {
        if [catch "$VM get_mem $j" value] {
          set output " [format %-8s $value]" 
        } else {
          set output " [format  %08x $value]"
        }
        if [winfo exists wordhit($j)] {
          add_line $win.pmemDataF.pmemDataT $output hashit
        } else {
          add_line $win.pmemDataF.pmemDataT $output
        }
      }
      add_line $win.pmemDataF.pmemDataT "\n"
    }
  }
}
#
# End of aide32_update.tcl
#
