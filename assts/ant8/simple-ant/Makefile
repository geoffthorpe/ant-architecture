# $Id: Makefile,v 1.2 2000/05/16 19:13:43 ellard Exp $
#
# Makefile for ant VM -- 11/08/96

########################################################################
# INSTRUCTIONS:
#
# Add any new .c files you write to the ANT_SRC definition below. 
# This definition currently contains the names of all the .c files
# that we supply for you to use; if you add new files to implement
# your ant (which is not a bad idea) you'll need to add their names to
# this definition as well.
#
# After adding or changing any #includes, run "make depend" in order
# to keep the Makefile completely up-to-date.

ANT_SRC		= antvm.c ant_dump.c ant_load.c ant_utils.c

########################################################################
# You shouldn't need to change anything after this line.
########################################################################

CC		= gcc
CC_OPTIONS	= -g -pedantic -W -Wall
INCLUDES	= -I.
CFLAGS		= $(CC_OPTIONS) $(INCLUDES)
LIBS		= 

ANT_EXE		= ant
ANT_OBJ		= $(ANT_SRC:.c=.o)

$(ANT_EXE):	$(ANT_OBJ)
	$(CC) -o $@ $(CFLAGS) $(ANT_OBJ) $(LIBS)

clean:
	rm -f $(ANT_EXE) a.out core *.o

depend:		Makefile $(ANT_SRC)
	makedepend $(INCLUDES) $(ANT_SRC)

# end of Makefile
# DO NOT DELETE
