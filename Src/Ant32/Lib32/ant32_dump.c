/*
 * $Id: ant32_dump.c,v 1.8 2002/05/06 23:28:38 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 05/23/2000
 *
 * ant_dump.c -- Functions to dump an ant_t structure to file
 * (as a "core dump").
 */

#include	<stdio.h>
#include        <string.h>
#include        <stdlib.h>

#include	"ant32_external.h"

static int futz_byte_vma (int offset);

/*
 * ant_dump_text --
 *
 * Dump the entire state of an ANT (contained in an ant_t structure)
 * in text format.
 *
 * Returns non-zero (and prints an error message to stdout) if the
 * attempt to dump is unsuccessful.  Returns zero and creates or
 * overwrites the specified file upon success.
 */

int		ant_dump_text (char *filename, ant_t *ant)
{
	FILE *fout = fopen (filename, "w+");
	ant_mblk_t *b;
	char *str;

	if (fout == NULL) {
		return (-1);
	}

	ant32_show_state (fout, ant, 1);

	str = ant32_dump_regs (ant, 1);
	fprintf (fout, "Registers:\n%s\n", str);
	free (str);

	str = ant32_dump_eregs (ant, 1);
	fprintf (fout, "Exception Registers:\n%s\n", str);
	free (str);

	str = ant32_dump_kregs (ant, 1);
	fprintf (fout, "Kernel Registers:\n%s\n", str);
	free (str);

	str = ant32_dump_tlb (ant, 1);
	fprintf (fout, "TLB Entries:\n%s\n", str);
	free (str);

	/*
	 * It might be better to ensure that these are printed in
	 * some sort of logical order, rather that whatever order
	 * they happen to appear in the list.
	 */

	fprintf (fout, "Memory Block Descriptions:\n");
	for (b = ant->pmem; b != NULL; b = b->next) {
		fprintf (fout, "base = 0x%.8x  len = 0x%.8x  type = %d\n",
				b->base, b->len, b->type);
	}
	fprintf (fout, "\n");

	fprintf (fout, "Memory Contents:\n");
	for (b = ant->pmem; b != NULL; b = b->next) {
		ant_paddr_t p;

		for (p = b->base; p < b->base + b->len; p += ANT_MMU_PAGE_SIZE) {
			ant32_dump_page (fout, ant, p, 1);
		}
	}
	fprintf (fout, "\n");

	return (0);
}

int ant32_dump_page (FILE *fout, ant_t *ant, ant_paddr_t paddr, int fmt)
{
	char *str;

	if (! ant32_is_zero_page (ant, paddr)) {

		str = ant32_page2str (ant, paddr, fmt);
		if (str != NULL) {
			fprintf (fout, "%s", str);
			free (str);
		}
	}

	return (0);
}

/*
 * Returns 0 if the page starting at paddr contains non-zero values,
 * non-zero otherwise.
 */

int ant32_is_zero_page (ant_t *ant, ant_paddr_t paddr)
{
	ant_vma_t vma;
	int i;

	/*
	 * This really only works for pages, not just page-length
	 * blocks of memory!
	 */

	ANT_ASSERT ((paddr % ANT_MMU_PAGE_SIZE) == 0);

	vma = ant32_p2vm (paddr, ant->pmem, ANT_MEM_READ);

	ANT_ASSERT (vma != NULL);

	for (i = 0; i < ANT_MMU_PAGE_SIZE; i++) {
		if (vma [i] != 0) {
			return (0);
		}
	}

	return (-1);
}

/*
 * ant32_page2str -- produce a string (hex) representation of the
 * bytes in a page.
 *
 * If fmt is non-zero, tries hard to not print out too many extraneous
 * zeros-- only prints out rows that have non-zero values on them. 
 * The physical address of the start of each row is printed, in hex,
 * at the start of each row.
 */

#define	BYTES_PER_ROW	16
#define	PAGE_STR_LEN	(ANT_MMU_PAGE_SIZE * 8)	/* Generous */

char *ant32_page2str (ant_t *ant, ant_paddr_t paddr, int fmt)
{
	char buf [PAGE_STR_LEN];
	char *ptr = buf;
	ant_vma_t vma;
	int i, j;

	/*
	 * This really only works for pages, not just page-length
	 * blocks of memory!  Note that BYTES_PER_ROW must evenly
	 * devide ANT_MMU_PAGE_SIZE.
	 */

	ANT_ASSERT (ANT_MMU_PAGE_SIZE % BYTES_PER_ROW == 0);
	ANT_ASSERT ((paddr % ANT_MMU_PAGE_SIZE) == 0);

	vma = ant32_p2vm (paddr, ant->pmem, ANT_MEM_READ);
	ANT_ASSERT (vma != NULL);

	for (i = 0; i < ANT_MMU_PAGE_SIZE; i += BYTES_PER_ROW) {
		int all_zeros;

		all_zeros = 1;

		if (fmt) {
			for (j = 0; j < BYTES_PER_ROW; j++) {
				if (vma [i + j] != 0) {
					all_zeros = 0;
					break;
				}
			}

			if (all_zeros) {
				continue;
			}

			if ((i % BYTES_PER_ROW) == 0) {
				sprintf (ptr, "0x%.8x: ", paddr + i);
				ptr += strlen (ptr);
			}

			for (j = 0; j < BYTES_PER_ROW; j++) {
				int k = futz_byte_vma (i + j);

				sprintf (ptr, "%.2x ", LOWER_BYTE (vma [k]));
				ptr += strlen (ptr);
			}

			sprintf (ptr, "\n");
			ptr += strlen (ptr);
		}
		else {
			for (j = 0; j < BYTES_PER_ROW; j++) {
				int k = futz_byte_vma (i + j);

				sprintf (ptr, "%.2x ", LOWER_BYTE (vma [k]));
				ptr += strlen (ptr);
			}
		}
	}

	ANT_ASSERT (strlen (buf) < PAGE_STR_LEN);

	return (strdup (buf));
}

/*
 * A quick hack for mapping "VMA" offsets to the right byte addresses,
 * which depends on the endianess of the architecture hosting the VM.
 * Yucky.
 *
 * Ideally this would all be rolled into one set of routines for dealing
 * with memory, but the mainline code is optimized for the common case,
 * and since it is the biggest bottleneck in the system, it makes sense
 * to pull this out.  Well, at least for today.
 */

static int futz_byte_vma (int offset)
{
	int base;

#ifdef	IS_BIG_ENDIAN

	return (offset);

#else	/* Not IS_BIG_ENDIAN */

	base = offset & ~3;

	switch (offset % 4) {
		case 0 : base += 3; break; 
		case 1 : base += 2; break; 
		case 2 : base += 1; break; 
		case 3 : base += 0; break; 
	}

	return (base);

#endif	/* Not IS_BIG_ENDIAN */
}

/*
 * end of ant32_dump.c
 */
