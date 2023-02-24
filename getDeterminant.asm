extern printf

%define DWORD 4

global getDeterminant

getDeterminant:
    push rbp
    mov rbp, rsp

    sub rsp, 48

    mov dword[rbp - DWORD * 1], edi 
    mov dword[rbp - DWORD * 2], esi 
    mov dword[rbp - DWORD * 3], edx 
    mov dword[rbp - DWORD * 4], ecx 
    mov dword[rbp - DWORD * 5], r8d 
    mov dword[rbp - DWORD * 6], r9d 

    mov dword[rbp - DWORD * 7], 0 
    mov dword[rbp - DWORD * 8], 0 
    mov dword[rbp - DWORD * 9], 0 
    mov dword[rbp - DWORD * 10], 0

    mov dword[rbp - DWORD * 11], 0
    mov dword[rbp - DWORD * 12], 0

   
    mov eax, dword[rbp - DWORD * 1]
    mov ebx, dword[rbp - DWORD * 3]
    sub eax, ebx
    mov dword[rbp - DWORD * 7], eax

    mov eax, dword[rbp - DWORD * 2]
    mov ebx, dword[rbp - DWORD * 4]
    sub eax, ebx
    mov dword[rbp - DWORD * 8], eax

    mov eax, dword[rbp - DWORD * 5]
    mov ebx, dword[rbp - DWORD * 3]
    sub eax, ebx
    mov dword[rbp - DWORD * 9], eax

    mov eax, dword[rbp - DWORD * 6]
    mov ebx, dword[rbp - DWORD * 4]
    sub eax, ebx
    mov dword[rbp - DWORD * 10], eax

    mov eax, dword[rbp - DWORD * 7]
    imul eax, dword[rbp - DWORD * 10]
    mov dword[rbp - DWORD * 11], eax

    mov eax, dword[rbp - DWORD * 9]
    imul eax, dword[rbp - DWORD * 8]
    mov dword[rbp - DWORD * 12], eax

    mov eax, dword[rbp - DWORD * 11]
    mov ebx, dword[rbp - DWORD * 12]
    sub rax, rbx

    add rsp, 48

    mov rsp, rbp
    pop rbp

ret
