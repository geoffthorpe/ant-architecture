# Penny Ellard -- 9/7/97
# reverse.asm-- A program that reads a string from the user,
#       then prints out the string in reverse order
#
# Registers used:
#       r4      - hold characters as they're read in and printed out
#       r5      - addresses
#       r6      - addresses
#       r7      - index into the array of characters
#       r8      - the constant '\n'
#       r9      - -1, used for checking i in the print loop
#       r10     - the constant 79, limit on characters stored - 1, (zero-based)

initialize:
        lc      r5, $end_read   # Initialize r5 to end of read loop
        lc      r6, $start_read # Initialize r6 to start of read loop
        lc      r7, 0           # Initialize address of array
        lc      r8, '\n'        # Initialize r8 to '\n'
        lc      r9, -1          # Initialize r9 to -1, for check for i
        lc      r10, 79         # Initialize r10 to 79

start_read:
        sys     r4, 6           # Read a character, put in r4
        beq     r5, r4, r8      # if it's a newline, exit loop
        bgt     r6, r7, r10     # if we've read 80 chars, skip it
        st1     r4, r7, 0       # store character at r7
        inc     r7, 1           # i++
        jmp     $start_read 	# go to top of loop

end_read:
        lc      r5, $end_print  # Re-Initialize r5 to end of print loop
        lc      r6, $start_print #Re-Initialize r6 to start of print loop

start_print:
        ld1     r4, r7, 0       # load character at r7 into r4
        sys     r4, 3           # Print r4
        inc     r7, -1          # i--
        bgt     r6, r7, r9      # If r7 greater or equal 0, go to top of loop

end_print:
        sys     r8, 3           # Print a newline

        sys     r0, 0           # Halt

# end of reverse.asm
