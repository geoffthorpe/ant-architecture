# $Id: darwin-ppc.mk,v 1.5 2003/02/19 20:47:52 ellard Exp $
# darwin-ppc.mk
#
# Based on linux-intel.mk.
#
# For the all the *latex files, it assumes they are installed with fink.
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are correct
# for many systems but not for all.  On systems with dynamically-linked
# libraries, for example, strive to disable them by changing LFLAGS.

CC		= cc
RANLIB		= ranlib
AR		= ar
MAKE		= make
LD		= ld

LATEX		= pslatex
PDFLATEX	= pdflatex
PSNUP		= false
DVIPS		= dvips
MAKEINDEX	= makeindex

CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

TK_INC		= -I/usr/local/include -I/usr/X11R6/include
TK_LIBS		= -L/usr/local/lib -ltk -ltcl \
			-L/usr/X11R6/lib -lX11 -lm

