# $Id: sunos-sun4u.mk,v 1.8 2003/05/06 20:48:35 sara Exp $
# solaris-sparc.mk
#
# This is intended for use on cin00!

MAKE		= /usr/local/gnu/bin/gmake
CC		= /usr/local/bin/gcc
RANLIB		= /usr/local/gnu/bin/ranlib
AR		= /usr/ccs/bin/ar
LD		= /usr/ccs/bin/ld -G -z text

LATEX		= /usr/local/bin/pslatex
PDFLATEX	= /usr/local/bin/pdflatex
PSNUP		= /usr/local/bin/psnup
DVIPS		= /usr/local/bin/dvips
MAKEINDEX	= /usr/local/bin/makeindex

CC_OPT_BASE	= -g -O -fPIC -DIS_BIG_ENDIAN
CC_WARNING	= -W -Wall -Wno-char-subscripts
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS)

# For creating a shared library:

TK_INC		= -I/usr/local/include
TK_LIBS		= -L/usr/local/lib -ltk8.2 -ltcl8.2 -lX11 -lm
