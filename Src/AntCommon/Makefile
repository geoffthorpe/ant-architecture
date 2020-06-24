# $Id: Makefile,v 1.10 2002/06/27 17:31:18 ellard Exp $
#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Makefile for libant, common code (NOT architecture-specific)
# shared among the ANT utilities.
#
# targets:
# all (default): builds libant.a
# libant.a
# clean
# depend

ANTHOSTTYPE := $(shell uname -sm | sed -e 's/ /-/g')
include ./$(ANTHOSTTYPE).mk

# Choose the options for the ANT you are building...
# Do a "make clean" after changing any of these!

ANT_OPTS	=

ANT_VERSION	= $(ANT_LIB_VERSION)

# From here, things are pretty normal.

LIB		= libant.a

DEFINES		= $(ANT_OPTS) $(ANT_VERSION)
INCLUDES	=
CFLAGS		= $(CC_OPTIONS) $(INCLUDES) $(DEFINES)

SRC		= ant_string.c ant_parse.c ant_symtab.c \
			ant_file.c llist.c \
			ant_backpatch.c \
			ant_sys.c \
			ant_console.c

# NOTE: ant_error.o, which lives in this directory, doesn't
# get built into the library directly because of a bug in the
# Darwin linker.  Instead, it gets sucked directly into each
# executable that needs it.

OBJ		= $(SRC:.c=.o)

all:		$(LIB) ant_error.o

build:		$(LIB) ant_error.o

$(LIB):		$(OBJ)
	rm -f $@
	$(AR) rc $@ $(OBJ)
	$(RANLIB) $@

clean:
	rm -f $(LIB) a.out core *.exe *.o *.so *.a *.dll

depend:
	@$(CC) -MM $(INCLUDES) $(SRC)

## end of Makefile

ant_string.o: ant_string.c ant_external.h ant_internal.h
ant_parse.o: ant_parse.c ant_external.h ant_internal.h
ant_symtab.o: ant_symtab.c ant_external.h ant_internal.h
ant_file.o: ant_file.c ant_external.h ant_internal.h
ant_error.o: ant_error.c ant_external.h ant_internal.h
llist.o: llist.c ant_external.h ant_internal.h
ant_backpatch.o: ant_backpatch.c ant_external.h ant_internal.h
ant_sys.o: ant_sys.c ant_external.h
ant_console.o: ant_console.c ant_external.h ant_internal.h
