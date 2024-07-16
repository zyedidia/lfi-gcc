.global memcpy
.global __memcpy_fwd
.hidden __memcpy_fwd
.type memcpy,@function
memcpy:
__memcpy_fwd:
	mov %rdi,%rax
	cmp $8,%rdx
	jc 1f
	test $7,%edi
	jz 1f
.p2align 5
2:	movsb
	dec %rdx
	test $7,%edi
	jnz 2b
.p2align 5
1:	mov %rdx,%rcx
	shr $3,%rcx
	rep
	movsq
	and $7,%edx
	jz 1f
.p2align 5
2:	movsb
	dec %edx
	jnz 2b
.p2align 5
1:	ret
