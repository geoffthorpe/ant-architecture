# $Id: bsdi-intel.mk,v 1.2 2002/01/02 02:30:23 ellard Exp $
# bsdi-intel.mk
#
# Based on a blank template for architecture-dependent files to set up
# environment variables to create portable makefiles, etc.
#
# A kludge, but a relatively minor one...
#
# ALL OF THESE VALUES MUST BE DEFINED.  The initial values are correct
# for many systems but not for all.  On systems with
# dynamically-linked libraries, for example, strive to disable them by
# changing LFLAGS.

CC		= /usr/ucb/gcc
RANLIB		= /usr/ucb/ranlib
AR		= /usr/ucb/ar
MAKE		= /usr/contrib/bin/gmake
LD		= /usr/ucb/ld -G -z text

LATEX		= /usr/contrib/teTeX/bin/pslatex
PDFLATEX	= /usr/contrib/teTeX/bin/pdflatex
PSNUP		= /usr/contrib/bin/psnup
DVIPS		= /usr/contrib/teTeX/bin/dvips
MAKEINDEX	= /usr/contrib/teTeX/bin/makeindex

CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

TK_INC		= -I/usr/X11R6/include -I/usr/local/tcl8.0/include
TK_LIBS		= -L/usr/local/tcl8.0/lib -ltk8.0 -ltcl8.0 \
			-L/usr/X11/lib -lX11 -lmstd -lc -ldl

