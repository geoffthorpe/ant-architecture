/*
 * $Id: ant8_symtab.c,v 1.6 2001/12/16 19:35:13 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 07/19/99
 *
 * ant8_symtab.c --
 *
 */
 
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

void symtab2array (ant_symtab_t *symtab, char *array [ANT_DATA_ADDR_RANGE])
{
	int i;

	for (i = 0; i < ANT_DATA_ADDR_RANGE; i++) {
		array [i] = NULL;
	}

	while (symtab != NULL) {
		if ((symtab->value < 0) ||
				(symtab->value > ANT_DATA_ADDR_RANGE)) {
			printf ("BAD VALUE RANGE in symtab2array\n");
			return ;
		}
		array [symtab->value] = strdup (symtab->string);
		symtab = symtab->next;
	}

	return ;
}

void free_label_array (char *array [ANT_DATA_ADDR_RANGE])
{
	int i;

	for (i = 0; i < ANT_DATA_ADDR_RANGE; i++) {
		if (array [i] != NULL) {
			free (array [i]);
			array [i] = NULL;
		}
	}

	return ;
}

/*
 * This needs to be completely reworked for ANT-32
 */

int dump8_symtab_human (ant_symtab_t *table, char *buf)
{
	llist_t *l;

	buf [0] = '\0';

	for (l = table; l != NULL; l = l->next) {
		sprintf (buf + strlen (buf), "\t");
		ant_print_value_str (buf + strlen (buf),
				l->value, l->string);
		sprintf (buf + strlen (buf), "\n");
	}

	return (0);
}

/*
 * This needs to be completely reworked for ANT-32
 */

int dump8_symtab_machine (ant_symtab_t *table, FILE *stream)
{
	llist_t *l;

	for (l = table; l != NULL; l = l->next) {
		fprintf (stream, "# $%-12s = %4d (0x%x)\n",
				l->string, l->value, LOWER_BYTE (l->value));
	}

	return (0);
}

/*
 * end of ant8_symtab.c
 */
