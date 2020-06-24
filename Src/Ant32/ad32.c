/*
 * $Id: ad32.c,v 1.13 2002/01/02 02:26:02 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 12/21/2000
 *
 * ad32.c --
 *
 */

#include	<stdio.h>
#include	<unistd.h>
#include	<stdlib.h>

#include	"ant32_external.h"
#include	"ant_external.h"
#include	"ad32_util.h"

#define	DEBUG	0
#define	RUN	1
#define	DISASM	2
#define	VERSION	3

static	void	ad32_show_usage (char *progname);
void		show_version (char *progname);
static	int	parse_args (int argc, char **argv, int *cmd,
			int *do_dump, char **file);

extern	ant_symtab_t	*labelTable;

int	ant32Verbose	= 0;

/*
 * main --
 *
 */

int		main (int argc, char *argv [])
{
	char		*progname;
	ant_t		*ant;
	int		rc;
	int		cmd;
	int		do_dump;

	rc = parse_args (argc, argv, &cmd, &do_dump, &progname);
	if (rc != 0) {
		ad32_show_usage (progname);
		exit (1);
	}

	if (ant_check_params (&AntParameters) != 0) {
		exit (1);
	}

	ant = ant_create (&AntParameters);
	if (ant == NULL) {
		exit (1);
	}

	rc = ant_load_dbg (progname, ant, &labelTable);
	if (rc != 0) {
		printf ("ERROR: Couldn't load [%s].\n", progname);
		exit (1);
	}
	rc = ant_reset (ant);
	if (rc != 0) {
		printf ("ERROR: cannot reset the CPU properly.\n");
		exit (1);
	}
	ant32_clear_breakpoints ();

	switch (cmd) {
		case DEBUG	:
			rc = ant_debug (ant, progname);
			if (do_dump) {
				ant_dump_text ("ad32.core", ant);
			}
			printf ("Goodbye.\n");
			break;
		case RUN	:
			rc = ant_exec (ant);
			if (do_dump) {
				ant_dump_text ("ad32.core", ant);
			}
			break;
		case DISASM	:
			printf ("Disassembly not supported yet.\n");
			exit (1);
			break;
		default		:
			ANT_ASSERT (0);
			break;
	}

	return (rc);
}

static	int	parse_args (int argc, char **argv, int *cmd,
			int *do_dump, char **file)
{
	char		*usage	= "gr:t:m:M:dhRV";
	int		c;
	extern	char	*optarg;
	extern	int	optind;

	*cmd = DEBUG;

	while ((c = getopt (argc, argv, usage)) != -1) {
		switch (c) {
			case 'g'	:
				ant32Verbose = 1;
				break;

			case 'r'	:
				AntParameters.n_reg = atoi (optarg);
				break;
			case 't'	:
				AntParameters.n_tlb = atoi (optarg);
				break;
			case 'm'	:
				AntParameters.n_pages = atoi (optarg);
				break;

			case 'M'	:
				AntParameters.n_rom_pages = atoi (optarg);
				break;


			case 'd'	:
				*do_dump = 1;
				break;
			case 'R'	:
				*cmd = RUN;
				break;
			case 'D'	:
				*cmd = DISASM;
				break;
			case 'h'	:
				ad32_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
		}
	}

	if (argc != optind + 1) {
		printf ("Incorrect usage.\n");
		ad32_show_usage (argv [0]);
		exit (1);
	}

	*file = argv [optind];

	return (0);
}

static	void	ad32_show_usage (char *progname)
{
	char		*usage	=
	"usage: %s [options] filename\n"
	"\n"
	"\t-g       Run in verbose debugging mode.\n"
	"\t         (Results are implementation-dependent)\n"
	"\t-R       Run the program, and then exit.\n"
	"\t-d       Dump the ant's memory when exiting.\n"
	"\t-d       Dump the state of the machine to ad32.core at exit.\n"
	"\t-h       Show this message, and then exit.\n"
	"\t-V       Print program version, and then exit.\n"
	"\t-m size  Use the given RAM size (in 4k pages)\n"
	"\t         instead of the default (1 megabyte).\n"
	"\t-M size  Use the given ROM size (in 4k pages)\n"
	"\t         instead of the default (16K).\n"
	"\t-r num   Specify the number of general registers to use\n"
	"\t         instead of the default (64).\n"
	"\t-t num   Specify the number of TLB entries to use.\n"
	"\t         instead of the default (32).\n"
	"\n";

	printf (usage, progname);

	return ;
}

/*
 * end of ad32.c
 */
