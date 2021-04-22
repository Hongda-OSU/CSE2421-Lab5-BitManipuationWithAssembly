/* Name: Hongda Lin */
/* Date: 31/3/2020 */
.file "encryption.s"
.section	.rodata
.align 8

/* Data sections */
.data

/* Linker section */
.global main
	.type main, @function

.global printRestCharacter
	.type printRestCharacter, @function

.global encryptor
	.type encryptor, @function

.global modifierEncr
	.type modifierEncr, @function
.text

/* main function */
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp /* allocate 8 bytes for unsigned char myArr[8] */
	movq	%rsp, %rbx /* callee saved register %rbx contains the address of myArr */
	jmp	setZero 

store:
	movslq	%r12d, %rdx /* %rdx is the 64 bits extension of %r12d */
	movb	%al, (%rbx, %rdx); /* take the last byte of %eax, %al, store in *(myArr + i) */
	incl	%r12d /* i++ */
	cmpl	$8, %r12d /* if %r12d - 8 == 0, ZF flag set, 8 character read */
	jne	readchar /* else, jump to read until 8 character */
	movq	%rbx, %rdi /* set %rdi to point at %rbx, follow by assembly writing convention */
	call	encryptor /* %rdi is myArr, %rbx will not be cahnged */
	
setZero:
	movl	$0, %r12d /* %r12d contains int value 0 */
	
readchar:	
	call	getchar /* getchar() in assembly, %eax should be the return value from getchar() */
	cmpl	$-1, %eax /* check if %eax is EOF(-1) */
	jne	store /* jump to store if %eax is not EOF */
	cmpl	$0, %r12d /* if %r12d - 0 == 0, ZF flag set, no remaining characters in myArr */
	movq	%rbx, %rdi /* set %rdi to point at %rbx, as first parameter */
	movl	%r12d, %esi /* set %esi to point at %r12d, as second parameter */
	je	exitMain
	call	printRestCharacter /* %rdi as first parameter myArr, %esi as second parameter i */

exitMain:
	movq	$0, %rax /* return 0 */
	leave
	ret
	.size main, .-main

/* function encryptor, %rdi is myArr */
encryptor:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$0, %r12d /* %r12d = 0 */
	movb	7(%rdi), %r13b /* %r13b = *(myArr + 7), which is the 8th character, %r13b will not be modified */
	movq	%rdi, %r14 /* set callee saved regiser %r14 point at %rdi, %r14 is now myArr */

loopEncr:
	cmpl	$7, %r12d /* if %r12d - 7 == 0, ZF flag set, encryption complete */
	je	exitEncr
	movslq	%r12d, %rdx /* %rdx is the 64 bits extension of %r12d */
	movb	%r13b, %sil /* set temp %sil to have the value in %r13b */
	movb	(%r14, %rdx), %dil  /* set current %dil = *(myArr + i) */
	movl	%r12d, %edx /* set third parameter %edx = i */
	call	modifierEncr /* current %dil, temp %sil, i %edx */
	incl	%r12d /* %r12d++ */
	jmp	loopEncr

exitEncr:
	leave
	ret
	.size encryptor, .-encryptor

/* function modifierEncr, %dil is current, %sil is temp, %edx is i */
modifierEncr:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edx, %ecx /* convention for instruction shr */
	movzbl	%dil, %edi /* get the ASCII value of current */
	movzbl	%sil, %esi /* get the ASCII value of temp */
	shrl	%cl, %esi /* unsigned right shift: temp >> i */
	shll	$7, %esi /* unsigned left shift  temp << 7 */
	orl	%esi, %edi /* current|temp(update), %edi is the ASCII value passed into putchar() */
	call	putchar /* putchar() in assembly, putchar(ch) */
	leave
	ret
	.size modifierEncr, .-modifierEncr

/* function printRestCharacter: %rdi: address of myArr, %esi: count of remaining charaters */
printRestCharacter:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$0, %r13d /* set %r13d to be 0 */
	movl	%esi, %r12d /* set %r12d to be %esi */
	movq	%rdi, %rbx /* set %rbx to be %rdi (because we don't want 'call' to mess up %rdi) */
loopPC:
	cmpl	%r12d, %r13d /* if %r13d - %r12d == 0, ZF flag set, exit */
	je	exitPC
	movslq	%r13d, %rdx /* %rdx is the 64 bit extension of %r13d */
	movb	(%rbx, %rdx), %dil /* %dil get the character */
	movzbl	%dil, %edi /* %edi contains the ASCII value need to be passed to putchar */
	call	putchar /* putchar() in assembly,  putchar(ch) */
	incl	%r13d /* %r13d++ */
	jmp	loopPC
exitPC:
	leave
	ret
	.size printRestCharacter, .-printRestCharacter
	

