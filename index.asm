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
check_points_str: db "x1: %lu", 10, "y1: %lu", 10, "x2: %lu", 10, "y2: %lu", 10, "x3: %lu", 10, "y3: %lu", 10, 10, 0

section .bss
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1
x1: resq 1
y1: resq 1
x2: resq 1
y2: resq 1
x3: resq 1
y3: resq 1

section .text

mov byte[triangles_count], 0
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
        mov qword[x1], rax

        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov qword[y1], rax

        ; === vertex 2 === ;
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov qword[x2], rax

        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov qword[y2], rax

        ; === vertex 3 === ;
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov qword[x3], rax
        
        mov rdi, WINDOW_SIZE
        call getRandomNumber
        mov qword[y3], rax

        ; === print the points === ;
        ; mov rdi, check_points_str
        ; mov rsi, qword[x1]
        ; mov rdx, qword[y1]
        ; mov rcx, qword[x2]
        ; mov r8, qword[y2]
        ; mov r9, qword[x3]
        ; push qword[y3]
        ; mov rax, 0
        ; call printf

        ; ===== DRAW LINES FOR EACH SIDE OF TRIANGLE ===== ;
        ; === line 1 === ;
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov rcx,qword[x1]	
        mov r8,qword[y1]
        mov r9,qword[x2]
        push qword[y2]
        call XDrawLine

        ; === line 2 === ;
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov rcx,qword[x2]	
        mov r8,qword[y2]
        mov r9,qword[x3]
        push qword[y3]
        call XDrawLine

        ; === line 3 === ;
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov rcx,qword[x3]	
        mov r8,qword[y3]
        mov r9,qword[x1]
        push qword[y1]
        call XDrawLine

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
