/*
 * $Id: ant32.c,v 1.16 2002/05/16 14:08:46 ellard Exp $
 *
 * Copyright 1996-2002 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32.c --
 *
 */

#include	<stdio.h>
#include	<unistd.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant32_external.h"

static int ant32_parse_args (int argc, char **argv, int *do_dump, char **file);
void show_version (char *progname);
void ant32_show_usage (char *progname);

/*
 * main --
 *
 */

int main (int argc, char *argv [])
{
	char		*progname	= argv [0];
	ant_t		*ant;
	int		rc;
	char		*file;
	int 		do_dump = 0;

	rc = ant32_parse_args (argc, argv, &do_dump, &file);
	if (rc != 0) {
		ant32_show_usage (progname);
		exit (1);
	}

	if (ant_check_params (&AntParameters) != 0) {
		exit (1);
	}

	ant = ant_create (&AntParameters);
	if (ant == NULL) {
		exit (1);
	}

	rc = ant_load_text (file, ant, 0);
	if (rc != 0) {
		printf ("ERROR: Couldn't load [%s].\n", file);
		exit (1);
	}

	rc = ant_reset (ant);
	if (rc != 0) {
		printf ("ERROR: cannot reset the CPU properly.\n");
		exit (1);
	}

	rc = ant_exec (ant);
	if (do_dump) {
		ant32_reg_names_change ('r');
		ant_dump_text ("ant32.core", ant);
	}
	return (rc);
}

static	int	ant32_parse_args (int argc, char **argv,
			int *do_dump, char **file)
{
	char		*usage	= "r:t:m:M:dhV";
	int		c;
	extern	int	optind;
        extern  char    *optarg;

	while ((c = getopt (argc, argv, usage)) != -1) {
		switch (c) {

			/*
			 * &&& Sure could use some up-front error
			 * checking!  None of the parameters are
			 * actually checked until the VM is
			 * initialized.
			 */

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

			case 'h'	:
				ant32_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
		}
	}

	if (argc != optind + 1) {
		printf ("Incorrect usage.\n");
		ant32_show_usage (argv [0]);
		exit (1);
	}

	*file = argv [optind];

	return (0);
}


void	ant32_show_usage (char *progname)
{
	char		*usage	=
	"usage: %s [options] filename\n"
	"\n"
	"\t-d       Dump the state of the machine to ant32.core\n"
	"\t         when the program halts (or crashes).\n"
	"\t-h       Show this message, and then exit.\n"
	"\t-V       Print program version, and then exit.\n"
	"\t-m size  Use the given memory size (in 4k pages)\n"
	"\t         instead of the default (%d megabytes).\n"
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
 * end of ant32.c
 */
