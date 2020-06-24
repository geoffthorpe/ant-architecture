/*
 * $Id: ant_sys.c,v 1.4 2002/01/02 02:30:23 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant_sys.c --
 *
 */
 
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>

#include	"ant_external.h"

#define	MAX_LINE_LEN 128

/*
 * ant_get_int --
 *
 * Nothing subtle here.  Consumes an entire line of input,
 * but that line better not be too long or the function will
 * reject it!
 */

int ant_get_int (int *status, int base)
{
	unsigned int i;
	long int val;
	char buf [MAX_LINE_LEN];
	char *end_ptr;
	int dummy;

	if (status == NULL) {
		status = &dummy;
	}

	/*
	 * If we've run out of input, complain.
	 */

	if (NULL == fgets (buf, MAX_LINE_LEN, stdin)) {
		*status = 1;
		return (0);
	}

	/*
	 * If the line is empty or too long, then complain.
	 */

	if ((strlen (buf) == 0) || (buf [strlen (buf) - 1] != '\n')) {
		*status = 2;
		return (0);
	}

	val = strtol (buf, &end_ptr, base);

	/*
	 * check for any trailing junk.
	 */

	for (i = 0; i < strlen (end_ptr); i++) {
		if (!isspace ((unsigned) end_ptr [i])) {
			*status = 3;
			return (0);
		}
	}

	/*
	 * we were lucky and everything worked...
	 */

	*status = 0;
	return (val);
}

void show_version (char *progname)
{
        char *ant_build_version = strdup (ANT_LIB_VERSION);


        printf ("%s: %s\n", progname, ant_build_version);

        return ;
}

/*
 * end of ant_sys.c
 */
