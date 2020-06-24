/*
 * $Id: ant32_code.c,v 1.5 2002/01/02 02:29:17 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 11/08/01
 *
 * ant32_code.c -- Keeps track of what the original text is for each
 * instruction loaded into the VM.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include	"ant_external.h"
#include	"ant32_external.h"

/*
 * NB:  I'm going to assume that nobody writes more than a few pages
 * of code, and so this mapping is usually one-to-one or at most
 * uniformly dense (not counting the bootstrap code, which is a pain
 * in the neck).  This hash scheme falls flat on its face if code
 * distribution is not uniform, or there's more than a few dozen pages
 * of code.
 */

#define	CODE_HASH_TSIZE		(8 * ANT_MMU_PAGE_SIZE)

typedef	struct _code_cell_t {
	struct _code_cell_t *next;
	unsigned int addr;
	ant32_lcode_t lcode;
	char *code;
} code_cell_t;

static code_cell_t *codeHash [CODE_HASH_TSIZE];

/*
 * line_insert -- creates a binding between addr and a line of code. 
 * Assumes that addr is properly aligned.  Makes a fresh copy of the
 * line, so the caller can destroy the original.  It is possible to
 * insert NULLs, if desired.
 */

int ant32_code_line_insert (unsigned int addr, char *line, ant32_lcode_t lcode)
{
	unsigned int bucket;
	code_cell_t *cell;

	if (line != NULL) {
		line = strdup (line);
		ANT_ASSERT (line != NULL);
	}

	bucket = addr % CODE_HASH_TSIZE;
	cell = codeHash [bucket];

	while ((cell != NULL) && (cell->addr != addr)) {
		cell = cell->next;
	}

	if (cell != NULL) {
		if (cell->code != NULL) {
			free (cell->code);
		}
		cell->code = line;
		cell->lcode = lcode;
	}
	else {
		code_cell_t *new;
		
		new = (code_cell_t *) malloc (sizeof (code_cell_t));
		ANT_ASSERT (new != NULL);

		new->next = codeHash [bucket];
		new->code = line;
		new->addr = addr;
		new->lcode = lcode;

		codeHash [bucket] = new;
	}

	return (0);
}

char *ant32_code_line_lookup (unsigned int addr, ant32_lcode_t *lcode)
{
	unsigned int bucket;
	code_cell_t *cell;

	bucket = addr % CODE_HASH_TSIZE;
	cell = codeHash [bucket];

	while ((cell != NULL) && (cell->addr != addr)) {
		cell = cell->next;
	}

	if (cell != NULL) {
		if (lcode != NULL) {
			*lcode = cell->lcode;
		}
		return (cell->code);
	}
	else {
		if (lcode != NULL) {
			*lcode = UNKNOWN;
		}
		return (NULL);
	}
}

void ant32_code_init (void)
{
	unsigned int bucket;
	code_cell_t *cell, *next;

	for (bucket = 0; bucket < CODE_HASH_TSIZE; bucket++) {
		cell = codeHash [bucket];

		while (cell != NULL) {
			if (cell->code != NULL) {
				free (cell->code);
			}
			next = cell->next;
			free (cell);
			cell = next;
		}

		codeHash [bucket] = NULL;

	}
}

/*
 * end of ant32_code.c
 */
