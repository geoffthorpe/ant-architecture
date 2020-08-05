/*
 * $Id: ant8_load.c,v 1.3 2001/01/02 15:30:03 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_load.c -- functions to load an ANT program from file.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

#include	"ant_external.h"


static int read_prog_line (FILE *fin, char *line, int max_len, int *lineno);
int read_option_lines (FILE *fin, ant_t *ant);

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

int ant_load_text (const char *filename, ant_t *ant)
{
	int		i;
	FILE		*fin;
	unsigned int	val;
	int		rc;
	char		line [ANT_MAX_LINE_LEN + 1];
	int		len;
	int		lineno;
	int started_data = 0;

	ant_clear (ant);

	ant->inst_cnt = ILLEGAL_INSTRUCTION;

	lineno = 0;

	fin = fopen (filename, "r");
	if (fin == NULL) {
		printf ("Can't open file.\n");
		return (1);
	}

	read_option_lines (fin, ant);

	for (i = 0; i < ANT_DATA_ADDR_RANGE; i++) {
		len = read_prog_line (fin, line, ANT_MAX_LINE_LEN, &lineno);
		if (len == 0) {
			break;
		}

		rc = sscanf (line, "0x%x\n", &val);
		if (rc != 1) {
			printf ("Bad data at line %d\n", lineno);
			fclose (fin);
			return (1);
		}

		ant->data [i] = val;

		/*
		 * Did we see the marker for the end of instructions?
		 */
		if (!started_data && (i > 0) &&
				(ant->data [i - 1] == (ant_data_t) 0xff) &&
				(ant->data [i - 0] == (ant_data_t) 0xff)) {
			started_data = 1;
			ant->inst_cnt = i;
			printf ("ant->inst_cnt = %d\n", ant->inst_cnt);
		}
	}

	fclose (fin);
	return (0);
}

/*
 * read_option_lines --
 *
 * Reads lines from the input stream until it enounters one that
 * matches "#@ END OF OPTIONS", and sets the option variables in the
 * specified ant to whatever values it finds.  This is all horribly
 * fragile.
 */

int read_option_lines (FILE *fin, ant_t *ant)
{
	char line [ANT_MAX_LINE_LEN + 1];
	int val;
	char *ptr;
	char *end_marker	= "#@ END OF OPTIONS\n";
	char *inst_marker	= "#@ Instructions %d\n";

	while ((ptr = fgets (line, ANT_MAX_LINE_LEN, fin)) != NULL) {
		int rc;

		if (strcmp (ptr, end_marker) == 0) {
			return (0);
		}
		else if (1 == (rc = sscanf (ptr, inst_marker, &val))) {
			ant->inst_cnt = val;
		}
	}

	return (-1);
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
 *
 * For each actual line read from the stream, the variable pointed at
 * by "lineno" is incremented by one.
 */

static	int	read_prog_line (FILE *fin, char *line, int max_len, int *lineno)
{
	char		*ptr;

	ANT_ASSERT (lineno != NULL);

	for (;;) {
		ptr = fgets (line, max_len, fin);
		if (ptr == NULL) {
			return (0);
		}

		++(*lineno);

		if (line [strlen (line) - 1] != '\n') {
			printf ("Program line too long at line %d\n", *lineno);
			exit (0);
		}

		if ((strlen (line) > 1) && (line [0] != '#')) {
			break;
		}
	}

	return (strlen (line));
}

/*
 * ant_load_labels --
 *
 * Returns 0 upon success, non-zero on failure.
 */

int ant_load_labels (const char *filename, ant_symtab_t **table)
{
	FILE		*fin;
	int		rc;
	char		line [ANT_MAX_LINE_LEN + 1];
	char		sym [ANT_MAX_LINE_LEN];
	int		addr;
	int		symbols = 0;

	fin = fopen (filename, "r");
	if (fin == NULL) {
		printf ("Can't open file.\n");
		return (1);
	}

	while (NULL != fgets (line, ANT_MAX_LINE_LEN, fin)) {
		rc = sscanf (line, "# $%s = %i\n", sym, &addr);
		if (rc == 2) {
			char *sym_copy = strdup (sym);
			if (add_symbol (table, sym_copy, addr, "Label")) {
				fclose (fin);
				return (-1);
			}
			symbols++;
		}
	}

	fclose (fin);
	return (0);
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
 
void ant_clear (ant_t *ant)
{
	int		i;

	for (i = 0; i < ANT_DATA_ADDR_RANGE; i++) {
		ant->data [i] = 0;
	}

	/*
	 * Note that we clear out ALL the registers, including
	 * register zero, even though (theoretically) this register
	 * can't ever contain anything other than zero.  Better safe
	 * than sorry.
	 */

	for (i = 0; i < ANT_REG_RANGE; i++) {
		ant->reg [i] = 0;
	}

	ant->pc = 0;

	return ;
}

/*
 * end of ant8_load.c
 */
