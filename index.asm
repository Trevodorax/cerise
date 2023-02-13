; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)
extern printf
extern exit
extern sleep

; internal functions
extern initX11
extern getRandomNumber
extern getDeterminant
extern min
extern max

%define	StructureNotifyMask	131077
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1
%define NB_TRIANGLES  3
%define WINDOW_SIZE 500

global main

section .data
triangles_count: db    0
event:		times	24 dq 0
check: db "%d ", 10, 0
isDrawDone: db 0
poney: db "poney", 10, 0

section .bss
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1
x1: resd 1
y1: resd 1
x2: resd 1
y2: resd 1
x3: resd 1
y3: resd 1
currentX: resd 1
currentY: resd 1
determinant: resd 1
isClockwise: resb 1
isRight: resb 1
fillColor: resd 1
minX: resd 1
minY: resd 1
maxX: resd 1
maxY: resd 1

section .text

main:
push rbp

; ===== TEST VALUES HERE ===== ;
; mov dword[x1], 50
; mov dword[y1], 100
; mov dword[x2], 100
; mov dword[y2], 200
; mov dword[x3], 300
; mov dword[y3], 250

; === initial search points value === ;
mov dword[minX], 0
mov dword[minY], 0
mov dword[maxX], WINDOW_SIZE
mov dword[maxY], WINDOW_SIZE

x11_init:
    ; ===== INIT THE X11 WINDOW ===== ;
    ; === create a display === ;
    xor rdi, rdi
    mov rax, 0
    call XOpenDisplay
    mov qword[display_name], rax

    ; === get screen name === ;
    ; display_name structure
    ; screen = DefaultScreen(display_name);
    mov     rax,qword[display_name]
    mov     eax,dword[rax+0xe0]
    mov     dword[screen],eax

    ; === get parent of the window === ;
    mov rdi, qword[display_name]
    mov esi, dword[screen]
    mov rax, 0
    call XRootWindow
    mov rbx, rax

    ; === create a window === ;
    mov rdi, qword[display_name]
    mov rsi, rbx
    mov rdx, 10      ; window position
    mov rcx, 10      ; window position
    mov r8, WINDOW_SIZE      ; width
    mov r9, WINDOW_SIZE	    ; height
    push 0xFFFFFF   ; border
    push 0x00FF00   ; background
    push 1
    mov rax, 0
    call XCreateSimpleWindow
    mov qword[window], rax

    ; === setup events === ;
    mov rdi, qword[display_name]
    mov rsi, qword[window]
    mov rdx, StructureNotifyMask
    mov rax, 0
    call XSelectInput

    ; === map the window === ;
    mov rdi, qword[display_name]
    mov rsi, qword[window]
    mov rax, 0
    call XMapWindow

    ; === create graphics context for the window === ;
    mov rsi, qword[window]
    mov rdx, 0
    mov rcx, 0
    mov rax, 0
    call XCreateGC
    mov qword[gc], rax

; ===== HANDLE EVENTS ===== ;
handle_events:
    ; === get event === ;
    mov rdi, qword[display_name]
    mov rsi, event
    mov rax, 0
    call XNextEvent

    ; === draw if drawing hasn't been done yet === ;
    cmp byte[isDrawDone], 0
    je draw

    ; === stop program if a key is pressed === ;
    cmp dword[event], KeyPress           ; KeyPress = event when any key is pressed
    je closeDisplay

    jmp handle_events

; ================================ ;
; ====== DRAWING ZONE START ====== ;
; ================================ ;
draw:
    mov byte[isDrawDone], 1
    triangles_loop:
        ; ===== CREATE RANDOM POINTS FOR EACH VERTEX ===== ;
        ; === vertex 1 === ;
        mov rdi, WINDOW_SIZE
        mov rax, 0
        call getRandomNumber
        mov dword[x1], eax

        mov rdi, WINDOW_SIZE
        mov rax, 0
        call getRandomNumber
        mov dword[y1], eax

        ; === vertex 2 === ;
        mov rdi, WINDOW_SIZE
        mov rax, 0
        call getRandomNumber
        mov dword[x2], eax

        mov rdi, WINDOW_SIZE
        mov rax, 0
        call getRandomNumber
        mov dword[y2], eax

        ; === vertex 3 === ;
        mov rdi, WINDOW_SIZE
        mov rax, 0
        call getRandomNumber
        mov dword[x3], eax
        
        mov rdi, WINDOW_SIZE
        mov rax, 0
        call getRandomNumber
        mov dword[y3], eax

        ; ===== CHECK IF TRIANGLE IS CLOCKWISE ===== ;
        clockwise_check:
            mov edi, dword[x1]
            mov esi, dword[y1]
            mov edx, dword[x2]
            mov ecx, dword[y2]
            mov r8d, dword[x3]
            mov r9d, dword[y3]
            call getDeterminant
            mov dword[determinant], eax

            cmp dword[determinant], 0
            jl clockwise

            counterclockwise:
                mov byte[isClockwise], 0
                jmp fill_rectangle

            clockwise:
                mov byte[isClockwise], 1
        
        ; ===== DRAW POINTS TO FILL THE TRIANGLE ===== ;
        fill_rectangle:
            ; === set beginning point of the fill square === ;
            ; minX
            mov edi, dword[x1]
            mov esi, dword[x2]
            mov edx, dword[x3]
            mov rax, 0
            call min
            mov dword[minX], eax

            ; minY
            mov edi, dword[y1]
            mov esi, dword[y2]
            mov edx, dword[y3]
            mov rax, 0
            call min
            mov dword[minY], eax

            ; maxX
            mov edi, dword[x1]
            mov esi, dword[x2]
            mov edx, dword[x3]
            mov rax, 0
            call max
            mov dword[maxX], eax

            ; maxY
            mov edi, dword[y1]
            mov esi, dword[y2]
            mov edx, dword[y3]
            mov rax, 0
            call max
            mov dword[maxY], eax

            ; === put random color in edx === ;
            ; red
            mov rdi, 250
            mov rax, 0
            call getRandomNumber
            mov byte[fillColor], al
            
            ; green
            mov rdi, 250
            mov rax, 0
            call getRandomNumber
            mov byte[fillColor + 1], al

            ; blue
            mov rdi, 250
            mov rax, 0
            call getRandomNumber
            mov byte[fillColor + 2], al

            ; make sure there is nothing here
            mov byte[fillColor + 3], 0 

            ; set the color accordingly
            mov rdi,qword[display_name]
            mov rsi,qword[gc]
            mov edx,dword[fillColor]
            mov rax, 0
            call XSetForeground

            mov rax, 0

            ; ===== DISPLAY THE POINTS IN THE TRIANGLE ===== ;
            mov eax, dword[minX]
            mov dword[currentX], 0 ; eax
            points_loop_x:
                mov eax, dword[minY]
                mov dword[currentY], 0 ; eax
                points_loop_y:
                    ; ===== CHECK IF POINT IS IN THE TRIANGLE ===== ;
                    point_side_check:
                        side_1:
                            mov edi, dword[x2]
                            mov esi, dword[y2]
                            mov edx, dword[x1]
                            mov ecx, dword[y1]
                            mov r8d, dword[currentX]
                            mov r9d, dword[currentY]
                            mov rax, 0
                            call getDeterminant
                            mov dword[determinant], eax

                            cmp dword[determinant], 0
                            jl first_left
                            
                            first_right:
                                mov byte[isRight], 1
                                jmp side_2

                            first_left:
                                mov byte[isRight], 0

                        side_2:
                            mov edi, dword[x3]
                            mov esi, dword[y3]
                            mov edx, dword[x2]
                            mov ecx, dword[y2]
                            mov r8d, dword[currentX]
                            mov r9d, dword[currentY]
                            mov rax, 0
                            call getDeterminant
                            mov dword[determinant], eax

                            cmp dword[determinant], 0
                            jl second_left

                            second_right:
                                cmp byte[isRight], 0
                                je point_outside
                                jmp side_3
                            
                            second_left:
                                cmp byte[isRight], 1
                                je point_outside
                        
                        side_3:
                            mov edi, dword[x1]
                            mov esi, dword[y1]
                            mov edx, dword[x3]
                            mov ecx, dword[y3]
                            mov r8d, dword[currentX]
                            mov r9d, dword[currentY]
                            mov rax, 0
                            call getDeterminant
                            mov dword[determinant], eax

                            cmp dword[determinant], 0
                            jl third_left

                            third_right:
                                cmp byte[isRight], 0
                                je point_outside
                                jmp all_right
                            
                            third_left:
                                cmp byte[isRight], 1
                                je point_outside
                                jmp all_left

                        all_right:
                            cmp byte[isClockwise], 1
                            je point_inside
                            jmp point_outside

                        all_left:
                            cmp byte[isClockwise], 0
                            je point_inside
                            jmp point_outside 

                    point_inside:
                        jmp draw_point
                    
                    point_outside:
                        jmp points_loop_y_check

                    draw_point:
                        mov rdi, qword[display_name]
                        mov rsi, qword[window]
                        mov rdx, qword[gc]
                        mov ecx, dword[currentX]
                        mov r8d, dword[currentY]
                        mov rax, 0
                        call XDrawPoint
                    
                points_loop_y_check:
                    inc dword[currentY]
                    mov eax, dword[maxY]
                    cmp dword[currentY], 500 ; eax
                    jl points_loop_y

            points_loop_x_check:
                inc dword[currentX]
                mov eax, dword[maxX]
                cmp dword[currentX], 500; eax
                jl points_loop_x

         ; ===== DRAW LINES FOR EACH SIDE OF TRIANGLE ===== ;
        ; === set draw color === ;
        mov rdi,qword[display_name]
        mov rsi,qword[gc]
        mov edx,0x000000
        call XSetForeground

        ; === line 1 === ;
        mov rdi, qword[display_name]
        mov rsi, qword[window]
        mov rdx, qword[gc]
        mov ecx, dword[x1]	
        mov r8d, dword[y1]
        mov r9d, dword[x2]
        mov ebx, dword[y2]
        push rbx
        call XDrawLine
        pop rbx

        ; === line 2 === ;
        mov rdi, qword[display_name]
        mov rsi, qword[window]
        mov rdx, qword[gc]
        mov ecx, dword[x2]	
        mov r8d, dword[y2]
        mov r9d, dword[x3]
        mov ebx, dword[y3]
        push rbx
        call XDrawLine
        pop rbx

        ; === line 3 === ;
        mov rdi, qword[display_name]
        mov rsi, qword[window]
        mov rdx, qword[gc]
        mov ecx, dword[x3]	
        mov r8d, dword[y3]
        mov r9d, dword[x1]
        mov ebx, dword[y1]
        push rbx
        call XDrawLine
        pop rbx

        ; ===== triangles loop check ===== ;
        triangle_loop_check:
            inc byte[triangles_count]
            cmp byte[triangles_count], NB_TRIANGLES
            jb triangles_loop

; ================================ ;
; ======= DRAWING ZONE END ======= ;
; ================================ ;

jmp handle_events

; ===== END OF PROGRAM ===== ;
closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    pop     rbp
    call    exit
