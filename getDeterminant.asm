extern printf

%define DWORD 4

global getDeterminant

getDeterminant:
    push rbp
    mov rbp, rsp

    ; ===== STORING THE ARGUMENTS ===== ;
    ; 6 dwords = 24 bytes
    ; 24 bytes is not a multiple of 16
    ; 24 + (16 - (24 % 16)) = 32
    sub rsp, 32

    mov dword[rbp - DWORD * 1], edi ; x1
    mov dword[rbp - DWORD * 2], esi ; y1
    mov dword[rbp - DWORD * 3], edx ; x2
    mov dword[rbp - DWORD * 4], ecx ; y2
    mov dword[rbp - DWORD * 5], r8d ; x3
    mov dword[rbp - DWORD * 6], r9d ; y3

    ; === print the points === ;
    mov rdi, r10
    mov esi, dword[rbp - DWORD * 1]
    mov edx, dword[rbp - DWORD * 2]
    mov ecx, dword[rbp - DWORD * 3]
    mov r8d, dword[rbp - DWORD * 4]
    mov r9d, dword[rbp - DWORD * 5]
    mov ebx, dword[rbp - DWORD * 6]
    push rbx
    mov rax, 0
    call printf
    pop rbx

    mov rsp, rbp
    pop rbp
ret
