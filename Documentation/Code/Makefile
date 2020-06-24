# $Id: Makefile,v 1.1 2000/02/02 20:33:10 ellard Exp $
#
# Makefile for ant example code -- 11/26/96

CODE_SRC	= add.asm add2.asm atoi-1.asm atoi-2.asm \
			ave_example.asm box.asm cat.asm echo.asm \
			hello.asm hi-q.asm larger.asm multiples.asm \
			palindrome.asm reverse.asm \
			squares.asm stripcom.asm
CODE_TEX	= $(CODE_SRC:.asm=.tex)
CODE_ANT	= $(CODE_SRC:.asm=.ant)

build:		$(CODE_TEX)

clean:
	rm -f $(CODE_TEX) $(CODE_ANT)

.SUFFIXES:	.tex .asm

.asm.tex:
	rm -f $@
	echo "\begin{verbatim}"				> $@
	cat -n $< | expand | sed -e s/"^   "/""/g	>> $@
	echo "\end{verbatim}"				>> $@

# end of Makefile
