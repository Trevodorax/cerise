extern printf

global getRandomNumber

getRandomNumber:
    push rbp
    mov rbp, rsp

    get_rand:
        mov r8, 0
        RDRAND r8
        mov rax, r8
        mov rbx, rdi
        jnc get_rand
        xor rdx, rdx
        div rbx
        mov r8, rdx
        mov rax, r8

    mov rsp, rbp
    pop rbp

ret
