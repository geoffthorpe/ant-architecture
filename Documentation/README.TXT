# $Id: README.TXT,v 1.3 2000/05/31 14:04:55 ellard Exp $

README.TXT -- ANT 3.0.1

This file gives an overview of the ANT 3.0.1 distribution and describes
the contents of each directory and many of the files.

README.TXT

	This file.


bin

	The bin directory contains the executable files used by ANT. 
	The bin directory also contains a subdirectory named tcl,
	which contains TCL/TK code which implements AIDE (the Ant
	Integrated Development Environment).

	UNIX Name	Windows Name	Description

	ant		ant.exe		The ANT virtual machine
	ad		ad.exe		The text-based ANT debugger
	aa		aa.exe		The command-line ANT assembler
	aide		aide.bat	The ANT Integrated Development
					Environment.

	Under Windows, the usual way to start up AIDE is by clicking
	on the shortcut on the desktop or in the "Start" menus. 
	(aide.bat is not used under ordinary circumstances.)


doc

	The ANT documentation-- tutorials, specifications, and
	references.  Documents are available in Postscript and PDF, or
	in HTML. 

	ad_root.pdf	ad_root.ps	Debugger Reference ^M
	aide_doc.pdf    aide_doc.ps	Using AIDE     ^M
	ant-cflow.html			C Control Statements in ANT 3.0
	card.pdf	card.ps		Programming Card Language Tutorial
	arch_root.pdf	arch_root.ps	Architecture Reference ^
	dr_root.pdf	dr_root.ps	Data Representation^M
	tut_root.pdf	tut_root.ps	Assembly Language Tutorial^M


examples

	Example ANT programs.

	add.asm		add2.asm	atoi1.asm	bigadd.asm
	echo.asm	fib.asm		hello.asm	larger.asm
	loop.asm	reverse.asm	shout.asm	sieve.asm^


assigns

	Example ANT assignments.


assigns/src

	The src directory contains the ANSI C source code for most of
	the core ANT virtual machine, and documentation describing the
	organization of this source code.  This code is intended to be
	used as part of a programming exercise for students who are
	learning C.  Using this source code as a beginning, they can
	implement their own ANT VM by writing just a few hundred lines
	of additional code.

