/*
 * $Id: ant32_boot.c,v 1.8 2002/01/02 02:29:17 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 12/21/00
 *
 * ant32_boot.c -- boot and reset functions for the VM.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include	"ant_external.h"
#include	"ant32_external.h"

/*
 * ant_reset --
 *
 * Resets (reinitializes) the CPU state but does not touch memory in
 * any way.
 *
 * NOTE:  ant->eh is untouched by a reset; its value is undefined
 * after a reset.  (Why, I'm not sure, but someone argued that this
 * was the right behavior.)
 */

int ant_reset (ant_t *ant)
{
	int i;
	int fault;

	ant->mode = ANT_SUPER_MODE;

	ant->exc_disable = 1;
	ant->int_disable = 1;

	/*
	 * Invalidate all the TLB entries.
	 *
	 * Note that according to the spec, all that we really need to
	 * do is mark the entries as invalid.  We don't need to
	 * actually zero them out.  Perhaps there's some reason for
	 * this, but for now I zero them...
	 */

	ant32_tlb_init (ant->tlb, ant->params.n_tlb);

	/*
	 * Blow away ALL the registers.  This takes care of all of the
	 * cycle counters, kernel, and exception handling registers.
	 *
	 * Save this for last, just in case any of the other
	 * activities of resetting the CPU has some side effect on the
	 * cycle counters or whatnot.
	 */

	for (i = 0; i < ANT_REG_RANGE; i++) {
		ant->reg [i] = 0;
	}

	/*
	 * The timer is turned off.
	 */

	ant->timer_set = 0;
	ant->timer = 0;

	/*
	 * Pending console I/O, if any, is discarded.
	 */

	ant->console.out_new = 0;
	ant->console.in_new = 0;

	/*
	 * If we can't read the exception handling vector, that's
	 * disasterous.
	 */

	fault = do_load_store (sizeof (ant_reg_t), ANT_MEM_READ,
			ant, (ant_vaddr_t) ANT_RESET_PC_ADDR, &ant->pc, 0);
	if (fault != 0) {
		printf ("ERROR: Cannot load PC from %x.\n", ANT_RESET_PC_ADDR);
		return (-1);
	}

	return (0);
}

/*
 * end of ant32_boot.c
 */
