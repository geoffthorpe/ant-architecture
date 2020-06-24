/*
 * $Id: llist.c,v 1.7 2002/01/02 02:30:23 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * llist.c --
 */ 

#include	<stdlib.h>
#include	<string.h>
#include	<stdio.h>

#include	"ant_external.h"
#include	"ant_internal.h"

llist_t		*llist_create(char *string, int value, int type, 
						  ant_jumpmode_t jumpmode)
{
	llist_t	*new	= (llist_t *) malloc(sizeof(llist_t));

	if (new == NULL) {
		printf("llist_create: Out of memory!\n");
		exit(1);
	} else {
		new->next = NULL;
		new->prev = NULL;
		new->string = string;
		new->value = value;
		new->type = type;
		new->jumpmode = jumpmode;
	}

	return new;
}

/* 
 * llist_destroy --
 * 
 * Frees the memory taken up by a linked list cell.
 *
 * Note that free() deals with NULL pointers, so we don't have to!
 */

void		llist_destroy(llist_t *cell)
{
	free(cell);

	return ;
}

llist_t		*llist_insert(llist_t *cell, char *string, int value, int type, 
						  ant_jumpmode_t jumpmode)
{
	llist_t	*new	= llist_create(string, value, type, jumpmode);

	if (cell != NULL) {
		new->next	= cell;
		new->prev	= cell->prev;
		cell->prev	= new;
		if (new->prev != NULL) {
			new->prev->next = new;
		}
	}

	return new;
}

llist_t		*llist_lookup_str(llist_t *cell, char *string)
{

	while ((cell != NULL) && (strcmp(cell->string, string) != 0)) {
		cell = cell->next;
	}

	return cell;
}

llist_t		*llist_lookup_val (llist_t *cell, int value)
{

	while ((cell != NULL) && (cell->value != value)) {
		cell = cell->next;
	}

	return cell;
}

llist_t		*llist_delete(llist_t *cell, llist_t *dead)
{
	if (dead == NULL) {
		return cell;
	}
	else {
		llist_t	*return_cell;

		if (dead->prev != NULL) {
			dead->prev->next = dead->next;
		}
		if (dead->next != NULL) {
			dead->next->prev = dead->prev;
		}

		if (dead != cell) {
			return_cell = cell;
		}
		else {
			return_cell = (dead->prev == NULL) ?
					dead->next : dead->prev;
		}

		llist_destroy(dead);

		return return_cell;
	}
}

/*
 * end of llist.c
 */
