/*
 * $Id: ant32_vm.c,v 1.22 2003/01/23 03:26:34 sara Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_vm.c -- utility functions for the VM.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include	"ant_external.h"
#include	"ant32_external.h"

ant_param_t	AntParameters	= {
	ANT_MIN_N_REG,
	ANT_MIN_N_TLB,
	(4 * 1024 * 1024) / ANT_MMU_PAGE_SIZE,
	(16 * 1024) / ANT_MMU_PAGE_SIZE
};

/*
 * ant_check_params -- sanity check the parameters, printing
 * error messages and returning -1 if they're bogus, 0 if plausible.
 */

int ant_check_params (ant_param_t *params)
{

	if (params->n_reg < ANT_MIN_N_REG) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "Too few registers (< %d) requested.\n",
				ANT_MIN_N_REG);
		return (-1);
	}
	if (params->n_reg > ANT_MAX_N_REG) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "Too many registers (> %d) requested.\n",
				ANT_MAX_N_REG);
		return (-1);
	}
	if (params->n_tlb < ANT_MIN_N_TLB) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "Too few TLB entries (< %d) requested.\n",
				ANT_MIN_N_TLB);
		return (-1);
	}
	if (params->n_tlb > ANT_MAX_N_TLB) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "Too many TLB entries (> %d) requested.\n",
				ANT_MAX_N_TLB);
		return (-1);
	}
	if (params->n_pages < 1) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "Not enough RAM to execute.\n");
		return (-1);
	}
	if (params->n_pages > (1 << 18)) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "Too much RAM requested.\n");
		return (-1);
	}
	if (params->n_rom_pages < 1) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "There must be at least one ROM page.\n");
		return (-1);
	}

	if (params->n_rom_pages + params->n_pages > (1 << 18)) {
		fprintf (stderr, "ERROR: ");
		fprintf (stderr, "RAM + ROM size is larger than the address space!\n");
		return (-1);
	}


	return (0);
}

/*
 * ant_create -- create a fresh new ant, using the given parameters.
 */

ant_t *ant_create (ant_param_t *params)
{
	ant_t *ant;
	ant_mblk_t *blk;
	unsigned long blk_size;

	/*
	 * This check should be redundant, but it never hurts
	 * to be really sure.
	 */

	if (ant_check_params (params) != 0) {
		return (NULL);
	}

	ant = malloc (sizeof (ant_t));
	ANT_ASSERT (ant != NULL);

	ant->pmem = NULL;

	blk = ant32_make_mblk (0, ANT_MMU_PAGE_SIZE * params->n_pages,
			ANT_MEM_WRITE | ANT_MEM_READ, NULL);
	ANT_ASSERT (blk != NULL);
	ant->pmem = ant32_add_mblk (blk, ant->pmem);
	ANT_ASSERT (ant->pmem != NULL);

	/*
	 * There always needs to be at least one page of "ROM" at the
	 * end of memory, to store the boot vector.  Optionally, we
	 * can have more.
	 */

	if (params->n_rom_pages == 0) {
		params->n_rom_pages = 1;
	}

	blk_size = ANT_MMU_PAGE_SIZE * params->n_rom_pages;

	blk = ant32_make_mblk (0x40000000 - blk_size, blk_size,
			ANT_MEM_WRITE | ANT_MEM_READ, NULL);
	ANT_ASSERT (blk != NULL);
	ant->pmem = ant32_add_mblk (blk, ant->pmem);
	ANT_ASSERT (ant->pmem != NULL);

	/*
	 * Fill in the rest of the parameters...
	 */

	ant->params.n_reg	= params->n_reg;
	ant->params.n_tlb	= params->n_tlb;

	ant->timer		= 0;
	ant->timer_set		= 0;

	/*
	 * By default, console i/o is done via stdio.  This is fine
	 * for ant32 and ad32, but for aide32 these defaults need to
	 * be overridden.
	 */

	ant->console.in		= stdin;
	ant->console.in_new	= 0;
	ant->console.out	= stdout;
	ant->console.out_new	= 0;

	return (ant);
}

int ant32_cout (ant_t *ant, int val)
{

	/*
	 * If using FILEs, just pump the char out.  Otherwise,
	 * simulate placing the char into an output buffer and
	 * indicating that the buffer has something to read in it. 
	 * This is done without checking, because sometimes there will
	 * be something to check it (i.e.  aide32) and sometimes there
	 * won't be.  For now, we'll just assume that putting the char
	 * in out_val is all that is necessary.
	 *
	 * &&& For now, we always do output both ways (if possible),
	 * for debugging purposes. 
	 */

	if (ant->console.out != NULL) {
		fprintf (ant->console.out, "%c", LOWER_BYTE (val));
		fflush (ant->console.out);
	}

	ant->console.out_val = LOWER_BYTE (val);
	ant->console.out_new = 1;

	return (0);
}

int ant32_cin (ant_t *ant, ant_reg_t *val)
{

	/*
	 * Note that if using STDIN, input is "synchronous", but
	 * otherwise if there isn't anything new to read, then
	 * immediately return non-zero (to give the VM a chance to do
	 * something else, which might result in there be something to
	 * read in the future).
	 */

	if (ant->console.in != NULL) {
		*val = getc (ant->console.in);
		return (0);
	}
	else {
		if (ant->console.in_new) {
			*val = LOWER_BYTE (ant->console.in_val);
			ant->console.in_new = 0;
			return (0);
		}
		else {
			return (1);
		}
	}
}

/*
 * end of ant32_vm.c
 */
