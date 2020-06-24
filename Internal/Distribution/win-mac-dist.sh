#!/bin/csh -f
# $Id: win-mac-dist.sh,v 1.18 2003/06/27 17:09:09 sara Exp $
  
# csh -x filename
# csh -v filename
# csh -x -v filename

echo ""
echo ""
# echo "This script is for -- Mac or Win -- versions of Ant ONLY."
echo "This script is for the MSWINDOWS version of Ant ONLY."
echo ""
echo "This script assumes that the following have already been built:"
echo "  <> THE DOCUMENTATION "
echo "     (cd to Ant3.1/Documentation and run make dist)"
echo "  <> THE EXECUTABLES ON THE WIN "
echo "     (cd Ant3.1/Src/Ant8 and Ant32 and run make all on the WIN Machine)"

# ??? don't know equivalent directory on MAC: ...SS

# echo "     on WIN, make sure they're on the E: Drive, "
echo "     make sure they're on the E: Drive, "
echo "     so that they are readable on Unix"
echo ""
echo "If you haven't yet:"
echo "  <> Run 'make dist' in the Documentation directory on UNIX."

# ??? still need "global make" am not sure which dir 
#     it will go in (../../Src ?)...SS

echo "  <> Run make in the Src/Ant* directories on the WIN machine"
echo "     (for now) 'make clean;make' "
echo "     in these: AntCommon, Ant8/Lib8, Ant8, Ant32/Lib32, and Ant32"
# echo "  <> Run makelinks in Ant3.1/Internal/ on the Unix machine" 
# echo "     (this sets up the libraries for the WIN environment)"

#
# Get Version
#
set VERSION = `cat ../../CurrVersion`
echo ""
echo -n "Enter current version [default $VERSION]: "
set nv = $<
if ("$nv" != "") then
	set VERSION = "$nv"
endif

#
# Get Platform
#
set PLATFORM = "Win"
# echo " "
# echo -n "Enter platform [Mac/Win, default Win]: "
# set platform = $<
# if ("$platform" != "") then    
#    if ("$platform" =~ [Mm]*) then
#       set PLATFORM = "Mac"
#    else if ("$platform" =~ [Ww]*) then
#       set PLATFORM = "Win"
#    endif
# endif

#
# Get Distribution directory
#
set DIST_DIR = "$HOME/Ant-$PLATFORM-$VERSION"
echo " "
echo "Enter Directory where distribution will be built:\
[this MUST start with your home directory in order to be readable"
echo -n \
"     as 'E:' on the win machine, default: $HOME/Ant-$PLATFORM-$VERSION]: "
set directory = $<
if ("$directory" != "") then
   set DIST_DIR = $directory
endif
if { test -d $DIST_DIR } then
   echo " "
   echo "$DIST_DIR already exists."
   echo -n "   Shall I clear and overwrite it? [yes/no, default yes]: "
   set dwrite = $<
   if ("$dwrite" != "") then    
     if ("$dwrite" =~ [Nn]*) then
       echo bye
       exit
     endif
   else
     echo " "
     echo "Removing directory: $DIST_DIR"
     echo " "
     rm -Rf $DIST_DIR
   endif
else if { test -e $DIST_DIR } then
   echo "$DIST_DIR" is a file.
   echo bye
   exit
endif
#  if we got this far then directory doesn't exist (now)
echo "Creating directory: $DIST_DIR"
mkdir $DIST_DIR

#
# Create and Load Subdirectories
#

# Assignments directories
#
set ASSIGN_DIR = "$DIST_DIR/assignments"
if ! { test -d $ASSIGN_DIR } then
   echo "Creating directory: $ASSIGN_DIR"
   mkdir $ASSIGN_DIR 
endif 

set SIMPLE_ANT_DIR = "$ASSIGN_DIR/Ant8/SimpleAnt"
if ! { test -d $SIMPLE_ANT_DIR } then
   echo "Creating directory: $ASSIGN_DIR/Ant8/"
   mkdir $ASSIGN_DIR/Ant8/
   echo "Creating directory: $SIMPLE_ANT_DIR"
   mkdir $SIMPLE_ANT_DIR 
endif 

set FROM_DIR = ../../Assignments/Ant8/SimpleAnt/
echo "Loading  directory: $SIMPLE_ANT_DIR"
foreach file \
   (Makefile README.TXT ant.h ant_dump.c ant_mach.h antvm.c SOL_antvm.c ant_bits.h \
   ant_load.c ant_utils.c)
   cp $FROM_DIR/$file $SIMPLE_ANT_DIR
end

# bin directory
#
set BIN_DIR = "$DIST_DIR/bin"
if ! { test -d $BIN_DIR } then
   echo "Creating directory: $BIN_DIR"
   mkdir $BIN_DIR 
endif 

set FROM_DIR = ../../Src/Ant8/
echo "Loading  directory: $BIN_DIR"
foreach file (aa8.exe ad8.exe aide8.exe ant8.exe)
   cp $FROM_DIR/$file $BIN_DIR
end
foreach file (aide8.bat cygtcl80.dll cygtk80.dll cygwin1.dll)
   cp ../WinBuildFiles/$file $BIN_DIR
end
set FROM_DIR = ../../Src/Ant32/
foreach file (aa32.exe ad32.exe aide32.exe ant32.exe)
   cp $FROM_DIR/$file $BIN_DIR
end

# examples directory
#
set EXAMPLES_DIR = "$DIST_DIR/examples"
if ! { test -d $EXAMPLES_DIR } then
   echo "Creating directory: $EXAMPLES_DIR"
   mkdir $EXAMPLES_DIR 
endif 

set EXAMPLES8_DIR = "$DIST_DIR/examples/ant8"
if ! { test -d $EXAMPLES8_DIR } then
   echo "Creating directory: $EXAMPLES8_DIR"
   mkdir $EXAMPLES8_DIR 
endif 

set FROM_DIR = ../../Examples/Ant8
echo "Loading  directory: $EXAMPLES8_DIR"
foreach file \
   (add.asm add2.asm atoi1.asm bigadd.asm echo.asm fib.asm hello.asm \
	larger.asm loop.asm reverse.asm shout.asm sieve.asm)
   cp $FROM_DIR/$file $EXAMPLES8_DIR
end

set EXAMPLES32_DIR = "$DIST_DIR/examples/ant32"
if ! { test -d $EXAMPLES32_DIR } then
   echo "Creating directory: $EXAMPLES32_DIR"
   mkdir $EXAMPLES32_DIR 
endif 

set FROM_DIR = ../../Documentation/Tut32
echo "Loading  directory: $EXAMPLES32_DIR"
foreach file \
   (add-func.asm  add.asm  echo.asm  fibonacci.asm  \
    hello.asm  hello2.asm  larger.asm)
   cp $FROM_DIR/$file $EXAMPLES32_DIR
end

# share directories: tcl8.0, http1.0, http2.0, opt0.1, tk8.0
#
set SHARE_DIR = "$DIST_DIR/share"
if ! { test -d $SHARE_DIR } then
   echo "Creating directory: $SHARE_DIR"
   mkdir $SHARE_DIR 
endif 

set TCL8_DIR = "$SHARE_DIR/tcl8.0"
if ! { test -d $TCL8_DIR } then
   echo "Creating directory: $TCL8_DIR"
   mkdir $TCL8_DIR 
endif 

set FROM_DIR = ../WinBuildFiles/share/tcl8.0
echo "Loading  directory: $TCL8_DIR"
foreach file \
   (history.tcl ldAout.tcl parray.tcl tclAppInit.c init.tcl safe.tcl word.tcl tclIndex)
   cp $FROM_DIR/$file $TCL8_DIR
end

set HTTP1_DIR = "$TCL8_DIR/http1.0"
if ! { test -d $HTTP1_DIR } then
   echo "Creating directory: $HTTP1_DIR"
   mkdir $HTTP1_DIR 
endif 

set FROM_DIR = ../WinBuildFiles/share/tcl8.0/http1.0/
echo "Loading  directory: $HTTP1_DIR"
foreach file (http.tcl pkgIndex.tcl)
   cp $FROM_DIR/$file $HTTP1_DIR
end

set HTTP2_DIR = "$TCL8_DIR/http2.0"
if ! { test -d $HTTP2_DIR } then
   echo "Creating directory: $HTTP2_DIR"
   mkdir $HTTP2_DIR 
endif 

set FROM_DIR = ../WinBuildFiles/share/tcl8.0/http2.0/
echo "Loading  directory: $HTTP2_DIR"
foreach file (http.tcl pkgIndex.tcl)
   cp $FROM_DIR/$file $HTTP2_DIR
end

set OPT0_DIR = "$TCL8_DIR/http2.0/opt0.1"
if ! { test -d $OPT0_DIR } then
   echo "Creating directory: $OPT0_DIR"
   mkdir $OPT0_DIR 
endif 

set FROM_DIR = ../WinBuildFiles/share/tcl8.0/opt0.1/
echo "Loading  directory: $OPT0_DIR"
foreach file (optparse.tcl pkgIndex.tcl)
   cp $FROM_DIR/$file $OPT0_DIR
end

set TK8_DIR = "$SHARE_DIR/tk8.0"
if ! { test -d $TK8_DIR } then
   echo "Creating directory: $TK8_DIR"
   mkdir $TK8_DIR 
endif 

set FROM_DIR = ../WinBuildFiles/share/tk8.0
echo "Loading  directory: $TK8_DIR"
foreach file \
   (bgerror.tcl button.tcl clrpick.tcl comdlg.tcl console.tcl dialog.tcl \
   entry.tcl focus.tcl listbox.tcl menu.tcl msgbox.tcl obsolete.tcl \
   optMenu.tcl palette.tcl prolog.ps safetk.tcl scale.tcl scrlbar.tcl \
   tearoff.tcl text.tcl tk.tcl tkAppInit.c tkfbox.tcl xmfbox.tcl tclIndex)
   cp $FROM_DIR/$file $TK8_DIR
end

# tcl directories
#
set TCL8_DIR = "$BIN_DIR/Tcl8"
if ! { test -d $TCL8_DIR } then
   echo "Creating directory: $TCL8_DIR"
   mkdir $TCL8_DIR 
endif 

set FROM_DIR = ../../Src/Ant8/Tcl8/
echo "Loading  directory: $TCL8_DIR"
foreach file \
   (ant.tcl dbg_help.tcl edit.tcl help.tcl quick_ref.tcl debug.tcl \
   gad_dbg.tcl ide.tcl utils.tcl console.tcl)
   cp $FROM_DIR/$file $TCL8_DIR
end

# ??? THIS NEEDS TO BE ADDED ONCE ANT32 GUI IS SET UP: 
#
set TCL32_DIR = "$BIN_DIR/Tcl32"
if ! { test -d $TCL32_DIR } then
   echo "Creating directory: $TCL32_DIR"
   mkdir $TCL32_DIR 
endif 

set FROM_DIR = ../../Src/Ant32/Tcl32/
echo "Loading  directory: $TCL32_DIR"
foreach file \
   (aide32_clear.tcl aide32_control.tcl aide32_edit.tcl aide32_ide.tcl \
   aide32_mainwindow.tcl aide32_popups.tcl aide32_update.tcl)
   cp $FROM_DIR/$file $TCL32_DIR
end

# doc directory
#
set DOC_DIR = "$DIST_DIR/doc"
if ! { test -d $DOC_DIR } then
   echo "Creating directory: $DOC_DIR"
   mkdir $DOC_DIR 
endif 
set FROM_DIR = ../../Documentation/
echo "Loading  directory: $DOC_DIR"

foreach file ( ant32_architecture ant32_tutorial \
  ad8_tutorial ant8_card ant8_architecture ant8_tutorial data_rep)
   cp $FROM_DIR/$file.ps $DOC_DIR/$file.ps
   cp $FROM_DIR/$file.pdf $DOC_DIR/$file.pdf
end

foreach file (aide_doc)
   cp $FROM_DIR/$file.ps.orig $DOC_DIR/$file.ps
   cp $FROM_DIR/$file.pdf.orig $DOC_DIR/$file.pdf
end

foreach file (aa8.htm ad8.htm ant8.htm ant-cflow.html)
   cp $FROM_DIR/$file $DOC_DIR
end

cp $FROM_DIR/index-both.html $DOC_DIR/index.htm

set FROM_DIR = ../../Src/Ant32/
foreach file (aa32_notes.html ad32_notes.html)
     cp $FROM_DIR/$file $DOC_DIR
end

# graphics directory
#
set GRAPHICS_DIR = "$DIST_DIR/graphics"
if ! { test -d $GRAPHICS_DIR } then
   echo "Creating directory: $GRAPHICS_DIR"
   mkdir $GRAPHICS_DIR 
endif 
set FROM_DIR = ../WinBuildFiles/graphics/
echo "Loading  directory: $GRAPHICS_DIR"
foreach file (ant-16x16.bmp ant-32x32.bmp ant-side.bmp ant-up.bmp \
  ant32-16x16.bmp ant32-32x32.bmp help-32x32.bmp help32-32x32.bmp)
   cp $FROM_DIR/$file $GRAPHICS_DIR
end

#
# Change AntDistributionSetup token in installBuilderScriptTemplate
#    to E:\$DIST_DIR
#

#    remove $HOME, change "/" to "\", add "E:"
#
set INST_DIST_DIR = `echo $DIST_DIR | sed s,$HOME,,`
set INST_DIST_DIR = `echo $INST_DIST_DIR | sed s',/,\\\\,g'`
set FOR_PROMPT = `echo $INST_DIST_DIR | sed s',\\\\,\\,g'`
set INST_DIST_DIR = "E:$INST_DIST_DIR"
set FOR_PROMPT = "E:$FOR_PROMPT"

set FROM_DIR = ../WinBuildFiles

echo " "
echo "Generating $DIST_DIR/installBuilderScript.txt "
echo "  from template file $FROM_DIR/installBuilderScriptTemplate "

sed "s/AntDistributionSetup/$INST_DIST_DIR/g" \
   $FROM_DIR/installBuilderScriptTemplate \
   > $DIST_DIR/installBuilderScript.tmp

sed "s/CurrentAntVersion/$VERSION/g" \
   $DIST_DIR/installBuilderScript.tmp \
   > $DIST_DIR/installBuilderScript.txt

rm $DIST_DIR/installBuilderScript.tmp

echo " "
echo "Do the following on the WIN Machine:"
echo "  1. Open and Compile the script file you just created:"
echo "     <> run Installbuilder"
echo "     <> open $FOR_PROMPT\installBuilderScript.txt"
echo "             select ''all files *.*'' because it defaults to *.wse"
echo "     <> compile $FOR_PROMPT\installBuilderScript.txt"
echo "     <> the build file will be called $FOR_PROMPT\installBuilderScript.EXE"
echo "  2. Run the EXE file to test installation: "
echo "         by selecting ''run'' in the Installbuilder application, or "
echo "         by clicking on the $FOR_PROMPT\installBuilderScript.EXE icon"
echo "         "
echo "         "
echo "  NOTE:"
echo "         If any files were added or deleted, or if any file names"
echo "         changed, you need to create a new version of:"
echo "              $FROM_DIR/installBuilderScriptTemplate"
echo "         using installbuilder wizard on the win machine."
echo "         (and update it in CVS too)"
echo "         so that when it is run on the windows machine,"
echo "         the correct files will be packaged into the new EXE file."
exit 0
