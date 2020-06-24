/*
 * $Id: ant8.c,v 1.6 2001/03/18 09:16:50 ellard Exp $
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant8.c --
 *
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<unistd.h>

#include	"ant8_external.h"

static int parse_args (int argc, char **argv, char **file);
void show_version (char *progname);
static void ant8_show_usage (char *progname);

/*
 * main --
 *
 */

int		main (int argc, char *argv [])
{
	char		*progname	= argv [0];
	ant_t		ant;
	int		rc;
	char		*file;

	rc = parse_args (argc, argv, &file);
	if (rc != 0) {
		ant8_show_usage (progname);
		exit (1);
	}

	rc = ant_load_text (file, &ant);
	if (rc != 0) {
		printf ("ERROR: Couldn't load [%s].\n", file);
		exit (1);
	}

	rc = ant_exec (&ant);
	ant_dump_text ("ant.core", &ant);
	return (rc);
}

static	int	parse_args (int argc, char **argv, char **file)
{
	char		*usage	= "hV";
	int		c;
	extern	int	optind;
	extern	char	*optarg;

	while ((c = getopt (argc, argv, usage)) != -1) {
		switch (c) {
			case 'h'	:
				ant8_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
		}
	}

	if (argc != optind + 1) {
		printf ("Incorrect usage.\n");
		ant8_show_usage (argv [0]);
		exit (1);
	}

	*file = argv [optind];

	return (0);
}


static	void	ant8_show_usage (char *progname)
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
 * end of ant8.c
 */
