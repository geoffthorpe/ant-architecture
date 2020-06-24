/*
 * $Id: ad8.c,v 1.7 2001/03/18 09:16:50 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ad8.c --
 *
 */

#include	<stdio.h>
#include	<unistd.h>
#include	<stdlib.h>

#include	"ant8_external.h"
#include	"ad8_util.h"



#define	DEBUG	0
#define	RUN	1
#define	DISASM	2
#define	VERSION	3

static	void	ad8_show_usage (char *progname);
void	show_version (char *progname);
static	int	ad8_parse_args (int argc, char **argv, int *cmd, char **file);

extern	ant_symtab_t	*labelTable;

int		ant8Verbose	= 0;

/*
 * main --
 *
 */

int		main (int argc, char *argv [])
{
	char		*progname;
	ant_t		ant;
	int		rc;
	int		cmd;

	rc = ad8_parse_args (argc, argv, &cmd, &progname);

	rc = ant_load_dbg (progname, &ant, &labelTable);
	if (rc != 0) {
		printf ("ERROR: Couldn't load [%s].\n", progname);
		exit (1);
	}

	switch (cmd) {
		case DEBUG	:
			rc = ant_debug (&ant, progname);
			ant_dump_text ("ad.core", &ant);
			printf ("Goodbye.\n");
			break;
		case RUN	:
			rc = ant_exec (&ant);
			ant_dump_text ("ad.core", &ant);
			break;
		case DISASM	:
			ant_disasm_i_mem_print (&ant);
			printf ("_data_:\n");
			ant_disasm_d_mem_print (&ant);
			break;
		default		:
			ANT_ASSERT (0);
			break;
	}

	return (rc);
}

static	int	ad8_parse_args (int argc, char **argv, int *cmd, char **file)
{
	char		*usage	= "gdhrVX:";
	int		c;
	extern	char	*optarg;
	extern	int	optind;

	*cmd = DEBUG;

	while ((c = getopt (argc, argv, usage)) != -1) {
		switch (c) {
			case 'g'	:
				ant8Verbose = 1;
				break;
			case 'r'	:
				*cmd = RUN;
				break;
			case 'd'	:
				*cmd = DISASM;
				break;
			case 'h'	:
				ad8_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
		}
	}

	if (argc != optind + 1) {
		printf ("Incorrect usage.\n");
		ad8_show_usage (argv [0]);
		exit (1);
	}

	*file = argv [optind];

	return (0);
}

static	void	ad8_show_usage (char *progname)
{
	char		*usage	=
		"usage: %s [options] filename\n"
		"\n"
		"\t-g     Run in verbose mode.\n"
		"\t-r     Run the program, and then exit.\n"
		"\t-d     Disassemble the program, and then exit.\n"
		"\t-h     Show this message, and then exit.\n"
		"\t-V     Print program version, and then exit.\n"
		"\n";

	printf (usage, progname);

	return ;
}

/*
 * end of ad8.c
 */
