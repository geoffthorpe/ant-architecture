/*
 * $Id: ant32_pmem.c,v 1.9 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 12/19/00
 *
 * ant32_pmem.c -- emulation of physical memory.
 */

#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>

 	/* Yeccch */
#include	"ant_external.h"
#include	"ant32_external.h"

/*
 * Map an ant physical address to a VM address.  Returns NULL if the
 * mapping fails.
 */

ant_vma_t ant32_p2vm (ant_paddr_t paddr, ant_pmem_t pmem, ant_mem_op_t op)
{
	ant_mblk_t *blk;

	if (op == ANT_MEM_EXEC) {
		op = ANT_MEM_READ;
	}

	for (blk = pmem; blk != NULL; blk = blk->next) {
		if ((paddr >= blk->base) && (paddr < (blk->base + blk->len))) {

			if ((op & blk->type) != op) {
				printf ("permission for op (%x) nuked (%x).\n",
						op, blk->type);
				return (NULL);
			}


			return (blk->mem + (paddr - blk->base));

#ifdef	FOO /* Not IS_BIG_ENDIAN */

			{
				int reverses [4] = { 3, 2, 1, 0 };

				int offset = reverses [paddr % 4];

				return (blk->mem +
						(((paddr & ~3) + offset) -
						blk->base));
			}

#endif	/* IS_BIG_ENDIAN */

		}
	}

	return (NULL);
}

/*
 * Create a new memory block, but don't add it to any lists.
 *
 * No sanity checking is done here, because there are a lot of insane
 * things that people might want to do.  This will need to be resolved
 * in the future.
 */

ant_mblk_t *ant32_make_mblk (ant_paddr_t paddr, int len, int mode,
		void (*cb)(ant_paddr_t paddr))
{
	ant_mblk_t *blk = malloc (sizeof (ant_mblk_t));

	if (blk == NULL) {
		return (NULL);
	}

	blk->mem	= malloc (len * sizeof (char));
	if (blk->mem == NULL) {
		free (blk);
		return (NULL);
	}

	blk->base	= paddr;
	blk->len	= len;
	blk->type	= mode;
	blk->cb		= cb;
	blk->next	= NULL;

		/*
		 * Start with the block zero'd.
		 */

	memset (blk->mem, 0, blk->len);

	return (blk);
}

/*
 * Add the memory block to the given list.  Right now,
 * it is simply inserted at the front of the list.
 */

ant_mblk_t *ant32_add_mblk (ant_mblk_t *blk, ant_mblk_t *head)
{

	blk->next = head;

	return (blk);
}

/*
 * ant_pmem_clear --
 *
 * Zero all the physical memory associated with linked list of pmem
 * blocks.
 *
 * If clear_rom is non-zero, then the contents of any read-only memory
 * are also zero'd.  Deus ex machina.
 */
 
void ant_pmem_clear (ant_pmem_t head, int clear_rom)
{
	ant_mblk_t *b;

	for (b = head; b != NULL; b = b->next) {

		/*
		 * Note that no callbacks associated with the memory
		 * are invoked either.  That would really be a mess. 
		 * The question remains-- who should be responsible
		 * for setting the memory to zero?
		 *
		 * &&& Perhaps resetting the CPU should not touch
		 * device memory.
		 */

		if ((clear_rom != 0) || (b->type | ANT_MEM_WRITE)) {
			memset (b->mem, 0, b->len);
		}
	}
}

/*
 * end of ant32_pmem.c
 */
