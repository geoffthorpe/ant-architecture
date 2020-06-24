/*
 * $Id: ant_load.c,v 1.2 2000/03/27 22:05:43 ellard Exp $
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant_load.c -- functions to load an ANT program from file.
 *
 * NOTE TO CS50 STUDENTS - You are not expected, for assignment 5, to
 * understand all of the code in this file.  This code uses constructs
 * that have NOT been covered yet (but will be covered later in the
 * semester).
 */

#include	<stdio.h>
#include	<string.h>

#include	"ant.h"

#define	ANT_MAX_LINE_LEN	512

int read_prog_line (FILE *fin, char *line, int max_len);

/*
 * ant_get_file --
 *
 * Determine the name of the file to load, and return it.
 */

char *ant_get_prog_name (int argc, char **argv)
{
	char *name;

	if (argc == 2) {
		name = argv [1];
	}
	else {
		printf ("usage: %s [filename]\n", argv [0]);
		name = NULL;
	}

	return  (name);
}

/*
 * ant_load_text --
 *
 * Load a hex file into the ant memory, and clear the registers and PC
 * as defined by the spec.  Somewhat short on error checking-- will
 * always load correct files correctly, but can botch some kinds of
 * incorrect files.
 *
 * Returns 0 upon success, non-zero on failure.
 */

int ant_load_text (char *filename)
{
	int i, len, rc;
	FILE *fin;
	unsigned int val;
	char line [ANT_MAX_LINE_LEN + 1];

	ant_clear ();

	fin = fopen (filename, "r");
	if (fin == NULL) {
		printf ("Can't open file.\n");
		return (1);
	}

	for (i = 0; i < ANT_ADDR_RANGE; i++) {
		len = read_prog_line (fin, line, ANT_MAX_LINE_LEN);
		if (len == 0) {
			break;
		}

		rc = sscanf (line, "0x%x\n", &val);
		if (rc != 1) {
			printf ("Bad data line.\n");
			return (1);
		}

		AntMemory [i] = val;
	}

	return (0);
}

/*
 * read_prog_line --
 *
 * A worker function used by the ant_load_text function.  Reads lines
 * from the given stream until something that looks like a non-empty
 * line is encountered.
 *
 * Reads each line into the buffer pointed to by "line", and returns
 * the length of the line.  If a line that is too long is encountered,
 * this error is detected here and the program bails out immediately.
 */

int read_prog_line (FILE *fin, char *line, int max_len)
{
	char *ptr;

	for (;;) {
		ptr = fgets (line, max_len, fin);
		if (ptr == NULL) {
			return (0);
		}

		if (line [strlen (line) - 1] != '\n') {
			printf ("Program line too long!\n");
			exit (0);
		}

		if ((strlen (line) > 1) && (line [0] != '#')) {
			break;
		}
	}

	return (strlen (line));
}

/*
 * ant_clear -- set an ant_t structure to the "uninitialized" state
 * (generally done before the loading of an ANT program).  See ant.txt
 * for a description of this state.
 *
 * 1.  Fill the data memory with zero bytes.
 *
 * 2.  Fill the instruction memory with illegal instructions.
 *
 * 3.  Set all the registers to zero.
 *
 * 4.  Set the PC to zero.
 *
 */
 
void ant_clear (void)
{
	int i;

	for (i = 0; i < ANT_ADDR_RANGE; i++) {
		AntMemory [i] = 0;
	}

		/*
		 * Note that we clear out ALL the registers, including
		 * register zero, even though (theoretically) this
		 * register can't ever contain anything other than
		 * zero.  Better safe than sorry.
		 */

	for (i = 0; i < ANT_REG_RANGE; i++) {
		AntRegisters [i] = 0;
	}

	AntPC = 0;

	return ;
}

/*
 * end of ant_load.c
 */
