/*
 * $Id: aa32.c,v 1.26 2003/03/31
 *
 * Copyright 1996-2003 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * aide32_wish.c --
 *
 */

/* START ADDING: */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <X11/Xlib.h>
#include <X11/X.h>
#include <tk.h>

#include "ant32_external.h"
#include "aide32_gui.h"

/* EO ADDING: */

#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <tcl.h>

/*
 * IS_HELP checks whether the arg we bombed on is -?, which is a help option.
 * If it is, we return TCL_OK (but leave the result set to whatever
 * Tcl_GetIndexFromObj says, which lists all the valid options.  Otherwise
 * return TCL_ERROR.
 */
#define IS_HELP(s)                                              \
	(strcmp(Tcl_GetStringFromObj(s,NULL), "-?") == 0) ? TCL_OK : TCL_ERROR

/*
 * Handle data structures.  These need to be populated with useful fields.
 */


typedef struct _vm_handle {
        ant_t     	*ant;
        ant_symtab_t	*symtab;
} vm_handle;

typedef struct _ed_handle {
	int	foo;
} ed_handle;

/*
 * Prototypes for procedures defined later in this file:
 */
static int ant_tcl_init(Tcl_Interp *);
static int ant_cmd(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST objv[]);
static int ant_version(Tcl_Interp *, int, Tcl_Obj *CONST objv[]);
static int ant_vmbreak(Tcl_Interp *, int, Tcl_Obj *CONST objv[], vm_handle *);
static int ant_vmconfig(Tcl_Interp *, int, Tcl_Obj *CONST objv[], vm_handle *);
static int ant_vmwatch(Tcl_Interp *, int, Tcl_Obj *CONST objv[], vm_handle *);
static int ed_cmd(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST objv[]);
static int vm_cmd(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST objv[]);
static int getword(ant_t *ant, int address, unsigned int *result);
static char *find_exe_path (char *argv0);
static char *find_script_path (char *ide_path, char *script);

main(argc, argv)
int argc;
char **argv;
{
  int i, tmpargc;
  char *tmpargv[256];


  /* In order to use tcl/tk more the way it is "supposed to" be used, we use
  // Tk_Main() to handle all of the initialization.  Unfortunately, 8.0
  // version of Tk_Main() is stupid about arguments - if any exist, the
  // first will always be used as a script file to run.
  //
  // So we just exploit this by inserting our script name into the arg list
  // as the first arg, that way the user can use command line arguments, and
  // everyone is happy.  We have to figure out where the script lives too,
  // based on where the binary lives.  Note that Tcl can figure out where
  // the binary lives, but not until later, and we need it now.
  //
  // Next time around, just switch to Tcl 8.3.  We won't have to muck with
  // the arglist, we can just call TclSetStartupScriptFileName(filename) in
  // the init function.  This happens after Tcl has called
  // Tcl_FindExecutable(), so we can use that (Tcl_GetNameOfExecutable()) to
  // figure out where the app lives, and don't have to do it ourselves.  And
  // with this method, Tk_Main won't touch the arg list.
  */

  tmpargv[0]=find_exe_path(argv[0]);
  tmpargv[1]=find_script_path(tmpargv[0],"Tcl32/aide32_ide.tcl");
  for (i=1; i<argc; ++i) {
    tmpargv[i+1]=argv[i];
  }
  tmpargc=argc+1;

  Tk_Main(tmpargc, tmpargv, ant_tcl_init);
  exit(0);
}

static char *find_exe_path (char *argv0)
{
        char path_sep;
	char real[1024];

        path_sep = '/';

        /*
         * If there's a path seperator in there somewhere, then the
         * path has been given explictily as an absolute or relative
         * path.  Otherwise, we have to paw through the users path,
         * trying to figure out which copy of the executable execvp
         * found for them, and then doing the right thing.
         */

        if (strchr (argv0, path_sep) == NULL) {
                char *curr, *next;
                char *base;
                char *path = NULL;
                char buf [1024];

                base = strdup (getenv ("PATH"));

                for (curr = base; curr != NULL; curr = next) {
                        next = strchr (curr, ':');
                        if (next != NULL) {
                                *next = '\0';
                                next++;
                        }

                        sprintf (buf, "%s%c%s", curr, path_sep, argv0);

                        if (! access (buf, X_OK)) {
                                path = strdup (buf);
                                break;
                        }
                }

                if (path == NULL) {
                        printf ("ERRROR: can't find [%s].\n", argv0);
                        return (NULL);
                }
                else {
                        free (base);
			if (realpath(buf,real) == NULL) {
				return (NULL);
			} else {
				return (strdup (real));
 			}	
                }
        }
        else {
		if (realpath(argv0,real) == NULL) {
			return (NULL);
		} else {
                	return (strdup (real));
		}
        }
}

static char *find_script_path (char *ide_path, char *script)
{
        int len;
        char path_sep;
        char *last_sep;
        char *str;

        if (ide_path[0]=='\"') {
                /* assume it is in this format: "e:...."
                   and change it to //e/ for cygnus */
                ide_path[2] = ide_path[1];
                ide_path[1] = '/';
                ide_path[0] = '/';
                ide_path[strlen(ide_path)-1] = '\0';
        }

        path_sep = '/';

        len = strlen (ide_path) + 1 + strlen (script) + 1;
        str = malloc (len * sizeof (char));

        last_sep = strrchr (ide_path, path_sep);

        strncpy (str, ide_path, last_sep - ide_path);
        str [last_sep - ide_path] = '\0';
        sprintf (str + strlen (str), "%c%s", path_sep, script);

        return (str);
}



/*
 * ant_tcl_init --
 *
 * This is a package initialization procedure, which is called by Tcl when
 * this package is to be added to an interpreter.  The name is based on the
 * name of the shared library, currently libant_tcl-X.Y.so, which Tcl uses
 * to determine the name of this function.
 */

int
ant_tcl_init(interp)
	Tcl_Interp *interp;		/* Interpreter in which the package is
					 * to be made available. */
{
	int code;
        char *errorExitCmd = "exit 1";
	char *msg;

        if (Tcl_Init(interp) == TCL_ERROR) {
                return(TCL_ERROR);
        }
        if (Tk_Init(interp) == TCL_ERROR) {
                return(TCL_ERROR);
        }

	/*  This code would be used for loadable module
        code = Tcl_PkgProvide(interp, "ant_tcl", "1.0");
	if (code != TCL_OK)
		return (code);
        */

	Tcl_CreateObjCommand(interp, "ant", (Tcl_ObjCmdProc *)ant_cmd,
	    (ClientData)0, NULL);

        /* chdir ("Tcl32"); */
        /* Tcl_EvalFile(interp, "aide32_ide.tcl"); */
/*
	code = Tcl_VarEval(interp, "source aide32_ide.tcl", (char *) NULL); 
	if (code != TCL_OK) {
          msg = Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY);
	  if (msg == NULL) {
	    msg = interp->result;
          }
          fprintf(stderr, "%s\n", msg);
          Tcl_Eval(interp, errorExitCmd);
        }
*/
        /*  If we start using 8.3 or greater, this will set the startup
            script AND block scriptname argument processing in Tk_MainEx()
        TclSetStartupScriptFileName("aide32_ide.tcl");
        */

	return (TCL_OK);
}

/*
 * ant_cmd --
 *	Implements the "ant" command.
 *	This command supports three sub commands:
 *	ant version - Returns a list {major minor patch}
 *	ant vm - Creates a new VM handle and returns a binding
 *	  to a new command of the form vmX, where X is an
 *	  integer starting at 0 (vm0, vm1, ...)
 *	ant editor - Creates a new editor and returns a binding to a new
 *	  command of the form edX, where X is an integer
 *	  starting at 0 (eb0, eb1, ...)
 */
static int
ant_cmd(notused, interp, objc, objv)
	ClientData notused;		/* Not used. */
	Tcl_Interp *interp;		/* Interpreter */
	int objc;			/* How many arguments? */
	Tcl_Obj *CONST objv[];		/* The argument objects */
{
	static char *antcmds[] = {
		"editor",
		"version",
		"vm",
		NULL
	};
	/*
	 * All commands enums below ending in X are compatibility
	 */
	enum antcmdsIx {
		ANT_EDITOR,
		ANT_VERSION,
		ANT_VM,
	};
	static int vm_id = 0;
	static int ed_id = 0;

	Tcl_Obj *res;
	void *ip;
	ed_handle *ed_ip;
	vm_handle *vm_ip;
	int cmdindex, result;
	char newname[32];

	res = NULL;
	Tcl_ResetResult(interp);
	result = TCL_OK;
	if (objc <= 1) {
		Tcl_WrongNumArgs(interp, 1, objv, "command cmdargs");
		return (TCL_ERROR);
	}

	/*
	 * Get the command name index from the object based on the berkdbcmds
	 * defined above.
	 */
	if (Tcl_GetIndexFromObj(interp,
	    objv[1], antcmds, "command", TCL_EXACT, &cmdindex) != TCL_OK)
		return (IS_HELP(objv[1]));

	switch ((enum antcmdsIx)cmdindex) {
	case ANT_EDITOR:
		sprintf(newname, "ed%d", ed_id);
		ed_ip = malloc(sizeof(ed_handle));
		if (ed_ip == NULL) {
			Tcl_SetResult(interp, "Could not set up handle info",
			    TCL_VOLATILE);
			result = TCL_ERROR;
			break;
		}
			
		vm_id++;
		Tcl_CreateObjCommand(interp, newname,
		    (Tcl_ObjCmdProc *)vm_cmd,
		    (ClientData)ed_ip, NULL);
		res = Tcl_NewStringObj(newname, strlen(newname));
		break;
	case ANT_VERSION:
		result = ant_version(interp, objc, objv);
		break;
	case ANT_VM:
		sprintf(newname, "vm%d", vm_id);
		vm_ip = malloc(sizeof(vm_handle));
		if (vm_ip == NULL) {
			Tcl_SetResult(interp, "Could not set up handle info",
			    TCL_VOLATILE);
			result = TCL_ERROR;
			break;
		}

		vm_ip->symtab = NULL;
		vm_ip->ant = ant_create(&AntParameters);
		vm_ip->ant->console.in=NULL;
		vm_ip->ant->console.out=NULL;
			
		vm_id++;
		Tcl_CreateObjCommand(interp, newname,
		    (Tcl_ObjCmdProc *)vm_cmd,
		    (ClientData)vm_ip, NULL);
		res = Tcl_NewStringObj(newname, strlen(newname));
		break;
	}

	/* Set up return value. */
	if (result == TCL_OK && res != NULL)
		Tcl_SetObjResult(interp, res);
	return (result);
}


/*
 * Implements the vm command (handle).
 * XXX Stub routines that return some valid value.
 */

int
vm_cmd(clientData, interp, objc, objv)
	ClientData clientData;          /* vm handle */
	Tcl_Interp *interp;             /* Interpreter */
	int objc;                       /* How many arguments? */
	Tcl_Obj *CONST objv[];          /* The argument objects */
{
	static char *vmcmds[] = {
		"break",
		"config",
		"get_mode",
		"get_mem",
		"get_register",
		"get_src1_reg",
		"get_src2_reg",
		"get_src3_reg",
		"get_dest1_reg",
		"get_dest2_reg",
		"get_src_mem",
		"get_dest_mem",
		"get_num_registers",
                "get_num_tlbs",
                "get_tlb_entry",
                "find_tlb_entry",
                "virt_to_phys",
		"load",
		"disassemble",
		"codeline",
		"register_name",
		"set_mem",
		"set_register",
		"set_special",
		"step",
		"console",
		"watch",
		NULL
	};
	enum vmcmds {
		VMBREAK,
		VMCONFIG,
		VMGET_MODE,
		VMGET_MEM,
		VMGET_REGISTER,
		VMGET_SRC1_REG,
		VMGET_SRC2_REG,
		VMGET_SRC3_REG,
		VMGET_DEST1_REG,
		VMGET_DEST2_REG,
		VMGET_SRC_MEM,
		VMGET_DEST_MEM,
		VMGET_NUM_REGISTERS,
                VMGET_NUM_TLBS,
                VMGET_TLB_ENTRY,
                VMFIND_TLB_ENTRY,
                VMVIRT_TO_PHYS,
		VMLOAD,
		VMDISASSEMBLE,
		VMCODELINE,
		VMREGISTER_NAME,
		VMSET_MEM,
		VMSET_REGISTER,
		VMSET_SPECIAL,
		VMSTEP,
		VMCONSOLE,
		VMWATCH
	};

	vm_handle *vmp;
	Tcl_Obj *res;
	int /*  u_int32_t  */ newval;
	int cmdindex, result, ret, rc;
        char *creg, *centry, buffer[256], *value, *ctemp, *subcmd;
        int len, goodlen, ireg, ientry, ivalue, *mem;
	int seg, vpn, po;

ant_inst_t inst;
ant_exc_t fault;
unsigned int vaddr, physaddr;
int i;
char *codeline;
int instrcount;
ant_reg_t *reg;
int src1, src2, src3, des1, des2, waddr, raddr, ovalue;
char **buf;
char err[256];
unsigned int contents;

int reg_label_type;

	char *filename;
	Tcl_ResetResult(interp);
	vmp = (vm_handle *)clientData;
	result = TCL_OK;

	if (objc <= 1) {
		Tcl_WrongNumArgs(interp, 1, objv, "command cmdargs");
		return (TCL_ERROR);
	}
	if (vmp == NULL) {
		Tcl_SetResult(interp, "NULL env pointer", TCL_VOLATILE);
		return (TCL_ERROR);
	}

	/*
	 * Get the command name index from the object based on the berkdbcmds
	 * defined above.
	 */
	if (Tcl_GetIndexFromObj(interp, objv[1], vmcmds, "command",
	    TCL_EXACT, &cmdindex) != TCL_OK)
		return (IS_HELP(objv[1]));
	res = NULL;
	switch ((enum vmcmds)cmdindex) {
	case VMBREAK:
		result = ant_vmbreak(interp, objc, objv, vmp);
		break;
	case VMCONFIG:
		result = ant_vmconfig(interp, objc, objv, vmp);
		break;
	case VMGET_MODE:
                sprintf(buffer, "%u", (unsigned int) vmp->ant->mode);
                Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                result = TCL_OK;
		break;
	case VMGET_MEM:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp, 
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                physaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces do_load_store() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, physaddr, &contents);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }
                sprintf(buffer, "%u", contents);
                Tcl_SetResult(interp, buffer, TCL_VOLATILE);
		result = TCL_OK;
		break;

	case VMGET_REGISTER:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "pc|number|eN");
		  return (TCL_ERROR);
	        }
                creg = Tcl_GetStringFromObj(objv[2], NULL);
                if (strcasecmp(creg,"pc")==0) {
                  /* return PC */
                  sprintf(buffer, "%u", (unsigned int) vmp->ant->pc);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                } else if (creg[0] == 'e') {
                  /* return exception registers */
                  switch (creg[1]) {
                    case '0':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[EXC_REG_0]);
                    break;
                    case '1':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[EXC_REG_1]);
                    break;
                    case '2':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[EXC_REG_2]);
                    break;
                    case '3':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[EXC_REG_3]);
                    break;
                  }
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                } else if (creg[0] == 'k') {
                  /* return exception registers */
                  switch (creg[1]) {
                    case '0':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[SUP_REG_0]);
                    break;
                    case '1':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[SUP_REG_1]);
                    break;
                    case '2':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[SUP_REG_2]);
                    break;
                    case '3':
                    sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[SUP_REG_3]);
                    break;
                  }
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                } else {
                  len=strlen(creg);
                  goodlen=strspn(creg,"-0123456789");
                  if (goodlen != len) {
                    Tcl_SetResult(interp, "Unknown register", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                  ireg = strtoul(creg, NULL, 10);
                  if (ireg < 0 || ireg >= ANT_REG_RANGE) {
                    Tcl_SetResult(interp, "register out of range", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                  sprintf(buffer, "%u", (unsigned int) vmp->ant->reg[ireg]);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
	case VMGET_NUM_REGISTERS:
                sprintf(buffer, "%u", (unsigned int) vmp->ant->params.n_reg);
                Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                result = TCL_OK;
		break;
	case VMGET_SRC1_REG:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Src 1 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) src1);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }



		break;
	case VMGET_SRC2_REG:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Src 2 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) src2);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
	case VMGET_SRC3_REG:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Src 3 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) src3);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
	case VMGET_DEST1_REG:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Dest 1 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) des1);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
	case VMGET_DEST2_REG:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Dest 2 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) des2);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
	case VMGET_SRC_MEM:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Dest 2 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) raddr);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
	case VMGET_DEST_MEM:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

		rc = ant_inst_src (inst, vmp->ant->reg, &src1, &src2, &src3,
                	&des1, &des2, &waddr, &raddr, &ovalue, NULL);
                if (rc != 0) {
                  Tcl_SetResult(interp, "Get Dest 2 Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                } else {
                  sprintf(buffer, "%d", (int) waddr);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_OK;
                }
		break;
        case VMGET_NUM_TLBS:
                sprintf(buffer, "%u", (unsigned int) vmp->ant->params.n_tlb);
                Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                result = TCL_OK;
                break;
        case VMGET_TLB_ENTRY:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "index");
		  return (TCL_ERROR);
	        }

                centry = Tcl_GetStringFromObj(objv[2], NULL);
                ientry = strtoul(centry, NULL, 10);
                if (ientry < 0 || ientry >= ANT_MAX_TLB_ENTRIES) {
                  Tcl_SetResult(interp, "TLB entry out of range", TCL_VOLATILE);
                  return(TCL_ERROR);
                }

                sprintf (buffer, "%u %u %u %u %u %u", \
                  (unsigned int)ANT_TLB_ATTR (vmp->ant->tlb [ientry]), \
                  (unsigned int)ANT_TLB_PHYS_PN(vmp->ant->tlb [ientry]), \
                  (unsigned int)ANT_TLB_VIRT_SEG(vmp->ant->tlb [ientry]), \
                  (unsigned int)ANT_TLB_VIRT_PN(vmp->ant->tlb [ientry]), \
                  (unsigned int)ANT_TLB_VIRT_SEGPN(vmp->ant->tlb [ientry]), \
                  (unsigned int)ANT_TLB_OS_INFO(vmp->ant->tlb [ientry])); \

                Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                result = TCL_OK;
                break;

        case VMFIND_TLB_ENTRY:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp, 
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);
		ant32_vaddr_split(vaddr, &seg, &vpn, &po);
		ientry = ant32_find_tlb_entry (vmp->ant->tlb, vmp->ant->params.n_tlb, seg, vpn, &fault);
		if (ientry < 0) {
                  Tcl_SetResult(interp, "-1", TCL_STATIC);
		} else {
                  sprintf(buffer, "%u", (unsigned int) ientry);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
		}
		return(TCL_OK);
                break;

        case VMVIRT_TO_PHYS:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp, 
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);
		/* if already a physical address, just return it */
		if (vaddr & 0x80000000) {
                  sprintf(buffer, "%u", vaddr);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
		  return(TCL_OK);
		}
		/* we don't just call ant32_v2p, because it does processing
		   for access mode that we don't want */
		ant32_vaddr_split(vaddr, &seg, &vpn, &po);
		ientry = ant32_find_tlb_entry (vmp->ant->tlb, vmp->ant->params.n_tlb, seg, vpn, &fault);
		if (ientry < 0) {
                  Tcl_SetResult(interp, "-1", TCL_STATIC);
		} else {
		  physaddr = po | (ANT_TLB_PHYS_PN(vmp->ant->tlb[ientry]) << 12) | 0x80000000;
                  sprintf(buffer, "%u", physaddr);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
		}
		return(TCL_OK);
                break;

	case VMLOAD:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "filename");
		  return (TCL_ERROR);
	        }
                filename = Tcl_GetStringFromObj(objv[2], NULL);

		clear_symtab(vmp->symtab);
		vmp->symtab = NULL;
                ant_pmem_clear (vmp->ant->pmem, 1);
		rc = ant_load_dbg(filename, vmp->ant, &vmp->symtab);
                if (rc == 0) {
                   rc = ant_reset (vmp->ant);
                   if (rc == 0) {
                      rc = ant_load_text_info(filename, &instrcount);
                      if (rc == 0) {
                        sprintf(buffer, "%d", instrcount);
                        Tcl_SetResult(interp,buffer,TCL_VOLATILE);
                        result = TCL_OK;
                      } else {
                     Tcl_SetResult(interp, "Instr Count Failed!", TCL_VOLATILE);
                     result = TCL_ERROR;
                      }
                   } else {
                     Tcl_SetResult(interp, "Reset Failed!", TCL_VOLATILE);
                     result = TCL_ERROR;
                   }
                } else {
                  Tcl_SetResult(interp, "Load Failed!", TCL_VOLATILE);
                  result = TCL_ERROR;
                }
		break;

	case VMDISASSEMBLE:
		if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);

		/* 
		** getword() replaces ant32_fetch_inst() which caused unwanted 
                ** exceptions
		*/
                rc=getword(vmp->ant, vaddr, &inst);
                if (rc) {
                   if (rc==ANT_EXC_BUS_ERR) { 
                      Tcl_SetResult(interp, "BusError", TCL_STATIC); 
                   }
                   if (rc==ANT_EXC_TLB_MISS) { 
                      Tcl_SetResult(interp, "TLBmiss", TCL_STATIC); 
                   }
                   result = TCL_ERROR;
                   break;
                }

                if (rc != ANT_EXC_OK) {
                  Tcl_SetResult(interp, "Fetch Failed!?", TCL_VOLATILE);
                  return(TCL_ERROR);
                }
                ant_disasm_inst(inst, vaddr, vmp->ant->reg, buffer, 0);
                Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                result = TCL_OK;
                break;

	case VMCODELINE:
	        if (objc != 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "instruction_address");
		  return (TCL_ERROR);
	        }
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                    Tcl_SetResult(interp,
                      "Non-numeric values in memory address", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                vaddr = strtoul(ctemp, NULL, 10);
                codeline = ant32_code_line_lookup (vaddr, NULL);
                if (codeline) {
                  Tcl_SetResult(interp, codeline, TCL_VOLATILE);
                } else {
                  Tcl_SetResult(interp, "", TCL_STATIC);
                }
                result = TCL_OK;
                break;

	case VMREGISTER_NAME:
	        if (objc != 4) {
		  Tcl_WrongNumArgs(interp, 2, objv, "register_number label_type");
		  return (TCL_ERROR);
	        }
                creg = Tcl_GetStringFromObj(objv[2],NULL);
                reg_label_type = 
		        strtoul(Tcl_GetStringFromObj(objv[3], NULL), NULL, 10);
                if (reg_label_type == 1) {
                  ant32_reg_names_change('g'); 
                } else if (reg_label_type == 2) {
                  ant32_reg_names_change('r'); 
                } else if (reg_label_type == 3) {
                  ant32_reg_names_change('c'); 
                } else {
                  sprintf(err,"Unknown register Label Type: %d\n",
                    reg_label_type);
                  Tcl_SetResult(interp, err, TCL_VOLATILE);
                  return(TCL_ERROR);
                }
                len=strlen(creg);
                 goodlen=strspn(creg,"-0123456789");
                 if (goodlen != len) {
                   Tcl_SetResult(interp, "Unknown register", TCL_VOLATILE);
                   return(TCL_ERROR);
                 }
                 ireg = strtoul(creg, NULL, 10);
                 if (ireg < 0 || ireg >= ANT_REG_RANGE) {
                   Tcl_SetResult(interp,"register out of range", TCL_VOLATILE)
;
                   return(TCL_ERROR);
                 }
                 sprintf(buffer, "%s", ant32_reg_name(ireg));
                 Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                 result = TCL_OK;

                break;
/* not used yet: 

	case VMSET_MEM:
                ctemp = Tcl_GetStringFromObj(objv[2], NULL);
                value = Tcl_GetStringFromObj(objv[3], NULL);
                len=strlen(ctemp);
                goodlen=strspn(ctemp,"-0123456789");
                if (goodlen != len) {
                  Tcl_SetResult(interp,
                     "Non-Numeric values in memory address", TCL_VOLATILE);
                  return(TCL_ERROR);
                }
                ivalue = strtoul(value, NULL, 10);
                physaddr = strtoul(ctemp, NULL, 10);
                mem = ant32_p2vm (physaddr, vmp->ant->pmem, ANT_MEM_WRITE);
                vmp->ant->pmem = ivalue;
                result = TCL_OK;
                break;
*/

/* not used yet: 
	case VMSET_REGISTER:
                creg = Tcl_GetStringFromObj(objv[2], NULL);
                value = Tcl_GetStringFromObj(objv[3], NULL);
                if (strcasecmp(creg,"pc")==0) {
                  ivalue = strtoul(value, NULL, 10);
                  vmp->ant->pc = ivalue;
                  result = TCL_OK;
                } else {
                  len=strlen(creg);
                  goodlen=strspn(creg,"-0123456789");
                  if (goodlen != len) {
                    Tcl_SetResult(interp, "Unknown register", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                  ireg = strtoul(creg, NULL, 10);
                  if (ireg < 0 || ireg >= ANT_REG_RANGE) {
                    Tcl_SetResult(interp, "register out of range", TCL_VOLATILE);
                    return(TCL_ERROR);
                  }
                  ivalue = strtoul(value, NULL, 10);
                  vmp->ant->reg[ireg] = ivalue;
                  result = TCL_OK;
                }
                break;
*/

	case VMSET_SPECIAL:
                Tcl_SetResult(interp, "0", TCL_VOLATILE);
		result = TCL_OK;
		break;
	case VMSTEP:
                rc = ant_exec_inst (vmp->ant);
                if (rc == 0) {
                  result = TCL_OK;
                } else if (rc == ANT_EXC_HALT) {
                  Tcl_SetResult(interp, "halted", TCL_STATIC);
                  result = TCL_OK;
                } else {
                  Tcl_SetResult(interp, "Step Failed!", TCL_STATIC);
                  result = TCL_ERROR;
                }
		break;
	case VMCONSOLE:
	        if (objc < 3) {
		  Tcl_WrongNumArgs(interp, 2, objv, "subcommand [value]");
		  return (TCL_ERROR);
	        }
                subcmd = Tcl_GetStringFromObj(objv[2], NULL);
                if (strcmp(subcmd,"get") == 0) {
                  if (vmp->ant->console.out_new == 0) {
                    Tcl_SetResult(interp, "no output available", TCL_VOLATILE);
                    result = TCL_ERROR;
                  } else {
                    sprintf(buffer,"%d",vmp->ant->console.out_val);
                    Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                    vmp->ant->console.out_new=0;
                    result = TCL_OK;
                  }
                } else if (strcmp(subcmd,"put") == 0) {
                  if (vmp->ant->console.in_new == 1) {
                    Tcl_SetResult(interp, "old input still unread", TCL_VOLATILE);
                    result = TCL_ERROR;
                  } else {
	            if (objc != 4) {
		      Tcl_WrongNumArgs(interp, 3, objv, "value");
		      return (TCL_ERROR);
	            }
                    value = Tcl_GetStringFromObj(objv[3], NULL);
                    ivalue = strtoul(value, NULL, 10);
                    vmp->ant->console.in_new=1;
                    vmp->ant->console.in_val=ivalue&0xff;
                    result = TCL_OK;
                  }
                } else if (strcmp(subcmd,"canget") == 0) {
                  if (vmp->ant->console.out_new) {
                    Tcl_SetResult(interp, "1", TCL_VOLATILE);
                  } else {
                    Tcl_SetResult(interp, "0", TCL_VOLATILE);
                  }
                  result = TCL_OK;
                } else if (strcmp(subcmd,"canput") == 0) {
                  if (vmp->ant->console.in_new) {
                    Tcl_SetResult(interp, "0", TCL_VOLATILE);
                  } else {
                    Tcl_SetResult(interp, "1", TCL_VOLATILE);
                  }
                  result = TCL_OK;
                } else if (strcmp(subcmd,"reset") == 0) {
                  /* throws away the buffered I/O characters */
                  vmp->ant->console.in_new=0;
                  vmp->ant->console.out_new=0;
                  result = TCL_OK;
                } else {
                  sprintf(buffer,"console: unknown option %s; should be one of get, put, canget, canput, or reset",subcmd);
                  Tcl_SetResult(interp, buffer, TCL_VOLATILE);
                  result = TCL_ERROR;
                }
                break;
	case VMWATCH:
		result = ant_vmwatch(interp, objc, objv, vmp);
		break;
	}

	return (result);
}

/* Placeholder for routine that gets the version number from the library. */
static int
ant_version(interp, objc, objv)
	Tcl_Interp *interp;		/* Interpreter */
	int objc;			/* How many arguments? */
	Tcl_Obj *CONST objv[];		/* The argument objects */
{	
	Tcl_Obj *res, *verobjv[3];
	int verobjc;

	verobjc = 3;
	verobjv[0] = Tcl_NewIntObj(3);
	verobjv[1] = Tcl_NewIntObj(1);
	verobjv[2] = Tcl_NewIntObj(0);

	res = Tcl_NewListObj(verobjc, verobjv);
	Tcl_SetObjResult(interp, res);

	return (TCL_OK);
}

/* Implement the "vm config" commands. */
static int
ant_vmconfig(interp, objc, objv, vmp)
	Tcl_Interp *interp;		/* Interpreter */
	int objc;			/* How many arguments? */
	Tcl_Obj *CONST objv[];		/* The argument objects */
	vm_handle *vmp;			/* VM handle. */
{
	static char *config_opts[] = {
		"-set",
		NULL
	};
	enum config_opts {
		CONFIG_SET
	};
	Tcl_Obj *res;
	int optindex, result;

	result = TCL_OK;
	if (objc < 2) {
		Tcl_WrongNumArgs(interp, 2, objv,
		    "?-set {name val} {name val}");
		return (TCL_ERROR);
	}

	/*
	 * See if we have a "-set" option.  If the number of arguments is
	 * greater than 2, we had better be either asking for info (-?) or
	 * setting configuration values.
	 */
	if (objc > 2) {
		if (Tcl_GetIndexFromObj(interp, objv[2],
		    config_opts, "option", TCL_EXACT, &optindex) != TCL_OK)
			return (IS_HELP(objv[2]));

		switch ((enum config_opts)optindex) {
		case CONFIG_SET:
			/*
			 * Treat the rest of the line as a list of name
			 * value pairs and set the configuration options
			 * accordingly.
			 */
			Tcl_SetResult(interp, "0", TCL_VOLATILE);
			break;
		}
	} else {
		/* Simply return the list of configuation options. */
		Tcl_SetResult(interp, "{nregs 32}", TCL_VOLATILE);
	}

	return (result);
}

/* Implement the "vm break" commands. */
static int
ant_vmbreak(interp, objc, objv, vmp)
	Tcl_Interp *interp;		/* Interpreter */
	int objc;			/* How many arguments? */
	Tcl_Obj *CONST objv[];		/* The argument objects */
	vm_handle *vmp;			/* VM handle. */
{
	static char *break_opts[] = {
		"-clr",
		"-set",
		NULL
	};
	enum break_opts {
		BREAK_CLR,
		BREAK_SET
	};
	Tcl_Obj *res;
	int optindex, result;

	result = TCL_OK;
	if (objc != 4) {
		Tcl_WrongNumArgs(interp, 2, objv, "[-set addr] [-clr num]");
		return (TCL_ERROR);
	}

	/*
	 * See if we have a "-set" or "-clr" option. 
	 */
	if (Tcl_GetIndexFromObj(interp, objv[2],
	    break_opts, "option", TCL_EXACT, &optindex) != TCL_OK)
		return (IS_HELP(objv[2]));

	switch ((enum break_opts)optindex) {
	case BREAK_CLR:
		/* Clear the breakpoint indicated by objv[3]. */
		Tcl_SetResult(interp, "0", TCL_VOLATILE);
		break;
	case BREAK_SET:
		/* Set a breakpoint at objv[3]. Return bp number. */
		Tcl_SetResult(interp, "5", TCL_VOLATILE);
		break;
	}

	return (result);
}

/* Implement the "vm watch" commands. */
static int
ant_vmwatch(interp, objc, objv, vmp)
	Tcl_Interp *interp;		/* Interpreter */
	int objc;			/* How many arguments? */
	Tcl_Obj *CONST objv[];		/* The argument objects */
	vm_handle *vmp;			/* VM handle. */
{
	static char *watch_opts[] = {
		"-clr",
		"-set",
		NULL
	};
	enum watch_opts {
		WATCH_CLR,
		WATCH_SET
	};
	Tcl_Obj *res;
	int optindex, result;

	result = TCL_OK;
	if (objc < 4) {
		Tcl_WrongNumArgs(interp, 2, objv,
		    "[-set addr ?-read -write -change?] [-clr num]");
		return (TCL_ERROR);
	}

	/*
	 * See if we have a "-set" or "-clr" option. 
	 */
	if (Tcl_GetIndexFromObj(interp, objv[2],
	    watch_opts, "option", TCL_EXACT, &optindex) != TCL_OK)
		return (IS_HELP(objv[2]));

	switch ((enum watch_opts)optindex) {
	case WATCH_CLR:
		/* Clear the watchpoint indicated by objv[3]. */
		Tcl_SetResult(interp, "0", TCL_VOLATILE);
		break;
	case WATCH_SET:
		/*
		 * Set a watchpoint at objv[3]. Return watchpoint number. 
		 * Process optional arguments to determine the kidn of
		 * watchpoint.
		 */
		Tcl_SetResult(interp, "6", TCL_VOLATILE);
		break;
	}

	return (result);
}

/*
 * Implements the ed command (handle).
 * XXX Make this look like the vm_cmd for now and then fill in as it
 * gets implemented.
 */
int
ed_cmd(clientData, interp, objc, objv)
	ClientData clientData;          /* vm handle */
	Tcl_Interp *interp;             /* Interpreter */
	int objc;                       /* How many arguments? */
	Tcl_Obj *CONST objv[];          /* The argument objects */
{
	return (TCL_OK);
}

int getword(ant, address, result)
ant_t *ant;
int address; 
unsigned int *result;
{
  int physaddr, seg, vpn, po, ientry;
  int *pointer;
  ant_exc_t fault;

  if (! (address & 0x80000000)) {
    ant32_vaddr_split(address, &seg, &vpn, &po);
    ientry = 
      ant32_find_tlb_entry (ant->tlb, ant->params.n_tlb, seg, vpn, &fault);
    if (ientry < 0) {
      return(ANT_EXC_TLB_MISS);
    } else {
      physaddr = po | (ANT_TLB_PHYS_PN(ant->tlb[ientry]) << 12) | 0x80000000;
    }
  } else {
    physaddr=address;
  }

  physaddr &= 0x3fffffff;

  pointer=ant32_p2vm(physaddr, ant->pmem, ANT_MEM_READ);
  if (pointer == NULL) {
    /* address is larger than available memory */
    return(ANT_EXC_BUS_ERR); 
  }
  *result=*pointer;
  return(ANT_EXC_OK);
}

