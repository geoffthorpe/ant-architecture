# DJE $Id: Makefile,v 1.42 2003/02/14 17:31:21 ellard Exp $
# 02/20/94, updated 09/05/97
#
# Makefile for the parts of the course book I'm trying to put together.
# targets:
#
#	show:	(lazily) build + preview tut_root.pdf, the tutorial.
#		This is the default target.
#
#	dist:	build everything ($ALL_PS, $ALL_PDF) from scratch,
#		making sure that everything is up-to-date.  (Currently
#		also builds the 2-up versions of things, which we
#		don't use.)
#
#	www:	Do a dist, and then copy everything over to where the
#		makefile GUESSES is the right place, based on CurrVersion. 
#		This target is not recommended.
#
#	clean:	Removed derived files.
#
#	*_root.pdf: build the individual documents.
#
# One very important thing to note about this Makefile-- it does a lot
# of things twice, or sometimes more than twice.  THIS IS INTENTIONAL. 
# The way that LaTeX builds the index, table of contents, and cross
# references actually takes two (or more passes).  So instead of
# trying to figure out whether the table of contents is going to be
# changed when we rebuild something, we just assume that it always
# will be, and so we rebuild once to generate the new TOC and then
# rebuild a second time to get this new TOC properly inserted.  (If
# you are tricky you can build a TeX document that always has the
# wrong page numbers...  but in general, two passes suffice.)
#
# Don't try to optimize this!  It isn't worth the incredible pain and
# likelihood that you will miss something, and it only takes 30
# seconds to rebuild EVERYTHING from scratch, (and most makes take
# only a few seconds) so it's really not worth the risk or effort.

PDFLATEX = pdflatex -halt-on-error
MAKEINDEX = makeindex

# include ../Src/AntCommon/$(antHostType).mk

# Version number of the ANT release we're working on.

VERSION:sh	= cat ../CurrVersion
WWW_DIR		= ../WWW/ANT-$(VERSION)/doc/

MACROS		= macros.tex dan.tex

DR_ROOT		= data_rep.tex
DR_TEX		= datarep-sec.tex ascii.tex

CODE_ASM	= \
			Tutorial/add.asm \
			Tutorial/add2.asm \
			Tutorial/atoi1.asm \
			Tutorial/atoiC.asm \
			Tutorial/echo.asm \
			Tutorial/hello.asm \
			Tutorial/larger.asm \
			Tutorial/loop.asm \
			Tutorial/multiples.asm \
			Tutorial/multiplesC.asm \
			Tutorial/print-1.asm \
			Tutorial/print-2.asm \
			Tutorial/print-3.asm \
			Tutorial/print-4.asm \
			Tutorial/reverse.asm \
			Tutorial/shout.asm
CODE_TEX	= $(CODE_ASM:.asm=.tex)

TUT_ROOT	= ant8_tutorial.tex
TUT_TEX		= $(CODE_TEX) \
			tutorial.tex ant-chap.tex ad-chap.tex \
			code.tex tutex.tex func.tex \
			ant.tex \
			ant8.tex ant-asm.tex \
			ant-macros.tex dan.tex

ARCH_ROOT	= ant8_architecture.tex
ARCH_TEX	= ant8.tex \
			Arch/add.tex Arch/and.tex Arch/beq.tex Arch/bgt.tex \
			Arch/div.tex Arch/hlt.tex Arch/in.tex Arch/inc.tex \
			Arch/io.tex Arch/jmp.tex Arch/lc.tex Arch/ld1.tex \
			Arch/mul.tex Arch/nor.tex Arch/or.tex Arch/out.tex \
			Arch/shf.tex Arch/st1.tex Arch/sub.tex Arch/sys.tex

AD_ROOT		= ad8_tutorial.tex
AD_TEX		= ad8.tex

CARD_ROOT	= ant8_card.tex
CARD_TEX	=

### 32-bit stuff:

CODE32_ASM	= \
			Tut32/add.asm \
			Tut32/add-func.asm \
			Tut32/echo.asm \
			Tut32/fibonacci.asm \
			Tut32/hello.asm \
			Tut32/larger.asm
CODE32_TEX	= $(CODE32_ASM:.asm=.tex)

TUT32_ROOT	= ant32_tutorial.tex
TUT32_TEX	= $(CODE32_TEX) \
			tut32.tex reg32.tex rom32.tex t32-inst.tex \
			ant32-asm.tex

ARCH32_ROOT	= ant32_architecture.tex
ARCH32_TEX	= ant32_date.tex ant32-ver.tex \
			ant-spec.tex ant-macros.tex dan.tex \
			ant32-cycle.tex ant32-exc.tex \
			ant32-init.tex ant32-inst.tex ant32-over.tex \
			ant32-vm.tex \
			Arch32/add.tex Arch32/addi.tex \
			Arch32/addio.tex Arch32/addo.tex \
			Arch32/and.tex Arch32/bez.tex Arch32/bezi.tex \
			Arch32/bnz.tex Arch32/bnzi.tex Arch32/cin.tex \
			Arch32/cle.tex Arch32/cli.tex Arch32/cout.tex \
			Arch32/div.tex Arch32/divi.tex Arch32/eq.tex \
			Arch32/ex4.tex Arch32/ges.tex Arch32/geu.tex \
			Arch32/gts.tex Arch32/gtu.tex Arch32/halt.tex \
			Arch32/idle.tex \
			Arch32/info.tex Arch32/jez.tex \
			Arch32/jnz.tex Arch32/jral.tex \
			Arch32/lch.tex Arch32/lcl.tex Arch32/ld1.tex \
			Arch32/ld4.tex Arch32/leh.tex \
			Arch32/mod.tex Arch32/modi.tex Arch32/mul.tex \
			Arch32/muli.tex Arch32/mulio.tex \
			Arch32/mulo.tex Arch32/nor.tex Arch32/or.tex \
			Arch32/rand.tex Arch32/rfe.tex \
			Arch32/shl.tex Arch32/shli.tex Arch32/shr.tex \
			Arch32/shri.tex Arch32/shru.tex \
			Arch32/shrui.tex Arch32/srand.tex \
			Arch32/st1.tex Arch32/st4.tex Arch32/ste.tex \
			Arch32/sti.tex Arch32/sub.tex \
			Arch32/subi.tex Arch32/subio.tex \
			Arch32/subo.tex Arch32/tlble.tex \
			Arch32/tlbpi.tex Arch32/tlbse.tex \
			Arch32/trap.tex Arch32/xor.tex

# Combined stuff.

ALL_PS		= \
		data_rep.ps \
		ant8_tutorial.ps \
		ant8_architecture.ps \
		ant8_card.ps \
		ad8_tutorial.ps \
		ant32_tutorial.ps \
		ant32_architecture.ps
ALL_PDF		= $(ALL_PS:.ps=.pdf)

dist:	$(ALL_PDF)

ant32_date.tex:
	rm -f $@
	cat $? | grep '\$$Date' | head -1 | \
		sed -e 's/.*\$$Date\:\ \(....\).\(..\).\(..\).\(..\).\(..\).\(..\).\$$.*/\2\/\3\/\1\ \4:\5:\6/'  > $@

ant8_tutorial.pdf:	$(TUT_ROOT) $(TUT_TEX) Makefile
ant8_architecture.pdf:	$(TUT_ROOT) $(TUT_TEX) Makefile
ad8_tutorial.pdf:	$(AD_ROOT) $(AD_TEX) Makefile
data_rep.pdf:		$(DR_ROOT) $(DR_TEX) Makefile
ant32_architecture.pdf:	$(ARCH32_ROOT) $(ARCH32_TEX) Makefile
ant32_tutorial.pdf:	$(TUT32_ROOT) $(TUT32_TEX) Makefile

ant8_card.pdf:	$(CARD_ROOT) $(CARD_TEX) Makefile
	$(PDFLATEX) $<
	$(PDFLATEX) $<

# New names for things

clean:
	rm -f *.dvi *.log *.idx *.aux *.ind *.ilg *.toc *.ps *.pdf
	cd Tutorial; $(MAKE) clean
	cd Tut32; $(MAKE) clean

.SUFFIXES:	.tex .c .asm .pdf

.tex.pdf:
	$(PDFLATEX) $<
	$(MAKEINDEX) $*.idx
	$(PDFLATEX) $<

.asm.tex:
	rm -f $@ ; touch $@ 	
	echo "{\small "					>> $@
	echo '\\begin{verbatim}'			>> $@
	#cat -n $< | expand | sed -e s/"^   "/""/g	>> $@
	cat $< | expand 				>> $@
	echo '\\end{verbatim}'				>> $@
	echo "}"					>> $@
	
.c.tex:
	rm -f $@ ; touch $@ 	
	echo "{\small "					>> $@
	echo '\\begin{verbatim}'			>> $@
	#cat -n $< | expand | sed -e s/"^   "/""/g	>> $@
	cat $< | expand 				>> $@
	echo '\end{verbatim}'				>> $@
	echo "}"					>> $@

# end of Makefile
