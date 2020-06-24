/*
 * $Id: ant_backpatch.c,v 1.12 2002/01/02 02:30:23 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96
 * James Megquier -- 11/09/96
 *
 * ant_asm_backpatch.c --
 *
 */
 
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant_internal.h"

	/* Labels we know the address of, and those we don't */

ant_symtab_t *knownList		= NULL;
ant_symtab_t *unknownInstList	= NULL;
ant_symtab_t *unknownDataList	= NULL;

int do_patch (char *memory, unsigned int index, unsigned int size,
		int val);
int ant_backpatch (char *memory, ant_symtab_t *syms, int offset, int mode);

#ifdef	COMMENT
int OLD_ant_asm_backpatch (char *instTable, char *dataTable)
{
	ant_inst_t s;
	llist_t *curr;
	int val;

	/*
	 * Backpatching the instructions and the data is a little
	 * different in ANT-8, because the instructions are 16-bits
	 * and the data is 8-bits.  (otherwise, we could use the same
	 * code to backpatch both)
	 */

	for (curr = unknownInstList; curr != NULL; curr = curr->next) {
		if (find_symbol (knownList, curr->string, &val)) {
			sprintf (AntErrorStr, "undefined symbol: [$%s]",
					curr->string);
			return (1);
		}
		s = instTable[curr->value];

#ifdef	IS_BIG_ENDIAN
		s = PUT_BYTE(s, val, 0);
#else	/* Not IS_BIG_ENDIAN */
		s = PUT_BYTE(s, val, 1);
#endif	/* IS_BIG_ENDIAN */

		instTable[curr->value] = s;

	}

	for (curr = unknownDataList; curr != NULL; curr = curr->next) {
		if (find_symbol (knownList, curr->string, &val)) {
			sprintf (AntErrorStr, "undefined symbol: [$%s]",
					curr->string);
			return (1);
		}
		dataTable[curr->value] = val;
	}

	return(0);
}
#endif	/* COMMENT */

int ant8_asm_backpatch (char *instTable, char *dataTable)
{
	int rc;

	rc = ant_backpatch (instTable, unknownInstList, 1, PATCH_BYTE);
	if (rc != 0) {
		return (rc);
	}

	rc = ant_backpatch (dataTable, unknownDataList, 0, PATCH_BYTE);
	if (rc != 0) {
		return (rc);
	}

	return(0);
}

int ant_backpatch (char *memory, ant_symtab_t *syms, int offset, int mode)
{
	llist_t *curr;
	unsigned int size;
	int val;

	/*
	 * &&& This sizing is SLOPPY!  Not well parameterized.
	 */
	switch (mode) {
		case PATCH_BYTE		:
			size = 1;
			break;
		case PATCH_HWORD	:
			size = 2;
			break;
		case PATCH_WORD		:
			size = 4;
			break;
		case PATCH2_HWORD	:
			size = 2;
			break;
		default			:
			ANT_ASSERT (0);
			break;
	}

	for (curr = syms; curr != NULL; curr = curr->next) {
		if (find_symbol (knownList, curr->string, &val)) {
			sprintf (AntErrorStr, "undefined symbol: [$%s]",
					curr->string);
			return (1);
		}
		else {
			do_patch (memory, curr->value + offset, size, val);
		}
	}

	return (0);
}

int do_patch (char *memory, unsigned int index, unsigned int size, int val)
{
	int bytes [4];

	bytes [0] = (val >> 0x00) & 0xff;
	bytes [1] = (val >> 0x08) & 0xff;
	bytes [2] = (val >> 0x10) & 0xff;
	bytes [3] = (val >> 0x18) & 0xff;

	/*
	 * I think the shifting and masking does away with the need to
	 * worry about further byte-ordering problems.  Of course,
	 * this is just an accident waiting to happen...
	 */

#ifdef	IS_BIG_ENDIAN
#else	/* Not IS_BIG_ENDIAN */
#endif	/* IS_BIG_ENDIAN */

	switch (size) {
		case 4 :
			memory [index + 0] = bytes [3];
			memory [index + 1] = bytes [2];
			memory [index + 2] = bytes [1];
			memory [index + 3] = bytes [0];
			break;
		case 2 :
			memory [index + 0] = bytes [1];
			memory [index + 1] = bytes [0];
			break;
		case 1 :
			memory [index + 0] = bytes [0];
			break;
		default :
			ANT_ASSERT (0);
	}

	return (0);
}


/*
 * end of backpatch.c
 */
