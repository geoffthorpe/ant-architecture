/*
 * $Id: ant_symtab.c,v 1.9 2002/01/09 21:05:40 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 07/19/99
 *
 * ant_symtab.c --
 *
 */

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include        "ant_external.h"
#include        "ant_internal.h"

int add_symbol (ant_symtab_t **table, char *name, int value, char *type)
{

	ANT_ASSERT (table != NULL);

	if (name == NULL) {
		return (1);
	}

	if (llist_lookup_str (*table, name) != NULL) {
		sprintf (AntErrorStr, "%s [%s] defined more than once",
				type, name);
		return (1);
	}
	else {
		/* JUMP_ABS is just a placeholder;
		 * no reason to actually use it here
		 */

		*table = llist_insert (*table, name, value, 0, JUMP_ABS);
		return (0);
	}
}

int del_symbol (ant_symtab_t **table, char *name)
{
	ant_sym_t *s;

	ANT_ASSERT (table != NULL);

	if (name == NULL) {
		return (-1);
	}

	s = llist_lookup_str (*table, name);
	if (s == NULL) {
		return (-1);
	}
	else {
		ant_symtab_t *p;

		/* &&& This depends too much on the exact way that
		 * llist_delete works.  (In fact, this whole file is
		 * pretty much a big hack.)
		 */

		p = llist_delete (*table, s);
		*table = p;

		return (0);
	}
}

int find_symbol (ant_symtab_t *table, char *name, int *value)
{
	ant_sym_t *s;

	ANT_ASSERT (value != NULL);

	if (name == NULL) {
		return (-1);
	}

	s = llist_lookup_str (table, name);
	if (s == NULL) {
		return (-1);
	}
	else {
		*value = s->value;
		return (0);
	}
}

int find_value (ant_symtab_t *table, char **name, int value)
{
	ant_sym_t *s;

	if (table == NULL) {
		return (-1);
	}

	s = llist_lookup_val (table, value);
	if (s == NULL) {
		return (-1);
	}
	else {
		*name = s->string;
		return (0);
	}
}

int add_unresolved (ant_symtab_t **table, char *name, int offset, int type)
{

	ANT_ASSERT (table != NULL);

	*table = llist_insert (*table, name, offset, type, JUMP_ABS);

	return (0);
}

/* NCM
 * function to deal with unresolved labels associated with branches
 */

int add_relative_unresolved (ant_symtab_t **table, char *name, 
		 int offset, int type, ant_jumpmode_t jumpmode)
{
	
	ANT_ASSERT (table != NULL);

	*table = llist_insert (*table, name, offset, type, jumpmode);

	return (0);
}

void clear_symtab (ant_symtab_t *table)
{

	while (table != NULL) {
		table = llist_delete (table, table);
	}
}

/*
 * end of ant_asm_symtab.c
 */

