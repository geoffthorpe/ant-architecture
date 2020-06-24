/*
 * $Id: ad8_util.c,v 1.15 2001/12/16 19:35:10 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 06/09/2000
 *
 * ad8_util.c --
 *
 */

#include	<stdio.h>
#include	<signal.h>
#include	<string.h>
#include	<stdlib.h>

#include	"ant8_external.h"
#include	"ad8_util.h"

#define	MAX_CMD_LEN	1024

#define	MAX_STRING_LEN	(8 * 1024)

extern	int		ant8Verbose;

static	void	ant_debug_help (ant_asm_stmnt_t *stmnt);
void		ant8_dbg_catch_intr (int code);
static	int	get_cmd (FILE *in, FILE *out, char *buf, unsigned int buflen);

static int check_addr_arg (int addr, int max);
static int check_raw_addrs (int start, int end);
static int check_addrs2 (ant_asm_stmnt_t *stmnt, int *start,
			int *end, int max);
static int check_all_ints (ant_asm_stmnt_t *stmnt, char *op);
static int check_all_regs (ant_asm_stmnt_t *stmnt, char *op);
static int zero_mem (ant_asm_stmnt_t *stmnt, ant_data_t *data);
static int part_dump (ant_asm_stmnt_t *stmnt, ant_data_t *data);
static int part_disasm (ant_asm_stmnt_t *stmnt, ant_t *ant);
static int store_data (ant_asm_stmnt_t *stmnt,
		ant_data_t *data, ant_reg_t *regs);
char *print_labels (ant_asm_stmnt_t *stmnt);


ant_asm_str_id_t commands [] = {
	{ "?",	DBG_HELP	},
	{ "h",	DBG_HELP	}, { "help",	DBG_HELP	},
	{ "q",	DBG_QUIT	}, { "quit",	DBG_QUIT	},
	{ "r",	DBG_RUN		}, { "run",	DBG_RUN		},
	{ "R",	DBG_RELOAD	}, { "Reload",	DBG_RELOAD	},
	{ "g",	DBG_GO		}, { "go",	DBG_GO		},
	{ "j",	DBG_JUMP	}, { "jump",	DBG_JUMP	},
	{ "b",	DBG_BREAK	}, { "break",	DBG_BREAK	},
	{ "c",	DBG_CLEAR_BP	}, { "clear",	DBG_CLEAR_BP	},
	{ "t",	DBG_TRACE	}, { "trace",	DBG_TRACE	},
	{ "n",	DBG_NEXT	}, { "next",	DBG_NEXT	},
	{ "p",	DBG_PRINT_REG	}, { "print",	DBG_PRINT_REG	},
	{ "d",	DBG_PRINT_DADDR	}, { "data",	DBG_PRINT_DADDR	},
	{ "i",	DBG_PRINT_IADDR	}, { "inst",	DBG_PRINT_IADDR	},
	{ "l",	DBG_PRINT_LABEL	}, { "label",	DBG_PRINT_LABEL	},
	{ "z",	DBG_ZERO	}, { "zero",	DBG_ZERO	},
	{ "s",	DBG_STORE	}, { "store",	DBG_STORE	},
	{ "w",  DBG_WATCH	}, { "watch",	DBG_WATCH	},
	{ "u",  DBG_CLEAR_WP	}, { "unwatch",	DBG_CLEAR_WP	},
	{ NULL, 0		}
};

static	ant_asm_str_id_t	reg_names []	= {
	{ "r0",  0 }, { "r1",  1 }, { "r2",  2 }, { "r3",  3 },
	{ "r4",  4 }, { "r5",  5 }, { "r6",  6 }, { "r7",  7 },
	{ "r8",  8 }, { "r9",  9 }, { "r10",10 }, { "r11",11 },
	{ "r12",12 }, { "r13",13 }, { "r14",14 }, { "r15",15 },
	{ NULL,	 0 }
};

/*
 * ant_debug --
 *
 */

int		ant_debug (ant_t *ant, char *filename)
{
	int		rc;
	ant_dbg_op_t	cmd;
	ant_dbg_bp_t	ant_dbg;
	unsigned int	i;
	int		trace	= 0;
	char		buf [MAX_CMD_LEN];
	ant_arg_type_t arg_type;
	ant_asm_stmnt_t stmnt;
	int errors;
	int value;
	ant_inst_t inst;
	char dis_buf [1024];

	ant_parse_setup (commands);
	ant8_wp_init ();

	signal (SIGINT, ant8_dbg_catch_intr);

	ant_dbg_clear_bp (&ant_dbg);

	for (;;) {
		char *copy;

		arg_type = UNKNOWN_ARG;

		inst = ant_fetch_instruction (ant, ant->pc);
		ant_disasm_inst (inst, ant->pc, ant->reg, dis_buf, 1);
		printf ("\n%s\n", dis_buf);

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

		/*
		 * &&& Handle "help" as a special case.  This is necessary,
		 * at least right now, because the statement parser does
		 * not know how to deal with anything that doesn't look like
		 * an asm language line, and help requests don't!
		 *
		 * It's a help request, p
		 */

		rc = ad_parse_help (copy, &cmd, commands);
		if (rc == 0) {
			ad_help (cmd);
			free (copy);
			continue;
		}

		rc = parse_stmnt (copy, &stmnt, commands, 0, 1);
		free (copy);
		if (rc != 0) {
			printf ("\tERROR: %s\n", AntErrorStr);
			continue;
		}

		cmd = stmnt.op;
		errors = 0;

		/*
		 * Find the values of labels, and fill in the values
		 * corresponding with registers, wherever necessary.
		 *
		 * We could do this later, just for the operations where
		 * it is necessary, but it simplifies the code to just
		 * get it done here.
		 */

		for (i = 0; i < stmnt.num_args; i++) {
			if (stmnt.args [i].type == LABEL_ARG) {
				if (!find_symbol (labelTable,
						stmnt.args [i].label, &value)) {
					stmnt.args [i].val = value;
				}
				else {
					printf ("\tERROR: undefined label ($%s).\n",
							stmnt.args [i].label);
					errors = 1;
					break;
				}
			}
			else if (stmnt.args [i].type == REG_ARG) {
				value = ant->reg [stmnt.args [i].reg];
				stmnt.args [i].val = value;
			}

			/*
			 * Add in the offset...  There is a chance
			 * that this will overflow (or underflow) but
			 * that should be detected and handled later.
			 */

			stmnt.args [i].val += stmnt.args [i].offset;
		}

		if (errors) {
			continue;
		}

		switch (cmd) {
		case DBG_HELP:
			/* &&& help should be handled above. */
			ANT_ASSERT (0);
			break;

		case DBG_QUIT:
			return (0);
			break;

		case DBG_RELOAD:
			if (stmnt.num_args > 0) {
				printf ("\tERROR: 'Reload' does not take any arguments.\n");
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

			/*
			 * After reloading, there's a possibility that
			 * all the watchpoints will trigger.  We don't
			 * want that, so force an update.
			 */

			ant8_wp_update (ant);

			break;

		case DBG_RUN:
			if (stmnt.num_args > 1) {
				printf ("\tERROR: too many arguments to 'run'.\n");
				break;
			}
			else if (stmnt.num_args == 0) {
				ant->pc = 0;
			}
			else if ((stmnt.args [0].type != INT_ARG) &&
					(stmnt.args [0].type != LABEL_ARG) &&
					(stmnt.args [0].type != REG_ARG)) {
				printf ("\tERROR: the argument to 'run' "
					"must be an integer, label, or register.\n");
				break;
			}
			else if (! check_addr_arg (stmnt.args [0].val,
						ANT_INST_ADDR_RANGE)) {
				break;
			}
			else {
				ant->pc = stmnt.args [0].val;
			}

			ant_exec_dbg (ant, &ant_dbg, trace);
			break;

		case DBG_GO:
			if (stmnt.num_args > 0) {
				printf ("\tERROR: 'go' does not take any arguments.\n");
				break;
			}

			ant_exec_dbg (ant, &ant_dbg, trace);
			break;

		case DBG_NEXT:
			if (stmnt.num_args > 0) {
				printf ("\tERROR: 'next' does not take any arguments.\n");
				break;
			}

			ant_exec_inst_dbg (ant, &ant_dbg, trace);
			break;

		case DBG_JUMP:
			if (stmnt.num_args != 1) {
				printf ("\tERROR: 'jump' requires one argument.\n");
				break;
			}
			else if ((stmnt.args [0].type != INT_ARG) &&
					(stmnt.args [0].type != LABEL_ARG) &&
					(stmnt.args [0].type != REG_ARG)) {
				printf ("\tERROR: the argument to 'jump' "
					"must be an integer, label or register.\n");
				break;
			}

			value = stmnt.args [0].val;

			if (check_addr_arg (value, ANT_INST_ADDR_RANGE)) {
				if ((value % 2) != 0) {
					printf ("\tWARNING:"
					" setting the PC to an odd address!\n");
				}
				ant->pc = value;
				printf ("Set PC to 0x%x.\n", value);
			}
			break;

		case DBG_TRACE:
			if (stmnt.num_args > 1) {
				printf ("\tERROR: too many arguments to 'trace'.\n");
				break;
			}
			else if (stmnt.num_args == 0) {
				printf ("Toggling trace mode.\n");
				trace = (trace == 0);
			}
			else if (stmnt.args [0].type != INT_ARG) {
				printf ("\tERROR: the argument to 'trace' "
					"must be an integer.\n");
				break;
			}
			else {
				trace = (stmnt.args [0].val != 0);
			}

			if (trace) {
				printf ("Trace mode ON.\n");
			}
			else {
				printf ("Trace mode OFF.\n");
			}
			break;

		case DBG_BREAK:
			if (stmnt.num_args == 0) {
				printf ("\tERROR: 'break' requires at least one argument.\n");
				break;
			}
			else if (check_all_ints (&stmnt, "break")) {
				break;
			}

			for (i = 0; i < stmnt.num_args; i++) {
				value = stmnt.args [i].val;

				if (check_addr_arg (value, ANT_INST_ADDR_RANGE)) {
					ant8_dbg_bp_set (&ant_dbg, value, 1);
					printf ("Set breakpoint at 0x%x.\n",
							value);
				}
			}
			break;

		case DBG_CLEAR_BP:
			if (stmnt.num_args == 0) {
				ant_dbg_clear_bp (&ant_dbg);
				printf ("Cleared all breakpoints.\n");
				break;
			}
			else if (check_all_ints (&stmnt, "clear")) {
				break;
			}

			for (i = 0; i < stmnt.num_args; i++) {
				value = stmnt.args [i].val;

				if (check_addr_arg (value,
						ANT_INST_ADDR_RANGE)) {
					ant8_dbg_bp_set (&ant_dbg, value, 0);
					printf ("Cleared breakpoint at 0x%x.\n",
							value);
				}
			}
			break;

		case DBG_WATCH:
			if (stmnt.num_args == 0) {
				printf ("\tERROR: 'watch' requires at least one argument.\n");
				break;
			}
			else if (check_all_ints (&stmnt, "watch")) {
				break;
			}

			for (i = 0; i < stmnt.num_args; i++) {
				value = stmnt.args [i].val;

				if (check_addr_arg (value,
						ANT_INST_ADDR_RANGE)) {
					ant8_wp_set (ant, value);
					printf ("Set watchpoint at 0x%x.\n",
							value);
				}
			}
			break;

		case DBG_CLEAR_WP:
			if (stmnt.num_args == 0) {
				ant8_wp_init ();
				printf ("Cleared all watchpoints.\n");
				break;
			}
			else if (check_all_ints (&stmnt, "cw")) {
				break;
			}

			for (i = 0; i < stmnt.num_args; i++) {
				value = stmnt.args [i].val;
				if (check_addr_arg (value,
						ANT_INST_ADDR_RANGE)) {
					ant8_wp_clear (value);
					printf ("Cleared watchpoint at 0x%x.\n",
							value);
				}
			}
			break;

		case DBG_PRINT_REG:
			if (stmnt.num_args == 0) {
				ant_print_reg (stdout, ant);
				break;
			}
			else if (check_all_regs (&stmnt, "print")) {
				break;
			}
			else {
				int args [ANT_ASM_MAX_ARGS];

				for (i = 0; i < stmnt.num_args; i++) {
					args [i] = stmnt.args [i].reg;
				}

				ant_print_reg_vec (stdout, ant,
						args, stmnt.num_args);
			}
			break;

		case DBG_PRINT_DADDR:
			if (stmnt.num_args == 0) {
				ant_disasm_d_mem_print (ant);
				printf ("\n");
			}
			else {
				part_dump (&stmnt, ant->data);
				printf ("\n");
			}
			break;

		case DBG_PRINT_IADDR: {
			if (stmnt.num_args == 0) {
				ant_disasm_i_mem_print (ant);
			}
			else {
				part_disasm (&stmnt, ant);
			}
			break;
		}

		case DBG_ZERO:
			zero_mem (&stmnt, ant->data);
			break;

		case DBG_STORE:
			store_data (&stmnt, ant->data, ant->reg);
			break;

		case DBG_PRINT_LABEL:

			if (check_all_ints (&stmnt, "label")) {
				break;
			}
			else {
				char *str = print_labels (&stmnt);

				printf ("%s", str);
				free (str);
			}
			break;

		default		:
			printf ("Unknown cmd: type 'h' for help.\n");
			break;
		}
	}
}

static	void	ant_debug_help (ant_asm_stmnt_t *stmnt)
{
	char *help = 
	"help [cmd]    Get help about debugger commands.\n"
	"quit          Quit the debugger.\n"
	"go            Start (or continue) executing the program.\n"
	"run   [addr]  Run the program (starting from PC = 0, or addr).\n"
	"next          Execute the next instruction and then break.\n"
	"print         Print the contents of the registers.\n"
	"Reload        Reload the program and reinitialize data memory.\n"
	"jump  addr    Set the PC to the specified address.\n"
	"trace [val]   Toggle or set trace mode.\n"
	"\n"
	"store  addr, val           Store val to the specified address.\n"
	"break  addr [, addr...]    Set breakpoints at the specified addresses.\n"
	"clear [addr [, addr...]]   Remove the breakpoints at the specified addresses.\n"
	"watch  addr [, addr...]    Set watchpoints at the specified addresses.\n"
	"unwatch [addr [, addr...]] Remove the watchpoints at the specified addresses.\n"
	"label [addr [, addr...]]   Print the numeric value of addresses.\n"
	"data [addr [, addr]]       Print the contents of data memory.\n"
	"inst [addr [, addr]]       Disassemble instructions.\n"
	"zero [addr [, addr]]       Set the given addresses to zero.\n"
	"\n"
	"\taddr can be specified in decimal, octal, hex, or as a label.\n"
	"\n"
	"Each command can be abbreviated by its first letter.\n"
	"\n";

	if (stmnt->num_args == 1) {
		ad_help (stmnt->args [0].val);
	}
	else {
		printf ("%s", help);
	}

	return ;
}

void ant8_dbg_catch_intr (int code)
{

	if (&code) (void) 0 /* unused param */ ;

	signal (SIGINT, ant8_dbg_catch_intr);

	ant8_dbg_intr (1);

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

		if (ant8Verbose) {
			fprintf (out, "%s", buf);
		}

		ptr = skip_whitespace (buf);
		if (strlen (ptr) > 0) {
			break;
		}
	}

	return (0);
}

static int check_addr_arg (int addr, int max)
{

	if ((addr < max) && (addr >= 0)) {
		return (1);
	}
	else if (addr >= max) {
		printf ("\tERROR: addr >= %d.\n", max);
		return (0);
	}
	else {
		printf ("\tERROR: addr < 0.\n");
		return (0);
	}
}

static int check_addrs2 (ant_asm_stmnt_t *stmnt, int *start, int *end, int max)
{

	ANT_ASSERT (start != NULL);
	ANT_ASSERT (end != NULL);

	if (stmnt->num_args > 2) {
		printf ("\tERROR: too many arguments.\n");
		return (-1);
	}

	if (stmnt->num_args == 0) {
		*start = 0;
		*end = max;
	}
	else if (stmnt->num_args == 1) {
		*start = stmnt->args [0].val;
		*end = *start;
	}
	else if (stmnt->num_args == 2) {
		*start = stmnt->args [0].val;
		*end = stmnt->args [1].val;
	}

	return (check_raw_addrs (*start, *end));
}

static int check_raw_addrs (int start, int end)
{

	if (start < 0 || end < 0) {
		printf ("\tERROR: addresses must be >= 0.\n");
		return (-1);
	}
	else if ((start >= ANT_DATA_ADDR_RANGE) ||
			(end > ANT_DATA_ADDR_RANGE)) {
		printf ("\tERROR: addresses must be < %d.\n",
				ANT_DATA_ADDR_RANGE);
		return (-1);
	}
	else if (start > end) {
		printf ("\tERROR: start addr cannot be greater than end addr.\n");
		return (-1);
	}
	else {
		return (0);
	}
}

/*
 * check to make sure that all the operands are ints (including
 * labels, and registers).
 */

static int check_all_ints (ant_asm_stmnt_t *stmnt, char *op)
{
	unsigned int i;

	for (i = 0; i < stmnt->num_args; i++) {
		if ((stmnt->args [i].type != INT_ARG) &&
				(stmnt->args [i].type != LABEL_ARG) &&
				(stmnt->args [i].type != REG_ARG)) {
			break;
		}
	}

	if (i != stmnt->num_args) {
		printf ("\tERROR: the arguments to '%s' "
			"must be integers, labels, or registers.\n", op);
		return (1);
	}

	return (0);
}

/*
 * check to make sure that all the operands are registers.
 */

static int check_all_regs (ant_asm_stmnt_t *stmnt, char *op)
{
	unsigned int i;

	for (i = 0; i < stmnt->num_args; i++) {
		if (stmnt->args [i].type != REG_ARG) {
			break;
		}
	}

	if (i != stmnt->num_args) {
		printf ("\tERROR: the arguments to '%s' "
			"must be registers.\n", op);
		return (1);
	}

	return (0);
}

static int zero_mem (ant_asm_stmnt_t *stmnt, ant_data_t *data)
{
	int start, end;
	int i;

	if (check_all_ints (stmnt, "zero")) {
		return (-1);
	}

	if (stmnt->num_args == 0) {
		start = 0;
		end = ANT_DATA_ADDR_RANGE - 1;
	}
	else if (stmnt->num_args == 1) {
		start = stmnt->args [0].val;
		end = start;
	}
	else if (stmnt->num_args == 2) {
		if (check_addrs2 (stmnt, &start, &end, MAX_DATA) != 0) {
			return (-1);
		}
	}
	else {
		printf ("\tERROR: 'zero' takes at most two arguments.\n");
		return (-1);
	}

	if (check_raw_addrs (start, end) != 0) {
		return (-1);
	}

	for (i = start; i <= end; i++) {
		data [i] = 0;
	}

	return (0);
}

static int part_dump (ant_asm_stmnt_t *stmnt, ant_data_t *data)
{
	int start, end;
	char buf [8 * 1024];

	if (check_all_ints (stmnt, "data")) {
		return (-1);
	}

	if (check_addrs2 (stmnt, &start, &end, MAX_DATA) != 0) {
		return (-1);
	}

	ant_disasm_data_block (data, start, end - start + 1, buf, 1);
	printf ("%s", buf);

	return (0);
}

static int part_disasm (ant_asm_stmnt_t *stmnt, ant_t *ant)
{
	int start, end;
	int i;
	char buf [1024];
	ant_inst_t inst;

	if (check_all_ints (stmnt, "data")) {
		return (-1);
	}

	if (check_addrs2 (stmnt, &start, &end, MAX_DATA) != 0) {
		return (-1);
	}

	for (i = start; i <= end; i += 2) {
		inst = ant_fetch_instruction (ant, i);
		ant_disasm_inst (inst, i, NULL, buf, 1);
		printf ("%s\n", buf);
	}
	printf ("\n");

	return (0);
}

static int store_data (ant_asm_stmnt_t *stmnt, ant_data_t *data,
		ant_reg_t *regs)
{

	if (stmnt->num_args != 2) {
		printf ("\tERROR: 'store' requires exactly two arguments.\n");
		return (-1);
	}

	if (stmnt->args [1].val < MIN_ANT_INT ||
			stmnt->args [1].val >= -2 * MIN_ANT_INT) {
		printf ("\tERROR: value out of range (won't fit in 8 bits).\n");
		return (-1);
	}

	if (stmnt->args [0].type == REG_ARG) {
		if (stmnt->args [0].reg == ZERO_REG) {
			printf ("\tERROR: register r%d cannot be modified.\n",
					ZERO_REG);
			return (-1);
		}

		if (stmnt->args [0].reg == SIDE_REG) {
			printf ("\tWARNING: ordinarily it not legal to modify r%d directly.\n", 
					SIDE_REG);
		}
		regs [stmnt->args [0].reg] = stmnt->args [1].val;
	}
	else {
		if ((stmnt->args [0].val < 0) ||	
				(stmnt->args [0].val >= MAX_DATA)) {
			printf ("\tERROR: address out of range.\n");
			return (-1);
		}
		data [stmnt->args [0].val] = stmnt->args [1].val;
	}

	return (0);
}

char *print_labels (ant_asm_stmnt_t *stmnt)
{
	char buf [MAX_STRING_LEN];
	unsigned int i;
			
	buf [0] = '\0';

	sprintf (buf, "\t%-4.4s  %-4.4s  %-4.4s  %-10.10s  %s  %s\n\n",
			"Dec", "Hex", "Oct", "Binary", "ASCII", "Label");

	if (stmnt->num_args < 1) {
		dump8_symtab_human (labelTable, buf + strlen (buf));
	}
	else {
		for (i = 0; i < stmnt->num_args; i++) {
			sprintf (buf + strlen (buf), "\t");
			ant_print_value_str (buf + strlen (buf),
					stmnt->args [i].val,
					stmnt->args [i].label);
			sprintf (buf + strlen (buf), "\n");
		}
	}
	sprintf (buf + strlen (buf), "\n");

	return (strdup (buf));
}

/*
 * end of ad8_util.c
 */
