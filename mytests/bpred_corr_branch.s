	.file	1 "mytests/tests-bpreds.c"

 # GNU C 2.6.3 [AL 1.1, MM 40, tma 0.1] SimpleScalar running sstrix compiled by GNU C

 # Cc1 defaults:
 # -mgas -mgpOPT

 # Cc1 arguments (-G value = 8, Cpu = default, ISA = 1):
 # -quiet -dumpbase -o

gcc2_compiled.:
__gnu_compiled_c:
	.rdata
	.align	2
$LC0:
	.ascii	"Running script %s...\n\000"
	.align	2
$LC1:
	.ascii	"mytests/tests-bpreds.c\000"
	.sdata
	.align	3
$LC2:
	.word	0xffc00000		# 2.1199235294506577914e-314
	.word	0x46bcee8ed53a7400
	.align	3
$LC3:
	.word	0x33333333		# 4.2439915809424133385e-315
	.word	0x46bcee8ed53a7400
	.text
	.align	2
	.globl	main

	.text

	.loc	1 9
	.ent	main
main:
	.frame	$fp,40,$31		# vars= 16, regs= 2/0, args= 16, extra= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	move	$fp,$sp
	jal	__main
	sw	$0,24($fp)
	sw	$0,20($fp)
	la	$4,$LC0
	la	$5,$LC1
	jal	printf
	sw	$0,16($fp)
$L2:
	lw	$2,16($fp)
	slt	$3,$2,10000
	bne	$3,$0,$L5
	j	$L3
$L5:
	jal	rand
	mtc1	$2,$f0
	#nop
	cvt.d.w	$f0,$f0
	l.d	$f2,$LC2
	div.d	$f0,$f0,$f2
	l.d	$f2,$LC3
	c.lt.d	$f0,$f2
	bc1f	$L6
	li	$2,0x00000001		# 1
	sw	$2,24($fp)
$L6:
	lw	$2,24($fp)
	beq	$2,$0,$L7
	sw	$0,24($fp)
$L7:
$L4:
	lw	$3,16($fp)
	addu	$2,$3,1
	move	$3,$2
	sw	$3,16($fp)
	j	$L2
$L3:
	move	$2,$0
	j	$L1
$L1:
	move	$sp,$fp			# sp not trusted here
	lw	$31,36($sp)
	lw	$fp,32($sp)
	addu	$sp,$sp,40
	j	$31
	.end	main