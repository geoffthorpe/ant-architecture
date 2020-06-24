#!/bin/csh -f

if ( `hostname` != "ant.eecs.harvard.edu" ) then
	echo "Run this program on ant."
	exit 1
endif

make clean all ant32rom.a32
if ($status != 0) then
	echo "Something didn't make properly."
	exit 1
endif

(cd ../../Documentation; make t32_root.pdf t32_root.ps )
if ($status != 0) then
	echo "Tutorial doc didn't make properly."
	exit 1
endif

(cd ../../Documentation; make ant32.pdf ant32.ps )
if ($status != 0) then
	echo "Arch doc didn't make properly."
	exit 1
endif

echo "copying notes"
foreach html ( aa32_notes.html ad32_notes.html ant32_notes.html )

	if (! -f $html) then
		echo "Missing $html.  Better write it..."
	else
		cp $html /usr/local/ant32/doc/$html
		chmod 644 /usr/local/ant32/doc/$html
	endif
end

echo "copying programs"
foreach prog ( aa32 ad32 ant32 )

	if (! -f $prog ) then
		echo "Missing $prog.  Better make it..."
	else
		cp $prog /usr/local/ant32/bin/$prog
		chmod 755 /usr/local/ant32/bin/$prog
	endif
end

echo "copying roms"
foreach rom ( ant32rom.a32 )

	if (! -f $rom ) then
		echo "Missing $rom.  Better write it..."
	else
		cp $rom /usr/local/ant32/lib/$rom
		chmod 644 /usr/local/ant32/lib/$rom
	endif
end

echo "copying docs"
foreach doc ( t32_root.ps t32_root.pdf ant32.ps ant32.pdf )
	if (! -f ../../Documentation/$doc) then
		echo "Missing $doc."
	else
		cp ../../Documentation/$doc /usr/local/ant32/doc/$doc
		chmod 644 /usr/local/ant32/doc/$doc
	endif
end

echo "All finished."
exit 0
