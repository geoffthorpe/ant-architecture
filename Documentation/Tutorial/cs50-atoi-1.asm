# Register usage:
# r3 - used as scratch space to load each byte into.
# r4 - used to hold the sum.
# r5 - the address of the next byte to load.
# r6 - the location of the end of the main loop.
# r7 - used to hold the constant 10.
# r8 - used to hold the constant '0'.
# r9 - used to hold the constant '\n'.

        lc      r4, 0                   # Initialize sum to 0.
        lc      r5, $string_start       # Start at beginning of string.
        lc      r6, $end_sum_loop       # Location of end of the loop.
        lc      r7, 10                  # Initialize r7 to 10.
        lc      r8, '0'                 # Initialize r8 to '0'.

sum_loop:
        ld1     r3, r5, 0               # load the byte *str into r3,
        beq     r6, r3, r0              # if r3 == 0, branch out of loop.
        mul     r4, r4, r7              # r4 *= 10.
        sub     r3, r3, r8              # r3 -= '0'.
        add     r4, r4, r3              # sum += r3.
        inc     r5, 1                   # increment str to the next char,
        jmp     $sum_loop               #  and repeat the loop.
end_sum_loop:

        sys     r4, SysPutInt           # print out the number

        lc      r9, '\n'                # put newline into r9
        sys     r9, SysPutChar          # print out a newline

        sys     r0, SysHalt             # halt

_data_:

string_start:
        .byte   '1', '0', '5', 0
