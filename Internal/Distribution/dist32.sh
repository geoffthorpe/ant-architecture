#!/bin/csh -f
# $Id: dist.sh,v 1.14 2001/01/27 04:23:02 sara Exp $

echo "This is the distribution builder for UNIX, ant-32."
echo ""
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

echo -n "Setting up distribution directory:"

if ($HOSTTYPE == "HP-UX") then
	set PLATFORM = `uname -sm | sed -e 's/[ \/]/-/g'`
else
	set PLATFORM = `uname -smr | sed -e 's/[ \/]/-/g'`
endif

set DIST_DIR = "../ANT-DIST"
set DIST_NAME = "ant32-$VERSION-$PLATFORM"
set DIST = "$DIST_DIR/$DIST_NAME"

echo " [$DIST]"

rm -rf $DIST $DIST.tgz

mkdir -p $DIST \
	$DIST/bin $DIST/lib $DIST/doc $DIST/examples
chmod 755 $DIST \
	$DIST/bin $DIST/lib $DIST/doc $DIST/examples 

echo ".. creating directories:"
echo "            $DIST/doc "
echo "            $DIST/bin "
echo "            $DIST/lib "
echo "            $DIST/examples "

uname -a > $DIST/arch-name

# I assume that we're doing UNIX.  Otherwise, a separate step is
# needed to pull things together.

echo "... copying documentation directory"

cp ../../Documentation/README.TXT $DIST/README.TXT
chmod 444 $DIST/README.TXT

cp ../../WWW/Ant-$VERSION/dist/unix.txt $DIST/doc/unix.txt
chmod 444 $DIST/doc/unix.txt

foreach ps ( dr_root t32_root ant32 )
	cp ../../Documentation/$ps.ps $DIST/doc/$ps.ps
	cp ../../Documentation/$ps.pdf $DIST/doc/$ps.pdf
	chmod 444 $DIST/doc/$ps.ps
	chmod 444 $DIST/doc/$ps.pdf
end

foreach html ( ant32_notes ad32_notes aa32_notes index )
	cp $html.html $DIST/doc/$html.html
	chmod 444 $DIST/doc/$html.html
end

echo "... copying bin directories"

foreach exe ( ant32 ad32 aa32 )
	strip ../../Src/Ant32/$exe
	cp ../../Src/Ant32/$exe $DIST/bin/$exe
	chmod 755 $DIST/bin/$exe
end

echo "... copying examples directory"

foreach ex ( add.asm add2.asm atoi1.asm \
			bigadd.asm echo.asm fib.asm \
			larger.asm loop.asm reverse.asm \
			shout.asm sieve.asm )
	cp ../../Examples/Ant8/$ex $DIST/examples/$ex
	chmod 444 $DIST/examples/$ex
end

echo "... creating tarball."

(cd $DIST_DIR; tar cf $DIST_NAME.T $DIST_NAME)
gzip $DIST.T
# mv $DIST.T.gz $DIST.tgz
cp $DIST.T.gz $DIST.tgz

rm -rf $DIST

exit 0
