#ifndef	_ANT32_MMU_H_
#define _ANT32_MMU_H_

/*
 * $Id: ant32_mmu.h,v 1.4 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/05/99
 *
 * ant32_mmu.h -- MMU emulation for the VM.
 *
 * &&& This is just a sketch, not a complete implementation.
 */

/*
 * Bit fields within a virtual address:
 *
 * &&& These are all hardwired, and mutually dependent.  If you change
 * *anything*, you might have to change nearly *everything*.
 */

#define	ANT_MMU_SEG_BITS	2
#define	ANT_MMU_SEG_MASK	0xc0000000
#define	ANT_MMU_GET_SEGMENT(x)	((((x) & ANT_MMU_SEG_MASK) >> 30) & 0x3)

#define	ANT_MMU_PAGE_BITS	18
#define	ANT_MMU_PAGE_MASK	0x3ffff000
#define	ANT_MMU_GET_PAGE(x)	((((x) & ANT_MMU_PAGE_MASK) >> 12) & 0x3ffff)

#define	ANT_MMU_OFFSET_BITS	12
#define	ANT_MMU_OFFSET_MASK	0x00000fff
#define	ANT_MMU_GET_OFFSET(x)	((x) & ANT_MMU_OFFSET_MASK)
#define	ANT_MMU_PAGE_SIZE	(1 << ANT_MMU_OFFSET_BITS)

#define	ANT_MMU_SEG_USER		0
#define	ANT_MMU_SEG_SUP_MAP		1
#define	ANT_MMU_SEG_SUP_NOMAP		2
#define	ANT_MMU_SEG_SUP_NOMAP_NOCACHE	3

#define	ANT_MMU_INVALID_BIT	(1 << 0x0)
#define	ANT_MMU_READ_BIT	(1 << 0x1)
#define	ANT_MMU_WRITE_BIT	(1 << 0x2)
#define	ANT_MMU_EXEC_BIT	(1 << 0x3)

#define	ANT_PTE_INVALID(par)	((par) & ANT_MMU_INVALID_BIT)
#define	ANT_PTE_READ(par)	((par) & ANT_MMU_READ_BIT)
#define	ANT_PTE_WRITE(par)	((par) & ANT_MMU_WRITE_BIT)
#define	ANT_PTE_EXEC(par)	((par) & ANT_MMU_MAP_BIT)

typedef	enum	{
	ANT_MMU_OK		= 0x0,		/* No problems... */
	ANT_MMU_SEG_ILL		= 0x1,		/* Illegal seg in user mode. */
	ANT_MMU_SEG_EXTENT	= 0x2,		/* Illegal extent in segment. */
	ANT_MMU_SEG_INV		= 0x4,		/* Invalid segment. */
	ANT_MMU_SEG_READ	= 0x8,		/* No read permission. */
	ANT_MMU_SEG_WRITE	= 0x10,		/* No write permission. */
	ANT_MMU_SEG_EXEC	= 0x20,		/* No fetch permission. */
	ANT_MMU_PAGE_INV	= 0x40,		/* Invalid page. */
	ANT_MMU_PAGE_READ	= 0x80,		/* Invalid page. */
	ANT_MMU_PAGE_WRITE	= 0x100,	/* Invalid page. */
	ANT_MMU_PAGE_EXEC	= 0x200		/* Invalid page. */
} ant32_mmu_fault_t;

ant_addr_t	ant32_v2p (ant_addr_t v, ant_tlb_t *tlb,
			ant_exec_mode_t run_mode,
			unsigned int access_mode,
			ant32_mmu_fault_t *fault);
int		ant32_find_tlb_entry (ant_tlb_t *tlb,
			unsigned int seg, unsigned int vpn);
int		ant32_vaddr_split (ant_addr_t v, unsigned int *seg,
			unsigned int *vpn, unsigned int *po);
int		ant32_tlb_init (ant_tlb_t *tlb);


/*
 * end of ant32_mmu.c
 */

#endif	/* _ANT32_MMU_H_ */
