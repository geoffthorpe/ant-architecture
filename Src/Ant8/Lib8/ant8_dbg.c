/*
 * $Id: ant8_dbg.c,v 1.8 2002/06/27 17:30:01 ellard Exp $
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

#include        "ant8_external.h"
#include        "ant8_internal.h"

#include	"ant_external.h"

int		ant_exec_dbg (ant_t *ant, ant_dbg_bp_t *dbg, int trace);
int		ant_exec_inst_dbg (ant_t *ant, ant_dbg_bp_t *dbg, int trace);
ant_symtab_t	*labelTable	= NULL;

static int	Interrupted = 0;

void ant8_dbg_intr (int val)
{
	Interrupted = val;

	return ;
}

int		ant_exec_dbg (ant_t *ant, ant_dbg_bp_t *dbg, int trace)
{
	int rc;

	Interrupted = 0;

	for (;;) {
		rc = ant_exec_inst_dbg (ant, dbg, trace);
		if (rc != 0) {
			if (ant_get_status () == STATUS_INPUT) {
				printf ("I want input\n");
			}
			else {
				break;
			}
		}
	}

	return (rc);
}

int ant_exec_inst_dbg (ant_t *ant, ant_dbg_bp_t *dbg, int trace)
{
	int rc;
	int pc = ant->pc;
	ant_inst_t inst;
	char buf [1024];
	int addr, oval, nval;

	if (trace) {
		printf ("\t");
		inst = ant_fetch_instruction (ant, ant->pc);
		ant_disasm_inst (inst, ant->pc, ant->reg, buf, 1);
		printf ("%s\n", buf);
	}

	if (Interrupted) {
		printf ("INTERRUPTED at (0x%x).\n", pc);
		return (1);
	}

	rc = ant_exec_inst (ant, NULL, NULL, stdout);
	if (rc > 0) {
		if (ant_get_status () == STATUS_HALT) {
			printf ("HALTED at (0x%x)\n", pc);
		}
		else {
			printf ("PC = 0x%x, Status = %s\n",
					pc, ant_get_status_str ());
		}
		return (1);
	}
	else if (rc < 0) {
		return (-1);
	}

	rc = 0;

	/*
	 * If we hit a breakpoint and a watchpoint at the same time,
	 * then announce both of them.
	 */

	if (dbg->breakpoints [ant->pc] != 0) {
		printf ("BREAKPOINT at (0x%x).\n", ant->pc);
		rc = 1;
	}

	if ((addr = ant8_wp_cycle (ant, &oval, &nval)) >= 0) {
		printf ("WATCHPOINT at (0x%x) changed from 0x%x to 0x%x.\n",
				addr, LOWER_BYTE (oval), LOWER_BYTE (nval));
		rc = 1;
	}

	return (rc);
}

int ant_load_dbg (char *filename, ant_t *ant, ant_symtab_t **table)
{
	int rc;

	rc = ant_load_text (filename, ant);
	if (rc) {
		return (-1);
	}

	if (ant_load_labels (filename, table)) {
		return (-1);
	}

	return (0);
}

void ant_dbg_clear_bp (ant_dbg_bp_t *a)
{
	int i;

	for (i = 0; i < ANT_INST_ADDR_RANGE; i++) {
		ant8_dbg_bp_set (a, i, 0);
	}

	return ;
}

void ant8_dbg_bp_set (ant_dbg_bp_t *b, int offset, int val)
{

	if ((offset >= 0) && (offset < ANT_INST_ADDR_RANGE)) {
		b->breakpoints [offset] = val;
	}               
	else {
		printf ("Illegal offset.\n");
	}
}

/*
 * end of ant8_dbg.c
 */
