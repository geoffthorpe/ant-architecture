#
# Copyright 1996-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Makefile for libant8
#
# targets:
# all (default): builds libant8
# libant8
# clean
# depend

ANTHOSTTYPE := $(shell uname -sm | sed -e 's/ /-/g')
include ../../AntCommon/$(ANTHOSTTYPE).mk

# Choose the options for the ANT you are building...
# Do a "make clean" after changing any of these!

ANT_OPTS	=

ANT_VERSION	= $(ANT_LIB_VERSION)

LIB		= libant8.a

DEFINES		= $(ANT_OPTS) $(ANT_VERSION)
INCLUDES	= -I../../AntCommon
CFLAGS		= $(CC_OPTIONS) $(INCLUDES) $(DEFINES)

SRC		= ant8_exec.c ant8_load.c ant8_dump.c \
			ant8_bits.c ant8_dis.c ant8_dbg.c \
			ant8_util.c ant8_watch.c \
			ant8_core.c ant8_check.c \
			ant8_symtab.c ant8_fault.c
OBJ		= $(SRC:.c=.o)

all:		$(LIB)

build:		$(LIB)

$(LIB):		$(OBJ)
	rm -f $@
	$(AR) rc $@ $(OBJ)
	$(RANLIB) $@

clean:
	rm -f $(LIB) a.out core *.exe *.o *.so *.a *.dll

depend:
	@$(CC) -MM $(INCLUDES) $(SRC)

## end of Makefile

ant8_exec.o: ant8_exec.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_load.o: ant8_load.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_dump.o: ant8_dump.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_bits.o: ant8_bits.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_dis.o: ant8_dis.c ant8_external.h ../../AntCommon/ant_external.h \
 ant8_internal.h
ant8_dbg.o: ant8_dbg.c ant8_external.h ../../AntCommon/ant_external.h \
 ant8_internal.h
ant8_util.o: ant8_util.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_watch.o: ant8_watch.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_core.o: ant8_core.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_check.o: ant8_check.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_symtab.o: ant8_symtab.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
ant8_fault.o: ant8_fault.c ant8_external.h \
 ../../AntCommon/ant_external.h ant8_internal.h
