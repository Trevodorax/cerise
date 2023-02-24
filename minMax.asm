global min
global max

min:
    push rbp
    mov rbp, rsp

    cmp rdi, rsi
    jl rdi_small
    jmp rsi_small

    rdi_small:
        cmp rdi, rdx
        jl rdi_smallest
        jmp rdx_smallest

    rsi_small:
        cmp rsi, rdx
        jl rsi_smallest
        jmp rdx_smallest

    rdi_smallest:
        mov rax, rdi
        jmp min_end
    
    rsi_smallest:
        mov rax, rsi
        jmp min_end
    
    rdx_smallest:
        mov rax, rdx
        jmp min_end

    min_end:
        mov rsp, rbp
        pop rbp
ret

max:
    push rbp
    mov rbp, rsp

    cmp rdi, rsi
    jg rdi_big
    jmp rsi_big

    rdi_big:
        cmp rdi, rdx
        jg rdi_biggest
        jmp rdx_biggest

    rsi_big:
        cmp rsi, rdx
        jg rsi_biggest
        jmp rdx_biggest

    rdi_biggest:
        mov rax, rdi
        jmp max_end
    
    rsi_biggest:
        mov rax, rsi
        jmp max_end
    
    rdx_biggest:
        mov rax, rdx
        jmp max_end

    max_end:
        mov rsp, rbp
        pop rbp

ret
