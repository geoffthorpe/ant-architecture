# Penny Ellard -- 9/7/97
# reverse.asm-- An Ant-8 program that reads a string from the user,
#       then prints out the string in reverse order
# Registers used:
# r4  - hold characters as they are read in and printed out.
# r5  - address - used for conditional branches.
# r6  - address - used for conditional branches.
# r7  - the address of the next byte in char_array to visit.
# r8  - the constant '\n'.
# r9  - address of the start of char_array.
# r10 - the address of the last byte in the char_array.

initialize:
        lc      r5, $end_read   # Initialize r5 to end of read loop
        lc      r6, $read_loop  # Initialize r6 to start of read loop
        lc      r9, $char_array # r9 is the address of the start of char_array
        lc      r8, '\n'        # Initialize r8 to '\n'
        lc      r10, $end_array # Initialize r10 to the address of the
                                # location after the end of the char_array,
        inc     r10, -1         # and decrement r10 so that it is the address
                                # the last location in the char_array.
        add     r7, r9, r0      # r7 starts at the start of char_array

read_loop:
        in      r4, ASCII	# Read a character, put in r4
        beq     r5, r4, r8      # if it's a newline, exit read loop
        bgt     r5, r7, r10     # if char_array is full, exit read loop
        st1     r4, r7, 0       # store character at r7
        inc     r7, 1           # i = i + 1
        jmp     $read_loop      # go to top of loop

end_read:
        lc      r5, $end_print  # Re-Initialize r5 to end of print loop
        lc      r6, $print_loop # Re-Initialize r6 to start of print loop
        lc      r9, $char_array # r9 is the address of the first byte
                                # in char_array.

print_loop:
        inc     r7, -1          # i = i - 1
        bgt     r5, r9, r7      # Have we backed off the end of char_array?
                                # If so, then exit print loop.
        ld1     r4, r7, 0       # load character at r7 into r4
        out     r4, ASCII	# Print r4
        jmp     $print_loop

end_print:
        out	r8, ASCII	# Print a newline

        hlt                     # Halt

_data_:

                                # enough space for 40 characters:
char_array:
        .byte   0, 0, 0, 0, 0, 0, 0, 0
        .byte   0, 0, 0, 0, 0, 0, 0, 0
        .byte   0, 0, 0, 0, 0, 0, 0, 0
        .byte   0, 0, 0, 0, 0, 0, 0, 0
        .byte   0, 0, 0, 0, 0, 0, 0, 0
end_array:

# end of reverse.asm
