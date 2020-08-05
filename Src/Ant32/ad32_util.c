/*
 * $Id: ad32_util.c,v 1.21 2002/01/02 02:26:02 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 06/09/2000
 *
 * ad32_util.c --
 *
 */

#include	<stdio.h>
#include	<signal.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant32_external.h"
#include	"ant_external.h"
#include	"ad32_util.h"

#define	MAX_CMD_LEN	1024

#define	MAX_STRING_LEN	(8 * 1024)

extern	ant_symtab_t	*labelTable;
extern	int		ant32Verbose;

static	void	ant_debug_help (ant_asm_stmnt_t *stmnt);
void		ant32_dbg_catch_intr (int code);
static	int	get_cmd (FILE *in, FILE *out, char *buf, unsigned int buflen);
static	void	print_labels (ant_asm_stmnt_t *stmnt, int all);
static int exec_next (ant_t *ant, int trace, int surface);
static int print_region (int cmd, ant_t *ant, ant_asm_stmnt_t *stmnt);

ant_asm_str_id_t commands [] = {
	{ "?",		DBG_HELP	},
	{ "h",		DBG_HELP	},
	{ "q",		DBG_QUIT	},
	{ "r",		DBG_RUN		},
	{ "g",		DBG_GO		},
	{ "n",		DBG_NEXT	},
	{ "rl",		DBG_RELOAD	},
	{ "j",		DBG_JUMP	},
	{ "t",		DBG_TRACE	},
	{ "b",		DBG_SET_BP	},
	{ "c",		DBG_CLEAR_BP	},
	{ "p",		DBG_PRINT_REG	},
	{ "pw",		DBG_PRINT_WDATA	},
	{ "pb",		DBG_PRINT_BDATA	},
	{ "pi",		DBG_PRINT_INST	},
	{ "pc",		DBG_PRINT_CYCLE },
	{ "lc",		DBG_LC		},
	{ "st4",	DBG_ST4		},
	{ "sw",		DBG_ST4		},
	{ "st1",	DBG_ST1		},
	{ "sb",		DBG_ST1		},
	{ "l",		DBG_PRINT_LABEL	},
	{ "la",		DBG_PRINT_ALL_LABEL },
	{ "v", 		DBG_V2P		},
	{ "S", 		DBG_STATUS	},
	{ "T", 		DBG_TLB		},
	{ "rn",		DBG_REG_NAMES	},
	{ "im",		DBG_INST_MODE	},
	{ NULL,		0		}
};

/*
 * ant_debug --
 *
 */

int ant_debug (ant_t *ant, char *filename)
{
	int		rc;
	ant_dbg_op_t	cmd;
	unsigned int	i;
	char		buf [MAX_CMD_LEN];
	int showTrace	= 0;
	int showSurface	= 1;
	ant_asm_stmnt_t stmnt;
	int errors;
	int value;
	char value1;
	ant_pc_t orig_pc = ant->pc;
	char *str;
	char *copy;

	ant_parse_setup (commands);

	signal (SIGINT, ant32_dbg_catch_intr);

	for (;;) {
		printf ("\n");
		ant_dbg_show_curr_inst (ant, showSurface);

		ant_asm_stmnt_clear (&stmnt);

		for (;;) {
			if (get_cmd (stdin, stdout, buf, MAX_CMD_LEN)) {
				return (0);
			}

			copy = ant_asm_clean_str (buf);

			/*
			 * If the line was utterly empty, skip it.
			 */

			if (strlen (copy) == 0) {
				free (copy);
				continue;
			}
			else {
				break;
			}
		}

		rc = parse_stmnt (copy, &stmnt, commands, 0, 1);
		free (copy);
		if (rc != 0) {
			printf ("\tERROR: %s\n", AntErrorStr);
			continue;
		}

		cmd = stmnt.op;
		errors = 0;
		for (i = 0; i < stmnt.num_args; i++) {
			if (stmnt.args [i].type == REG_ARG) {
				stmnt.args [i].val =
						ant->reg [stmnt.args [i].reg];
			}
			else if (stmnt.args [i].type == LABEL_ARG) {
				if (!find_symbol (labelTable,
						stmnt.args [i].label, &value)) {
					stmnt.args [i].type = INT_ARG;
					stmnt.args [i].val = value;
				}
				else {
					printf ("\tERROR: undefined label ($%s).\n",
							stmnt.args [i].label);
					errors = 1;
					break;
				}
			}
			else if (stmnt.args [i].type != INT_ARG) {
				printf ("\tERROR: arguments must be registers, labels or constants.\n");
				errors = 1;
				break;
			}

			stmnt.args [i].val += stmnt.args [i].offset;

		}

		if (errors) {
			continue;
		}

		switch (cmd) {
		case DBG_HELP:
			ant_debug_help (&stmnt);
			break;

		case DBG_QUIT:
			return (0);
			break;

		case DBG_RELOAD:
			if (stmnt.num_args > 0) {
				printf ("\tERROR: too many arguments.\n");
				break;
			}

			/*
			 * Before we can reload, we need to "unload".
			 * Otherwise, the symbol table can get gummed up.
			 */

			clear_symtab (labelTable);
			labelTable = NULL;

			rc = ant_load_dbg (filename, ant, &labelTable);
			if (rc != 0) {
				printf ("\tERROR: Couldn't load file [%s].\n",
						filename);
				return (-1);
			}
			rc = ant_reset (ant);
			if (rc != 0) {
				printf ("ERROR: cannot reset the CPU properly.\n");
				exit (1);
			}
			orig_pc = ant->pc;

			break;

		case DBG_RUN:
			if (stmnt.num_args == 0) {
				ant->pc = orig_pc;
			}
			else if (stmnt.num_args == 1) {
				ant->pc = stmnt.args [0].val;
				printf ("pc = %x\n", ant->pc);
			}
			else {
				printf ("\tERROR: too many arguments.\n");
				break;
			}

			ant_exec_dbg (ant, showTrace, showSurface);
			break;

		case DBG_GO:
			if (stmnt.num_args > 0) {
				printf ("\tERROR: too many arguments.\n");
				break;
			}

			ant_exec_dbg (ant, showTrace, showSurface);
			break;

		case DBG_NEXT:
			if (stmnt.num_args > 0) {
				printf ("\tERROR: too many arguments.\n");
				break;
			}
			exec_next (ant, showTrace, showSurface);
			break;

		case DBG_JUMP:
			if (stmnt.num_args != 1) {
				printf ("\tERROR: one argument required.\n");
				break;
			}

			if ((stmnt.args [0].val % sizeof (ant_inst_t)) != 0) {
				printf ("\tERROR: Misaligned PC!\n");
			}
			else {
				ant->pc = stmnt.args [0].val;
				printf ("Set PC to 0x%x.\n", stmnt.args [0].val);
			}
			break;

		case DBG_TRACE:
			if (stmnt.num_args == 0) {
				printf ("Toggling trace mode.\n");
				showTrace = (showTrace == 0);
			}
			else if (stmnt.num_args == 1) {
				showTrace = (stmnt.args [0].val != 0);
			}
			else {
				printf ("\tERROR: Too many arguments.\n");
				break;
			}

			if (showTrace) {
				printf ("Trace mode ON.\n");
			}
			else {
				printf ("Trace mode OFF.\n");
			}
			break;

		case DBG_PRINT_REG:
			if (stmnt.num_args == 0) {
				str = ant32_dump_regs (ant, 1);
				printf ("%s\n", str);
				free (str);
			}
			else {
				for (i = 0; i < stmnt.num_args; i++) {
					if (stmnt.args [i].type != REG_ARG) {
						break;
					}
					if (stmnt.args [i].offset != 0) {
						break;
					}
				}
				if (i != stmnt.num_args) {
					printf ("\tUsage: arguments to 'p' must be register names.\n");
					break;
				}

				for (i = 0; i < stmnt.num_args; i++) {
					ant32_print_reg (stdout, ant,
							stmnt.args [i].reg);
				}
			}
			break;

		case DBG_PRINT_CYCLE:
			if (stmnt.num_args != 0) {
				printf ("\tUsage: 'pc' does not accept argument.\n");
				break;
			}

			str = ant32_dump_cycle (ant, 1);
			printf ("%s\n", str);
			free (str);

			break;

		case DBG_PRINT_WDATA:
		case DBG_PRINT_BDATA:
		case DBG_PRINT_INST:

			print_region (cmd, ant, &stmnt);

			break;
		case DBG_LC	:
			if (stmnt.num_args != 2 ||
					stmnt.args [0].type != REG_ARG ||
					stmnt.args [1].type != INT_ARG) {
				printf ("\tUsage: lc reg, val\n");
				break;
			}

			if (stmnt.args [0].reg != ZERO_REG) {
				ant->reg [stmnt.args [0].reg] =
						stmnt.args [1].val;
			}
			break;

		case DBG_ST4	:
			if (stmnt.num_args != 2) {
				printf ("\tUsage: st4 val, addr\n");
				break;
			}

			value = stmnt.args [0].val;
			rc = do_load_store (4, ANT_MEM_WRITE, ant,
					stmnt.args [1].val, &value, 0);
			if (rc != ANT_EXC_OK) {
				printf ("\tBad address with st4.\n");
			}

			break;

		case DBG_ST1	:
			if (stmnt.num_args != 2) {
				printf ("\tUsage: st1 val, addr, val\n");
				break;
			}

			value1 = LOWER_BYTE (stmnt.args [0].val);
			rc = do_load_store (1, ANT_MEM_WRITE, ant,
					stmnt.args [1].val, &value1, 0);
			if (rc != ANT_EXC_OK) {
				printf ("\tBad address with st1.\n");
			}

			break;

		case DBG_PRINT_LABEL:
			print_labels (&stmnt, 0);
			break;

		case DBG_PRINT_ALL_LABEL:
			print_labels (&stmnt, 1);
			break;

		case DBG_TLB:
			str = ant32_dump_tlb (ant, 1);
			printf ("%s\n", str);
			free (str);
			break;

		case DBG_STATUS:
			ant32_show_state (stdout, ant, 1);
			break;

		case DBG_V2P:
			if (stmnt.num_args == 0) {
				printf ("\tERROR: missing address.\n");
			}
			else if (stmnt.num_args > 1) {
				printf ("\tERROR: more than one address.\n");
			}
			else {
				ant_paddr_t p;
				ant_exc_t fault;

				p = ant32_v2p (stmnt.args [0].val, ant,
						ant->mode, 0, &fault, 0);

				if (fault == ANT_EXC_OK) {
					printf ("virtual %.8x -> ",
						stmnt.args [0].val);
					printf ("physical %.8x\n", p);
				}
				else {
					printf ("virtual %.8x -> FAULT: %s\n",
						stmnt.args [0].val,
						ant_status_desc (fault));
				}
			}

			break;

		case DBG_SET_BP :
			if (stmnt.num_args < 1) {
				printf ("\tUsage: b addr [, addr ...]\n");
			}
			else {
				for (i = 0; i < stmnt.num_args; i++) {
					ant32_set_breakpoint (stmnt.args [i].val);
				}
			}
			break;

		case DBG_CLEAR_BP :
			if (stmnt.num_args == 0) {
				printf ("Clearing all breakpoints.\n");
				ant32_clear_breakpoints ();
			}
			else {
				for (i = 0; i < stmnt.num_args; i++) {
					ant32_clear_breakpoint (stmnt.args [i].val);
				}
			}
			break;

		case DBG_REG_NAMES :
			if (stmnt.num_args != 1) {
				printf ("\tUsage: rn const\n");
			}
			else {
				rc = ant32_reg_names_change (stmnt.args [0].val);
				if (rc != 0) {
					printf ("\tInvalid register names (%c).\n",
							stmnt.args [0].val);
				}
			}
			break;

		case DBG_INST_MODE :
			showSurface = (showSurface == 0) ? 1 : 0;

			if (showSurface) {
				printf ("MODE: showing original source code.\n");
			}
			else {
				printf ("MODE: showing machine instructions.\n");
			}

			break;

		default		:
			printf ("Unknown cmd: type 'h' for help.\n");
			break;
		}
	}
}

static unsigned long absorb_unused;

static	void	ant_debug_help (ant_asm_stmnt_t *stmnt)
{
char *help = 
"h                     Print this help screen.\n"
"q                     Quit the debugger.\n"
"r [addr]              Run (beginning from start of image, or addr).\n"
"g                     Continue execution from the current address.\n"
"n                     Execute the next instruction and then stop.\n"
"rl                    Reload the program and reinitialize data memory.\n"
"j addr                Jump to the specified address.\n"
"t [val]               Toggle trace mode on/off, or set trace mode to val (0/1).\n"
"b addr [, addr...]    Set breakpoints at the specified addresses.\n"
"c [addr [, addr...]]  Remove the breakpoints at the specified addresses.\n"
"p [reg [, reg...]]    Print the contents of registers.\n"
"                      If no registers are specified, all are printed.\n"
"lc reg, value         Load the specified reg with the given value.\n"
"l [addr [, addr...]]  Print the numeric value of labels or addresses.\n"
"                      If no labels or addresses are given, print all\n"
"                      labels except those defined in the ROM.\n"
"la [addr [, addr...]] Print the numeric value of labels or addresses.\n"
"                      If no labels or addresses are given, print all\n"
"                      labels, including those defined in the ROM.\n"
"pw addr [, cnt]       Print the contents of data memory (as words).\n"
"pb addr [, cnt]       Print the contents of data memory (as bytes).\n"
"st4 val, addr         Store val to the given address (as a 4-byte word)\n"
"st1 val, addr         Store val to the given address (as a byte)\n"
"pc                    Print the cycle counters.\n"
"pi [addr [, cnt]]     Disassemble instructions.\n"
"v addr                Print the physical address associated\n"
"                      with the given virtual address.\n"
"S                     Print CPU status and kernel and exception registers.\n"
"T                     Print the contents of the TLB.\n"
"rn mnemonic           Change the mnemonics used for the register names.\n"
"                      The possible names are 'g', 'r', and 'c'.\n"
"im                    Toggle instruction mode between macro mode and native\n"
"                      instructions only.\n"
"\n"
"\taddr can be specified in decimal, octal, hex, or as a label.\n"
"\tAll addresses are virtual addresses, unless otherwise specified.\n"
"\n";

	absorb_unused += (unsigned long)stmnt;

/* XXX: ad_help() doesn't exist yet, it exists in Ant8 though */
//	if (stmnt->num_args == 1) {
//		ad_help (stmnt->args [0].val);
//	}
//	else {
		printf ("%s", help);
//	}

	return ;
}

static unsigned long absorb_unused;

void ant32_dbg_catch_intr (int code)
{

	absorb_unused += code;

	signal (SIGINT, ant32_dbg_catch_intr);

	ant32_dbg_intr (1);

	return ;
}

static int get_cmd (FILE *in, FILE *out, char *buf, unsigned int buflen)
{
	char *ptr;

		/* Ignore EOF sent to the program, if any. */

	if (feof (in)) {
		clearerr (in);
	}

	for (;;) {
		fprintf (out, ">> ");

		ptr = fgets (buf, buflen, in);
		if (ptr == NULL) {
			if (feof (in)) {
				return (-1);
			}
			fprintf (out, "\n");
		}

		if (ant32Verbose) {
			fprintf (out, "%s", buf);
		}

		ptr = skip_whitespace (buf);
		if (strlen (ptr) > 0) {
			break;
		}
	}

	return (0);
}

static void print_labels (ant_asm_stmnt_t *stmnt, int all)
{
	char *str;
	unsigned int i;

	if (stmnt->num_args < 1) {
		str = dump32_symtab_human (labelTable, all);
		printf ("%s\n", str);
		free (str);
		return ;
	}

	for (i = 0; i < stmnt->num_args; i++) {
		if (stmnt->args [i].label != NULL) {
			if (stmnt->args [i].offset == 0) {
				printf ("\t0x%.8x = %11d = $%s",
					stmnt->args [i].val,
					stmnt->args [i].val,
					stmnt->args [i].label);
			}
			else {
				printf ("\t0x%.8x = %11d = $%s+0x%x",
					stmnt->args [i].val,
					stmnt->args [i].val,
					stmnt->args [i].label,
					stmnt->args [i].offset);
			}
		}
		else {
			printf ("\t0x%.8x = %11d",
					stmnt->args [i].val,
					stmnt->args [i].val);
		}

		if ((stmnt->args [i].label == NULL) ||
				(stmnt->args [i].offset != 0)) {

			/*
			 * if the argument wasn't a simple label, but
			 * the argument is in fact the address of a
			 * label, mention this label as well.
			 */
				 
			if (0 == find_value (labelTable, &str,
					stmnt->args [i].val)) {
				printf (" = $%s\n", str);
			}
			else {
				printf ("\n");
			}
		}
	}
	return ;
}

/*
 * When we do a "next", what we really try to do is "run to the next
 * instruction I actually asked for".  Due to the differences between
 * the surface language and the machine instructions, each instruction
 * in the surface world might expand to several machine instructions. 
 * We want to make this look natural to the user, by trying to only
 * stop at instructions that are not the by-product of this expansion
 * except for the first instruction in an expansion, which represents
 * the expansion). 
 */

static int exec_next (ant_t *ant, int trace, int surface)
{

	if (!surface) {
		return (ant_exec_inst_dbg (ant, trace, surface));
	}
	else {
		for (;;) {
			ant32_lcode_t lcode;
			ant_exc_t rc;
			char *str;

			rc = ant_exec_inst_dbg (ant, trace, surface);
			if (rc != ANT_EXC_OK) {
				ant_exec_dbg_exc (ant, rc);
				return (rc);;
			}

			/*
			 * If we can't figure out where the next
			 * instruction came from, or we know that the
			 * next instruction is the first element in an
			 * expansion, stop and return the rc from
			 * executing the previous instruction.
			 */

			str = ant32_code_line_lookup (ant->pc, &lcode);
			if ((str == NULL) || (lcode != SYNTHETIC)) {
				return (rc);
			}
		}
	}
}


static int print_region (int cmd, ant_t *ant, ant_asm_stmnt_t *stmnt)
{
	char *cmd_name;
	unsigned int addr;
	unsigned int count;
	char *str;

	switch (cmd) {
		case DBG_PRINT_WDATA: cmd_name = "pw"; break;
		case DBG_PRINT_BDATA: cmd_name = "pb"; break;
		case DBG_PRINT_INST: cmd_name = "pi"; break;
		default: cmd_name = "??"; break;
	}

	if (stmnt->num_args != 1 && stmnt->num_args != 2) {
		printf ("\tUsage: %s addr [, cnt]\n", cmd_name);
		return (-1);
	}

	if (stmnt->num_args == 2) {
		count = stmnt->args [1].val;
	}
	else {
		count = 1;
	}

	if (stmnt->args [0].type == REG_ARG) {
		addr = stmnt->args [0].val;
	}
	else if (stmnt->args [0].type == INT_ARG) {
		addr = stmnt->args [0].val;
	}
	else {
		printf ("\tThe address must be a constant or register name.\n");
		return (-1);
	}

	switch (cmd) {
		case DBG_PRINT_WDATA:
			str = ant32_dump_vmem_words (ant, addr, count, 1);
			break;

		case DBG_PRINT_BDATA:
			str = ant32_dump_vmem_bytes (ant, addr, count, 1);
			break;

		case DBG_PRINT_INST:
			str = ant32_dump_vmem_insts (ant, addr, count, 1);
			break;

		default:
			return (-1);	/* &&& Complain!!! */
	}

	printf ("%s", str);
	free (str);

	return (0);
}

/*
 * end of ad32_util.c
 */
