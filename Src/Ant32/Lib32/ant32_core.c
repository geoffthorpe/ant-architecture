/*
 * $Id: ant32_core.c,v 1.35 2002/05/16 14:08:48 ellard Exp $
 *
 * Dan Ellard -- 05/25/2000
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant32_core.c --
 *
 * Routines to print/init statement structures in the ANT assembler.
 */

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant_external.h"
#include	"ant32_external.h"

#define	INST_SEGMENT	0
#define	DATA_SEGMENT	1
#define	DATA_SEG_LABEL	"_data_"

#define	MAX_LINE_LEN	1024

extern	ant_symtab_t	*unknownInstList;
extern	ant_symtab_t	*knownList;

int		AddBootJump     = 1;
unsigned long	BootAddress     = 0x80000000;
unsigned long	BaseAddress     = 0x80000000;

	ant_symtab_t	*constantList	= NULL;

static int ant32_asm_align (ant_asm_stmnt_t *stmnt,
		char *buf, unsigned int offset,
		unsigned int *consumed);
static int ant32_asm_word (ant_asm_stmnt_t *stmnt,
		char *buf, unsigned int offset,
		unsigned int *consumed, ant_symtab_t **list);

void ant_asm_init (void)
{

	/*
	 * Clear out the various symbol lists:  clear out the list of
	 * constants, the list of symbols with known addresses, and
	 * the lists of symbol references that need to be backpatched
	 * when their addresses become known.
	 */

	clear_symtab (constantList);
	constantList = NULL;
	clear_symtab (knownList);
	knownList = NULL;

	clear_symtab (unknownInstList);
	unknownInstList = NULL;

	ant32_code_init ();

	return;
}


/*
 * Actually do the work of assembling the given lines.  (The asm_filename
 * parameter is for the diagnostic messages ONLY).
 */

int ant_asm_lines (char *asm_filename, char **lines,
			int line_cnt, char *memTable,
			unsigned int *inst_cnt, unsigned int *last_addr )
{
	int line;
	char *str;
	ant_asm_stmnt_t	stmnt;
	int segment = INST_SEGMENT;
	unsigned int used;
	int rc;
	int curr_offset = 0;

	*inst_cnt = 0;

	ant_err_clr ();

	/*
	 * This is actually a three-pass assembler (or four, if you
	 * count backpatching as a separate pass).  This is weird and
	 * clunky, but really simplifies a lot of other things and
	 * gives better error messages via less complexity than any
	 * other solution that I can quickly invent.  (Like every
	 * other part of the Ant project, this code is being written
	 * under extreme time pressure...)
	 *
	 * 1.  The code is scanned, parsed, and checked.  If it passes
	 * this phase, then it's probably mostly OK.
	 *
	 * 2.  The code is scanned and parsed a second time, and the
	 * text segment is assembled.
	 *
	 * 3.  The code is scanned and parsed a third time, and the
	 * data segment is filled in.
	 *
	 * It would be nicer to just scan and parse once, but that
	 * would require more care and fancier data structures.  Maybe
	 * later.
	 */

	for (line = 1; line <= line_cnt; line++) {

		str = lines [line - 1];
		if (str == NULL) {
			ANT_ASSERT (0);
			break;
		}

		/* 
		 * Check for lines that are ridiculously long.
		 */

		if (strlen (str) > MAX_LINE_LEN) {
			sprintf (AntErrorStr, "line too long (> %d)",
					MAX_LINE_LEN);
			goto parse_error;
		}


		rc = ant_asm_parse_str (str, &stmnt, &constantList, 0);
		if (rc != 0) {
			goto parse_error;
		}

		if (ant_asm_args_check (&stmnt) != 0) {
			goto parse_error;
		}
	}

	/*
	 * Always begin a pass assuming that it's instructions.
	 */

	segment = INST_SEGMENT;

	for (line = 1; line <= line_cnt; line++) {

		str = lines [line - 1];
		rc = ant_asm_parse_str (str, &stmnt, &constantList, 0);
		if (rc != 0) {
			goto parse_error;
		}

		if (stmnt.label != NULL) {
		}

		if (stmnt.op == ASM_OP_TEXT) {
			segment = INST_SEGMENT;
			continue;
		}
		else if (stmnt.op == ASM_OP_DATA) {
			segment = DATA_SEGMENT;
			continue;
		}
		else if (stmnt.op == ASM_OP_ADDR) {
			printf ("base = %lx\n", BaseAddress);

			printf ("curr_offset at %u (%u %lu)\n",
					curr_offset, stmnt.args [0].val,
					BaseAddress);
			curr_offset = stmnt.args [0].val - BaseAddress;
			printf ("curr_offset rs %u\n", curr_offset);
			continue;
		}
		else if (stmnt.op == ASM_OP_DEFINE) {
			continue;
		}

		/*
		 * If we see the magic DATA_SEG_LABEL, we switch into
		 * the data segment
		 *
		 * It is NOT OK if the program has more than one
		 * "_data_" label!
		 *
		 * Explicit use of _data_ to change segments is now
		 * denigrated.  Use .text and .data instead.
		 */

		if ((stmnt.label != NULL) &&
				(strcmp (stmnt.label, DATA_SEG_LABEL) == 0)) {

			*inst_cnt = curr_offset / sizeof (ant_inst_t);
			segment = DATA_SEGMENT;
		}

		if (segment != INST_SEGMENT) {
			continue;
		}

		/*
		 * Hold onto this instruction's string so that later
		 * we can print it next to the bytecode.  Note that
		 * the trailing newline, if any, is removed.
		 */

		if (stmnt.op >= 0 || stmnt.op == ASM_OP_WORD) {
			int len = strlen (str);
			if ((len > 0) && (str [len - 1] == '\n')) {
				str [len - 1] = '\0';
			}

			ant32_code_line_insert (curr_offset, str, LITERAL);
		}

		/*
		 * If the line begins with a label, make a note of the
		 * current address (and hence the labels' value).
		 *
		 * Whether the current address is the actual final
		 * address depends on whether we're in the data or
		 * text segment; in the data segment we have to
		 * postpone the final assignment.
		 */

		if (stmnt.label != NULL) {
			rc = add_symbol (&knownList, stmnt.label,
					BaseAddress + curr_offset,
					"Label");
			if (rc != 0) {
				sprintf (AntErrorStr,
				"label [%s] defined more than once",
						stmnt.label);
				goto parse_error;
			}
		}

		rc = ant_asm_assemble_inst (&stmnt,
				memTable, curr_offset,
				ANT_MAX_INSTS - curr_offset,
				&used);
		if (rc != 0) {
			goto parse_error;
		}
		curr_offset += used;
	}

	*inst_cnt = curr_offset / sizeof (ant_inst_t);

	/*
	 * &&& Should zoom up to the next page boundary?
	 * &&& Probably, but for now let's keep small programs
	 * &&& small by smooshing them all together.  Maybe this
	 * &&& should be controlled by a commandline switch.
	 * &&& -DJE 11/10/01
	 */

	/*
	 * Always begin a pass assuming that it's instructions.
	 */

	segment = INST_SEGMENT;

	for (line = 1; line <= line_cnt; line++) {

		str = lines [line - 1];
		rc = ant_asm_parse_str (str, &stmnt, &constantList, 0);
		if (rc != 0) {
			goto parse_error;
		}

		if (stmnt.op == ASM_OP_TEXT) {
			segment = INST_SEGMENT;
			continue;
		}
		else if (stmnt.op == ASM_OP_DATA) {
			segment = DATA_SEGMENT;
			continue;
		}
		else if (stmnt.op == ASM_OP_DEFINE) {
			continue;
		}

		/*
		 * If we see the magic DATA_SEG_LABEL, we switch into
		 * the data segment
		 *
		 * It is NOT OK if the program has more than one
		 * "_data_" label!
		 *
		 * Explicit use of _data_ to change segments is now
		 * denigrated.  Use .text and .data instead.
		 */

		if ((stmnt.label != NULL) &&
				(strcmp (stmnt.label, DATA_SEG_LABEL) == 0)) {

			*inst_cnt = curr_offset / sizeof (ant_inst_t);

			segment = DATA_SEGMENT;
		}

		if (segment != DATA_SEGMENT) {
			continue;
		}

		if (stmnt.label != NULL) {
			rc = add_symbol (&knownList, stmnt.label,
					BaseAddress + curr_offset,
					"Label");
			if (rc != 0) {
				sprintf (AntErrorStr,
				"label [%s] defined more than once",
						stmnt.label);
				goto parse_error;
			}
		}

		rc = ant_asm_assemble_data (&stmnt,
				memTable, curr_offset,
				ANT_MAX_INSTS - curr_offset,
				&used);
		if (rc != 0) {
			goto parse_error;
		}
		curr_offset += used;
	}

	rc = ant32_asm_backpatch (memTable);
	if (rc != 0) {
		goto parse_error;
	}

	strcpy (AntErrorStr, "no errors detected");

	*last_addr = curr_offset;

	return (0);

parse_error:
	{
		char *err = strdup (AntErrorStr);

		sprintf (AntErrorStr, "%s:line %d: %s",
				asm_filename, line, err);

		free (err);
		return (-1);
	}
}

/*
 * Initialize an ANT VM directly from an instruction and data table,
 * instead of from file.  This makes it possible to have a load-and-go
 * interpreter that can assemble and execute programs.
 */

int ant_asm_init_ant (ant_t *ant, int inst_cnt, ant_inst_t *mem)
{
	int i;

	ant_pmem_clear (ant->pmem, 1);

	for (i = 0; i < inst_cnt; i++) {

		/* Store the instruction.  This is not as simple as
		 * you might hope.
		 */

		a32_store_instruction (ant, i * sizeof (ant_inst_t), mem [i]);
	}

	return (0);
}

int ant_asm_assemble_inst (ant_asm_stmnt_t *stmnt, char *b_memory,
		unsigned int b_offset, unsigned int remaining,
		unsigned int *consumed)
{
	int rc;
	ant_inst_t *memory = (ant_inst_t *) b_memory;
	unsigned int offset = b_offset / sizeof (ant_inst_t);
	ant_inst_t s = 0;

	ANT_ASSERT (consumed != NULL);
	ANT_ASSERT (stmnt != NULL);

	*consumed = 0;

	if ((stmnt->op == ASM_OP_NONE) || (stmnt->op == ASM_OP_DEFINE)) {
		*consumed = 0;
		return (0);
	}


	/* Deal with instruction memory */

	switch (stmnt->op) {
	case ASM_OP_BYTE:
	case ASM_OP_ASCII:
	case ASM_OP_ASCIIZ:
		sprintf (AntErrorStr,
			"data given in instruction segment");
		return (1);

	case ASM_OP_ALIGN:
		return (ant32_asm_align (stmnt, b_memory, offset, consumed));
		break;

	/* Arithmetic Format instructions */

	case OP_ADD:
	case OP_SUB:
	case OP_MUL:
	case OP_DIV:
	case OP_MOD:
	case OP_OR:
	case OP_NOR:
	case OP_XOR:
	case OP_AND:
	case OP_SHR:
	case OP_SHRU:
	case OP_SHL:
		/* Put in the opcode and registers [des, src1, src2] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].reg, 0);
		break;

	case OP_ORI:
	case OP_NORI:
	case OP_XORI:
	case OP_ANDI:
		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	/* Immediate Arithmetic Instructions */

	case OP_ADDI:
	case OP_SUBI:
	case OP_MULI:
	case OP_DIVI:
	case OP_MODI:

		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	case OP_SHRI:
	case OP_SHRUI:
	case OP_SHLI:
		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	/* Overflow Arithmetic Instructions */

	case OP_ADDO:
	case OP_SUBO:
	case OP_MULO:
		/* Put in the opcode and registers [des, src1, src2] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].reg, 0);
		break;

	/* Immediate Overflow Arithmetic Instructions */

	case OP_ADDIO:
	case OP_SUBIO:
	case OP_MULIO:
		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	/* Comparison Instructions */

	case OP_EQ:
	case OP_GTS:
	case OP_GES:
	case OP_GTU:
	case OP_GEU:
		/* Put in the opcode and registers [des, src1, src2] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].reg, 0);
		break;

	case OP_LTS:	/* pseudo op */
	case OP_LES:	/* pseudo op */
	case OP_LTU:	/* pseudo op */
	case OP_LEU:	/* pseudo op */
		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	/* Branch Instructions */

	case OP_BEZ:
	case OP_JEZ:
	case OP_BNZ:
	case OP_JNZ:
		/* Put in the opcode and registers [des, src1, src2] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].reg, 0);
		break;

	case OP_BEZI:
	case OP_BNZI:
	case OP_B:       /* pseudo op */
	case OP_J:       /* pseudo op */
	case OP_JEZI:    /* pseudo op */
	case OP_JNZI:    /* pseudo op */
		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	/* Load/Store Instructions */

	case OP_LD1:
	case OP_LD4:
		/* Put in the opcode and registers [des, src1, const8] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].val, 0);
		break;

	case OP_ST1:
	case OP_ST4:
		/* Put in the opcode and registers [src1, src2, const8] */
	case OP_EX4:
		/* Put in the opcode and registers [des, src1, const8] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].val, 0);
		break;

	/* Constant Instructions */

	case OP_LCH: {
		int hi_hword;

		hi_hword = HI_16 (stmnt->args [1].val);

		/* Put in the opcode and register number... */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);

		/* Followed by the constant, if known */
		if (stmnt->args[1].type == INT_ARG) {
			s = PUT_HWORD (s, hi_hword, 0);
		}
		else if (stmnt->args[1].type == LABEL_ARG) {
			int value;

			if (!find_symbol (knownList,
					stmnt->args[1].label, &value)) {
				s = PUT_HWORD(s, value, 0);
			}
			else {
				add_unresolved (&unknownInstList,
					stmnt->args[1].label,
					b_offset + 2, BYTE1);
				add_unresolved (&unknownInstList,
					stmnt->args[1].label,
					b_offset + 3, BYTE0);
			}
		}
		else {
			return(1);
		}

		break;
	}

	case OP_LCL: {
		int lo_hword;

		lo_hword = LO_16 (stmnt->args [1].val);

		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args [0].reg, 2);

		if (stmnt->args[1].type == INT_ARG) {
			s = PUT_HWORD(s, lo_hword, 0);
		}
		else {
			ANT_ASSERT (0);
		}
		break;
	}

	case OP_LC: 	/* pseudo op */

		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	/* Special Instructions */

	case OP_TRAP:
                /* Put in the opcode [reserved] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].val, 2);
		s = PUT_BYTE(s, stmnt->args[1].val, 1);
		s = PUT_BYTE(s, stmnt->args[2].val, 0);
		break;

	case OP_INFO:
		/* Put in the opcode and registers [des, const16] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_HWORD (s, stmnt->args [1].val, 0);
		break;

	/* Optional Instructions */

	case OP_RAND:
                /* Put in the opcode and register [des] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		break;

	case OP_SRAND:
                /* [src1, src2, src3] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].reg, 0);
		break;

	case OP_CIN:
                /* Put in the opcode and register [des] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		break;

	case OP_COUT:
                /* Put in the opcode and register [0,src1] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 1);
		break;

	/* MMU Instructions (supervisor mode only) */

	case OP_TLBPI:
	case OP_TLBLE:
                /* Put in the opcode and registers [des, src1] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		break;

	case OP_TLBSE:
                /* Put in the opcode and registers [0, src1, src2] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 1);
		s = PUT_BYTE(s, stmnt->args[1].reg, 0);
		break;

	/* Supervisor Mode Instructions */

	case OP_LEH:
		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return (rc);
		break;

	case OP_RFE:
                /* Put in the opcode and registers [src1, src2, src3] */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		s = PUT_BYTE(s, stmnt->args[2].reg, 0);
		break;

	case OP_HALT:
	case OP_IDLE:
	case OP_STI:
	case OP_CLI:
	case OP_STE:
	case OP_CLE:
		s = PUT_BYTE(s, stmnt->op, 3);
		break;

	case OP_TIMER: /* &&& BOGUS stop-gap */
		s = PUT_BYTE(s, stmnt->op, 3);
		s = PUT_BYTE(s, stmnt->args[0].reg, 2);
		s = PUT_BYTE(s, stmnt->args[1].reg, 1);
		break;

	case OP_MOV: 	/* pseudo op */
	case OP_PUSH: 	/* pseudo op */
	case OP_POP: 	/* pseudo op */
	case OP_CALL: 	/* pseudo op */
	case OP_ENTRY: 	/* pseudo op */
	case OP_RETURN:	/* pseudo op */

		rc = asm_expand_op (stmnt->op, stmnt,
				b_memory, b_offset, remaining, consumed);
		return(rc);

	case ASM_OP_WORD:
		return (ant32_asm_word (stmnt, b_memory, b_offset, consumed,
				&unknownInstList));
		break;

	default:
		sprintf (AntErrorStr, "invalid opcode");
		return(1);
		break;
	}

	if (1 > remaining) {
		sprintf(AntErrorStr, "instruction memory overflow");
		return (1);
	}

	memory [offset] = s;

	*consumed = sizeof (ant_inst_t);

	return(0);
}

int ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, char *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed)
{
	unsigned int i;

	ANT_ASSERT (consumed != NULL);

	*consumed = 0;

	if (stmnt->op != ASM_OP_NONE && stmnt->op != ASM_OP_BYTE &&
			stmnt->op != ASM_OP_WORD &&
			stmnt->op != ASM_OP_ALIGN &&
			stmnt->op != ASM_OP_ASCII &&
			stmnt->op != ASM_OP_ASCIIZ) {
		sprintf (AntErrorStr, "instructions given in data segment");
		return(1);
	}

	if (stmnt->num_args > remaining) {
		sprintf (AntErrorStr, "data memory overflow");
		return (1);
	}

	switch (stmnt->op) {

	case ASM_OP_ASCIIZ:
	case ASM_OP_ASCII: {
		char *s = stmnt->args [0].string;
		unsigned int len = stmnt->args [0].strlen;
		int ba;

		/*
		 * If it's ASCIIZ, then include the terminating
		 * nul character as part of the length.
		 */

		if (stmnt->op == ASM_OP_ASCIIZ) {
			len++;
		}

		for (i = 0; i < len; i++) {

#ifdef	IS_BIG_ENDIAN
			ba = offset + i;
#else	/* Not IS_BIG_ENDIAN */

			ba = (offset + i) & ~3;
			switch ((offset + i) % 4) {
				case 0: ba += 3; break;
				case 1: ba += 2; break;
				case 2: ba += 1; break;
				case 3: ba += 0; break;
			}
#endif	/* IS_BIG_ENDIAN */

			buf [ba] = s [i];
		}

		*consumed = len * sizeof (char);

		break;
	}

	case ASM_OP_BYTE:
		for (i = 0; i < stmnt->num_args; i++) {
			int ba;

#ifdef	IS_BIG_ENDIAN

			ba = offset + i;

#else	/* Not IS_BIG_ENDIAN */

			ba = (offset + i) & ~3;
			switch ((offset + i) % 4) {
				case 0: ba += 3; break;
				case 1: ba += 2; break;
				case 2: ba += 1; break;
				case 3: ba += 0; break;
			}

#endif	/* IS_BIG_ENDIAN */

			if (stmnt->args [i].type == INT_ARG) {
				buf [ba] = stmnt->args [i].val;
			}
			else if (stmnt->args [i].type == LABEL_ARG) {

				sprintf (AntErrorStr, "labels cannot be used as byte constants in Ant-32");
				return(1);
			}
		}

		*consumed = stmnt->num_args * sizeof (char);

		break;

	case ASM_OP_WORD:
		return (ant32_asm_word (stmnt, buf,
				offset, consumed, &unknownInstList));
		break;

	case ASM_OP_ALIGN:
		return (ant32_asm_align (stmnt, buf, offset, consumed));
		break;
	}

	return (0);
}

static int ant32_asm_align (ant_asm_stmnt_t *stmnt,
		char *buf, unsigned int offset,
		unsigned int *consumed)
{
	unsigned int bytes_used;
	unsigned int i;
	int alignment;

	if (stmnt->args [0].type != INT_ARG ||
			stmnt->args [0].val < 0) {
		sprintf (AntErrorStr, "alignment must be a positive integer");
		return (1);
	}

	alignment = stmnt->args [0].val;

	if (offset % alignment != 0) {
		bytes_used = alignment - (offset % alignment);
	}
	else {
		bytes_used = 0;
	}

	for (i = 0; i < bytes_used; i++) {
		int ba;

#ifdef	IS_BIG_ENDIAN

		ba = offset + i;

#else	/* Not IS_BIG_ENDIAN */

		ba = (offset + i) & ~3;
		switch ((offset + i) % 4) {
			case 0: ba += 3; break;
			case 1: ba += 2; break;
			case 2: ba += 1; break;
			case 3: ba += 0; break;
		}

#endif	/* IS_BIG_ENDIAN */

		buf [ba] = 0;
	}

	*consumed = bytes_used;

	return (0);
}


static int ant32_asm_word (ant_asm_stmnt_t *stmnt,
		char *buf, unsigned int offset,
		unsigned int *consumed, ant_symtab_t **list)
{
	unsigned int wbuffer [ANT_ASM_MAX_ARGS];
	unsigned int i;
	int value;
	unsigned int bytes_used;

	for (i = 0; i < stmnt->num_args; i++) {
		if (stmnt->args [i].type == INT_ARG) {
			wbuffer [i] = stmnt->args [i].val;
		}
		else if (stmnt->args [i].type == LABEL_ARG) {
			if (!find_symbol (knownList,
					stmnt->args [i].label, &value)) {
				wbuffer [i] = value;
			}
			else {
#ifdef	IS_BIG_ENDIAN
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 0,
					BYTE3);
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 1,
					BYTE2);
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 2,
					BYTE1);
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 3,
					BYTE0);
#else	/* Not IS_BIG_ENDIAN */
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 0,
					BYTE0);
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 1,
					BYTE1);
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 2,
					BYTE2);
				add_unresolved (list,
					stmnt->args [i].label,
					offset + (sizeof (ant_inst_t) * i) + 3,
					BYTE3);
#endif	/* IS_BIG_ENDIAN */
				wbuffer [i] = 0;
			}
		}
	}

	bytes_used = stmnt->num_args * sizeof (ant_inst_t);

	memcpy (buf + offset, wbuffer, bytes_used);

	*consumed = bytes_used;

	return (0);
}

/*
 * end of ant32_core.c
 */
