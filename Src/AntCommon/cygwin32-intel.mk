# $Id: cygwin32-intel.mk,v 1.4 2002/01/02 02:30:23 ellard Exp $
# cygwin32-index.mk
#
# &&& This is under-specified...  but I can't test it from home...

MAKE		= make
CC		= gcc
RANLIB		= ranlib
AR		= ar
LD		= ld

LATEX		= false
PDFLATEX	= false
PSNUP		= false
DVIPS		= false
MAKEINDEX	= false

AIDE8_FLAGS	= -mwindows

CC_OPT_BASE	= -g -O -DWINTEL
CC_WARNING	= -W -Wall -Wno-char-subscripts -pedantic
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC) -static
LFLAGS		= $(CFLAGS)

AA8_EXE		= aa8.exe
AD8_EXE		= ad8.exe
ANT8_EXE	= ant8.exe
AIDE8_EXE	= aide8.exe

AA32_EXE	= aa32.exe
AD32_EXE	= ad32.exe
ANT32_EXE	= ant32.exe
AIDE32_EXE	= aide32.exe

TK_INC	=
TK_LIBS	= -L//d/cygnus/cygwin-b20/H-i586-cygwin32/lib -ltk80 -ltcl80

