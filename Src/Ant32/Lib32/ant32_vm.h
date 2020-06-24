#ifndef	_ANT32_VM_H_
#define	_ANT32_VM_H_

/* $Id: ant32_vm.h,v 1.4 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_vm.h -- header file for the ANT VM.
 */

typedef	struct	{
	ant_tlbe_t	entries [ANT_MAX_TLB_ENTRIES];
	unsigned int	num_entries;
} ant_tlb_t;

typedef	struct	{
	unsigned int	n_reg;
	unsigned int	n_freg;
	unsigned int	mem_size;
	unsigned int	tlb_size;
} ant_param_t;

extern	ant_param_t	AntParameters;

/*
 * A structure that contains all of the information about the state of
 * an ANT-32:  the program counter (pc), all the registers, and the
 * memory.
 *
 * The memory is organized in "blocks" of variable size, corresponding
 * to places in the physical address space where memory resides. 
 */

typedef	struct	{
	ant_exec_mode_t	mode;
	ant_pc_t	pc;
	ant_reg_t	reg [ANT_REG_RANGE];
	ant_freg_t	freg [ANT_FREG_RANGE];
	ant_tlb_t	tlb;
	ant_pmem_blk_t	*blks;
	int		blk_cnt;
	ant_param_t	params;
} ant_t;

/*
 * The default memory size of an ANT, which can be overridden during
 * intialization.  This size was chosen because it seems reasonable
 * for wide variety of exercises, but small enough so that it doesn't
 * place a huge burden on the computer that is running the VM.
 */

#define	ANT_DEFAULT_MEM_SIZE	(1024 * 1024)

/*
 * &&& Note the cheesy assumption that ANT32 programs are contiguous
 * in memory, start at location 0 (in VM space), and are never longer
 * than ANT_DEFAULT_MEM_SIZE.  This is large enough for some pretty
 * huge programs, but not enough for "real" purposes.
 */

#define	ANT_MAX_INSTS	(ANT_DEFAULT_MEM_SIZE)

/*
 * Define the longest line allowable in an ANT program file (in the
 * text format described in ant.txt).
 */

#define	ANT_MAX_LINE_LEN	512

ant_t		*ant_create (ant_param_t *params);
void		ant_clear (ant_t *ant);

/*
 * end of ant32_vm.h
 */

#endif /* _ANT32_VM_H_ */
