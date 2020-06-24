# Dan Ellard -- 11/2/96
# hello.asm-- A "Hello World" program.
# Registers used:
#       r2      - holds the address of the string

        lc      r2, $str_data   # load the address of the string into r2
        sys     r2, SysPutStr   # Print the characters in memory
        sys     r0, SysHalt     # Halt

_data_:				# Data for the program begins here:
 
str_data: 
        .byte   'H', 'e', 'l', 'l', 'o', ' '
        .byte   'W', 'o', 'r', 'l', 'd', '\n', 0

# end of hello.asm
