#ifndef	_ANT32_AA_UTIL_H_
#define	_ANT32_AA_UTIL_H_

/*
 * $Id: ant32_core.h,v 1.3 2002/01/02 02:29:17 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 05/25/2000
 *
 * ant32_aa_util.h --
 *
 */

	/* From ant_asm_core.c: */
int ant_asm_lines (char *asm_filename, char **lines, int line_cnt,
		char *b_mem, unsigned int *inst_cnt, unsigned int *last_addr);
int ant_asm_init_ant (ant_t *ant, int inst_cnt, char *memTable);
int ant_asm_assemble_inst (ant_asm_stmnt_t *stmnt, char *b_mem,
		unsigned int b_offset, unsigned int remaining,
		unsigned int *consumed);
int ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, char *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed);
int ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, char *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed);

/*
 * end of ant_asm_util.h
 */
#endif	/* _ANT32_AA_UTIL_H_ */
