# $Id: os-mach.mk,v 1.2 2002/01/02 02:30:23 ellard Exp $
# os-mach.mk
#
# Blank template for Makefile definitions.

MAKE		= false
CC		= false
RANLIB		= false
AR		= false
LD		= false

LATEX		= false
PDFLATEX	= false
PSNUP		= false
DVIPS		= false
MAKEINDEX	= false

CC_OPT_BASE	=
CC_WARNING	=
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

# For creating a shared library:

TK_INC		= 
TK_LIBS		= 
