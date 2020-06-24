#!sh
# $Id: dosdist.sh,v 1.2 2000/03/06 22:12:34 ellard Exp $

echo "THIS SCRIPT ASSUMES THAT THE TUTORAL LaTeX DOCUMENTATION"
echo "HAS ALREADY BEEN BUILT"
echo ""
echo "THIS SCRIPT ASSUMES THAT EVERYTHING WILL BUILD CLEANLY"
echo "If the build fails, do not let the script continue!"
make clean
make
sleep 5

echo "Setting up distribution directory."

DIST_DIR="../ANT-DIST"		; export DIST_DIR
DIST_NAME="awin300a"		; export DIST_NAME
DIST="$DIST_DIR/$DIST_NAME"	; export DIST

CYG="//d/cygnus/cygwin-b20"; 		export CYG

CYG_SHARE="$CYG/share"; 		export CYG_SHARE
CYG_BIN="$CYG/H-i586-cygwin32/bin";	export CYG_BIN

rm -rf $DIST $DIST.tgz
mkdir -p $DIST $DIST/bin $DIST/bin/tcl $DIST/doc $DIST/examples $DIST/cygnus
chmod 755 $DIST $DIST/bin $DIST/bin/tcl $DIST/doc $DIST/examples $DIST/cygnus

echo "Windows NT4 / CYGWIN B20" > $DIST/arch.txt
chmod 444 $DIST/arch_name

strip ant.exe ad.exe aa.exe aide.exe
cp ant.exe ad.exe aa.exe aide.exe $DIST/bin
chmod 555 $DIST/bin/*.exe

# Copy all the tcl whatnot that is part of the aide gui:

cp tcl/*.tcl $DIST/bin/tcl
chmod 444 $DIST/bin/tcl/*.tcl

cp ../WWW/ANT-3.0/dist/win.txt $DIST/doc/win.txt
cp ant.html ad.html ad.html $DIST/doc
cp ../Tutorial/tut_root.ps $DIST/doc
cp ../Tutorial/tut_root.pdf $DIST/doc
cp ../Tutorial/card.ps $DIST/doc
cp ../Tutorial/card.pdf $DIST/doc
chmod 444 $DIST/doc/*

T=../Tutorial/Tutorial; export T
cp $T/add.asm $T/add2.asm $T/atoi1.asm $DIST/examples
cp $T/echo.asm $T/hello.asm $DIST/examples
cp $T/larger.asm $T/loop.asm $T/reverse.asm $DIST/examples
cp $T/sieve.asm $T/fib.asm $DIST/examples
chmod 444 $DIST/examples/*


# Grab a copy of the tcl initialization libraries:

mkdir -p $DIST/bin/share
(cd $DIST/bin; cp -R $CYG_SHARE/tcl8.0 share)
(cd $DIST/bin; cp -R $CYG_SHARE/tk8.0 share)

cp $CYG_BIN/cygtcl80.dll $DIST/cygnus
cp $CYG_BIN/cygtk80.dll $DIST/cygnus
cp $CYG_BIN/cygwin1.dll $DIST/cygnus
cp CYGNUS/cygnus_b20.exe $DIST/cygnus
chmod 444 $DIST/cygnus/*.*

echo "Creating tarball."

# &&&
# Need to figure out the right args to ZIP!
# (cd $DIST_DIR; zip $DIST_NAME)
# mv $DIST $DIST.tgz

# rm -rf $DIST

exit 0
