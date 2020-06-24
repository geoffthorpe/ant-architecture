/*
 * $Id: ant32_debug.c,v 1.26 2002/01/05 15:12:23 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_debug.c -- utility functions for the debugger.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<ctype.h>

#include	"ant_external.h"
#include	"ant32_external.h"

/*
 * Print out a bunch of stuff that might be useful for debugging an
 * ANT.  Not to be confused with a debugger...
 */

void ant32_show_state (FILE *fout, ant_t *ant, int fmt)
{
	char *str;

	str = ant32_dump_cntrl (ant, 1);
	fprintf (fout, "%s\n", str);
	free (str);

	str = ant32_dump_kregs (ant, fmt);
	fprintf (fout, "%s\n", str);
	free (str);

	str = ant32_dump_eregs (ant, fmt);
	fprintf (fout, "%s\n", str);
	free (str);


	return ;
}

char *ant32_dump_cntrl (ant_t *ant, int fmt)
{
	char buf [1024];
	char *ptr = buf;
	char *fmt_string;

	if (fmt) {
		fmt_string = "PC = 0x%.8x  mode = %c  int = %s  exc = %s\n";
	}
	else {
		fmt_string = "0x%.8x %c %s %s\n";
	}

	sprintf (buf, fmt_string,
			ant->pc,
			(ant->mode == ANT_SUPER_MODE) ? 'S' : 'U',
			ant->int_disable ? "off" : "on",
			ant->exc_disable ? "off" : "on");
	ptr += strlen (ptr);

	return (strdup (buf));
}

#define	REG_PER_LINE	8

char *ant32_dump_regs (ant_t *ant, int fmt)
{
	unsigned int i;
	unsigned int len;
	char *ptr, *str;

		/* A guess of how much space is needed.
		 */

	len = ant->params.n_reg * 80;

	ptr = str = malloc (len * sizeof (char));
	ANT_ASSERT (ptr != NULL);
	*ptr = '\0';

	if (fmt) {
		if (regNamesType == 'r') {
			for (i = 0; i < ant->params.n_reg; i++) {
				if ((i % REG_PER_LINE) == 0) {
					if (i > 0) {
						sprintf (ptr, "\n");
						ptr += strlen (ptr);
					}
					sprintf (ptr, "%.2x:  ", i);
					ptr += strlen (ptr);
				}
				else {
					sprintf (ptr, " ");
					ptr += strlen (ptr);
				}
				sprintf (ptr, "%.8x", ant->reg [i]);
				ptr += strlen (ptr);
			}
			sprintf (ptr, "\n");
			ptr += strlen (ptr);
		}
		else if (regNamesType == 'g') {
			for (i = 0; i < 56; i++) {
				if ((i % REG_PER_LINE) == 0) {
					if (i > 0) {
						sprintf (ptr, "\n");
						ptr += strlen (ptr);
					}
					sprintf (ptr, "g%-2d:  ", i);
					ptr += strlen (ptr);
				}
				else {
					sprintf (ptr, " ");
					ptr += strlen (ptr);
				}
				sprintf (ptr, "%.8x", ant->reg [i + 4]);
				ptr += strlen (ptr);
			}

			sprintf (ptr, "\nra:   %.8x\nsp:   %.8x\nfp:   %.8x",
					ant->reg [1], ant->reg [2],
					ant->reg [3]);
			ptr += strlen (ptr);

		}
		else if (regNamesType == 'c') {

			sprintf (ptr, "\nv0-1  ");
			ptr += strlen (ptr);

			for (i = 0; i < 2; i++) {
				sprintf (ptr, "%.8x ", ant->reg [i + 4]);
			}
			sprintf (ptr, "\na0-6  ");
			ptr += strlen (ptr);

			for (i = 0; i < 6; i++) {
				sprintf (ptr, "%.8x ", ant->reg [i + 6]);
			}

			for (i = 0; i < 24; i++) {
				if ((i % REG_PER_LINE) == 0) {
					if (i > 0) {
						sprintf (ptr, "\n");
						ptr += strlen (ptr);
					}
					sprintf (ptr, "s%-2d:  ", i);
					ptr += strlen (ptr);
				}
				else {
					sprintf (ptr, " ");
					ptr += strlen (ptr);
				}
				sprintf (ptr, "%.8x", ant->reg [i + 12]);
				ptr += strlen (ptr);
			}
			sprintf (ptr, "\n");
			ptr += strlen (ptr);

			for (i = 0; i < 24; i++) {
				if ((i % REG_PER_LINE) == 0) {
					if (i > 0) {
						sprintf (ptr, "\n");
						ptr += strlen (ptr);
					}
					sprintf (ptr, "t%-2d:  ", i);
					ptr += strlen (ptr);
				}
				else {
					sprintf (ptr, " ");
					ptr += strlen (ptr);
				}
				sprintf (ptr, "%.8x", ant->reg [i + 36]);
				ptr += strlen (ptr);
			}
			ptr += strlen (ptr);

			sprintf (ptr, "\nra:   %.8x\nsp:   %.8x\nfp:   %.8x",
					ant->reg [1], ant->reg [2],
					ant->reg [3]);
			ptr += strlen (ptr);
		}
	}
	else {
		for (i = 0; i < ant->params.n_reg; i++) {
			char *rn;

			rn = ant32_reg_name (i);
			if (rn == NULL) {
				rn = "??";
			}

			sprintf (ptr, "%3s  0x%.8x\n",
					ant32_reg_name (i), ant->reg [i]);
			ptr += strlen (ptr);
		}
	}

	ANT_ASSERT (strlen (str) < len);

	return (str);
}

char *ant32_dump_cycle (ant_t *ant, int fmt)
{
	char buf [2048];
	char *ptr = buf;

	if (fmt) {
		sprintf (ptr, "\t%s\n", "Cycle Counters:");
		ptr += strlen (ptr);
		sprintf (ptr, "\tCPU        %8d  ", ant->reg [CYCLE_REG_CPU]);
		ptr += strlen (ptr);
		sprintf (ptr, "CPU (sup)  %8d\n", ant->reg [CYCLE_REG_CPU_SUP]);
		ptr += strlen (ptr);
		sprintf (ptr, "\tloads      %8d  ", ant->reg [CYCLE_REG_READ]);
		ptr += strlen (ptr);
		sprintf (ptr, "stores     %8d\n", ant->reg [CYCLE_REG_WRITE]);
		ptr += strlen (ptr);
		sprintf (ptr, "\tTLB miss   %8d  ", ant->reg [CYCLE_REG_TLB_MISS]);
		ptr += strlen (ptr);
		sprintf (ptr, "cache miss %8d\n", ant->reg [CYCLE_REG_CACHE_MISS]);
		ptr += strlen (ptr);
		sprintf (ptr, "\tIRQs       %8d  ", ant->reg [CYCLE_REG_IRQ]);
		ptr += strlen (ptr);
		sprintf (ptr, "exceptions %8d\n", ant->reg [CYCLE_REG_EXC]);
		ptr += strlen (ptr);
	}
	else {
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_CPU]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_CPU_SUP]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_READ]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_WRITE]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_TLB_MISS]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_CACHE_MISS]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_IRQ]);
		ptr += strlen (ptr);
		sprintf (ptr, "%d\n", ant->reg [CYCLE_REG_EXC]);
		ptr += strlen (ptr);
	}

	return (strdup (buf));
}

#define GANT_RPL 1

char *ant32_dump_eregs (ant_t *ant, int fmt)
{
	char buf [300];	/* 2-3 lines at most. */
	char *ptr = buf;
	char *fmt_str;

	if (fmt) {
		fmt_str = "e0 = 0x%.8x  e1 = 0x%.8x  e2 = 0x%.8x  e3 = 0x%.8x\n";
	}
	else {
		fmt_str = "0x%.8x\n0x%.8x\n0x%.8x\n0x%.8x\n";
	}

	ptr = buf;

	sprintf (ptr, fmt_str,
			ant->reg [EXC_REG_0], ant->reg [EXC_REG_1],
			ant->reg [EXC_REG_2], ant->reg [EXC_REG_3]);
	ptr += strlen (ptr);

	if (fmt) {
		sprintf (ptr, "     ");
		ptr += strlen (ptr);
		sprintf (ptr, "(Shadow PC)      (INT mask)       ");
		ptr += strlen (ptr);
		sprintf (ptr, "(TLB addr)       (Exception)\n");
		ptr += strlen (ptr);
	}

	return (strdup (buf));
}

char *ant32_dump_kregs (ant_t *ant, int fmt)
{
	char buf [100];
	char *fmt_str;

	if (fmt) {
		fmt_str = "k0 = 0x%.8x  k1 = 0x%.8x  k2 = 0x%.8x  k3 = 0x%.8x\n";
	}
	else {
		fmt_str = "0x%.8x\n0x%.8x\n0x%.8x\n0x%.8x";
	}

	sprintf (buf, fmt_str,
			ant->reg [SUP_REG_0], ant->reg [SUP_REG_1],
			ant->reg [SUP_REG_2], ant->reg [SUP_REG_3]);

	return (strdup (buf));
}

void ant32_print_reg (FILE *fout, ant_t *ant, int reg)
{

	if (check_src_reg (ant, reg)) {
		fprintf (fout, "Register %d cannot be accessed.\n", reg);
	}
	else {
		ant_reg_t val = ant->reg [reg];

		fprintf (fout, "%-3s:  ", ant32_reg_name (reg));
		fprintf (fout, "hex: 0x%.8x  ", val);
		fprintf (fout, "dec: %11d  ", val);

		if (0 <= val && val < 128) {
			fprintf (fout, "ascii: ");

			if (isprint (val)) {
				fprintf (fout, "'%c'", val);
			}
			else {
				fprintf (fout, "'\\%.3o'", val);
			}
		}

		fprintf (fout, "\n");
	}
	return;
}

/*
 * &&& Dependent on the internal representation of the TLB entries.
 */

#define	TLB_PER_LINE	2

char *ant32_dump_tlb (ant_t *ant, int fmt)
{
	char *str, *ptr;
	unsigned int len;
	unsigned int n_tlb = ant->params.n_tlb;
	unsigned int i;

	/*
	 * I assume that each tlb entry has its own line,
	 * and there's a banner line of some kind.  This
	 * is actually very generous.
	 */

	len = (1 + n_tlb) * 80 + 1;

	ptr = str = malloc (len * sizeof (char));
	ANT_ASSERT (ptr != NULL);
	*ptr = '\0';

	if (fmt) {
		for (i = 0; i < n_tlb; i++) {
			if ((i % TLB_PER_LINE) == 0) {
				if (i > 0) {
					sprintf (ptr, "\n");
					ptr += strlen (ptr);
				}

				sprintf (ptr, "%.2x:  ", i);
				ptr += strlen (ptr);
			}
			else {
				sprintf (ptr, "    ");
				ptr += strlen (ptr);
			}

			sprintf (ptr, "ppn=%.5x at=%.3x ",
					ANT_TLB_PHYS_PN (ant->tlb [i]),
					ANT_TLB_ATTR (ant->tlb [i]));
			ptr += strlen (ptr);

			sprintf (ptr, "vpn=%.5x os=%.3x",
					ANT_TLB_VIRT_SEGPN (ant->tlb [i]),
					ANT_TLB_OS_INFO (ant->tlb [i]));
			ptr += strlen (ptr);
		}
		sprintf (ptr, "\n");
		ptr += strlen (ptr);
	}
	else {
		for (i = 0; i < n_tlb; i++) {
			sprintf (ptr, "%.5x %.3x ",
					ANT_TLB_PHYS_PN (ant->tlb [i]),
					ANT_TLB_OS_INFO (ant->tlb [i]));
			ptr += strlen (ptr);

			sprintf (ptr, "%.5x %.3x",
					ANT_TLB_VIRT_SEGPN (ant->tlb [i]),
					ANT_TLB_ATTR (ant->tlb [i]));
			ptr += strlen (ptr);

			sprintf (ptr, "\n");
			ptr += strlen (ptr);
		}
	}

	ANT_ASSERT (strlen (str) <= len);

	return (str);
}

#define	WORDS_PER_LINE	4

char *ant32_dump_vmem_words (ant_t *ant, int base, int count, int fmt)
{
	int i;
	ant_reg_t val;
	int rc;
	char *str, *ptr;
	unsigned int len;

	/*
	 * perhaps over-generous, but that's better than the
	 * alternative.
	 */

	len = ((count + 1) * 20) + (((count / WORDS_PER_LINE) + 1) * 20) + 1;

	ptr = str = (char *) malloc (len);
	ANT_ASSERT (ptr != NULL);
	*ptr = '\0';

	for (i = 0; i < count; i++) {
		if (fmt) {
			if ((i % WORDS_PER_LINE) == 0) {
				if (i > 0) {
					sprintf (ptr, "\n");
					ptr += strlen (ptr);
				}

				sprintf (ptr, "0x%.8x:  ", base + (i * 4));
				ptr += strlen (ptr);
			}
		}

		rc = do_load_store (4, ANT_MEM_READ, ant,
				base + (i * sizeof (ant_reg_t)), &val, 0);
		if (rc != ANT_EXC_OK) {
			sprintf (ptr, "0x????????");
			ptr += strlen (ptr);
		}
		else {
			sprintf (ptr, "0x%.8x", val);
			ptr += strlen (ptr);
		}

		if (fmt) {
			sprintf (ptr, "  ");
			ptr += strlen (ptr);
		}
		else {
			sprintf (ptr, "\n");
			ptr += strlen (ptr);
		}

	}

	if (fmt) {
		sprintf (ptr, "\n");
		ptr += strlen (ptr);
	}

	ANT_ASSERT (strlen (str) < len);

	return (str);
}

#define	BYTES_PER_LINE	8

char *ant32_dump_vmem_bytes (ant_t *ant, int base, int count, int fmt)
{
	int i;
	char val;
	int rc;
	char *str, *ptr;
	unsigned int len;

	/*
	 * perhaps over-generous, but that's better than the
	 * alternative.
	 */

	len = ((count + 1) * 10) + (((count / BYTES_PER_LINE) + 1) * 12) + 1;

	ptr = str = (char *) malloc (len);
	ANT_ASSERT (ptr != NULL);
	*ptr = '\0';

	for (i = 0; i < count; i++) {

		if (fmt) {
			if ((i % BYTES_PER_LINE) == 0) {
				if (i > 0) {
					sprintf (ptr, "\n");
					ptr += strlen (ptr);
				}

				sprintf (ptr, "0x%.2x:  ", base + i);
				ptr += strlen (ptr);
			}
		}

		rc = do_load_store (1, ANT_MEM_READ, ant, base + i, &val, 0);

		if (rc != ANT_EXC_OK) {
			sprintf (ptr, "0x??");
			ptr += strlen (ptr);
		}
		else {
			sprintf (ptr, "0x%.2x", 0xff & val);
			ptr += strlen (ptr);
		}

		if (fmt) {
			sprintf (ptr, "  ");
			ptr += strlen (ptr);
		}
		else {
			sprintf (ptr, "\n");
			ptr += strlen (ptr);
		}
	}

	if (fmt) {
		sprintf (ptr, "\n");
		ptr += strlen (ptr);
	}

	ANT_ASSERT (strlen (str) < len);

	return (str);
}

char *ant32_dump_vmem_insts (ant_t *ant, int base, int count, int fmt)
{
	int i;
	ant_reg_t val;
	int rc;
	char *str, *ptr;
	unsigned int len;

	/*
	 * perhaps over-generous, but that's better than the
	 * alternative.
	 */

	len = (count + 1) * 60 + 1;

	ptr = str = (char *) malloc (len);
	ANT_ASSERT (ptr != NULL);
	*ptr = '\0';

	for (i = 0; i < count; i++) {
		int addr;

		addr = base + i * sizeof (ant_reg_t);

		rc = do_load_store (4, ANT_MEM_READ, ant, addr, &val, 0);

		if (rc == ANT_EXC_OK) {
			char buf [100];

			ant_disasm_inst (val, addr, ant->reg, buf, 0);
			sprintf (ptr, "0x%.8x:\t%s\n", addr, buf);
			ptr += strlen (ptr);
		}
		else {
			sprintf (ptr, "0x%.8x:  .word  0x???????? #\n", addr);
			ptr += strlen (ptr);
		}
	}

	ANT_ASSERT (strlen (str) < len);

	return (str);
}
/*
 * end of ant32_debug.c
 */
