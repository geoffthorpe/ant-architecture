/*
 * $Id: ad8_help.c,v 1.7 2002/05/09 14:59:55 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 07/28/99
 *
 * ad8_help.c --
 *
 */

#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>

#include	"ant8_external.h"

#define	MAX_INST	ANT_INST_ADDR_RANGE
#define	MAX_DATA	ANT_DATA_ADDR_RANGE

#define	COMMANDS	\
"Commands: help, quit, run, Reload, print, go, next, jump, trace,\n" \
"\tbreak, clear, watch, unwatch, data, inst, label, zero, store\n" \
"\n" \
"All commands can be abbreviated by their first character.\n"

static	char	*help_help	=
"\n"
"Usage: help [cmd]\n"
"Usage: h    [cmd]\n"
"\n"
"	With no arguments, prints the help screen.\n"
"\n"
"	With a character argument, prints the help screen for the\n"
"	corresponding debugger command.  For example:\n"
"\n"
"		h run\n"
"\n"
"	This command will print the help screen for the 'run' command. \n"
"\n"
;

static	char	*help_quit	=
"\n"
"Usage: quit\n"
"Usage: q\n"
"\n"
"	Quits the debugger.\n"
"\n"
;

static	char	*help_reload	=
"\n"
"Usage: Reload\n"
"Usage: R\n"
"\n"
"	Reloads the current program, including resetting the contents\n"
"	of data memory and the registers.\n"
"\n"
;

static char	*help_run	=
"\n"
"Usage: run [addr]\n"
"Usage: r   [addr]\n"
"\n"
"	Runs the current program.\n"
"\n"
"	With no argument, the PC is set to zero before the program is\n"
"	run.  If an address is specified, then the PC starts at that\n"
"	address instead of zero.\n"
"\n"
;

static	char	*help_go	=
"\n"
"Usage: go\n"
"Usage: g\n"
"\n"
"	Begins or continues the execution of the program, starting at\n"
"	the current PC.\n"
"\n"
;

static	char	*help_jump	=
"\n"
"Usage: jump addr\n"
"Usage: j    addr\n"
"\n"
"	Sets the PC to the specified address.\n"
"\n"
;

static	char	*help_trace	=
"\n"
"Usage: trace [arg]\n"
"Usage: t     [arg]\n"
"\n"
"	If no arguments are specified, the trace mode is toggled:  if\n"
"	tracing is off, it turned on, or vice versa.\n"
"\n"
"	If an argument is specified, trace mode is turned on if the\n"
"	argument is non-zero, and turned off if it is zero.\n"
"\n"
;

static	char	*help_break	=
"\n"
"Usage: break addr [, addr ...]\n"
"Usage: b     addr [, addr ...]\n"
"\n"
"	Sets a breakpoint at each of the specified addresses.\n"
"\n"
"	When execution reaches a breakpoint, the program is stopped\n"
"	and control is returned to the debugger.  While the program is\n"
"	stopped, the user can examine the state of the ANT, add or\n"
"	delete breakpoints, etc.  The program can be continued with\n"
"	the 'g' command.\n"
"\n"
;

static	char	*help_watch	=
"\n"
"Usage: watch addr [, addr ...]\n"
"Usage: w     addr [, addr ...]\n"
"\n"
"	Sets a watchpoint at each of the specified addresses.\n"
"\n"
"	If the value stored at any of the watch point addresses is changed,\n"
"	the program is stopped and control is returned to the debugger.\n"
"	While the program is stopped, the user can examine the state of the\n"
"	ANT, add or delete breakpoints, etc.  The program can be continued\n"
"	with the 'g' command.\n"
"\n"
;

static	char	*help_clear	=
"\n"
"Usage: clear [addr [, addr ...]]\n"
"Usage: c     [addr [, addr ...]]\n"
"\n"
"	Clears the breakpoint (if any) at each of the specified\n"
"	addresses.  If no addresses are specified, then all\n"
"	breakpoints are cleared.\n"
"\n"
;

static	char	*help_unwatch	=
"\n"
"Usage: unwatch [addr [, addr ...]]\n"
"Usage: u       [addr [, addr ...]]\n"
"\n"
"	Clears the watchpoint (if any) at each of the specified\n"
"	addresses.  If no addresses are specified, then all\n"
"	watchpoints are cleared.\n"
"\n"
;

static	char	*help_reg	=
"\n"
"Usage: print [reg [, reg ...]]\n"
"Usage: p     [reg [, reg ...]]\n"
"\n"
"	Prints the values of the registers.\n"
"\n"
"	If no argument is given, then the values of all of the registers\n"
"	are printed.  Otherwise, only the values of the specified registers\n"
"	are printed.\n"
"\n"
"	The first line of the display is the names of the registers. \n"
"	The second line is the value of each register, expressed in\n"
"	hex, and the third line is the value expressed in decimal.\n"
"\n"
;

static	char	*help_data	=
"\n"
"Usage: data [addr [, addr]]\n"
"Usage: d    [addr [, addr]]\n"
"\n"
"	Prints the contents of data memory.\n"
"\n"
"	If no addresses are specified, then the entire contents of\n"
"	data memory are displayed.\n"
"\n"
"	If a single address is specified, the value at that location\n"
"	in data memory is displayed.\n"
"\n"
"	If two addresses are specified, then the values of each memory\n"
"	location between the two addresses is printed.\n"
"\n"
;

static	char	*help_inst	=
"\n"
"Usage: inst [addr [, addr]]\n"
"Usage: i    [addr [, addr]]\n"
"\n"
"	Disassembles and prints the contents of instruction memory.\n"
"\n"
"	If no addresses are specified, then the entire program is\n"
"	disassembled and displayed.\n"
"\n"
"	If a single address is specified, the instruction at that\n"
"	location is disassembled and displayed.\n"
"\n"
"	If two addresses are specified, then the values of each\n"
"	instruction between the two addresses is disassembled and\n"
"	displayed.\n"
"\n"
;

static	char	*help_zero	=
"\n"
"Usage: zero [addr [, addr]]\n"
"Usage: z    [addr [, addr]]\n"
"\n"
"	Sets the contents of data memory to zero.\n"
"\n"
"	If no addresses are specified, then the entire data memory is\n"
"	set to zero values.\n"
"\n"
"	If a single address is specified, the value at that location\n"
"	in data memory is set to zero.\n"
"\n"
"	If two addresses are specified, then the values of each data\n"
"	memory locatation between the two addresses is set to zero.\n"
"\n"
;


static	char	*help_label	=
"\n"
"Usage: label [addr [, addr...]]\n"
"Usage: l     [addr [, addr...]]\n"
"\n"
"	Prints the numeric values of labels.  If one or more labels\n"
"	are specified, the value of each label is printed.  If no\n"
"	addresses are specified, then all labels are printed.\n"
"\n"
"	This command is also very useful for converting numbers from\n"
"	one base to another.  Simply type the value as decimal, octal,\n"
"	hex, binary, ASCII, or as a label, and it will be printed in\n"
"	all the possible formats.\n"
"\n"
;


static	char	*help_store	=
"\n"
"Usage: store addr, value\n"
"Usage: s     addr, value\n"
"\n"
"	Sets the specified address to the specified value.\n"
"\n"
"	If the address is specified as a register, then the value is\n"
"	stored in that register, as if an \"lc\" instruction had been\n"
"	executed.  Otherwise, the value is stored to data memory, as\n"
"	if an \"st1\" instruction had been executed.\n"
"\n"
;


static	char	*help_next	=
"\n"
"Usage: next\n"
"Usage: n\n"
"\n"
"	Executes the current instruction and then stops before\n"
"	executing the next instruction.\n"
"\n"
;

static	char	*help_unknown	=
"\n"
"	Unknown command.\n"
"\n"
;

/*
 * ad_help --
 *
 */

int ad_help (ant_dbg_op_t cmd)
{
	char *str;

	switch (cmd) {
		case DBG_HELP:		str = help_help;	break;
		case DBG_QUIT:		str = help_quit;	break;
		case DBG_RELOAD:	str = help_reload;	break;
		case DBG_RUN:		str = help_run;		break;
		case DBG_GO:		str = help_go;		break;
		case DBG_NEXT:		str = help_next;	break;
		case DBG_JUMP:		str = help_jump;	break;
		case DBG_TRACE:		str = help_trace;	break;
		case DBG_BREAK:		str = help_break;	break;
		case DBG_CLEAR_BP:	str = help_clear;	break;
		case DBG_PRINT_REG:	str = help_reg;		break;
		case DBG_PRINT_DADDR:	str = help_data;	break;
		case DBG_PRINT_IADDR:	str = help_inst;	break;
		case DBG_ZERO:		str = help_zero;	break;
		case DBG_STORE:		str = help_store;	break;
		case DBG_PRINT_LABEL:	str = help_label;	break;
		case DBG_EXEC:		str = help_unknown;	break;
		case DBG_WATCH:		str = help_watch;	break;
		case DBG_CLEAR_WP:	str = help_unwatch;	break;
		default:		str = help_unknown;	break;
	}

	printf ("- - - - - - -\n");
	printf ("%s", str);
	printf ("- - - - - - -\n");
	printf ("%s", COMMANDS);
	printf ("- - - - - - -\n");

	return (0);
}

int ad_parse_help (char *str, ant_dbg_op_t *cmd, ant_asm_str_id_t *commands)
{
	char *ptr;
	char *op1, *op2;
	unsigned int op1_len, op2_len;
	int i;

	ptr = str;
	while (isspace (*ptr)) {
		ptr++;
	}

	op1 = ptr;
	op1_len = strcspn (ptr, " \t");

	ptr += op1_len;
	while (isspace (*ptr)) {
		ptr++;
	}

	op2 = ptr;
	op2_len = strcspn (ptr, " \t,");

	if ((strncmp (op1, "?", op1_len) != 0) &&
			(strncmp (op1, "help", op1_len) != 0)) {
		return (1);
	}

	if (op2_len == 0) {
		*cmd = DBG_HELP;
		return (0);
	}

	for (i = 0; commands [i].str != NULL; i++) {
		char *cmd_str = commands [i].str;
		if ((strlen (cmd_str) == op2_len) &&
				(strncmp (op2, cmd_str, op2_len) == 0)) {
			*cmd = commands [i].id;
			return (0);
		}
	}

	/*
	 * We couldn't identify what kind of help the user wanted...
	 * but we know they need help.  Try to help them.
	 */

	*cmd = DBG_UNKNOWN;
	return (0);
}

/*
 * end of ad8_help.c
 */
