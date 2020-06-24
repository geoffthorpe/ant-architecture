Ant Virtual Machine Assignment
------------------------------

You are to write an Ant Virtual Machine.

We provide ant_load_text, which reads in the .ant file and stores it in the
AntMemory array.

Your code should scan through the memory, and:

* identify the opcode, parse and execute it according to the 
  definitions discussed in the "Ant 3.0 Architecture Reference."

  Note that we provide you with do_in and do_out to execute the 
  IN and OUT opcodes--you just have to parse them.

* increment the program counter (AntPC)

* The three global variables--AntPC, AntRegisters, and AntMemory--contain 
  the entire state of the Ant Virtual machine.
  Make sure that each of these is properly updated after the execution 
  of every instruction.


Here is what is provided:
-------------------------

.h files (described below): ant.h, ant_bits.h, ant_machine.h

.c files (described below): antvm.c, ant_dump.c, ant_load.c, ant_utils.c

Makefile : 
type make to compile the program
type make clean to remove files and start over
if you create additional .c files you should add their name as directed
  in the Makefile.


Description of .h Files:
------------------------
ant.h:

includes ant_bits.h, ant_machine.h

* declares functions in the .c files described below
* declares these global variables:
    ant_pc_t	AntPC;
    char	AntRegisters [ANT_REG_RANGE];
    char	AntMemory [ANT_DATA_ADDR_RANGE];

ant_bits.h:

* defines macros for dealing with bit level details
* describes the bit structures of the opcodes in great detail too.

ant_machine.h:

* defines the Ant opcodes
* defines various constants, including: 
    * number of registers 
    * size of memory
    * Ant bits per word


Description of .c Files:
------------------------

antvm.c, contains these subroutines:

1. main
   calls ant_load_text
   calls ant_exec
   checks return code

2. ant_exec -- this is left blank for you to fill in


ant_dump.c, contains these subroutines:

1. ant_dump_text -- dumps the entire state of the Ant VM, including 
   the registers and memory.
   calls ant_print_reg and ant_print_memory

2. ant_print_reg -- prints the Ant Registers
3. ant_print_memory -- prints the Ant Memory

ant_load.c contains these subroutines:

1. ant_get_prog_name -- gets the name of the program file
2. ant_load_text -- loads a hex file into the ant memory
   returns 0 upon success, non-zero on failure.
3. read_prog_line -- reads lines from the hex file into the Ant memory
   (a worker function used by the ant_load_text function)
4. ant_clear -- initialize the Program counter, Registers and Memory to zeros.


ant_utils.c contains these subroutines:

1. do_in  -- processes the  IN opcode 
2. do_out -- processes the OUT opcode 
3. ant_fault - prints given a fault code and the PC, and dump the Ant's core
   calls ant_dump_text
