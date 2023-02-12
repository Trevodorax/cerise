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

; internal functions
extern initX11
extern getRandomNumber
extern getDeterminant

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
check_points_str: db "x1: %u", 10, "y1: %u", 10, "x2: %u", 10, "y2: %u", 10, "x3: %u", 10, "y3: %u", 10, 10, 0
check: db "%d", 10, 0

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
determinant: resd 1

section .text

main:
push rbp

x11_init:
    ; ===== INIT THE X11 WINDOW ===== ;
    ; === create a display === ;
    xor rdi, rdi
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
    call XCreateSimpleWindow
    mov qword[window], rax

    ; === setup events === ;
    mov rdi, qword[display_name]
    mov rsi, qword[window]
    mov rdx, StructureNotifyMask
    call XSelectInput

    ; === map the window === ;
    mov rdi, qword[display_name]
    mov rsi, qword[window]
    call XMapWindow

    ; === create graphics context for the window === ;
    mov rsi, qword[window]
    mov rdx, 0
    mov rcx, 0
    call XCreateGC
    mov qword[gc], rax

; ===== HANDLE EVENTS ===== ;
handle_events:
    ; === get event === ;
    mov rdi, qword[display_name]
    mov rsi, event
    call XNextEvent

    ; === draw if program just started (or if the window is moved) === ;
    cmp dword[event], ConfigureNotify    ; ConfigureNotify = event at the beginning of the program
    je draw

    ; === stop program if a key is pressed === ;
    cmp dword[event], KeyPress           ; KeyPress = event when any key is pressed
    je closeDisplay

    jmp handle_events

; ================================ ;
; ====== DRAWING ZONE START ====== ;
; ================================ ;
draw:
    triangles_loop:
        ; === set draw color === ;
        mov rdi,qword[display_name]
        mov rsi,qword[gc]
        mov edx,0x000000
        call XSetForeground

        ; ===== CREATE RANDOM POINTS FOR EACH VERTEX ===== ;
        ; === vertex 1 === ;
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov dword[x1], eax

        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov dword[y1], eax

        ; === vertex 2 === ;
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov dword[x2], eax

        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov dword[y2], eax

        ; === vertex 3 === ;
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov dword[x3], eax
        
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov dword[y3], eax

        ; ===== DRAW LINES FOR EACH SIDE OF TRIANGLE ===== ;
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

        ; ===== CHECK IF TRIANGLE IS CLOCKWISE ===== ;
        ; mov edi, dword[x1]
        ; mov esi, dword[y1]
        ; mov edx, dword[x2]
        ; mov ecx, dword[y2]
        ; mov r8d, dword[x3]
        ; mov r9d, dword[y3]
        ; mov r10, check
        ; call getDeterminant        

        ; ===== triangles loop check ===== ;
        inc byte[triangles_count]
        cmp byte[triangles_count], NB_TRIANGLES - 1
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
