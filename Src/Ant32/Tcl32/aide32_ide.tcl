#!/opt/local/bin/wish8.0 -f

# 
# This is the startup TCL file for AIDE32
# 

tk appname aide32


set VM [ant vm]
#puts $VM
set PAGE_SIZE 4096

#set AIDE32_DIR [file dirname $argv0]
#set AIDE32_DIR "[file dirname [info nameofexecutable]]/Tcl32"
set AIDE32_DIR [file dirname [info script]]

source $AIDE32_DIR/aide32_mainwindow.tcl
source $AIDE32_DIR/aide32_clear.tcl
source $AIDE32_DIR/aide32_popups.tcl
source $AIDE32_DIR/aide32_update.tcl
source $AIDE32_DIR/aide32_control.tcl
source $AIDE32_DIR/aide32_edit.tcl

aide_window_setup
update

if [llength $argv]==1 {
  if [file readable $argv] {
    if [string match *.a32 $argv] {
      set filename $argv
      clear_display
      set instr_count [$VM load $filename]
      .buttonbar.runB  config -state normal
      .buttonbar.stepB config -state normal
      .buttonbar.resetB config -state normal
      .menubar.toolsMB.menu4 entryconfig "Watch Points" -state normal
      set init_PC [$VM get_register PC]
      get_register_label
      update_display
    } else {
      layout_edit
      load_file $argv
      raise $EDIT_BASENAME
    }
  } else {
    tk_messageBox -message "Can't open file $argv!" -icon error \
    -title Error -type ok
  }
}

wm minsize . [winfo width .] [winfo height .]
#
# End of aide32_ide.tcl
#

