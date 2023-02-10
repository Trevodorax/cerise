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

%define	StructureNotifyMask	131072
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
%define NBLOOP  3

global main

section .bss
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1
count:           resb    1

section .data

event:		times	24 dq 0
x1:	dd	500
x2:	dd	500
x3:     dd      500
y1:	dd	500
y2:	dd	500
y3:     dd      500

section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
mov byte[count], 0
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify ; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:

;couleur de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov edx,0x000000	; Couleur du crayon ; noir
call XSetForeground
; dessin de la ligne 1
mov r8, 0
RDRAND r8
mov rax, r8
mov rbx, 400
xor rdx, rdx
div rbx
mov r8, rdx
mov [x1], r8

mov r8, 0
RDRAND r8
mov rax, r8
mov rbx, 400
xor rdx, rdx
div rbx
mov r8, rdx
mov [x2], r8

mov r8, 0
RDRAND r8
mov rax, r8
mov rbx, 400
xor rdx, rdx
div rbx
mov r8, rdx
mov [x3], r8

mov r8, 0
RDRAND r8
mov rax, r8
mov rbx, 400
xor rdx, rdx
div rbx
mov r8, rdx
mov [y1], r8

mov r8, 0
RDRAND r8
mov rax, r8
mov rbx, 400
xor rdx, rdx
div rbx
mov r8, rdx
mov [y2], r8

mov r8, 0
RDRAND r8
mov rax, r8
mov rbx, 400
xor rdx, rdx
div rbx
mov r8, rdx
mov [y3], r8

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x1]	; coordonnée source en x
mov r8d,dword[y1]	; coordonnée source en y
mov r9d,dword[x2]	; coordonnée destination en x
push qword[y2]		; coordonnée destination en y
call XDrawLine

; coordonnées de la ligne 1 (noire)
; dessin de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x2]	; coordonnée source en x
mov r8d,dword[y2]	; coordonnée source en y
mov r9d,dword[x3]	; coordonnée destination en x
push qword[y3]		; coordonnée destination en y
call XDrawLine

; coordonnées de la ligne 1 (noire)
; dessin de la ligne 1
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,qword[gc]
mov ecx,dword[x3]	; coordonnée source en x
mov r8d,dword[y3]	; coordonnée source en y
mov r9d,dword[x1]	; coordonnée destination en x
push qword[y1]		; coordonnée destination en y
call XDrawLine

inc byte[count]
cmp byte[count], NBLOOP
jne dessin

; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush
pop rbp
flush:
mov rdi,qword[display_name]
call XFlush
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
	
