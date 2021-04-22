/* Name: Hongda Lin */
/* Date: 31/3/2020 */
.file "decryption.s"
.section	.rodata
.align 8

/* Data sections */
.data

.global main
	.type main, @function

.global printRestCharacter
	.type printRestCharacter, @function

.global decryptor
	.type encryptor, @function

.global modifierDecr
	.type modifierDecr, @function

.global eighthMaker
	.type eighthMaker, @function

.text
/* main function */
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$7, %rsp /* allocate 7 bytes for unsigned char myArr[7] */
	movq	%rsp, %rbx /* callee saved register %rbx contains the address of myArr */
	jmp	setZero

store:	
	movslq	%r12d, %rdx /* %rdx is the 64 bits extension of %r12d */
	movb	%al, (%rbx, %rdx); /* take the last byte of %eax, %al, store in *(myArr + i) */
	incl	%r12d /* i++ */
	cmpl	$7, %r12d /* if %r12d - 7 == 0, ZF flag set, 7 character read */
	jne	readchar /* else, jump to read until 7 character */
	movq	%rbx, %rdi /* set %rdi to point at %rbx, follow by assembly writing convention */
	call	decryptor /* %rdi is myArr, %rbx will not be changed */

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
	movq	$0, %rax
	leave
	ret
	.size main, .-main

/* function decryptor, %rdi is myArr */
decryptor:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$0, %r12d /* set %r12d (i) = 0 */
	movb	$0, %r13b /* set %r13b to be the 8th charater, initialize with NULL */
	movq	%rdi, %r14 /* set callee saved regiser %r14 point at %rdi, %r14 is now myArr */

loopDecr:
	cmpl	$7, %r12d /* if %r12d - 7 == 0, ZF flag set, encryption complete */
	je	exitDecr
	movslq	%r12d, %rdx /* %rdx is the 64 bits extension of %r12d */
	movb	(%rbx, %rdx), %dil /* set current %dil = *(myArr + i) */
	movb	%dil, %r15b /* store %dil in %r15b (temp) */
	call	modifierDecr /* %dil as the first parameter */
	movl	%r12d, %edx /* set third parameter %edx = i */
	movb	%r15b, %dil /* store temp as first parameter in %dil */
	movb	%r13b, %sil /* store ch8 as second parameter in %sil */
	call	eigthMaker 
	movb	%al, %r13b /* update %r13b by the return value from eigthMaker */
	incl	%r12d /* i++ */
	jmp	loopDecr

exitDecr:
	movzbl	%r13b, %edi /* get the ASCII value of 8th character */
	call	putchar /* putchar(ch) */
	leave
	ret
	.size decryptor, .-decryptor

/* function modifierDecr, %dil is current */
modifierDecr:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$1, %ecx /* set %ecx to be 1 */
	movzbl	%dil, %edi /* get the ASCII value of current */
	shll	%cl, %edi /* unsigned left shift  temp << 1 */
	movb	%dil, %sil /* get the last byte of %edi, store as %sil */
	movzbl	%sil, %esi /* get the ASCII value of (old) %sil */
	shrl	%cl, %esi /* unsigned right shift: temp >> 1 */
	movzbl	%sil, %edi /* get the ASCII value of (new) %sil */
	call	putchar /* putchar() in assembly, putchar(ch) */
	leave
	ret
	.size modifierDecr, .-modifierDecr

/* function eigthMaker, %dil is temp, %sil is 8th character, %edx is i */
eigthMaker:
	pushq	%rbp
	movq	%rsp, %rbp
	movzbl	%dil, %edi /* get the ASCII value of temp */
	movzbl	%sil, %esi /* get the ASCII value of temp */
	movl	%edx, %ecx /* convention for instruction shr */
	shrl	$7, %edi /* unsigned right shift  temp >> 7 */
	shll	%cl, %edi /* unsigned left shift  temp << i */
	orl	%edi, %esi /* ch8|temp */
	movl	%esi, %eax /* store %esi in %eax */
	leave
	ret
	.size eigthMaker, .-eigthMaker


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
	

