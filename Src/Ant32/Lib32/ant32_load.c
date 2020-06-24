/*
 * $Id: ant32_load.c,v 1.17 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_load.c -- functions to load an ANT-32 program from file.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>

#include	"ant_external.h"
#include	"ant32_external.h"

static	int	read_option_lines (FILE *fin, unsigned int *cnt);
static	int	read_prog_line (FILE *fin, char *line, int max_len,
			int *lineno);

/*
 * ant_load_text --
 *
 * Load a hex file into the ant memory, and clear the registers and PC
 * as defined by the spec.  Somewhat short on error checking-- will
 * always load correct files correctly, but can botch some kinds of
 * incorrect files.
 *
 * This loader is meant ONLY as a bootstrap loader, to load the
 * initial program (perhaps an operating system) into a bare ANT
 * machine.  An operating system or any higher-level executive would
 * almost certainly use its own method of loading a program, although
 * this could probably be used in a pinch.
 *
 * Returns 0 upon success, non-zero on failure.
 *
 * &&& This loader only loads instructions properly right now.  Data
 * will be done later...
 */

int ant_load_text (char *filename, ant_t *ant, int save_code)
{
	FILE		*fin;
	unsigned int	val;
	char		line [ANT_MAX_LINE_LEN + 1];
	int		len, lineno;
	unsigned int	new_addr;
	unsigned int	curr_addr;
	static char	*prev_line = NULL;

	ant_pmem_clear (ant->pmem, 1);

	ant32_code_init ();

	fin = fopen (filename, "r");
	if (fin == NULL) {
		printf ("Can't open file [%s].\n", filename);
		return (1);
	}

	curr_addr = 0x80000000;

	lineno = 0;
	for (;;) {
		int offset;
		char *nl;

		len = read_prog_line (fin, line, ANT_MAX_LINE_LEN, &lineno);
		if (len == 0) {
			break;
		}

		nl = strchr (line, '\n');
		if (nl != NULL) {
			*nl = '\0';
		}

		if (2 == sscanf (line, "0x%x  ::  0x%x  ::%n",
				&new_addr, &val, &offset)) {
			curr_addr = new_addr;
			a32_store_instruction (ant, curr_addr, val);
		}
		else if (1 == sscanf (line, "+ ::  0x%x  ::%n",
				&val, &offset)) {
			a32_store_instruction (ant, curr_addr, val);
		}
		else {
			printf ("Bad instruction at line %d\n", lineno);
			fclose (fin);
			return (1);
		}

		/*
		 * If we got here, then line contained something
		 * resembling an actual assembly language construct. 
		 * If appropriate, record it, so that it can be used
		 * later.
		 */

		if (save_code) {
			int lcode;
			char *line_copy, *p;

			/*
			 * Is there anything actually there?  If not,
			 * assume that it's part of synthetic
			 * instruction that came before.
			 */

			p = line + offset;
			while (*p != '\0' && isspace (*p)) {
				p++;
			}
			if (*p == '\0') {
				lcode = SYNTHETIC;
				line_copy = prev_line;
			}
			else {
				line_copy = strdup (line + offset + 1);
				if (prev_line != NULL) {
					free (prev_line);
				}
				prev_line = line_copy;
				lcode = LITERAL;
			}

			ant32_code_line_insert (curr_addr,
					line_copy, lcode);
		}

		curr_addr += sizeof (ant_inst_t);
	}

	if (prev_line != NULL) {
		free (prev_line);
		prev_line = NULL;
	}

	fclose (fin);
	return (0);
}

int ant_load_text_info (char *filename, unsigned int *inst_cnt)
{
	FILE		*fin;

	fin = fopen (filename, "r");
	if (fin == NULL) {
		printf ("Can't open file [%s].\n", filename);
		return (1);
	}

	read_option_lines (fin, inst_cnt);

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

static int read_option_lines (FILE *fin, unsigned int *cnt)
{
	char line [ANT_MAX_LINE_LEN + 1];
	int val;
	char *ptr;
	char *end_marker	= "#@ END OF OPTIONS\n";
	char *inst_marker	= "#@ Instructions %ud\n";

	while ((ptr = fgets (line, ANT_MAX_LINE_LEN, fin)) != NULL) {
		int rc;

		if (strcmp (ptr, end_marker) == 0) {
			return (0);
		}
		else if (1 == (rc = sscanf (ptr, inst_marker, &val))) {
			*cnt = val;
		}
	}

	return (-1);
}

/*
 * This method of storing the instruction should only be used by the
 * loader at boot time.  It assumes it can do what it wants without
 * the usual error checking.
 */

int a32_store_instruction (ant_t *ant,
		ant_vaddr_t v_addr, ant_inst_t inst)
{
	ant_paddr_t p_addr;
	ant_exc_t fault;
	void *vm_addr;

	p_addr = ant32_v2p (v_addr, ant,
			ANT_SUPER_MODE, ANT_MEM_WRITE, &fault, 0);

	/* &&& check for FAULT! */
	if (fault != ANT_EXC_OK) {
		printf ("Error: no mapping for v_addr (%x)\n", v_addr);
		printf ("fault = %d\n", fault);
		return (-1);
	}

	vm_addr = ant32_p2vm (p_addr, ant->pmem, ANT_MMU_WRITE_BIT);
	if (vm_addr == NULL) {
		printf ("Error storing inst to v_addr (%x) p_addr (%x)\n",
				v_addr, p_addr);
		return (-1);
	}

	*(ant_inst_t *) vm_addr = inst;

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

int ant_load_labels (char *filename, ant_symtab_t **table)
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
 * end of ant32_load.c
 */
