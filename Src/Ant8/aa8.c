/*
 * $Id: aa8.c,v 1.8 2002/01/02 02:37:59 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96
 * James Megquier -- 11/09/96
 *
 * aa8.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<unistd.h>	/* for unlink */
#include	<string.h>

#include	"ant8_external.h"

#define ASM_EXT		".asm"
#define ASM_EXT_LEN	strlen (ASM_EXT)

#define ANT_EXT		".ant"
#define ANT_EXT_LEN	strlen (ANT_EXT)

extern	ant_symtab_t	*knownList;

/* Statements, for cool printing later */
extern char *stmnts [ANT_INST_ADDR_RANGE];

char *make_ant_filename (char *asm_filename);
int ant_asm_write_exec (FILE *FOUT, int verbose,
		unsigned int n_inst,
		ant_data_t *data, unsigned int n_data,
		ant_symtab_t *labels);

static	int	aa8_parse_args (int argc, char **argv, char **file);
static void aa8_show_usage (char *progname);
void show_version (char *progname);

static	ant_asm_str_id_t	opcodes []	= {
	{ "add",	OP_ADD },
	{ "sub",	OP_SUB },
	{ "mul",	OP_MUL },
	{ "and",	OP_AND },
	{ "nor",	OP_NOR },
	{ "shf",	OP_SHF },
	{ "beq",	OP_BEQ },
	{ "bgt",	OP_BGT },
	{ "ld1",	OP_LD1 },
	{ "ld",		OP_LD1 },
	{ "st1",	OP_ST1 },
	{ "st",		OP_ST1 },
	{ "lc",		OP_LC },
	{ "jmp",	OP_JMP },
	{ "inc",	OP_INC },
	{ "in",		OP_IN },
	{ "out",	OP_OUT },
	{ "hlt",	OP_HALT },
	{ ".byte",	ASM_OP_BYTE },
	{ ".define",	ASM_OP_DEFINE },
	{ NULL,		0 }
};

/*
 * main --
 *
 */

int main (int argc, char *argv [])
{
	char	*asm_filename, *ant_filename;
	FILE	*out = NULL;
	unsigned int	rc;
	ant_inst_t	*instTable;
	ant_data_t	dataTable [ANT_DATA_ADDR_RANGE];
		/* Which byte in memory we're on */
	int		current_inst = 0;
	int		current_data = 0;
	char **lines;
	int line_cnt;

	instTable = (ant_inst_t *) dataTable;

	if (aa8_parse_args (argc, argv, &asm_filename) != 0) {
		aa8_show_usage (argv [0]);
		exit (1);
	}

	lines = file2lines (asm_filename, &line_cnt);
	if (lines == NULL) {
		printf("Couldn't read input file [%s].\n", asm_filename);
		exit(1);
	}

	ant_parse_setup (opcodes);

	rc = ant_asm_lines (asm_filename, lines, line_cnt,
			instTable, &current_inst, dataTable, &current_data);
	if (rc != 0) {
		printf ("%s\n", AntErrorStr);
		exit (1);
	}

	free (lines);

	ant_filename = make_ant_filename (asm_filename);

	/* Note: If the output file exists, we nuke it. */
	out = fopen (ant_filename, "w");
	if (out == NULL) {
		printf ("Couldn't open output file [%s].\n", ant_filename);
		exit(1);
	}

	/* Write the beast */
	rc = ant_asm_write_exec (out, 1,
			current_inst,
			dataTable, current_data,
			knownList);
	fclose(out);
	if (rc != 0) {
		printf ("%s: write failed.\n", asm_filename);
		unlink(ant_filename);
		exit(1);
	}

	exit (0);
}

char *make_ant_filename (char *asm_filename)
{
	unsigned int len;
	char *ant_filename;

	len = strlen (asm_filename);
	ant_filename = malloc ((len + ANT_EXT_LEN + 1) * sizeof(char)); 
	strcpy (ant_filename, asm_filename);

	if (len > ASM_EXT_LEN &&
			!strcmp(asm_filename + len - ASM_EXT_LEN, ASM_EXT)) {
		strcpy(ant_filename + len - ANT_EXT_LEN, ANT_EXT);
	}
	else {
		strcpy(ant_filename + len, ANT_EXT);
	}

	return (ant_filename);
}

int ant_asm_write_exec (FILE *FOUT, int verbose,
		unsigned int n_inst,
		ant_data_t *data, unsigned int n_data,
		ant_symtab_t *labels)
{
	unsigned int i;

	fprintf (FOUT, "#@ Instructions %d\n", n_inst);

	fprintf (FOUT, "#@ Data %d\n", n_data);

	fprintf (FOUT, "#@ SINGLE_ADDRESS_SPACE\n");

	fprintf (FOUT, "#@ END OF OPTIONS\n");

	if (n_data == 0) {
		if (verbose) fprintf(FOUT, "# no data\n");
	}
	else {
		if (verbose) fprintf(FOUT, "# start of data\n");

		for (i = 0; i < n_data; i++) {
			fprintf(FOUT, "0x%2.2x", (unsigned char) data [i]);
			if (verbose) {
				fprintf(FOUT, "  # (%3d)",
						(unsigned char) data [i]);
				if ( data [i] >= ' ' &&  data [i] <= 'z')
					fprintf(FOUT, " '%c'",  data [i]);
			}
			fprintf(FOUT, "\n");
		}

		if (verbose) fprintf(FOUT, "# end of data\n");
	}

	if (verbose) {
		dump8_symtab_machine (labels, FOUT);
	}

	if (verbose) {
		fprintf(FOUT, "# end of file\n");
	}

	return(0);
}

static	int	aa8_parse_args (int argc, char **argv, char **file)
{
	char		*usage	= "hVwX:";
	int		c;
	extern	int	optind;
	extern	char	*optarg;

	while ((c = getopt (argc, argv, usage)) != -1) {
		switch (c) {
			case 'h'	:
				aa8_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
			case 'w'	:
				DesWarnOnly = 1;
				break;
		}
	}

	if (argc != optind + 1) {
		printf ("Incorrect usage.\n");
		aa8_show_usage (argv [0]);
		exit (1);
	}

	*file = argv [optind];

	return (0);
}

static	void	aa8_show_usage (char *progname)
{
	char		*usage	=
		"usage: %s [options] filename\n"
		"\n"
		"\t-h     Show this message, and then exit.\n"
		"\t-V     Print program version, and then exit.\n"
		"\n";

	printf (usage, progname);

	return ;
}

/*
 * end of aa8.c
 */
