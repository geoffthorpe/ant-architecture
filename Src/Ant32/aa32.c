/*
 * $Id: aa32.c,v 1.26 2002/05/16 14:08:45 ellard Exp $
 *
 * Copyright 1996-2002 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/20/96
 * James Megquier -- 11/09/96
 *
 * aa32.c --
 *
 * First cut of an assembler for the 32-bit version of ANT.  The goal
 * is to start with something reasonable, and bootstrap into a more
 * full-featured assembler.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<unistd.h>	/* for unlink */
#include	<string.h>

#include	"ant_external.h"
#include	"ant32_external.h"

#define ASM_EXT		".asm"
#define ASM_EXT_LEN	strlen (ASM_EXT)

#define ANT_EXT		".a32"
#define ANT_EXT_LEN	strlen (ANT_EXT)

/*
 * For now, everything is bootable, and everything starts at the
 * default base address of 0x80000000.
 */

extern int		AddBootJump;
extern unsigned long	BootAddress;
extern unsigned long	BaseAddress;

static	char		*BootRomFile;

extern	ant_symtab_t	*knownList;

/* Statements, for cool printing later */

char *make_ant_filename (char *asm_filename);

int ant_asm_write_exec (FILE *FOUT, int verbose,
		unsigned int n_inst, unsigned int last_addr,
		ant_inst_t *mem, ant_symtab_t *labels);

static	int	aa32_parse_args (int argc, char **argv,
			char **in_file, char **out_file);
void aa32_show_usage (char *progname);
void show_version (char *progname);

static	ant_asm_str_id_t	opcodes []	= {
	{ "add",	OP_ADD },
	{ "sub",	OP_SUB },
	{ "mul",	OP_MUL },
	{ "div",	OP_DIV },
	{ "mod",	OP_MOD },
	{ "or",		OP_OR },
	{ "nor",	OP_NOR },
	{ "xor",	OP_XOR },
	{ "and",	OP_AND },
	{ "shr",	OP_SHR },
	{ "shru",	OP_SHRU },
	{ "shl",	OP_SHL },

	{ "addi",	OP_ADDI },
	{ "subi",	OP_SUBI },
	{ "muli",	OP_MULI },
	{ "divi",	OP_DIVI },
	{ "modi",	OP_MODI },
	{ "shri",	OP_SHRI },
	{ "shrui",	OP_SHRUI },
	{ "shli",	OP_SHLI },

	{ "ori",	OP_ORI },	/* pseudo-op */
	{ "nori",	OP_NORI },	/* pseudo-op */
	{ "xori",	OP_XORI },	/* pseudo-op */
	{ "andi",	OP_ANDI },	/* pseudo-op */

	{ "addo",	OP_ADDO },
	{ "subo",	OP_SUBO },
	{ "mulo",	OP_MULO },

	{ "addio",	OP_ADDIO },
	{ "subio",	OP_SUBIO },
	{ "mulio",	OP_MULIO },

	{ "eq",		OP_EQ },
	{ "gts",	OP_GTS },
	{ "ges",	OP_GES },
	{ "gtu",	OP_GTU },
	{ "geu",	OP_GEU },

	{ "lts",	OP_LTS },   /* pseudo op */
	{ "les",	OP_LES },   /* pseudo op */
	{ "ltu",	OP_LTU },   /* pseudo op */
	{ "leu",	OP_LEU },   /* pseudo op */

	{ "bez",	OP_BEZ },
	{ "jez",	OP_JEZ },
	{ "bnz",	OP_BNZ },
	{ "jnz",	OP_JNZ },
	{ "bezi",	OP_BEZI },
	{ "bnzi",	OP_BNZI },
	{ "b",		OP_B },	    /* pseudo op */
	{ "j",		OP_J },	    /* pseudo op */
	{ "jezi",	OP_JEZI },  /* pseudo op */
	{ "jnzi",	OP_JNZI },  /* pseudo op */

	{ "ld1",	OP_LD1 },
	{ "ld4",	OP_LD4 },
	{ "st1",	OP_ST1 },
	{ "st4",	OP_ST4 },
	{ "ex4",	OP_EX4 },

	{ "lc",		OP_LC  },   /* pseudo op */
	{ "lcl",	OP_LCL },
	{ "lch",	OP_LCH },

	{ "trap",	OP_TRAP },
	{ "info",	OP_INFO },

	{ "rand",	OP_RAND },
	{ "srand",	OP_SRAND },
	{ "cin",	OP_CIN },
	{ "cout",	OP_COUT },

	{ "tlbpi",	OP_TLBPI },
	{ "tlble",	OP_TLBLE },
	{ "tlbse",	OP_TLBSE },

	{ "timer",	OP_TIMER },
	{ "halt",	OP_HALT },
	{ "idle",	OP_IDLE },

	{ "leh",	OP_LEH },
	{ "rfe",	OP_RFE },

	{ "cli",	OP_CLI },
	{ "sti",	OP_STI },
	{ "cle",	OP_CLE },
	{ "ste",	OP_STE },

	{ "mov",	OP_MOV  },   /* pseudo op */
	{ "push",	OP_PUSH },   /* pseudo op */
	{ "pop",	OP_POP  },   /* pseudo op */
	{ "call",	OP_CALL  },   /* pseudo op */
	{ "entry",	OP_ENTRY  },   /* pseudo op */
	{ "return",	OP_RETURN  },   /* pseudo op */

		/*
		 * Assembler directives
		 */

	{ ".byte",	ASM_OP_BYTE },
	{ ".word",	ASM_OP_WORD },
	{ ".align",	ASM_OP_ALIGN },
	{ ".define",	ASM_OP_DEFINE },
	{ ".ascii",	ASM_OP_ASCII },
	{ ".asciiz",	ASM_OP_ASCIIZ },
	{ ".text",	ASM_OP_TEXT },
	{ ".data",	ASM_OP_DATA },
	{ ".addr",	ASM_OP_ADDR },

	{ NULL,		0 }
};

/*
 * main --
 *
 */

int main (int argc, char *argv [])
{
	char	*asm_filename	= NULL;
	char	*ant_filename	= NULL;
	FILE	*out = NULL;
	unsigned int	rc;
	char **lines;
	int line_cnt;
	unsigned int inst_cnt = 0;
	unsigned int last_addr = 0;
	char *memTable = NULL;
	
	memTable = malloc (sizeof (char) * ANT_MAX_INSTS);
	ANT_ASSERT (memTable != NULL);

	memset (memTable, 0, ANT_MAX_INSTS * sizeof (char));

	if (aa32_parse_args (argc, argv, &asm_filename, &ant_filename) != 0) {
		aa32_show_usage (argv [0]);
	}

	lines = file2lines (asm_filename, &line_cnt);
	if (lines == NULL) {
		printf("Couldn't read input file [%s].\n", asm_filename);
		exit(1);
	}

	ant_parse_setup (opcodes);
	ant_asm_init ();

	if (BootRomFile != NULL) {
		ant_load_labels (BootRomFile, &knownList);
	}

	rc = ant_asm_lines (asm_filename, lines, line_cnt,
			memTable, &inst_cnt, &last_addr);
	if (rc != 0) {
		printf ("%s\n", AntErrorStr);
		exit (1);
	}

	free (lines);

	if (ant_filename == NULL) {
		ant_filename = make_ant_filename (asm_filename);
	}

	/* Note: If the output file exists, we nuke it. */
	out = fopen (ant_filename, "w");
	if (out == NULL) {
		printf ("Couldn't open output file [%s].\n", ant_filename);
		exit(1);
	}

	/* Write the beast */
	rc = ant_asm_write_exec (out, 1, inst_cnt, last_addr,
			(ant_inst_t *) memTable, knownList);

	if (BootRomFile != NULL) {
		FILE *br = fopen (BootRomFile, "r");
		char buf [ANT_MAX_LINE_LEN];

		if (br == NULL) {
			exit (1);
		}

		while (fgets (buf, ANT_MAX_LINE_LEN, br)) {
			char sym [ANT_MAX_LINE_LEN];
			int addr;

			/*
			 * &&& Add everything EXCEPT the symbol table,
			 * which has already been merged during the
			 * ordinary assembly.
			 *
			 * This is a gross hack, and depends too much
			 * on the format of the file.  Yucko!
			 */

			rc = sscanf (buf, "# $%s = %i\n", sym, &addr);
			if (rc != 2) {
				fputs (buf, out);
			}
		}

		fclose (br);
	}

	fclose(out);
	if (rc != 0) {
		printf ("%s: write failed.\n", asm_filename);
		unlink(ant_filename);
		exit(1);
	}


	exit (0);
}

char *make_ant_filename (char *asm_filename)
{
	unsigned int len;
	char *ant_filename;

	len = strlen (asm_filename);
	ant_filename = malloc ((len + ANT_EXT_LEN + 1) * sizeof(char)); 
	strcpy (ant_filename, asm_filename);

	if (len > ASM_EXT_LEN &&
			!strcmp(asm_filename + len - ASM_EXT_LEN, ASM_EXT)) {
		strcpy(ant_filename + len - ANT_EXT_LEN, ANT_EXT);
	}
	else {
		strcpy(ant_filename + len, ANT_EXT);
	}

	return (ant_filename);
}

int ant_asm_write_exec (FILE *FOUT, int verbose,
		unsigned int n_inst, unsigned int last_addr,
		ant_inst_t *memTable, ant_symtab_t *labels)
{
	unsigned int i;

	fprintf (FOUT, "#@ Instructions %d\n", n_inst);

	fprintf (FOUT, "#@ Data %d\n", last_addr);

	fprintf (FOUT, "#@ SINGLE_ADDRESS_SPACE\n");

	fprintf (FOUT, "#@ END OF OPTIONS\n");

	if (last_addr == 0) {
		if (verbose) fprintf(FOUT, "# no data\n");
	}
	else {
		unsigned int inst_cnt;

		if (verbose) fprintf(FOUT, "# start of data\n");

		inst_cnt = (last_addr / sizeof (ant_inst_t)) +
			((last_addr % sizeof (ant_inst_t) != 0) ? 1 : 0);

		for (i = 0; i < inst_cnt; i++) {
		    char *code;
		    
		    code = ant32_code_line_lookup (i * sizeof (ant_inst_t),
		    		NULL);
		    if (code == NULL)
		    	code = "";

		    if (i==0){
			fprintf(FOUT, "0x%8.8x  ::  0x%8.8x  ::  %s\n", 
				(unsigned int) BaseAddress,
                                LOWER_WORD (memTable [i]), 
                                code);
		    } else {
			fprintf(FOUT, "+           ::  0x%8.8x  ::  %s\n", 
                                LOWER_WORD (memTable [i]), 
                                code);
		    }
		}

		if (AddBootJump) {
			fprintf(FOUT, "0x%8.8x  ::  0x%8.8x  ::  %s\n",
				ANT_RESET_PC_ADDR,
				(unsigned int) BaseAddress, "Boot it!");
		}

		if (verbose) fprintf(FOUT, "# end of data\n");
	}

	if (verbose) {
		dump32_symtab_machine (labels, FOUT);
	}

	if (verbose) {
		fprintf(FOUT, "# end of file\n");
	}

	return(0);
}


static int aa32_parse_args (int argc, char **argv,
		char **in_file, char **out_file)
{
	char		*usage	= "a:lB:r:ho:VwX:";
	int		c;
	extern	int	optind;
	extern	char	*optarg;
	int		boot_address_set = 0;

	if (out_file != NULL) {
		*out_file = NULL;
	}

	while ((c = getopt (argc, argv, usage)) != -1) {
		switch (c) {
			case 'a'	:
				BaseAddress = strtoul (optarg, NULL, 0);
				break;
			case 'l'	:
				AddBootJump = 0;
				break;
			case 'B'	:
				boot_address_set = 1;
				BootAddress = strtoul (optarg, NULL, 0);
				break;
			case 'r'	:
				BootRomFile = optarg;
				break;
			case 'o'	:
				if (out_file != NULL) {
					*out_file = optarg;
				}
				else {
					ANT_ASSERT (0);
				}
				break;

			case 'h'	:
				aa32_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
			case 'w'	:
				DesWarnOnly = 1;
				break;
			default :
				aa32_show_usage (argv [0]);
				exit (1);
		}
	}

	if (argc != optind + 1) {
		printf ("Incorrect usage.\n");
		aa32_show_usage (argv [0]);
		exit (1);
	}

	if (! boot_address_set) {
		BootAddress = BaseAddress;
	}

	*in_file = argv [optind];

	return (0);
}

void	aa32_show_usage (char *progname)
{
	char		*usage	=
		"usage: %s [options] infile.asm\n"
		"\n"
		"\t-a addr  Set the base address to the specified addr.\n"
                "           (the default base address is 0x80000000)\n"
		"\t-B addr  Set the boot address to the specified addr.\n"
                "           (the default boot address is the base address)\n"
		"\t-l       Do not add a boot jump to the program.\n"
		"\t         (useful for building libraries)\n"
		"\t-o file  Write the output to the specified file.\n"
		"\t         (the default is infile.a32)\n"
		"\t-r file  Add the specified file into the created image.\n"
		"\t-h       Show this message, and then exit.\n"
		"\t-V       Print program version, and then exit.\n"
		"\n";

	printf (usage, progname);

	return ;
}

/*
 * end of aa32.c
 */
