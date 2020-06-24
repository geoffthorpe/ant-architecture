/*
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96
 * James Megquier -- 11/09/96
 * Nick Murphy -- 6/19/01 turned into its own ant32-specific file
 *
 * ant32_backpatch.c --
 *
 */
 
#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant_internal.h"

#include	"ant32_external.h"

//in ant_backpatch.c
extern ant_symtab_t *knownList;
extern ant_symtab_t *unknownInstList;

int ant32_backpatch (char *memory, ant_symtab_t *syms)
{
  llist_t *curr;
  int val;

  for (curr = syms; curr != NULL; curr = curr->next) {
    if (find_symbol (knownList, curr->string, &val)) {
      sprintf (AntErrorStr, "undefined symbol: [$%s]", curr->string);
      return (1);
    } else {
      /* &&& this won't actually work in the case of multi-line pseudo-ops...(d'oh) */
	  if (curr->jumpmode > JUMP_ABS) {
		//remove segment identifier
		val &= ~(((1 << ANT_MMU_SEG_BITS) - 1) << 
				(ANT_VADDR_BITS - ANT_MMU_SEG_BITS));

		//need to round down to beginning of instruction, then adjust for offset
		val -= (curr->value & ~(sizeof(ant_inst_t) - 1)) + 
			   (int)curr->jumpmode * sizeof(ant_inst_t); 
		val /= sizeof(ant_inst_t);
      }
      switch (curr->type) {
      case BYTE0:
        val = (val & 0x00ff);
        break;
      case BYTE1:
        val = (val & 0xff00) >> 8;
        break;
      case BYTE2:
        val = (val & 0x00ff0000) >> 16;
        break;
      case BYTE3:
        val = (val & 0xff000000) >> 24;
        break;
      default:
        break;
      }

    do_patch (memory, curr->value, 1, val);
    }
  }
  return (0);
}

int ant32_asm_backpatch (char *memory)
{
        int rc;

	rc = ant32_backpatch (memory, unknownInstList);
        if (rc != 0) {
		return (rc);
	}

	return(0);
}
