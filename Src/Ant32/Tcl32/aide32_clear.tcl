#!/opt/local/bin/wish8.0 -f
#
# $Id: aide32_clear.tcl,v 1.8 2003/05/30 18:14:02 sara Exp $
#
# Copyright 2000-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# This file contains the follwing procs:
#
# ----------------------------------------------------------------------
#
# clear_display: resets data in main aide32 window, including status area,
#    register data, memory, instructions, breaks
#    CALLED BY: do_reset, do_full_reset, do_run, do_step, aide32_ide.tcl
#    show_config, reset_config 
#    TCL PROCS CALLED: clear_latest_memory_hits
# clear_latest_memory_hits: get rid of highlighting of physical memory views
#    CALLED BY: clear_display, redraw_physical_memory
#    TCL PROCS CALLED: -
# clear_all_memory_hits: get rid of all memory hits in physical mem views
#    CALLED BY: do_reset, do_full_reset 
#    TCL PROCS CALLED: clear_page_data
# clear_page_data
#    CALLED BY:  clear_all_memory_hits
#    TCL PROCS CALLED: add_line
# clear_console: remove input and output from console window
# (used only during a reset)
#    CALLED BY: do_reset, do_full_reset
#    TCL PROCS CALLED: -
#    C FUNCTIONS CALLED: $VM console reset
# ----------------------------------------------------------------------
#
#
proc clear_display {} {

  #
  # Global Variables
  #
  global ROOT
  global VM
  global GEN_REG_START
  global TEMP_REG_START

  #
  # Root Window
  #
  set ROOT ""
  $ROOT.leftF.stateF.pcF.pcT config -state normal
  $ROOT.leftF.stateF.pcF.pcT delete 0.0 end
  $ROOT.leftF.stateF.pcF.pcT config -state disabled

  $ROOT.leftF.stateF.modeF.modeT config -state normal
  $ROOT.leftF.stateF.modeF.modeT delete 0.0 end
  $ROOT.leftF.stateF.modeF.modeT config -state disabled

  $ROOT.leftF.regF.reg2F.regDataF.regDataT config -state normal
  $ROOT.leftF.regF.reg2F.regDataF.regDataT delete 0.0 end
  $ROOT.leftF.regF.reg2F.regDataF.regDataT config -state disabled

  $ROOT.leftF.regF.reg2F.regSrcF.regSrcT config -state normal
  $ROOT.leftF.regF.reg2F.regSrcF.regSrcT delete 0.0 end
  $ROOT.leftF.regF.reg2F.regSrcF.regSrcT config -state disabled

  $ROOT.leftF.regF.reg2F.regDesF.regDesT config -state normal
  $ROOT.leftF.regF.reg2F.regDesF.regDesT delete 0.0 end
  $ROOT.leftF.regF.reg2F.regDesF.regDesT config -state disabled

  $ROOT.rightF.memHexF.memDataF.memDataT config -state normal
  $ROOT.rightF.memHexF.memDataF.memDataT delete 0.0 end
  $ROOT.rightF.memHexF.memDataF.memDataT config -state disabled

  $ROOT.rightF.memInstF.memInstT config -state normal
  $ROOT.rightF.memInstF.memInstT delete 0.0 end
  $ROOT.rightF.memInstF.memInstT config -state disabled

  $ROOT.rightF.memInstF.memBrkT config -state normal
  $ROOT.rightF.memInstF.memBrkT delete 0.0 end
  $ROOT.rightF.memInstF.memBrkT config -state disabled

  $ROOT.leftF.regF.reg2F.regDataF.regDataT config -state normal
  $ROOT.leftF.regF.reg2F.regSrcF.regSrcT   config -state normal
  $ROOT.leftF.regF.reg2F.regDesF.regDesT   config -state normal
  for {set i 0} {$i<[expr $TEMP_REG_START-$GEN_REG_START]} {incr i} {
    $ROOT.leftF.regF.reg2F.regDataF.regDataT insert end \n
    $ROOT.leftF.regF.reg2F.regSrcF.regSrcT   insert end \n
    $ROOT.leftF.regF.reg2F.regDesF.regDesT   insert end \n
  }
  $ROOT.leftF.regF.reg2F.regDataF.regDataT config -state disabled
  $ROOT.leftF.regF.reg2F.regSrcF.regSrcT   config -state disabled
  $ROOT.leftF.regF.reg2F.regDesF.regDesT   config -state disabled

  clear_latest_memory_hits
}
#
#
proc clear_latest_memory_hits {} {

  global pmem_pages

  foreach win [array names pmem_pages] {
    set num $pmem_pages($win)
    if ($num==262144) {
      $win.pmemDataF.pmemDataC delete latest
    } elseif ($num==2048) {
      $win.pmemDataF.pmemDataT tag remove latest 0.0 end
    } elseif ($num==256) {
      $win.pmemDataF.pmemDataC delete latest
    } elseif ($num==1) {
      $win.pmemDataF.pmemDataT tag remove latest 0.0 end
    }
  }
}
#
#
proc clear_all_memory_hits {} {

  global pmem_pages

  foreach win [array names pmem_pages] {
    set num $pmem_pages($win)
    if ($num==262144) {
      $win.pmemDataF.pmemDataC delete latest
      scan $win .pMEM%d id
      page_image$id put black -to 0 0 512 512 
    } elseif ($num==2048) {
      $win.pmemDataF.pmemDataT tag remove latest 0.0 end
      $win.pmemDataF.pmemDataT tag remove hashit 0.0 end
    } elseif ($num==256) {
      $win.pmemDataF.pmemDataC delete latest
      scan $win .pMEM%d id
      page_image$id put yellow -to 0 0 512 512 
    } elseif ($num==1) {
      $win.pmemDataF.pmemDataT tag remove latest 0.0 end
      $win.pmemDataF.pmemDataT tag remove hashit 0.0 end
      clear_page_data $win
    }
  }
}
#
#
proc clear_page_data {win} {

  global pmem_start

  $win.pmemDataF.pmemDataT config -state normal
  $win.pmemDataF.pmemDataT delete 1.0 end
  set byte_start [expr $pmem_start($win)*4096]
  #make sure we show physical addresses
  set PHYSBITS 0x80000000
  set byte_start [expr $byte_start | $PHYSBITS]
  set value 0
  for {set ln 0; set i $byte_start} {$ln < 256} {incr ln; incr i 16} {
    add_line $win.pmemDataF.pmemDataT [format "0x%08x: " $i]
    for {set j $i} {$j<$i+16} {incr j 4} {
      set output " [format  %08x $value]"
      add_line $win.pmemDataF.pmemDataT $output
    }
    add_line $win.pmemDataF.pmemDataT "\n"
  }
  $win.pmemDataF.pmemDataT config -state disabled
}
#
#
proc clear_console {} {

  global VM

  $VM console reset
  if [winfo exists .cONSOLE] {
    .cONSOLE.conDataF.conOutF.conOutT config -state normal
    .cONSOLE.conDataF.conOutF.conOutT delete 1.0 end
    .cONSOLE.conDataF.conOutF.conOutT config -state disabled

    set eofi [lindex [.cONSOLE.conDataF.conInF.conInT tag ranges EOF] 0]
    .cONSOLE.conDataF.conInF.conInT delete 1.0 $eofi
  }
}
#
# End of aide32_clear.tcl
#

