# $Id: bsdi-i386.mk,v 1.6 2002/01/02 02:30:23 ellard Exp $
# bsdi-i386.mk

CC		= gcc
CC_OPT_BASE	= -g -O -fPIC
CC_WARNING	= -W -Wall -Wno-char-subscripts -pedantic
CC_OPTIONS	= $(CC_OPT_BASE) $(CC_WARNING)
LINK		= $(CC)
LFLAGS		= $(CFLAGS) -static
RANLIB		= ranlib
AR		= ar

# For creating a shared library:
LD		= DUNNO

TK_INC		= /usr/X11/include
TK_LIBS		= /usr/contrib/lib

