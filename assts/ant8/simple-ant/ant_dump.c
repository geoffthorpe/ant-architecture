/*
 * $Id: ant_dump.c,v 1.3 2000/05/25 20:50:59 ellard Exp $
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant_dump.c -- Functions to dump an ant_t structure to file
 * (as a "core dump").
 *
 * NOTE TO CS50 STUDENTS - You are not expected, for assignment 5, to
 * understand all of the code in this file.  This code uses constructs
 * that have NOT been covered yet (but will be covered later in the
 * semester).
 */

#include	<stdio.h>

#include	"ant.h"

#define	SHORTS_PER_LINE		8
#define	BYTES_PER_LINE		8

/*
 * ant_dump_text --
 *
 * Dump the entire state of an ANT (contained in an ant_t structure)
 * in text format.
 *
 * Returns non-zero (and prints an error message to stdout) if the
 * attempt to dump is unsuccessful.  Returns zero and creates or
 * overwrites the specified file upon success.
 */

int ant_dump_text (char *filename)
{
	FILE *fout;

	fout = fopen (filename, "w");
	if (fout == NULL) {
		printf ("Error: can't dump text to [%s].\n", filename);
		return (1);
	}

	fprintf (fout, "PC = 0x%x\n\n", AntPC);
	fprintf (fout, "Registers:\n\n");
	ant_print_reg (fout);
	fprintf (fout, "\n\nData Memory:\n\n");
	ant_print_memory (fout);

	fclose (fout);
	return (0);
}

/*
 * ant_print_reg --
 *
 * Print the contents of the registers in the given ant_t structure,
 * in "human-readable" form.
 *
 * Always returns 0 (doesn't do any error checking...).
 */

int ant_print_reg (FILE *stream)
{
	int i;

	for (i = 0; i < ANT_REG_RANGE; i++) {
		fprintf (stream, " r%.2d ", i);
	}
	fprintf (stream, "\n");

	for (i = 0; i < ANT_REG_RANGE; i++) {
		fprintf (stream, "  %.2x ", LOWER_BYTE (AntRegisters [i]));
	}
	fprintf (stream, "\n");

	for (i = 0; i < ANT_REG_RANGE; i++) {
		fprintf (stream, "%4d ", AntRegisters [i]);
	}
	fprintf (stream, "\n");

	return (0);
}

/*
 * ant_print_memory --
 *
 * Print the contents of the data memory of the given ANT, in hex
 * (with some formatting to make it somewhat readable by humans).
 *
 * Always returns 0 (doesn't do any error checking...).
 */

int ant_print_memory (FILE *stream)
{
	int i, j;

	fprintf (stream, "    ");
	for (i = 0; i < BYTES_PER_LINE; i++) {
		fprintf (stream, "   0%x", i);
	}

	fprintf (stream, "\n\n");

	for (i = 0; i < ANT_ADDR_RANGE; i += BYTES_PER_LINE) {
		fprintf (stream, "%.2x: ", i);

		for (j = 0; j < BYTES_PER_LINE; j++) {
			fprintf (stream, "   %.2x",
					LOWER_BYTE (AntMemory [i + j]));
		}
		fprintf (stream, "\n    ");

		for (j = 0; j < BYTES_PER_LINE; j++) {
			fprintf (stream, " %4d", AntMemory [i + j]);
		}
		fprintf (stream, "\n");
	}

	return (0);
}

/*
 * end of ant_dump.c
 */
