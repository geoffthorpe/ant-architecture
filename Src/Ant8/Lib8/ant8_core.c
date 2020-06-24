/*
 * $Id: ant8_core.c,v 1.15 2002/12/11 20:22:56 ellard Exp $
 *
 * Dan Ellard -- 02/09/2000
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant_asm_core.c --
 *
 * Routines to print/init statement structures in the ANT assembler.
 */

#include	<stdio.h>
#include	<string.h>
#include	<stdlib.h>

#include        "ant8_external.h"
#include        "ant8_internal.h"

#define	INST_SEGMENT	0
#define	DATA_SEGMENT	1
#define	DATA_SEG_LABEL	"_data_"

#define	MAX_LINE_LEN	1024

#ifdef macintosh
#undef IS_BIG_ENDIAN
#endif

	/* Statements, for cool printing later */
char *stmnts [ANT_INST_ADDR_RANGE];

extern	ant_symtab_t	*unknownInstList;
extern	ant_symtab_t	*unknownDataList;
extern	ant_symtab_t	*knownList;

	ant_symtab_t	*constantList	= NULL;

/*
 * Actually do the work of assembling the given lines.  (The asm_filename
 * parameter is for the diagnostic messages ONLY).
 */

int ant_asm_lines (char *asm_filename, char **lines, int line_cnt,
			ant_inst_t *instTable, int *curr_inst,
			ant_data_t *dataTable, int *curr_data)
{
	int line;
	char *str;
	ant_asm_stmnt_t	stmnt;
	int segment = INST_SEGMENT;
	unsigned int used;
	int rc;
	int current_inst = 0;
	int current_data = 0;

	*curr_inst = 0;
	*curr_data = 0;

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
	clear_symtab (unknownDataList);
	unknownDataList = NULL;

	ant_err_clr ();

	/*
	 * If using single address space, then use the same table for
	 * both instructions and data.
	 *
	 * &&& THIS IS CLUMSY!  If we abandon the multiple address
	 * spaces in the future, then this really should be
	 * streamlined, and every place that data is treated
	 * differently than instructions should be reexamined.
	 */

	instTable = (ant_inst_t *) dataTable;

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

		/*
		 * Hold onto this instruction's string so that later
		 * we can print it next to the bytecode.  Note that
		 * the trailing newline, if any, if removed.
		 */

		if (stmnt.op >= 0) {
			int len = strlen (str);
			if ((len > 0) && (str [len - 1] == '\n')) {
				str [len - 1] = '\0';
			}
			stmnts[current_inst] = strdup (str);
		}

		/*
		 * If we see the magic DATA_SEG_LABEL, we switch into
		 * the data segment
		 *
		 * It is NOT OK if the program has more than one
		 * "_data_" label!
		 */

		if ((stmnt.label != NULL) &&
				(strcmp (stmnt.label, DATA_SEG_LABEL) == 0)) {

			segment = DATA_SEGMENT;

			/*
			 * If we're doing SINGLE_ADDRESS_SPACE, then
			 * there actually is only one segment, and it
			 * gets shared.  So current_data starts
			 * wherever the instructions end.
			 */

			current_data = 2 * current_inst;
		}

		if (segment == INST_SEGMENT) {

			/*
			 * If the line begins with a label, make a
			 * note of the current address (and hence the
			 * labels' value).
			 */

			if (stmnt.label != NULL) {
				int label_addr;

				label_addr = 2 * current_inst;

				rc = add_symbol (&knownList, stmnt.label,
						label_addr, "Label");
				if (rc != 0) {
					sprintf (AntErrorStr,
					"label [%s] defined more than once",
							stmnt.label);
					goto parse_error;
				}
			}

			rc = ant_asm_assemble_inst (&stmnt,
					instTable, current_inst,
					ANT_INST_ADDR_RANGE - 2 * current_inst,
					&used);
			current_inst += used;
		}
		else {
			/* Deal with Labels */
			if (stmnt.label != NULL) {
				rc = add_symbol (&knownList, stmnt.label,
						current_data, "Label");
				if (rc != 0) {
					sprintf (AntErrorStr,
					"multiply defined symbol [%s]",
							stmnt.label);
					goto parse_error;
				}
			}
			rc = ant_asm_assemble_data (&stmnt,
					dataTable, current_data,
					ANT_DATA_ADDR_RANGE - current_data,
					&used);
			current_data += used;
		}

		if (rc != 0) {
			goto parse_error;
		}
	}

	rc = ant8_asm_backpatch ((char *) instTable, (char *) dataTable);
	if (rc != 0) {
/* 		sprintf (AntErrorStr, "unresolved symbols"); */
		goto parse_error;
	}

	/*
	 * Deal with a corner case:  if there's no _data_ label, then
	 * because of the way that current_data is initialized above,
	 * the assembler might believe that there isn't any data at
	 * all-- but in the SAS model, instructions count as data, so
	 * the current_data index has to be jiggled to start at the
	 * end of the instructions.
	 */

	if (segment == INST_SEGMENT) {
		current_data = 2 * current_inst;
	}

	*curr_inst = current_inst;
	*curr_data = current_data;

	strcpy (AntErrorStr, "no errors detected");

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

int ant_asm_init_ant (ant_t *ant, int inst_cnt,
		ant_data_t *dataTable, int data_cnt)
{
	int i;

	ant_clear (ant);

	for (i = 0; i < data_cnt; i++) {
		ant->data [i] = dataTable [i];
	}

	ant->inst_cnt = inst_cnt;

	return (0);
}


int ant_asm_assemble_inst (ant_asm_stmnt_t *stmnt, ant_inst_t *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed)
{
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
			sprintf (AntErrorStr,
				"data given in instruction segment");
			return (1);


		case OP_LC:
			/* Put in the opcode and register number... */
			s = PUT_NIBBLE(s, stmnt->op, 3);
			s = PUT_NIBBLE(s, stmnt->args[0].reg, 2);

			/* Followed by the constant, if known */
			if (stmnt->args[1].type == INT_ARG) {
				s = PUT_BYTE(s, stmnt->args[1].val, 0);
			}
			else if (stmnt->args[1].type == LABEL_ARG) {
				int value;

				if (!find_symbol (knownList,
						stmnt->args[1].label, &value)) {
					s = PUT_BYTE(s, value, 0);
				}
				else {
					add_unresolved (&unknownInstList,
						stmnt->args[1].label,
						offset * sizeof (ant_inst_t),0);
				}
			}
			else {
				return(1);
			}

			break;

		/* Constant-Arg Format instructions */

		case OP_INC:

			/* Put in the opcode and register number... */
			s = PUT_NIBBLE(s, stmnt->op, 3);
			s = PUT_NIBBLE(s, stmnt->args[0].reg, 2);

			/* Followed by the constant, if known */

			if (stmnt->args[1].type == INT_ARG) {
				s = PUT_BYTE(s, stmnt->args[1].val, 0);
			}
			else if (stmnt->args[1].type == LABEL_ARG) {
				int value;

				if (!find_symbol (knownList,
						stmnt->args[1].label, &value)) {
					s = PUT_BYTE(s, value, 0);
				}
				else {
					add_unresolved (&unknownInstList,
						stmnt->args[1].label,
						offset * sizeof (ant_inst_t),0);
				}
			}
			else {
				return(1);
			}

			break;

		case OP_JMP:

			/* Put in the opcode, followed by 0 (since the
			 * first register field in jmp is unused).
			 */

			s = PUT_NIBBLE(s, stmnt->op, 3);
			s = PUT_NIBBLE(s, 0, 2);

			/* Followed by the constant, if known */
			if (stmnt->args[0].type == INT_ARG) {
				s = PUT_BYTE(s, stmnt->args[0].val, 0);
			}
			else {
				int val;

				if (stmnt->args[0].type != LABEL_ARG) {
					sprintf (AntErrorStr,
						"label expected");
					return(1);
				}

				if (!find_symbol (knownList,
						stmnt->args[0].label, &val)) {
					s = PUT_BYTE(s, val, 0);
				}
				else {
					add_unresolved (&unknownInstList,
						stmnt->args[0].label,
						offset * sizeof (ant_inst_t),0);
				}
			}

			break;

		case OP_HALT:
			s = PUT_NIBBLE(s, stmnt->op, 3);
			s = PUT_NIBBLE(s, 0, 2);
			s = PUT_NIBBLE(s, 0, 1);
			s = PUT_NIBBLE(s, 0, 0);
			break;

		case OP_IN:
			s = PUT_NIBBLE(s, OP_IN, 3);
			s = PUT_NIBBLE(s, stmnt->args[0].reg, 2);
			s = PUT_NIBBLE(s, 0, 1);
			s = PUT_NIBBLE(s, stmnt->args[1].val, 0);
			break;

		case OP_OUT:
			s = PUT_NIBBLE(s, OP_OUT, 3);
			s = PUT_NIBBLE(s, 0, 2);
			s = PUT_NIBBLE(s, stmnt->args[0].reg, 1);
			s = PUT_NIBBLE(s, stmnt->args[1].val, 0);
			break;

		/* Normal Format instructions */
		case OP_ADD:
		case OP_SUB:
		case OP_MUL:
		case OP_AND:
		case OP_NOR:
		case OP_SHF:
		case OP_BEQ:
		case OP_BGT:
			/* Put in the opcode and registers */
			s = PUT_NIBBLE(s, stmnt->op, 3);
			s = PUT_NIBBLE(s, stmnt->args[0].reg, 2);
			s = PUT_NIBBLE(s, stmnt->args[1].reg, 1);
			s = PUT_NIBBLE(s, stmnt->args[2].reg, 0);
			break;

		case OP_LD1:
		case OP_ST1:
			/* Put in the opcode and regsters */
			s = PUT_NIBBLE(s, stmnt->op, 3);
			s = PUT_NIBBLE(s, stmnt->args[0].reg, 2);
			s = PUT_NIBBLE(s, stmnt->args[1].reg, 1);
			s = PUT_NIBBLE(s, stmnt->args[2].val, 0);
			break;

		default:
			sprintf (AntErrorStr, "invalid opcode");
			return(1);
			break;
	}

	/*
	 * This part of the function is a crock!  &&&
	 *
	 * Here we assume that every instruction expands into exactly
	 * one machine instruction.  THIS WILL NOT BE THE CASE IN THE
	 * FUTURE but it suffices for ANT-2.0.X.
	 */

	if (1 > remaining) {
		sprintf(AntErrorStr, "instruction memory overflow");
		return (1);
	}

	/* Deal with byte-ordering issues... */
#ifdef	IS_BIG_ENDIAN
	buf [offset] = s;
#else	/* Not IS_BIG_ENDIAN */
	buf [offset] = ((s & 0xff) << 8) | (((s & 0xff00) >> 8) & 0xff);
#endif	/* IS_BIG_ENDIAN */

	*consumed = 1;

	return(0);
}

int ant_asm_assemble_data (ant_asm_stmnt_t *stmnt, ant_data_t *buf,
		unsigned int offset, unsigned int remaining,
		unsigned int *consumed)
{
	unsigned int i;

	ANT_ASSERT (consumed != NULL);

	*consumed = 0;

	if (stmnt->op == ASM_OP_NONE || stmnt->op == ASM_OP_DEFINE) {
		return (0);
	}

	if (stmnt->op != ASM_OP_BYTE) {
		sprintf (AntErrorStr, "instructions given in data segment");
		return(1);
	}

	if (stmnt->num_args > remaining) {
		sprintf (AntErrorStr, "data memory overflow");
		return (1);
	}

	for (i = 0; i < stmnt->num_args; i++) {
		int val;

		if (stmnt->args [i].type == INT_ARG) {
			val = stmnt->args[i].val;
		}
		else if (stmnt->args [i].type == LABEL_ARG) {

			if (find_symbol (knownList,
					stmnt->args [i].label, &val)) {
				add_unresolved (&unknownDataList,
					stmnt->args[i].label, offset + i,0);
				val = 0;
			}
		}
		else {
			return(1);
		}

		buf [offset + i] = val;
		(*consumed)++;
	}

	return (0);
}


/*
 * end of ant_asm_util.c
 */
