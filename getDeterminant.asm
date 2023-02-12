extern printf

%define DWORD 4

global getDeterminant

getDeterminant:
    push rbp
    mov rbp, rsp

    ; ===== LOCAL VARIABLES ===== ;
    ; === making space === ;
    ; 12 dwords = 48 bytes
    sub rsp, 48

    ; === store the arguments === ;
    mov dword[rbp - DWORD * 1], edi ; xa
    mov dword[rbp - DWORD * 2], esi ; ya
    mov dword[rbp - DWORD * 3], edx ; xb
    mov dword[rbp - DWORD * 4], ecx ; yb
    mov dword[rbp - DWORD * 5], r8d ; xc
    mov dword[rbp - DWORD * 6], r9d ; yc

    ; === variables for the calculations === ;
    mov dword[rbp - DWORD * 7], 0   ; Xba
    mov dword[rbp - DWORD * 8], 0   ; Yba
    mov dword[rbp - DWORD * 9], 0   ; Xbc
    mov dword[rbp - DWORD * 10], 0  ; Ybc

    mov dword[rbp - DWORD * 11], 0  ; Xba * Ybc
    mov dword[rbp - DWORD * 12], 0  ; Xbc * Yba

    ; =============================== ;
    ; ===== START CALCULATIONS ====== ;
    ; =============================== ;

    ; ===== Xba, Yba, Xbc, Ybc ===== ;
    ; Xba = xa - xb
    mov eax, dword[rbp - DWORD * 1]
    mov ebx, dword[rbp - DWORD * 3]
    sub eax, ebx
    mov dword[rbp - DWORD * 7], eax

    ; Yba = ya - yb
    mov eax, dword[rbp - DWORD * 2]
    mov ebx, dword[rbp - DWORD * 4]
    sub eax, ebx
    mov dword[rbp - DWORD * 8], eax

    ; Xbc = Xc - Xb
    mov eax, dword[rbp - DWORD * 5]
    mov ebx, dword[rbp - DWORD * 3]
    sub eax, ebx
    mov dword[rbp - DWORD * 9], eax

    ; Ybc = yc - yb
    mov eax, dword[rbp - DWORD * 6]
    mov ebx, dword[rbp - DWORD * 4]
    sub eax, ebx
    mov dword[rbp - DWORD * 10], eax

    ; ===== Xba*Ybc  AND  Xbc*Yba ===== ;
    ; Xba * Ybc
    mov eax, dword[rbp - DWORD * 7]
    imul eax, dword[rbp - DWORD * 10]
    mov dword[rbp - DWORD * 11], eax

    ; Xbc * Yba
    mov eax, dword[rbp - DWORD * 9]
    imul eax, dword[rbp - DWORD * 8]
    mov dword[rbp - DWORD * 12], eax

    ; ===== Xba * Ybc - Xbc * Yba ===== ;
    mov eax, dword[rbp - DWORD * 11]
    mov ebx, dword[rbp - DWORD * 12]
    sub rax, rbx

    ; =============================== ;
    ; ====== END CALCULATIONS ======= ;
    ; =============================== ;

    mov rsp, rbp
    pop rbp

ret


; ===== UNIT TEST ===== ;
; ; expect : -636
; mov edi, 14
; mov esi, 20
; mov edx, 25
; mov ecx, 69
; mov r8d, 10
; mov r9d, 60
; call getDeterminant
; mov dword[determinant], eax

; mov rdi, check
; mov esi, dword[determinant]
; mov rax, 0
; call printf