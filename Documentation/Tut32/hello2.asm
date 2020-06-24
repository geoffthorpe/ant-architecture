# Dan Ellard
# hello2.asm-- An Ant-32 "Hello World" program.
# More succinct than hello.asm; uses j and .asciiz.
# g0  - holds the address of the string
# g1  - holds the address of the end of the loop
# g3  - holds the next character to be printed.

        lc      g0, $str_data   # load the address of the string into g0
        lc      g1, $endloop    # load address of the end of the loop.
loop:
        ld1     g3, g0, 0       # Get the first character from the string
        jez     ze, g3, g1      # If the char is zero, we're finished.
        cout	g3		# Otherwise, print the character.
        addi    g0, g0, 1       # Increment g0 to point to the next char
        j	$loop		# and repeat the process...
endloop:
        halt

	# Data for the program begins here:
	.data
str_data: 
	.asciiz "Hello World\n"
