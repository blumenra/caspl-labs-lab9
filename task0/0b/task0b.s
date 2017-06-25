%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%macro  checkELF 1
	push dword %1
	call real_checkELF
	add esp, 4
%endmacro

%define	STDOUT	1

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
	
	global _start

	section .text
_start:
	
	push	ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage


	write STDOUT, virus_msg, 16
	open FileName, RDWR, 0x0777
	mov [ebp-4], eax
	.bla:
	checkELF [ebp-4]
	close dword [ebp-4]


; You code for this lab goes here

VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
	
FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:    db "perhaps not", 10 , 0
virus_msg:    db "This is a virus", 10 , 0
elf_magic:    db "ELF", 0


PreviousEntryPoint: dd VirusExit
virus_end:


real_checkELF:
	push ebp
	mov ebp, esp

	.bla:
	cmp dword [ebp+8], 0
	jge .cont
	mov eax, -1
	jmp .end_checkELF

	.cont:
		write STDOUT, virus_msg, 16

	.end_checkELF:

	mov esp, ebp
	pop ebp

	ret