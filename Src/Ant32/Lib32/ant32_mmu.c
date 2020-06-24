/*
 * $Id: ant32_mmu.c,v 1.19 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/05/99
 *
 * ant32_mmu.c -- MMU emulation for the VM.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include	"ant_external.h"
#include	"ant32_external.h"

/*
 * Translate a virtual address into a physical address, or indicate
 * that a fault has occured because an invalid address has been
 * specified.  If there is a fault, then the return value is -1 and
 * fault is set to the exception that caused the mapping from virtual
 * to physical failed.  (Because the Ant32 physical address space is
 * only 30 bits, there is no address corresponding to -1.) If there is
 * no fault, fault is set to ANT_EXC_OK.
 *
 * The mode represents what permission is necessary on the segment and
 * page (i.e.  reading or writing).
 */

ant_paddr_t ant32_v2p (ant_vaddr_t v, ant_t *ant,
			ant_exec_mode_t run_mode, unsigned int access_mode,
			ant_exc_t *fault, int update_e2)
{
	unsigned int seg, vpn, po;
	ant_addr_t paddr; 
	ant_addr_t phys_page;
	int index;
	int cached;

	ANT_ASSERT (fault != NULL);

	*fault = ANT_EXC_OK;

	ant32_vaddr_split (v, &seg, &vpn, &po);

	/*
	 * If appropriate, update register e2, in case there's a fault
	 * later.  This isn't always done because sometimes (for
	 * example, in the debugger), we want to be able to ``look''
	 * at addresses without modifying the state of the machine at
	 * all.
	 */

	if (update_e2 && (ant->exc_disable == 0)) {
		ant->reg [EXC_REG_2] = v;
	}

	if ((run_mode == ANT_USER_MODE) && (seg != ANT_MMU_SEG_USER)) {
		*fault = ANT_EXC_PRIV_SEG;
		return (-1);
	}

	if ((seg == ANT_MMU_SEG_SUP_NOMAP) ||
			(seg == ANT_MMU_SEG_SUP_NOMAP_NOCACHE)) {
		paddr = v & (ANT_MMU_PAGE_MASK | ANT_MMU_OFFSET_MASK);
		cached = 1;
		return (paddr);
	}


	index = ant32_find_tlb_entry (ant->tlb, ant->params.n_tlb, seg, vpn,
			fault);
	if (index < 0) {
		return (-1);
	}

	/*
	 * Check to make sure that attr permits the requested
	 * operation.
	 */

	if ((ANT_TLB_ATTR (ant->tlb [index]) & access_mode) != access_mode) {
		*fault = ANT_EXC_TLB_PROT;
		return (-1);
	}

	/*
	 * At one point, there was a notion that the TLB entries would
	 * also contain additional information about the status of
	 * each mapped page (dirty, read, etc).  Only the dirty bit
	 * remains.  If anything else gets added back in, this is
	 * where it should go.
	 */

	switch (access_mode) {
		case ANT_MMU_WRITE_BIT:
			/* &&& NOT CLEAN */
			ant->tlb [index].upper |= ANT_MMU_DIRTY_BIT;
			break;

		case ANT_MMU_READ_BIT:
			break;
		case ANT_MMU_EXEC_BIT:
			break;
		default:
			break;
	}

	*fault = ANT_EXC_OK;

	phys_page = ANT_TLB_PHYS_PN (ant->tlb [index]) << 12;
	return (phys_page | po);
}

/*
 * Nothing complicated here-- just boilerplate.
 */

int ant32_vaddr_split (ant_addr_t v, unsigned int *seg,
		unsigned int *vpn, unsigned int *po)
{

	if (seg != NULL) {
		*seg = ANT_MMU_GET_SEGMENT (v);
	}

	if (vpn != NULL) {
		*vpn = ANT_MMU_GET_PAGE (v);
	}

	if (po != NULL) {
		*po = ANT_MMU_GET_OFFSET (v);
	}

	return (ANT_MMU_GET_OFFSET (v));
}

int ant32_find_tlb_entry (ant_tlbe_t *tlb, int n_tlbe,
		unsigned int seg, unsigned int vpn, ant_exc_t *fault)
{
	ant_tlbe_t e;
	int tlb_index = -1;
	int i;

	/*
	 * If this isn't a segment that gets mapped through the TLB,
	 * then give up right away.
	 *
	 * Perhaps it would be useful to flag this error as a special
	 * case-- but really, this is something that should never
	 * happen anyway.
	 */

	if (seg != ANT_MMU_SEG_USER && seg != ANT_MMU_SEG_SUP_MAP) {
		return (-1);
	}

	/*
	 * Look through the table for the entry...
	 */

	for (i = 0; i < n_tlbe; i++) {
		e = tlb [i];

		if (((ANT_TLB_ATTR (e) & ANT_MMU_VALID_BIT) != 0) && 
				(ANT_TLB_VIRT_PN (e) == vpn) &&
				(ANT_TLB_VIRT_SEG (e) == seg)) {
			tlb_index = i;
			break;
		}
	}

	/*
	 * Then keep looking to make sure that there aren't any other
	 * valid entries for this SEG/VPN.  It's an exception if there
	 * is.
	 */

	for (i++ ; i < n_tlbe; i++) {
		e = tlb [i];

		if (((ANT_TLB_ATTR (e) & ANT_MMU_VALID_BIT) != 0) && 
				(ANT_TLB_VIRT_PN (e) == vpn) &&
				(ANT_TLB_VIRT_SEG (e) == seg)) {
			if (fault != NULL) {
				*fault = ANT_EXC_TLB_MULTI;
			}
			return (-1);
		}
	}

	if (tlb_index < 0) {
		if (fault != NULL) {
			*fault = ANT_EXC_TLB_MISS;
		}
	}

	return (tlb_index);
}

/*
 * Initialize the TLB.
 *
 * It's not required by the spec that we zero everything, just as long
 * as we make sure that the VALID bit is clear, but it's just as easy
 * to wipe it all.
 */

int ant32_tlb_init (ant_tlbe_t *tlb, int n_tlbe)
{
	int i;

	ANT_ASSERT (n_tlbe <= ANT_MAX_TLB_ENTRIES);

	for (i = 0; i < n_tlbe; i++) {
		tlb [i].upper = 0;
		tlb [i].lower = 0;
	}

	return (0);
}

/*
 * end of ant32_mmu.c
 */
