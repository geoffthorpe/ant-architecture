#ifndef	_ANT32_H_
#define	_ANT32_H_

/*
 * $Id: ant32.h,v 1.5 2002/01/02 02:29:17 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * ant.h -- General grab-bag header file for ANT programs.  Pulls in a
 * lot of common stuff (often more than necessary).
 */

#include	<stdio.h>

#include	"ant32_mach.h"
#include	"ant32_bits.h"
#include	"ant32_vm.h"
/* SSS
#include	"ant_symtab.h"
*/
#include	"ant_external.h"

/* SSS adding for ant32_symtab.c */
int dump32_symtab_human (ant_symtab_t *table, char *buf);
int dump32_symtab_machine (ant_symtab_t *table, FILE *stream);

	/*
	 * Functions from ant_load.c and ant_dump.c:
	 */

int		ant_load_text (char *filename, ant_t *ant);
int		ant_load_labels (char *filename, ant_symtab_t **table);
void		ant_clear (ant_t *ant);
int		ant_load_bin (char *filename, ant_t *ant);

int		ant_dump_text (char *filename, ant_t *ant);
int		ant_print_reg (FILE *stream, ant_t *ant);
int		ant_print_freg (FILE *stream, ant_t *ant);
int		ant_print_mem (FILE *stream, ant_t *ant);
int		ant_dump_bin (char *filename, ant_t *ant);

	/*
	 * ant_sys.c
	 */

int		ant_sys (ant_t *ant, int r1, ant_sys_t call, int old_pc);

	/*
	 * ant_util.c
	 */

int		ant_check_des_reg (int des_reg);

	/*
	 * ant_exec.c
	 */

int		ant32_init (ant_t *ant, unsigned int memsize,
			unsigned int n_reg, unsigned int n_freg,
			unsigned int n_tlbe);
int		ant_exec (ant_t *ant);
int		ant_exec_inst (ant_t *ant);

/*
 * end of ant32.h
 */
#endif	/* _ANT32_H_ */
