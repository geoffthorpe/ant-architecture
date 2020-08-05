/*
 * $Id: ant32_symtab.c,v 1.6 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 05/24/2000
 *
 * ant32_symtab.c --
 *
 */
 
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant32_external.h"

static unsigned long absorb_unused;

void symtab2array (ant_symtab_t *symtab, char **array)
{
	absorb_unused += (unsigned long)symtab;
	absorb_unused += (unsigned long)array;

	return ;
}

void free_label_array (char **array)
{
	absorb_unused += (unsigned long)array;

	return ;
}

char *dump32_symtab_human (ant_symtab_t *table, int all)
{
	llist_t *l;
	unsigned int len = 0;
	char *str, *ptr;

	for (l = table; l != NULL; l = l->next) {

		/*
		 * For each symbol, we need a certain amount of room
		 * for the value, and an unknown amount for the name. 
		 * I'm being very generous here, because I'm in a
		 * hurry.
		 *
		 * &&& This could be reduced.
		 */

		len += 80 + strlen (l->string);
	}

	ptr = str = malloc (len * sizeof (char));

	if (str == NULL) {
		return (NULL);
	}

	for (l = table; l != NULL; l = l->next) {
		unsigned int uval = (unsigned) l->value;

		if (all || (uval < 0x80400000)) {
			sprintf (ptr, "\t0x%.8x = %11d = $%s\n",
					l->value, l->value, l->string);
			ptr += strlen (ptr);
		}
	}

	return (str);
}

int dump32_symtab_machine (ant_symtab_t *table, FILE *stream)
{
	llist_t *l;

	for (l = table; l != NULL; l = l->next) {
		fprintf (stream, "# $%-24s = %11d (0x%.8x)\n",
				l->string,
				LOWER_WORD (l->value),
				LOWER_WORD (l->value));
	}

	return (0);
}

/*
 * ant32_symtab.c
 */
