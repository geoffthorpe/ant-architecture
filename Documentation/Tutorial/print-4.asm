# Dan Ellard -- 03/15/2000
# print-4.asm-- Ant-8 code to print a string.
# Registers used:
# r2  - holds the address of the string
# r15 - scratch register for function calls.

        lc  r2, $first_str	# load the address of the first string into r2
	jmp $print_str		# jump to the print_str code
        lc  r2, $second_str	# load the address of the second string into r2
	jmp $print_str		# jump to the print_str code
	hlt

# Registers used by function print_str:
# r2  - holds the address of the string
# r3  - holds the address of the end of the loop
# r4  - holds the next character to be printed.

print_str:
	lc  r15, $print_str_mem
	st1 r1, r15, 0		# save the return address into r15
	st1 r2, r15, 1		# preserve register 2
	st1 r3, r15, 2		# preserve register 3
	st1 r4, r15, 3		# preserve register 4

        lc  r3, $end_print_loop	# load address of the end of the print loop
print_loop:
        ld1  r4, r2, 0		# Get the first character from the string
        beq  r3, r4, r0		# If the char is zero, we're finished.
        out  r4, ASCII		# Otherwise, print the character.
        inc  r2, 1		# Increment r2 to point to the next char
        jmp  $print_loop	# and repeat the process...
end_print_loop:
	ld1 r4, r15, 3		# restore register 4
	ld1 r3, r15, 2		# restore register 3
	ld1 r2, r15, 1		# restore register 2
	ld1 r15, r15, 0		# restore return address
	beq  r15, r0, r0	# Jump back to return address

_data_:                         # Data for the program begins here:

first_str:	.byte   'f', 'i', 'r', 's', 't', '\n', 0
second_str:	.byte   's', 'e', 'c', 'o', 'n', 'd', '\n', 0

print_str_mem:	.byte	0, 0, 0, 0

# end of print-4.asm
