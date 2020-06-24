/*
 * $Id: ant32_dbg.c,v 1.14 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 07/21/99
 *
 * ant_dbg.c --
 *
 */

#include	<stdio.h>
#include	<signal.h>
#include	<string.h>
#include	<stdlib.h>

#include        "ant32_external.h"
#include	"ant_external.h"

ant_symtab_t	*labelTable	= NULL;

static int	Interrupted = 0;

void ant32_dbg_intr (int val)
{
	Interrupted = val;

	return ;
}

int ant_exec_dbg (ant_t *ant, int trace, int surface)
{
	int rc;

	Interrupted = 0;

	/* &&& This code is WAY too similar to the code in ant_exec. 
	 * These two functions should be unified to some extent.
	 */

	for (;;) {
		while ((rc = ant_exec_inst_dbg (ant, trace, surface)) == ANT_EXC_OK)
			;

		if (rc != ANT_EXC_OK) {
			return (ant_exec_dbg_exc (ant, rc));
		}
	}

	return (rc);
}

int ant_exec_dbg_exc (ant_t *ant, ant_exc_t rc)
{

	switch (rc) {
		case ANT_EXC_OK :
			/* hmmm... */
			break;

		case ANT_EXC_USER_INT :
			printf ("INTERRUPTED (by user) at (0x%.8x).\n",
					ant->pc);
			return (0);
			break;

		case ANT_EXC_BREAK :
			printf ("BREAKPOINT at (0x%.8x)\n", ant->pc);
			return (0);
			break;

		case ANT_EXC_HALT :
			printf ("HALTED at (0x%.8x)\n", ant->pc);
			return (0);
			break;

		case ANT_EXC_IDLE :
			/* &&& This probably isn't enough */
			printf ("IDLED at (0x%.8x)\n", ant->pc);
			return (0);
			break;

		case ANT_EXC_EXC :
			return (-1);
			break;

		default :
			printf ("rc = %d\n", rc);
			ANT_ASSERT (0);
			return (-1);
			break;
	}

	return (rc);
}

void ant_dbg_show_curr_inst (ant_t *ant, int surface)
{
	char *code;
	ant32_lcode_t lcode;
	ant_inst_t inst;
	ant_exc_t fault;
	char dis_buf [1000];
	char *label = NULL;
	int rc;

	rc = find_value (labelTable, &label, ant->pc);
	if (rc != 0) {
		label = NULL;
	}

	inst = ant32_fetch_inst (ant, ant->pc, &fault, 0);
	code = ant32_code_line_lookup (ant->pc, &lcode);

	if (label != NULL) {
		printf ("%s:\n", label);
	}

	if (surface) {
		if (lcode == LITERAL) {
			printf ("0x%.8x:\t%s\n", ant->pc, code);
		}
		else {
			/* Show nothing at all. */
		}
	}
	else {
		ant_disasm_inst (inst, ant->pc, ant->reg, dis_buf, 1);
		printf ("0x%.8x:\t%s\n", ant->pc, dis_buf);
	}
}

int ant_exec_inst_dbg (ant_t *ant, int trace, int surface)
{
	int rc;
	int pc = ant->pc;
	ant_exc_t fault;

	if (trace) {
		ant_dbg_show_curr_inst (ant, surface);
	}

	if (Interrupted) {
		return (ANT_EXC_USER_INT);
	}

	rc = ant_exec_inst (ant);
	if (rc != ANT_EXC_OK) {
		printf ("PC = 0x%x, Status = %s\n",
				pc, ant_status_desc (rc));
		return (rc);
	}
	else if (ant32_check_breakpoint (ant->pc)) {
		return (ANT_EXC_BREAK);
	}
	else {
		return (ANT_EXC_OK);
	}

}

int ant_load_dbg (char *filename, ant_t *ant, ant_symtab_t **table)
{
	int rc;

	rc = ant_load_text (filename, ant, 1);
	if (rc) {
		return (-1);
	}

	if (ant_load_labels (filename, table)) {
		return (-1);
	}

	return (0);
}

/*
 * A VERY SIMPLE interface.
 *
 * &&& This could stand some improvement, but should suffice for now.
 */

#define	MAX_BREAKPOINTS	16

typedef struct {
	ant_pc_t	pc;
	int		set;
} ant32_bp_t;

static ant32_bp_t breakpoints [MAX_BREAKPOINTS];

int ant32_check_breakpoint (ant_pc_t pc)
{
	unsigned int i;

	for (i = 0; i < MAX_BREAKPOINTS; i++) {
		if (breakpoints [i].set != 0 && pc == breakpoints [i].pc) {
			return (1);
		}
	}

	return (0);
}

int ant32_set_breakpoint (ant_pc_t pc)
{
	unsigned int i;

		/*
		 * If it's already there, don't set it again.
		 */

	for (i = 0; i < MAX_BREAKPOINTS; i++) {
		if (breakpoints [i].set != 0 && pc == breakpoints [i].pc) {
			return (0);
		}
	}

	for (i = 0; i < MAX_BREAKPOINTS; i++) {
		if (breakpoints [i].set == 0) {
			breakpoints [i].set = 1;
			breakpoints [i].pc = pc;
			return (0);
		}
	}

	printf ("ERROR: No more breakpoints available.\n");
	return (1);
}

int ant32_clear_breakpoint (ant_pc_t pc)
{
	unsigned int i;

	for (i = 0; i < MAX_BREAKPOINTS; i++) {
		if (breakpoints [i].set && pc == breakpoints [i].pc) {
			breakpoints [i].set = 0;
			return (0);
		}
	}

	return (1);

}

int ant32_clear_breakpoints (void)
{
	unsigned int i;

	for (i = 0; i < MAX_BREAKPOINTS; i++) {
		breakpoints [i].set = 0;
	}

	return (0);
}

/*
 * end of ant32_dbg.c
 */
