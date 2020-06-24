/*
 * $Id: aide8_wish.c,v 1.12 2002/06/29 01:48:10 ellard Exp $
 *
 * Copyright 2000-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * aide8_wish.c -- common routines used by the ANT tcl/tk shell, awish.
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#ifdef macintosh
	#include <Xlib.h>
	#include <X.h>
#else 
	#include <X11/Xlib.h>
	#include <X11/X.h>
#endif

#include <tk.h>

#include "ant8_external.h"

#include "aide8_gui.h"

int makeBindings (Tcl_Interp *interp);

int gantInitialize (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantExecSingleStep (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantBufferInput (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantBufferInputFlush (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantConsoleSeenEOI (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantDisasmInst (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantDisasmData (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetReg (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetPC (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetInst (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetBreakPoints (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetBreakPoint (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantSetBreakPoint (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantToggleBreakPoint (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetLabels (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetInstCount (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetStatus (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetInstSrc (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantAssemble (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantLoadLastGoodAnt (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantLoadFromAssembler (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantLoadFromFile (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetAntErrorStr (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetArgvElem (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);
int gantGetArgc (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv []);

void val2periph (char *buf, int periph, int value);


int		gantArgc		= 1;
char		**gantArgv		= NULL;

ant_t		_gantAnt;
ant_t		*gantCurrentAnt		= &_gantAnt;

int		gantCurrentAntInputReg	= 0;
int		gantCurrentAntInputType	= 0;
ant_dbg_bp_t	gantBreakPoints;
char		*gantAntFileName	= NULL;
char		*gantAsmFileName	= NULL;

	/*
	 * If CurrValid is zero, then none of these are valid. 
	 * Otherwise, they can be used to load from.
	 */

static	int		CurrValid	= 0;
static	ant_inst_t	CurrInstArray [ANT_INST_ADDR_RANGE];
static	ant_data_t	CurrDataArray [ANT_DATA_ADDR_RANGE];
static	int		CurrInstCount;
static	int		CurrDataCount;

static	ant_t		lastGoodAnt;
static	int		lastGoodAntGood = 0;

static	ant_asm_str_id_t	opcodes []	= {
	{ "add",	OP_ADD },
	{ "sub",	OP_SUB },
	{ "mul",	OP_MUL },
	{ "and",	OP_AND },
	{ "nor",	OP_NOR },
	{ "shf",	OP_SHF },
	{ "beq",	OP_BEQ },
	{ "bgt",	OP_BGT },
	{ "ld1",	OP_LD1 },
	{ "ld",		OP_LD1 },
	{ "st1",	OP_ST1 },
	{ "st",		OP_ST1 },
	{ "lc",		OP_LC },
	{ "jmp",	OP_JMP },
	{ "inc",	OP_INC },
	{ "in",		OP_IN },
	{ "out",	OP_OUT },
	{ "hlt",	OP_HALT },
	{ ".byte",	ASM_OP_BYTE },
	{ ".define",	ASM_OP_DEFINE },
	{ NULL,		0 }
};

#define	BIND(interp, name,function)	\
	Tcl_CreateCommand(interp, name, function, NULL, NULL);

int Awish_Init (Tcl_Interp *interp, int argc, char **argv)
{

	makeBindings (interp);

	ant_parse_setup (opcodes);

	gantArgc = argc;
	gantArgv = argv;

	return (0);
}

int makeBindings (Tcl_Interp *interp)
{

	BIND (interp, "gantInitialize",		gantInitialize); 
	BIND (interp, "gantExecSingleStep",	gantExecSingleStep);
	BIND (interp, "gantBufferInput",	gantBufferInput); 
	BIND (interp, "gantBufferInputFlush",	gantBufferInputFlush); 
	BIND (interp, "gantConsoleSeenEOI",	gantConsoleSeenEOI); 
	BIND (interp, "gantDisasmInst",		gantDisasmInst); 
	BIND (interp, "gantDisasmData",		gantDisasmData); 
	BIND (interp, "gantGetReg",		gantGetReg); 
	BIND (interp, "gantGetInst",		gantGetInst); 
	BIND (interp, "gantGetPC",		gantGetPC); 
	BIND (interp, "gantGetBreakPoints",	gantGetBreakPoints); 
	BIND (interp, "gantGetBreakPoint",	gantGetBreakPoint); 
	BIND (interp, "gantGetInstCount",	gantGetInstCount); 
	BIND (interp, "gantToggleBreakPoint",	gantToggleBreakPoint); 
	BIND (interp, "gantGetStatus",		gantGetStatus); 
	BIND (interp, "gantGetInstSrc",		gantGetInstSrc); 
	BIND (interp, "gantLoadFromFile",	gantLoadFromFile); 
	BIND (interp, "gantLoadLastGoodAnt",	gantLoadLastGoodAnt);
	BIND (interp, "gantLoadFromAssembler",	gantLoadFromAssembler); 
	BIND (interp, "gantAssemble",		gantAssemble);
	BIND (interp, "gantGetAntErrorStr",	gantGetAntErrorStr); 
	BIND (interp, "gantGetArgc",		gantGetArgc);
	BIND (interp, "gantGetArgvElem",	gantGetArgvElem); 

#ifdef	COMMENT
	BIND (interp, "gantSetBreakPoint",	gantSetBreakPoint);
	BIND (interp, "gantGetLabels",		gantGetLabels);
#endif	/* COMMENT */

	return (0);
}

int gantInitialize (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{

	ant_dbg_clear_bp (&gantBreakPoints);

        Tcl_ResetResult(interp);

	Tcl_SetResult (interp, "OK", TCL_VOLATILE);

	return (TCL_OK);
}

int gantExecSingleStep (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int rc;

        Tcl_ResetResult(interp);

	rc = ant_exec_inst (gantCurrentAnt, &gantCurrentAntInputReg,
			&gantCurrentAntInputType, NULL);

	Tcl_SetResult (interp, ant_get_status_str (), TCL_VOLATILE);

	return (TCL_OK);
}

int gantBufferInput (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int rc;

	Tcl_ResetResult(interp);

	if (argc == 2) {
		ant_console_enqueue (argv [1], strlen (argv [1]));
	}

	if (ant_get_status () == STATUS_INPUT) {
		if (gantCurrentAntInputReg >= 0) {
			char *side_ptr = &gantCurrentAnt->reg [SIDE_REG];

			gantCurrentAnt->reg [gantCurrentAntInputReg] =
					ant8_do_in_buf (gantCurrentAntInputType,
							side_ptr);
		}
	}

	ant_status (STATUS_OK);

	return (TCL_OK);
}

int gantBufferInputFlush (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int rc;

	Tcl_ResetResult(interp);

	ant_console_reset ();

	ant_status (STATUS_OK);

	return (TCL_OK);
}

int gantConsoleSeenEOI (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int rc;

	/*
	 * &&& DJE This is a hack.
	 */

	{
		extern int ant_seen_eoi;

		ant_seen_eoi = 1;
	}

	Tcl_ResetResult(interp);

	return (TCL_OK);
}

int gantDisasmInst (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{

        Tcl_ResetResult (interp);

	if (argc == 1) {
		char *str = NULL;

		if (CurrValid) {
			str = ant_disasm_i_mem (gantCurrentAnt, 0);

			Tcl_SetResult (interp, str, TCL_VOLATILE);
			free (str);
		}
		else {
			Tcl_SetResult (interp, "", TCL_STATIC);
		}

		return (TCL_OK);
	}
	else if (argc == 2) {
		if (CurrValid) {

			/* &&& PRETTY PATHETIC, DAN! */

			char buf [1024];
			int addr;
			ant_inst_t inst;

			addr = atoi (argv [1]);

			if (addr < 0) {
				addr = 0;
			}
			else if (addr >= 256) {
				addr = 0;
			}

			inst = ant_fetch_instruction (gantCurrentAnt, addr);
			ant_disasm_inst (inst, 0, gantCurrentAnt->reg, buf, 0);
			Tcl_SetResult (interp, buf, TCL_VOLATILE);
		}
		else {
			Tcl_SetResult (interp, "", TCL_STATIC);
		}

		return (TCL_OK);
	}
	else {
		return (TCL_ERROR);
	}
}

int gantDisasmData (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int len;

        Tcl_ResetResult (interp);

	if (argc == 1) {
		char *str = NULL;

		str = ant_disasm_d_mem (gantCurrentAnt, 0, 0);

		len = strlen (str);
		if ((len > 1) && (str [len - 1] == '\n')) {
			str [len - 1] = '\0';
		}

		Tcl_SetResult (interp, str, TCL_VOLATILE);
		free (str);

		return (TCL_OK);
	}
	else if (argc == 2) {
		char buf [1024];
		int addr;

		addr = atoi (argv [1]);

		if (addr < 0) {
			addr = 0;
		}
		else if (addr >= 256) {
			addr = 0;
		}

		sprintf (buf, "%.2", gantCurrentAnt->data [addr]);

		Tcl_SetResult (interp, buf, TCL_VOLATILE);
		return (TCL_OK);
	}
	else {
		return (TCL_ERROR);
	}

}

int gantGetInst (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int inst_ind;

        Tcl_ResetResult(interp);

	inst_ind = atoi (argv [1]);

	if (CurrValid) {
		ant_inst_t inst;
		char buf [1024];

		inst = ant_fetch_instruction (gantCurrentAnt, inst_ind);

		ant_disasm_inst (inst, inst_ind, NULL, buf, 0);

		Tcl_SetResult (interp, buf, TCL_VOLATILE);
	}
	else {
		Tcl_SetResult (interp, "", TCL_STATIC);
	}	

	return (TCL_OK);
}

int gantGetReg (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{

        Tcl_ResetResult(interp);
	if (argc != 2) {
		Tcl_SetResult (interp, "??????", TCL_STATIC);
	}
	else {
		int ind = atoi (argv [1] + 1);

		if (ind >= 0 && ind < 16) {
			char *str;

			str = antgGetRegByIndex (gantCurrentAnt, ind);
			Tcl_SetResult (interp, str, TCL_VOLATILE);
			free (str);
		}
		else {
			Tcl_SetResult (interp, "??????", TCL_STATIC);
		}
	}
	return (TCL_OK);
}

int gantGetPC (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	char buf [1024];

        Tcl_ResetResult(interp);

	sprintf (buf, "%d", gantCurrentAnt->pc);
	Tcl_SetResult (interp, buf, TCL_VOLATILE);

	return (TCL_OK);
}

int gantGetBreakPoints (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	char *str = antgGetBreakPoints (&gantBreakPoints);

        Tcl_ResetResult(interp);

	Tcl_SetResult (interp, str, TCL_VOLATILE);
	free (str);

	return (TCL_OK);
}

int gantGetBreakPoint (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int ind;

        Tcl_ResetResult(interp);

	if (argc != 2) {
		return (TCL_ERROR);
	}

	ind = atoi (argv [1]);

	if (gantBreakPoints.breakpoints [ind]) {
		Tcl_SetResult (interp, "1", TCL_STATIC);
	}
	else {
		Tcl_SetResult (interp, "0", TCL_STATIC);
	}

	return (TCL_OK);
}


int gantToggleBreakPoint (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int ind;

        Tcl_ResetResult(interp);

	if (argc != 2) {
		return (TCL_ERROR);
	}

	ind = atoi (argv [1]);

	if (ind < 0 || ind >= MAX_INST) {
		Tcl_SetResult (interp, "??", TCL_STATIC);
	}
	else {
		if (gantBreakPoints.breakpoints [ind]) {
			gantBreakPoints.breakpoints [ind] = 0;
			Tcl_SetResult (interp, "0", TCL_STATIC);
		}
		else {
			gantBreakPoints.breakpoints [ind] = 1;
			Tcl_SetResult (interp, "1", TCL_STATIC);
		}
	}

	return (TCL_OK);
}

int gantGetInstCount (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	char *ptr = antgGetInstCount (gantCurrentAnt);

        Tcl_ResetResult (interp);

	Tcl_SetResult (interp, ptr, TCL_VOLATILE);

	free (ptr);

	return (TCL_OK);
}

int gantGetStatus (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{

	char *status = ant_get_status_str ();

        Tcl_ResetResult (interp);

	Tcl_SetResult (interp, status, TCL_VOLATILE);

	return (TCL_OK);
}

int gantGetInstSrc (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	ant_inst_t inst;
	char buf [1024];
	int src1, src2, src3, des;
	int waddr, raddr;
	int iperiph, operiph, ovalue;
	ant_pc_t pc;

        Tcl_ResetResult (interp);

	src1 = src2 = src3 = des = -1;
	waddr = raddr = -1;
	iperiph = operiph = -1;

	if (argc != 2) {
		return (TCL_ERROR);
	}

	if (ant_get_status () == STATUS_INPUT) {
		pc = gantCurrentAnt->pc - 2;
	}
	else {
		pc = gantCurrentAnt->pc;
	}

	inst = ant_fetch_instruction (gantCurrentAnt, pc);

	ant_inst_src (inst, gantCurrentAnt->reg,
			&src1, &src2, &src3, &des,
			&iperiph, &operiph, &ovalue, &waddr, &raddr);

	if (!strcmp (argv [1], "src1")) {
		sprintf (buf, "%d", src1);
	}
	else if (!strcmp (argv [1], "src2")) {
		sprintf (buf, "%d", src2);
	}
	else if (!strcmp (argv [1], "src3")) {
		sprintf (buf, "%d", src3);
	}
	else if (!strcmp (argv [1], "des")) {
		sprintf (buf, "%d", des);
	}
	else if (!strcmp (argv [1], "iperiph")) {
		sprintf (buf, "%d", iperiph);
	}
	else if (!strcmp (argv [1], "operiph")) {
		sprintf (buf, "%d", operiph);
	}
	else if (!strcmp (argv [1], "ovalue")) {
		val2periph (buf, operiph, ovalue);
	}
	else if (!strcmp (argv [1], "waddr")) {
		sprintf (buf, "%d", waddr);
	}
	else if (!strcmp (argv [1], "raddr")) {
		sprintf (buf, "%d", raddr);
	}
	else {
		Tcl_SetResult (interp, "???", TCL_VOLATILE);
		return (TCL_ERROR);
	}

	Tcl_SetResult (interp, buf, TCL_VOLATILE);
	return (TCL_OK);
}

int gantLoadFromFile (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int rc;

        Tcl_ResetResult (interp);

	if (argc != 2) {
		return (TCL_ERROR);
	}

	gantAntFileName = argv [1];

	/*
	 * Before we can reload, we need to "unload".
	 * Otherwise, the symbol table can get gummed up.
	 */

	clear_symtab (labelTable);
	labelTable = NULL;

	rc = ant_load_dbg (gantAntFileName, gantCurrentAnt, &labelTable);
	if (rc != 0) {
		Tcl_SetResult (interp, "ERROR", TCL_STATIC);
		return (TCL_ERROR);
	}
	else {
		Tcl_SetResult (interp, "OK", TCL_STATIC);
		return (TCL_OK);
	}
}


int gantLoadLastGoodAnt (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{

	Tcl_ResetResult (interp);

	if (lastGoodAntGood) {
		memcpy (gantCurrentAnt, &lastGoodAnt, sizeof (ant_t));
	}

	Tcl_SetResult (interp, "OK", TCL_STATIC);
	return (TCL_OK);
}

int gantLoadFromAssembler (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int rc;
	extern ant_symtab_t *knownList;

        Tcl_ResetResult (interp);

	/*
	 * If the assembly failed, clear out the entire system.  This
	 * is much easier than trying to deal with each piece of state
	 * on a case-by-case basis!
	 *
	 */

	if (! CurrValid) {
		ant_clear (gantCurrentAnt);
		clear_symtab (labelTable);
		labelTable = NULL;
		lastGoodAntGood = 0;

		Tcl_SetResult (interp, "ERROR", TCL_STATIC);
		return (TCL_OK);
	}

	ANT_ASSERT (CurrInstCount >= 0);
	ANT_ASSERT (CurrDataCount >= 0);

	if (argc != 2) {
		gantAntFileName = argv [1];
	}

	rc = ant_asm_init_ant (gantCurrentAnt,
			CurrInstCount,
			CurrDataArray, CurrDataCount);

	/*
	 * "knownList" is the list of symbols that the assembler
	 * creates, while labelTable is what the awish uses.  So,
	 * unify these two here.
	 */

	labelTable = knownList;

	/*
	 * make a copy of the ant, to use as the last good ant (in
	 * gantLoadLastGoodAnt), and note that it is good.
	 */

	memcpy (&lastGoodAnt, gantCurrentAnt, sizeof (ant_t));
	lastGoodAntGood = 1;

	Tcl_SetResult (interp, "OK", TCL_STATIC);
	return (TCL_OK);
}

int gantAssemble (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	char **lines;
	int line_cnt;
	int rc;

        Tcl_ResetResult (interp);

	if (argc != 2) {
		return (TCL_ERROR);
	}

	lines = buf2lines (argv [1], &line_cnt);

	rc = ant_asm_lines ("EDIT BUFFER", lines, line_cnt,
			CurrInstArray, &CurrInstCount,
			CurrDataArray, &CurrDataCount);

	if (rc != 0) {
		Tcl_SetResult (interp, "ERROR", TCL_STATIC);
		CurrValid = 0;
	}
	else {
		Tcl_SetResult (interp, "OK", TCL_STATIC);
		CurrValid = 1;
	}

	return (TCL_OK);
}

int gantGetAntErrorStr (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
        Tcl_ResetResult (interp);

	Tcl_SetResult (interp, AntErrorStr, TCL_VOLATILE);

	return (TCL_OK);
}

int gantGetArgc (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	char buf [20];

        Tcl_ResetResult (interp);

	sprintf (buf, "%d", gantArgc);

	Tcl_SetResult (interp, buf, TCL_VOLATILE);

	return (TCL_OK);
}

int gantGetArgvElem (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int i;

        Tcl_ResetResult (interp);

	if (argc != 2) {
		return  (TCL_ERROR);
	}

	i = atoi (argv [1]);
	if ((i < 0) || (i >= gantArgc)) {
		return (TCL_ERROR);
	}
	
	if (gantArgv [i] == NULL) {
		return (TCL_ERROR);
	}

	Tcl_SetResult (interp, gantArgv [i], TCL_VOLATILE);

	return (TCL_OK);
}

void val2periph (char *buf, int periph, int value)
{
	int i;

	value = LOWER_BYTE (value);

	switch (periph) {
		case -1	:
			sprintf (buf, "-1");
			break;

		case 0	:
			sprintf (buf, "%x", value);
			break;

		case 1	:
			for (i = 0; i < 8; i++) {
				buf [i] = (value & (1 << (7 - i)) ?
						'1' : '0');
			}
			buf [8] = '\0';
			break;

		case 2	:
			if (isspace (value)) {
				sprintf (buf, "%c", value);
			}
			else if (value > 0 && value <= 127 && isprint (value)) {
				sprintf (buf, "%c", value);
			}
			else {
				sprintf (buf, "(0x%.2x)", value);
			}
			break;

		default	:
			sprintf (buf, "-1");
			break;
	}

	return ;
}

/*
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
 *
 * START OF DEAD OR UNUSED FUNCTIONS
 *
 * These functions are not known to work properly.  They are not
 * currently used by gad, and are not well-tested.  (They might work
 * perfectly, but who knows?)
 */

int gantSetBreakPoint (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	int ind;
	int val;

	if (argc != 3) {
		return (TCL_ERROR);
	}

	ind = atoi (argv [1]);
	val = atoi (argv [2]);

        Tcl_ResetResult(interp);

	if (gantBreakPoints.breakpoints [ind]) {
		Tcl_SetResult (interp, "1", TCL_STATIC);
	}
	else {
		Tcl_SetResult (interp, "0", TCL_STATIC);
	}

	gantBreakPoints.breakpoints [ind] = val ? 1 : 0;

	return (TCL_OK);
}

int gantGetLabels (ClientData client_data, Tcl_Interp *interp,
		int argc, char *argv [])
{
	char *ptr = antgGetLabels ();

	Tcl_SetResult (interp, ptr, TCL_VOLATILE);

	free (ptr);

	return (TCL_OK);
}

/*
 * end of aide8_wish.c
 */
