#!/bin/csh -f
# $Id: dist.sh,v 1.21 2002/05/23 13:15:57 ellard Exp $

echo "THIS SCRIPT ASSUMES THAT THE TUTORAL LaTeX DOCUMENTATION"
echo "HAS ALREADY BEEN BUILT"

set VERSION = `cat ../../CurrVersion`
echo ""
echo -n "Type current version [default=$VERSION]: "
set nv = $<
if ("$nv" != "") then
	set VERSION = "$nv"
endif

./build.sh $VERSION
if ($status != 0) then
	echo "Build failed"
	exit 1
endif

echo "Setting up distribution directory:"

if ($HOSTTYPE == "HP-UX") then
	set PLATFORM = `uname -sm | sed -e 's/-/_/g' | sed -e 's/[ \/]/-/g'`
else
	set OS	= `uname -sr | sed -e 's/[\ -]/_/g'`
	set ARCH = `uname -m | sed -e 's/[\ -]/_/g'`
	set PLATFORM = "$OS-$ARCH"
endif

set DIST_DIR = "../ANT-DIST"
set DIST_NAME = "$VERSION-$PLATFORM"

set DIST = "$DIST_DIR/$DIST_NAME"
set DIST_8 = "$DIST/ant8-$VERSION"
set DIST_32 = "$DIST/ant32-$VERSION"

# Chmod stuff so we can be sure to delete it.
if (-d "$DIST_8") then
	chmod 755 `find "$DIST_8" -type d`
	chmod 644 `find "$DIST_8" -type f`
	rm -rf "$DIST_8"
endif
if (-d "$DIST_32") then
	chmod 755 `find "$DIST_32" -type d`
	chmod 644 `find "$DIST_32" -type f`
	rm -rf "$DIST_32"
endif
rm -rf $DIST_8.tgz
rm -rf $DIST_32.tgz

# Construct the general structure.


mkdir -p $DIST_8
chmod 755 $DIST_8
echo "Ant-8 ($VERSION) for $PLATFORM" > "$DIST_8/arch-name"
chmod 444 "$DIST_8/arch-name"

mkdir -p $DIST_32
chmod 755 $DIST_32
echo "Ant-32 ($VERSION) for $PLATFORM" > "$DIST_32/arch-name"
chmod 444 "$DIST_32/arch-name"

foreach dir ( lib bin examples doc assigns )
	echo "    Creating subdir $DIST_8/$dir"
	mkdir -p "$DIST_8/$dir"
	chmod 755 "$DIST_8/$dir"

	echo "    Creating subdir $DIST_32/$dir"
	mkdir -p "$DIST_32/$dir"
	chmod 755 "$DIST_32/$dir"
end

# Copy over the bootstrap tcl/tk whatnot.
# Most of this unnecessary, but some of it needs
# to come along.

cp -Rp /home/lair/ant/usr/freebsd-intel/lib/tcl8.0 "$DIST_8/lib"
cp -Rp /home/lair/ant/usr/freebsd-intel/lib/tk8.0 "$DIST_8/lib"
cp -Rp /home/lair/ant/usr/freebsd-intel/lib/tcl8.0 "$DIST_32/lib"
cp -Rp /home/lair/ant/usr/freebsd-intel/lib/tk8.0 "$DIST_32/lib"

cp ../../Src/Ant32/ant32rom.a32 "$DIST_32/lib"

chmod 444 `find "$DIST_32/lib" -type f`
chmod 555 `find "$DIST_32/lib" -type d`

chmod 444 `find "$DIST_8/lib" -type f`
chmod 555 `find "$DIST_8/lib" -type d`

# I assume that we're doing UNIX.  Otherwise, a separate step is
# needed to pull things together.

echo "... copying documentation directory"

cp ../../Documentation/index-8.htm $DIST_8/doc/index.htm

cp unix.txt $DIST_8/README.txt

cp ../../Documentation/index-32.htm $DIST_32/doc/index.htm

cp unix.txt $DIST_32/README.txt

foreach ps ( ant32_architecture ant32_tutorial data_rep )
	cp ../../Documentation/$ps.ps $DIST_32/doc/$ps.ps
	cp ../../Documentation/$ps.pdf $DIST_32/doc/$ps.pdf
end

foreach html ( aa32_notes ad32_notes ant32_notes )
	cp ../../Src/Ant32/$html.html $DIST_32/doc/$html.html
end

foreach ps ( ad8_tutorial ant8_tutorial ant8_card data_rep )
	cp ../../Documentation/$ps.ps $DIST_8/doc/$ps.ps
	cp ../../Documentation/$ps.pdf $DIST_8/doc/$ps.pdf
end

foreach ps ( aide_doc )
	cp ../../Documentation/$ps.ps.orig $DIST_8/doc/$ps.ps
	cp ../../Documentation/$ps.pdf.orig $DIST_8/doc/$ps.pdf
end

foreach html ( ant8 ad8 aa8 )
	cp ../../Documentation/$html.htm $DIST_8/doc/$html.htm
end

cp ../../Documentation/ant-cflow.html $DIST_8/doc/ant-cflow.html

chmod 444 `find "$DIST_8/doc" -type f`
chmod 555 `find "$DIST_8/doc" -type d`
chmod 444 `find "$DIST_32/doc" -type f`
chmod 555 `find "$DIST_32/doc" -type d`

echo "... copying bin directories"

foreach exe ( ant8 ad8 aa8 aide8 )
	strip ../../Src/Ant8/$exe
	cp ../../Src/Ant8/$exe $DIST_8/bin/$exe
	chmod 755 $DIST_8/bin/$exe
end

foreach exe ( ant32 ad32 aa32 )
	strip ../../Src/Ant32/$exe
	cp ../../Src/Ant32/$exe $DIST_32/bin/$exe
	chmod 755 $DIST_32/bin/$exe
end

echo "... copying TCL directories"

mkdir $DIST_8/bin/Tcl8
cp ../../Src/Ant8/Tcl8/*.tcl $DIST_8/bin/Tcl8

chmod 444 `find "$DIST_8/bin/Tcl8" -type f`
chmod 555 `find "$DIST_8/bin/Tcl8" -type d`

# &&& Until aide32 is reality, don't include this stuff!!
#
# mkdir $DIST_32/bin/Tcl32
# cp ../../Src/Ant32/Tcl32/*.tcl $DIST_32/bin/Tcl32
#
# chmod 444 `find "$DIST_32/bin/Tcl32" -type f`
# chmod 555 `find "$DIST_32/bin/Tcl32" -type d`

# &&& HACK TO USE AIDE ON SYSTEMS WHERE TCL/TK VERSIONS ARE DIFFERENT
# OR MISSING
#
# Rename aide8 to _aide8, and slip into its place a shell script that
# sets the proper environment variables and then execs _aide8.
# 
# &&& Add aide32, when it exists.

mv "$DIST_8/bin/aide8" "$DIST_8/bin/_aide8"
cp unix-aide.sh "$DIST_8/bin/aide8"
chmod 755 "$DIST_8/bin/aide8"

echo "... copying examples directory"

foreach ex ( add.asm add2.asm atoi1.asm \
			bigadd.asm echo.asm fib.asm \
			larger.asm loop.asm reverse.asm \
			shout.asm sieve.asm )
	cp ../../Examples/Ant8/$ex $DIST_8/examples/$ex
	chmod 444 $DIST_8/examples/$ex
end

foreach ex ( add-func add echo fibonacci hello hello2 larger )
	cp ../../Documentation/Tut32/$ex.asm $DIST_32/examples/$ex.asm
	chmod 444 $DIST_32/examples/$ex.asm
end

echo "... copying assigns directories"

mkdir -p $DIST_8/assigns/Ant8/SimpleAnt
chmod 755 $DIST_8/assigns/Ant8/SimpleAnt
foreach c ( Makefile ant.h ant_bits.h ant_design.txt ant_dump.c \
		ant_load.c ant_mach.h ant_utils.c antvm.c README.TXT )
	cp ../../Assignments/Ant8/SimpleAnt/$c $DIST_8/assigns/Ant8/SimpleAnt/$c
	chmod 444 $DIST_8/assigns/Ant8/SimpleAnt/$c
end

# Make sure that everything is chmod'd correctly.

foreach f ( `find "$DIST_8" "$DIST_32" -print` )
	if (-d "$f") then
		chmod o+xr "$f"
	else if (-x "$f") then
		chmod o+xr "$f"
	else
		chmod o+r "$f"
	endif
end

echo "... creating tarball."

(cd $DIST; tar cf "ant8-$DIST_NAME.tar" "ant8-$VERSION")
(cd $DIST; tar cf "ant32-$DIST_NAME.tar" "ant32-$VERSION")
gzip "$DIST/ant8-$DIST_NAME.tar" "$DIST/ant32-$DIST_NAME.tar"
mv "$DIST/ant8-$DIST_NAME.tar.gz" "$DIST/ant8-$DIST_NAME.tgz"
mv "$DIST/ant32-$DIST_NAME.tar.gz" "$DIST/ant32-$DIST_NAME.tgz"

# &&& For now, don't delete things, for debugging purposes. -DJE
# 
# Chmod stuff so we can be sure to delete it.
# chmod 755 `find $DIST_8 -type d`
# chmod 644 `find $DIST_8 -type f`
# rm -rf $DIST_8
# rm -rf $DIST_32

exit 0
