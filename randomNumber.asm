extern printf

global getRandomNumber

getRandomNumber:
    push rbp
    mov rbp, rsp

    mov rax, 0
    call printf

    mov rsp, rbp
    pop rbp

ret
