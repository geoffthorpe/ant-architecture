/*
 * $Id: ant32_expand_op.c,v 1.24 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 2001- by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant32_expand_op.c --
 *
 */
 
#include        <stdio.h>
#include        <string.h>
#include        <stdlib.h>

#include        "ant_external.h"
#include        "ant32_external.h"

#define NOCOPY -1

#define DUMMY 0x4fffffff

/*
 * In all register-use conventions, registers 60-63 are reserved for
 * use by the assembler.  r60 is used by the simple expansions.
 */

#define RESERVED_REG	60
#define	REGISTER_RA	1
#define	REGISTER_SP	2
#define	REGISTER_FP	3
#define	REGISTER_RV	4
#define REGISTER_0	0x00

#define ARG0_REG -3
#define ARG1_REG -1
#define ARG2_REG -2
#define ARG0_CONST_BYTE3 -33
#define ARG0_CONST_BYTE2 -32
#define ARG0_CONST_BYTE1 -31
#define ARG0_CONST_BYTE0 -30
#define ARG1_CONST_BYTE3 -13
#define ARG1_CONST_BYTE2 -12
#define ARG1_CONST_BYTE1 -11
#define ARG1_CONST_BYTE0 -10
#define ARG2_CONST_BYTE3 -23
#define ARG2_CONST_BYTE2 -22
#define ARG2_CONST_BYTE1 -21
#define ARG2_CONST_BYTE0 -20

extern  ant_symtab_t    *unknownInstList;
extern  ant_symtab_t    *knownList;


typedef struct {
  unsigned int n_args;
  enum { REG,
  	CONST_LABEL,
	CONST8, CONST16, CONST32,
	CONST_ANY
  } arg_type [ANT_ASM_MAX_ARGS];
} pop_type_signature_t;


/* table for pseudo codes */

typedef struct {
  ant_op_t op_in;
  int size;
  char *mnemonic;
  pop_type_signature_t type;
  int translate_to[48];
} pseudo_table;

static void arg_const_byte (ant_asm_arg_t *arg, char *b_memory, int addr,
  int offset, int patch_loc);
static int match_types (ant_asm_stmnt_t *s, pop_type_signature_t *t);
static char *arg_type_str (int type);
static void print_valid_types (ant_op_t op, pseudo_table *table);

/* NCM 6/19/01
 * basically just a little switch to set whether we're in absolute or relative
 * branching mode (set at the beginning of each opcode expansion)
 */
ant_jumpmode_t curr_jumpmode = JUMP_ABS;

pseudo_table pseudo_op[] = {

  { OP_ADDI, 4, "addi",
    { 3, { REG, REG, CONST8 } },
    { OP_ADDI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_ADDI, 8, "addi",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_ADD, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_ADDI, 12, "addi",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_ADD, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_SUBI, 4, "subi",
    { 3, { REG, REG, CONST8 } },
    { OP_SUBI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_SUBI, 8, "subi",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SUB, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SUBI, 12, "subi",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_SUB, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_MULI, 4, "muli",
    { 3, { REG, REG, CONST8 } },
    { OP_MULI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_MULI, 8, "muli",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_MUL, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_MULI, 12, "muli",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_MUL, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_DIVI, 4, "divi",
    { 3, { REG, REG, CONST8 } },
    { OP_DIVI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_DIVI, 8, "divi",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_DIV, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_DIVI, 12, "divi",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_DIV, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_DIVI, 8, "divi",
    { 3, { REG, CONST16, REG } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_DIV, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },
  { OP_DIVI, 12, "divi",
    { 3, { REG, CONST_ANY, REG } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_DIV, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },

  { OP_MODI, 4, "modi",
    { 3, { REG, REG, CONST8 } },
    { OP_MODI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_MODI, 8, "modi",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_MOD, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_MODI, 12, "modi",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_MOD, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_MODI, 8, "modi",
    { 3, { REG, CONST16, REG } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_MOD, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },
  { OP_MODI, 12, "modi",
    { 3, { REG, CONST_ANY, REG } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_MOD, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },

  { OP_SHRI, 4, "shri",
    { 3, { REG, REG, CONST8 } },
    { OP_SHRI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_SHRI, 8, "shri",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SHR, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SHRI, 12, "shri",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_SHR, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SHRI, 8, "shri",
    { 3, { REG, CONST16, REG } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SHR, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },
  { OP_SHRI, 12, "shri",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_SHR, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },

  { OP_SHRUI, 4, "shrui",
    { 3, { REG, REG, CONST8 } },
    { OP_SHRUI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0, },
  },
  { OP_SHRUI, 8, "shrui",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SHRU, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SHRUI, 12, "shrui",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_SHRU, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SHRUI, 8, "shrui",
    { 3, { REG, CONST16, REG } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SHRU, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },
  { OP_SHRUI, 12, "shrui",
    { 3, { REG, CONST_ANY, REG } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_SHRU, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },

  { OP_SHLI, 4, "shli",
    { 3, { REG, REG, CONST8 } },
    { OP_SHLI, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0, },
  },
  { OP_SHLI, 8, "shli",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SHL, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SHLI, 12, "shli",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_SHL, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SHLI, 8, "shli",
    { 3, { REG, CONST16, REG } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SHL, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },
  { OP_SHLI, 12, "shli",
    { 3, { REG, CONST_ANY, REG } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_SHL, ARG0_REG, RESERVED_REG, ARG2_REG, },
  },

  { OP_ADDIO, 4, "addio",
    { 3, { REG, REG, CONST8 } },
    { OP_ADDIO, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_ADDIO, 8, "addio",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_ADDO, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_ADDIO, 12, "addio",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_ADDO, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_SUBIO, 4, "subio",
    { 3, { REG, REG, CONST8 } },
    { OP_SUBIO, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_SUBIO, 8, "subio",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_SUBO, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_SUBIO, 12, "subio",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_SUBO, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_MULIO, 4, "mulio",
    { 3, { REG, REG, CONST8 } },
    { OP_MULIO, ARG0_REG, ARG1_REG, ARG2_CONST_BYTE0 },
  },
  { OP_MULIO, 8, "mulio",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_MULO, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_MULIO, 12, "mulio",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_MULO, ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_ORI, 8, "ori",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_OR,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_ORI, 12, "ori",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_OR,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_NORI, 8, "nori",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_NOR,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_NORI, 12, "nori",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_NOR,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_XORI, 8, "xori",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_XOR,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_XORI, 12, "xori",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_XOR,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_ANDI, 8, "andi",
    { 3, { REG, REG, CONST16 } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_AND,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },
  { OP_ANDI, 12, "andi",
    { 3, { REG, REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG2_CONST_BYTE1, ARG2_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG2_CONST_BYTE3, ARG2_CONST_BYTE2,
      OP_AND,  ARG0_REG, ARG1_REG, RESERVED_REG, },
  },

  { OP_BEZI, 4, "bezi",
    { 2, { REG, CONST16 } },
    { OP_BEZI, ARG0_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0 },
  },
  { OP_BNZI, 4, "bnzi",
    { 2, { REG, CONST16 } },
    { OP_BNZI, ARG0_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0 },
  },

  { OP_LTS, 4, "lts",
    { 3, { REG, REG, REG } },
    { OP_GTS, ARG0_REG, ARG2_REG, ARG1_REG, },
  },

  { OP_LES, 4, "les",
    { 3, { REG, REG, REG } },
    { OP_GES, ARG0_REG, ARG2_REG, ARG1_REG, },  
  },

  { OP_LTU, 4, "ltu",
    { 3, { REG, REG, REG } },
    { OP_GTU, ARG0_REG, ARG2_REG, ARG1_REG, }, 
  },

  { OP_LEU, 4, "leu",
    { 3, { REG, REG, REG } },
    { OP_GEU, ARG0_REG, ARG2_REG, ARG1_REG, }, 
  },

  { OP_LC, 4, "lc",
    { 2, { REG, CONST16 } },
    { OP_LCL, ARG0_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0, },
  },
  { OP_LC, 8, "lc",
    { 2, { REG, CONST_ANY } },
    { OP_LCL, ARG0_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, ARG0_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2, },
  },

  { OP_MOV, 4, "mov",
    { 2, { REG, REG } },
    { OP_ADD, ARG0_REG, ARG1_REG, REGISTER_0, },
  },

  { OP_PUSH, 8, "push",
    { 1, { REG } },
    {
	OP_SUBI, REGISTER_SP, REGISTER_SP, 4,
	OP_ST4,  ARG0_REG, REGISTER_SP, 0
    },
  },
  { OP_PUSH, 12, "push",
    { 1, { CONST16 } },
    {
	OP_LCL, RESERVED_REG, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
	OP_SUBI, REGISTER_SP, REGISTER_SP, 4,
	OP_ST4,  RESERVED_REG, REGISTER_SP, 0
    },
  },
  { OP_PUSH, 16, "push",
    { 1, { CONST_ANY } },
    {
	OP_LCL, RESERVED_REG, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
	OP_LCH, RESERVED_REG, ARG0_CONST_BYTE3, ARG0_CONST_BYTE2,
	OP_SUBI, REGISTER_SP, REGISTER_SP, 4,
	OP_ST4,  RESERVED_REG, REGISTER_SP, 0
    },
  },

  { OP_POP, 8, "pop",
    { 1, { REG } },
    {
	OP_LD4,  ARG0_REG, REGISTER_SP, 0,
	OP_ADDI, REGISTER_SP, REGISTER_SP, 4
    },
  },

  { OP_J, 4, "j",
    { 1, { REG } },
    { OP_JEZ, REGISTER_0, REGISTER_0, ARG0_REG },
  },
  { OP_J, 12, "j",
    { 1, { CONST32 } },
    { OP_LCL, RESERVED_REG, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG0_CONST_BYTE3, ARG0_CONST_BYTE2,
      OP_JEZ, REGISTER_0, REGISTER_0, RESERVED_REG }
  },
  { OP_JEZI, 12, "jezi",
    { 2, { REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_JEZ, REGISTER_0, ARG0_REG, RESERVED_REG }
  },
  { OP_JNZI, 12, "jnzi",
    { 2, { REG, CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG1_CONST_BYTE3, ARG1_CONST_BYTE2,
      OP_JNZ, REGISTER_0, ARG0_REG, RESERVED_REG }
  },

  { OP_B, 12, "b",
    { 1, { CONST32 } },
    { OP_BEZI, REGISTER_0, ARG1_CONST_BYTE1, ARG1_CONST_BYTE0 },
  },
  { OP_B, 4, "b",
    { 1, { REG } },
    { OP_BEZ, REGISTER_0, REGISTER_0, ARG0_REG },
  },

  { OP_LEH, 4, "leh",
    { 1, { REG } },
    { OP_LEH, 0, ARG0_REG, 0, }
  },
  { OP_LEH, 12, "leh",
    { 1, { CONST_ANY } },
    { OP_LCL, RESERVED_REG, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG0_CONST_BYTE3, ARG0_CONST_BYTE2,
      OP_LEH, 0, RESERVED_REG, 0 }
  },

  { OP_CALL, 4, "call",
    { 1, { REG } },
    { OP_JEZ, REGISTER_RA, REGISTER_0, ARG0_REG }
  },
  { OP_CALL, 12, "call",
    { 1, { CONST_ANY } },
    {
      OP_LCL, RESERVED_REG, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG0_CONST_BYTE3, ARG0_CONST_BYTE2,
      OP_JEZ, REGISTER_RA, REGISTER_0, RESERVED_REG }
  },

  { OP_ENTRY, 28, "entry",
    { 1, { CONST_ANY } },
    {
      OP_SUBI, REGISTER_SP, REGISTER_SP, 8,
      OP_ST4,  REGISTER_FP, REGISTER_SP, 4,
      OP_ST4,  REGISTER_RA, REGISTER_SP, 0,
      OP_ADDI, REGISTER_FP, REGISTER_SP, 0,
      OP_LCL, RESERVED_REG, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
      OP_LCH, RESERVED_REG, ARG0_CONST_BYTE3, ARG0_CONST_BYTE2,
      OP_SUB, REGISTER_SP, REGISTER_SP, RESERVED_REG }
  },

  { OP_RETURN, 24, "return",
    { 0, { } },
    { OP_ADDI, REGISTER_SP, REGISTER_FP, 0,
      OP_LD4,  REGISTER_RA, REGISTER_SP, 0,
      OP_ADDI, REGISTER_RA, REGISTER_RA, 4,
      OP_LD4,  REGISTER_FP, REGISTER_SP, 4,
      OP_ADDI, REGISTER_SP, REGISTER_SP, 8,
      OP_JEZ,  REGISTER_0,  REGISTER_0, REGISTER_RA }
  },
  { OP_RETURN, 28, "return",
    { 1, { REG } },
    { OP_ADDI, REGISTER_RV, ARG0_REG, 0,
      OP_ADDI, REGISTER_SP, REGISTER_FP, 0,
      OP_LD4,  REGISTER_RA, REGISTER_SP, 0,
      OP_ADDI, REGISTER_RA, REGISTER_RA, 4,
      OP_LD4,  REGISTER_FP, REGISTER_SP, 4,
      OP_ADDI, REGISTER_SP, REGISTER_SP, 8,
      OP_JEZ,  REGISTER_0,  REGISTER_0, REGISTER_RA }
  },
  { OP_RETURN, 28, "return",
    { 1, { CONST16 } },
    { OP_LCL,  REGISTER_RV, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
      OP_ADDI, REGISTER_SP, REGISTER_FP, 0,
      OP_LD4,  REGISTER_RA, REGISTER_SP, 0,
      OP_ADDI, REGISTER_RA, REGISTER_RA, 4,
      OP_LD4,  REGISTER_FP, REGISTER_SP, 4,
      OP_ADDI, REGISTER_SP, REGISTER_SP, 8,
      OP_JEZ,  REGISTER_0,  REGISTER_0, REGISTER_RA }
  },
  { OP_RETURN, 32, "return",
    { 1, { CONST_ANY } },
    { OP_LCL,  REGISTER_RV, ARG0_CONST_BYTE1, ARG0_CONST_BYTE0,
      OP_LCH,  REGISTER_RV, ARG0_CONST_BYTE3, ARG0_CONST_BYTE2,
      OP_ADDI, REGISTER_SP, REGISTER_FP, 0,
      OP_LD4,  REGISTER_RA, REGISTER_SP, 0,
      OP_ADDI, REGISTER_RA, REGISTER_RA, 4,
      OP_LD4,  REGISTER_FP, REGISTER_SP, 4,
      OP_ADDI, REGISTER_SP, REGISTER_SP, 8,
      OP_JEZ,  REGISTER_0,  REGISTER_0, REGISTER_RA }
  },

  { DUMMY, 4, NULL,
    { 0, { 0 } },
    { 0x00, 0x00, 0x00, 0x00, },
  },
};

int asm_expand_op(ant_op_t op_code, ant_asm_stmnt_t *stmnt, char *b_memory, 
  unsigned int b_offset, unsigned int remaining, unsigned int *consumed) {

  int i, op_id = DUMMY;
  int ba;

  for (i=0; pseudo_op[i].op_in != DUMMY; i++) {
    if ((pseudo_op[i].op_in == op_code) &&
    		(match_types (stmnt, &pseudo_op [i].type) == 0)) {
      op_id = i;
      break;
    }
  }

  if (op_id == DUMMY) {
    sprintf(AntErrorStr, "invalid operand(s)");
    print_valid_types (op_code, pseudo_op);
    return (1);
  }

  if (remaining < (unsigned int)pseudo_op[op_id].size) {
    sprintf(AntErrorStr, "instruction memory overflow");
    return (1);
  }

  /* NCM 6/19/01
   * test for relative branching
   */
  if (op_code == OP_BEZI || op_code == OP_BNZI) {
	  /* is this a multi-line expansion or not? */
	  if (pseudo_op[op_id].size == 12) {
		  curr_jumpmode = JUMP_REL_2;
	  } else {
		  curr_jumpmode = JUMP_REL_0;
	  }
  } else {
	  curr_jumpmode = JUMP_ABS;
  }

  for (i=0; i< pseudo_op[op_id].size; i++) {

	/*
	 * Figure out the actual byte address of the byte to
	 * to patch.  Depending on whether the host is big or
	 * little endian, it might seem different.
	 */

#ifdef	IS_BIG_ENDIAN
    ba = i;
#else	/* Not IS_BIG_ENDIAN */
    ba = (i & ~3);
    switch (i % 4) {
	case 0: ba += 3; break; 
	case 1: ba += 2; break; 
	case 2: ba += 1; break; 
	case 3: ba += 0; break; 
    }
#endif	/* IS_BIG_ENDIAN */

    if (pseudo_op[op_id].translate_to[i] >= 0) {
      /* copy the value from the translation table to memory */
      b_memory[b_offset + ba] = pseudo_op[op_id].translate_to[i];
    } else {

      switch(pseudo_op[op_id].translate_to[i]) {

        /* copy register data into memory */

        case ARG0_REG:
          b_memory[b_offset + ba] = stmnt->args[0].reg;
          break;

        case ARG1_REG:
          b_memory[b_offset + ba] = stmnt->args[1].reg;
          break;

        case ARG2_REG:
          b_memory[b_offset + ba] = stmnt->args[2].reg;
          break;

        /* copy the constant (or label) data into memory */

        case ARG0_CONST_BYTE3:
	  arg_const_byte (&stmnt->args[0], b_memory, b_offset + ba, 3, BYTE3);
	  break;
        case ARG0_CONST_BYTE2:
	  arg_const_byte (&stmnt->args[0], b_memory, b_offset + ba, 2, BYTE2);
          break;
        case ARG0_CONST_BYTE1:
	  arg_const_byte (&stmnt->args[0], b_memory, b_offset + ba, 1, BYTE1);
          break;
        case ARG0_CONST_BYTE0:
	  arg_const_byte (&stmnt->args[0], b_memory, b_offset + ba, 0, BYTE0);
          break;

        case ARG1_CONST_BYTE3:
	  /* this is a horrible, horrible hack to update the offset for relative
	   * branching...basically, if we hit BYTE3 of ARG1 in either BEZI or BNZI,
	   * we're moving on to a different physical instruction, and the offset
	   * (from the actual branch instruction, as opposed to the loads that get
	   * inserted when the pseudo-op is expanded) needs to be updated.
	   * e.g., we'll get something like:
	   * bnzi r0, 0x80000004
	   *
	   * turned into:
	   * lcl r4, 4
	   * lch r4, 0x8000
	   * bnz r0, r0, r4
	   *
	   * notice here that the actual bnz instruction is two instructions below
	   * where the expanded bnzi appeared in the assembly code, hence the value
	   * loaded into r4 (in this case) needs to be changed accordingly.  Annoying,
	   * huh?
	   *
	   * NOTE: if for some reason the spec or pseudo-op definition for either
	   * BEZI or BNZI is changed, this logic will need to change too.
	   */
	  if (curr_jumpmode > JUMP_REL_0) {
		  curr_jumpmode--;
	  }
	  arg_const_byte (&stmnt->args[1], b_memory, b_offset + ba, 3, BYTE3);
          break;
        case ARG1_CONST_BYTE2:
	  arg_const_byte (&stmnt->args[1], b_memory, b_offset + ba, 2, BYTE2);
          break;
        case ARG1_CONST_BYTE1:
	  arg_const_byte (&stmnt->args[1], b_memory, b_offset + ba, 1, BYTE1);
          break;
        case ARG1_CONST_BYTE0:
	  arg_const_byte (&stmnt->args[1], b_memory, b_offset + ba, 0, BYTE0);
          break;

        case ARG2_CONST_BYTE3:
	  arg_const_byte (&stmnt->args[2], b_memory, b_offset + ba, 3, BYTE3);
          break;
        case ARG2_CONST_BYTE2:
	  arg_const_byte (&stmnt->args[2], b_memory, b_offset + ba, 2, BYTE2);
          break;
        case ARG2_CONST_BYTE1:
	  arg_const_byte (&stmnt->args[2], b_memory, b_offset + ba, 1, BYTE1);
          break;
        case ARG2_CONST_BYTE0:
	  arg_const_byte (&stmnt->args[2], b_memory, b_offset + ba, 0, BYTE0);
          break;
      }  
    }
  }

  *consumed += (pseudo_op[op_id].size);

  return(0);

}

/*
 * arg_const_byte -- eliminate some of the redundancy from the switch
 * statement in asm_expand_op.
 *
 * addr is the address within b_memory, offset is the byte of the word
 * to take, and patch_loc is the byte to backpatch.  offset and byte
 * represent the same thing, and are only distinguished here because
 * the backpatcher might not use the same constants.
 *
 * NCM: the curr_jumpmode is a hack, as per above comments, to get
 * the correct address in a multi-line branching expansion
 */

static void arg_const_byte (ant_asm_arg_t *arg, char *b_memory, int addr,
  int offset, int patch_loc)
{
  int l_value;

  if (arg->type == LABEL_ARG) {
    if (!find_symbol (knownList, arg->label, &l_value)) {
	if (curr_jumpmode > JUMP_ABS) {
		//remove segment identifier
		l_value &= ~(((1 << ANT_MMU_SEG_BITS) - 1) << 
				(ANT_VADDR_BITS - ANT_MMU_SEG_BITS));
			
		//calculate correct relative address
		l_value -= (addr & ~3) + (int)curr_jumpmode * sizeof(ant_inst_t);
		l_value /= sizeof(ant_inst_t);
	}
	b_memory [addr] = (l_value >> (offset * 8)) & 0xff;
    } else {
      if (curr_jumpmode > JUMP_ABS) {
        add_relative_unresolved(&unknownInstList, arg->label,
	                            addr, patch_loc, curr_jumpmode);
      } else {
        add_unresolved (&unknownInstList, arg->label,
	                    addr, patch_loc);
      }
    }
  } else { /* constant arg */
    b_memory[addr] = (arg->val >> (offset * 8)) & 0xff;
  }
}

static int match_types (ant_asm_stmnt_t *s, pop_type_signature_t *t)
{
	unsigned int i;
	int wanted_type, got_type;
	int arg_value;

	if (s->num_args != t->n_args) {
		return (1);
	}

	for (i = 0; i < t->n_args; i++) {

		wanted_type	= t->arg_type [i];
		got_type	= s->args [i].type;
		arg_value	= s->args [i].val;

		switch (wanted_type) {
			case REG :
				if (got_type != REG_ARG) {
					return (1);
				}
				break;

			case CONST_LABEL :
				if (got_type != LABEL_ARG) {
					return (1);
				}
				break;

			case CONST_ANY :
			case CONST32 :
				if (got_type != INT_ARG &&
						got_type != LABEL_ARG) {
					return (1);
				}
				break;

			case CONST16 :
				if (got_type != INT_ARG) {
					return (1);
				}

				if (arg_value < -32768 || arg_value > 32767) {
					return (1);
				}

				break;

			case CONST8 :
				if (got_type != INT_ARG) {
					return (1);
				}

				if (arg_value < -128 || arg_value > 127) {
					return (1);
				}

				break;

			default :
				ANT_ASSERT (0);
				return (1);
				break;

		}
	}

	return (0);
}

/*
 * Start of some very sketchy code to print out the acceptable
 * type signatures associated with a pseudo-op.
 */

static void print_valid_types (ant_op_t op, pseudo_table *table)
{
	unsigned int i, a;
	int printed_op = 0;

	for (i = 0; table [i].op_in != DUMMY; i++) {
		if (table [i].op_in == op) {
			pop_type_signature_t *pot = &table [i].type;

			if (! printed_op) {
				printed_op = 1;
				printf ("Valid formats for (%s):\n",
						table [i].mnemonic);
			}

			printf ("\t%s", table [i].mnemonic);

			for (a = 0; a < pot->n_args; a++) {
				printf ("\t%s", arg_type_str (pot->arg_type [a]));
				if (a < pot->n_args - 1) {
					printf (",");
				}
			}
			printf ("\n");
		}
	}
}

static char *arg_type_str (int type)
{

	switch (type) {
	case REG:		return ("reg");		break;
	case CONST8:		return ("const8");	break;
	case CONST16:		return ("const16");	break;
	case CONST32:		return ("const32");	break;
	case CONST_LABEL:	return ("label");	break;
	case CONST_ANY:		return ("const");	break;
	default:		return ("???");		break;
	}
}

/*
 * end of ant32_expand_op.c
 */

