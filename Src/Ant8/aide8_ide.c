/*
 * $Id: aide8_ide.c,v 1.8 2003/06/20 16:23:54 sara Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * aide8_ide.c -- the toplevel of the new Ant IDE, "aide".
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>

#include <X11/Xlib.h>
#include <X11/X.h>
#include <tk.h>

#include "ant8_external.h"

#include "aide8_wish.h"

void show_version (char *progname);
static void aide8_show_usage (char *progname);
static char *find_script_path (char *aide_path, char *script);
static char *find_exe_path (char *exe);

/* This sets up info for the error handler. */

int XErrorProc(ClientData data, XErrorEvent *errEventPtr) {

	fprintf (stderr, "X protocol error: ");
	fprintf (stderr, "error = %d request = %d minor = %d\n",
		errEventPtr->error_code, errEventPtr->request_code,
		errEventPtr->minor_code);

	return 0;
}


/*
 * This sets up the interpreter, the main window, the debugger, the
 * error handler, links our C functions to tcl command procedures, and
 * opens up the tcl script for our program.  Then, Tk_MainLoop() waits
 * for events to happen, and exits only when the exit command is
 * called in the tcl script. 
 */

int main (int argc, char *argv[])
{
	Tcl_Interp *interp;
	Tk_Window win;  
	char *script_path;
	int rc;
	int test;
	int c;
		/* this is used to create the main window */
	Tk_Window	mainWindow; 

	extern int optind;
	extern char *optarg;

	int opt;

	/*
	 * This creates and starts running a Tcl interpreter named
	 * interp.  It has all the basic functionality of wish and
	 * tclsh
	 */

	printf("a\n");
	interp = Tcl_CreateInterp();
	printf("b\n");

#ifdef	COMMENT
	/*
	 * This is necessary for initializing interp.  It checks to
	 * make sure that interp was created. 
	 */

	if (Tk_ParseArgv (interp, (Tk_Window)NULL, &argc, argv, argTable, 0) 
     			!= TCL_OK) {
		fprintf (stderr, "%s\n", interp->result);
		exit (0);
	}
#endif	/* COMMENT */

	while ((c = getopt (argc, argv, "hVX:")) != -1) {
		switch (c) {
			case 'h'	:
				aide8_show_usage (argv [0]);
				exit (0);
			case 'V'	:
				show_version (argv [0]);
				exit (0);
		}
	}

	printf("c\n");
	//argv [0] = find_exe_path (argv [0]);

        /* Necessary because it forces setup of library search path based
           on executable path name */
	Tcl_FindExecutable(argv[0]);
	printf("d\n");

	if (Tcl_Init(interp) != TCL_OK) {
		fprintf (stderr, "Tcl Failed: %s\n", Tcl_GetStringResult(interp));
		exit (1);
	}

	if (Tk_Init(interp) != TCL_OK) {
		fprintf (stderr, "tk Failed %s\n", Tcl_GetStringResult(interp));
		exit (1);
	}

	printf("e\n");
	Awish_Init (interp, argc, argv);
	printf("f\n");

	win = Tk_MainWindow (interp); 
	printf("g\n");

	mainWindow = Tk_CreateWindow (interp, win, "ant", NULL);
	printf("h\n");

	if (mainWindow == NULL) {
		fprintf (stderr, "ERROR: %s: %s\n", argv [0], Tcl_GetStringResult(interp));
		exit (1);
	}  

	/* Creates Error Handler */ 

	Tk_CreateErrorHandler(Tk_Display(mainWindow), -1, -1, -1, XErrorProc,
		(ClientData)mainWindow);
 
	printf("i\n");

	/* necessary initializing stuff.  It all changes when we 
	 * create our GUI.
	 */

	Tk_GeometryRequest(mainWindow, 200, 200);
	printf("i2\n");
	/* Tk_SetWindowBackground(mainWindow, 
		WhitePixelOfScreen(Tk_Screen(mainWindow)));
	*/

	printf("j\n");
  
        script_path = find_script_path (argv [0], "Tcl8/ide.tcl");
	test = Tcl_EvalFile(interp, script_path);  

	printf("k\n");

	/* This sits, waiting for Tk events to occur.  It's a loop that
	 * stops only when the "exit" command is called. 
	 */

	Tk_MainLoop();

	return (0);
}

static	void	aide8_show_usage (char *progname)
{
	char		*usage	=
		"usage: %s [options] filename\n"
		"\n"
		"\t-h     Show this message, and then exit.\n"
		"\t-V     Print program version, and then exit.\n"
		"\n";

	printf (usage, progname);

	return ;
}

/* SSS
static void show_version (char *progname)
{

	printf ("%s: %s\n", progname, ant_build_version);

	return ;
}
*/

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
	ANT_ASSERT (str != NULL);

	last_sep = strrchr (ide_path, path_sep);

	if (last_sep == NULL) {
	}

	strncpy (str, ide_path, last_sep - ide_path);
	str [last_sep - ide_path] = '\0';
	sprintf (str + strlen (str), "%c%s", path_sep, script);

	return (str);
}

/*
 * end of ide.c
 */

