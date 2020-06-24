/*
 * $Id: ant8_dump.c,v 1.6 2001/04/12 15:37:22 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_dump.c -- Functions to dump an ant_t structure to file
 * (as a "core dump").
 */

#include	<stdio.h>
#include	<stdlib.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

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

int		ant_dump_text (char *filename, ant_t *ant)
{
	FILE		*fout;

	fout = fopen (filename, "w");
	if (fout == NULL) {
		printf ("Error: can't dump text to [%s].\n", filename);
		return (1);
	}

	fprintf (fout, "PC = 0x%x\n\n", ant->pc);
	fprintf (fout, "Registers:\n\n");
	ant_print_reg (fout, ant);
	fprintf (fout, "\n\nData Memory:\n\n");
	ant_print_data (fout, ant);

	fclose (fout);
	return (0);
}

/*
 * ant_print_reg_vec --
 *
 * Print the contents of the registers specified in the given vector
 * of register numbers from the given ant_t structure, in
 * "human-readable" form.
 *
 * Always returns 0.  Dies horribly on error.
 */

int ant_print_reg_vec (FILE *stream, ant_t *ant, int *vec, int len)
{
	int i;

	for (i = 0; i < len; i++) {
		if ((vec [i] < 0) || (vec [i] >= ANT_REG_RANGE)) {
			printf ("ERROR: Bad register index (%d)\n", vec [i]);
			ANT_ASSERT (0);
		}
	}

	for (i = 0; i < len; i++) {
		fprintf (stream, " r%.2d ", vec [i]);
	}
	fprintf (stream, "\n");

	for (i = 0; i < len; i++) {
		fprintf (stream, "  %.2x ", LOWER_BYTE (ant->reg [vec [i]]));
	}
	fprintf (stream, "\n");

	for (i = 0; i < len; i++) {
		fprintf (stream, "%4d ", ant->reg [vec [i]]);
	}
	fprintf (stream, "\n");

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

int		ant_print_reg (FILE *stream, ant_t *ant)
{
	int i;
	int vec [ANT_REG_RANGE];

	for (i = 0; i < ANT_REG_RANGE; i++) {
		vec [i] = i;
	}

	ant_print_reg_vec (stream, ant, vec, ANT_REG_RANGE);

	return (0);
}

/*
 * ant_print_data --
 *
 * Print the contents of the data memory of the given ANT, in hex
 * (with some formatting to make it somewhat readable by humans).
 *
 * Always returns 0 (doesn't do any error checking...).
 */

int		ant_print_data (FILE *stream, ant_t *ant)
{
	int		i;
	int		j;

	fprintf (stream, "    ");
	for (i = 0; i < BYTES_PER_LINE; i++) {
		fprintf (stream, "   0%x", i);
	}

	fprintf (stream, "\n\n");

	for (i = 0; i < ANT_DATA_ADDR_RANGE; i += BYTES_PER_LINE) {
		fprintf (stream, "%.2x: ", i);

		for (j = 0; j < BYTES_PER_LINE; j++) {
			fprintf (stream, "   %.2x",
					LOWER_BYTE (ant->data [i + j]));
		}
		fprintf (stream, "\n    ");

		for (j = 0; j < BYTES_PER_LINE; j++) {
			fprintf (stream, " %4d", ant->data [i + j]);
		}
		fprintf (stream, "\n");
	}

	return (0);
}

/*
 * end of ant_dump.c
 */
