bits 64 
%idefine rip rel $
section .data
    value: db 0
section .bss
    block1: resq 10
    block2: resq 10

section .text
    global _start

_start:
    xor rdi, rdi
    push byte 12
    pop rax
    syscall
    
    push block1
    pop rdx
    
    mov r10,rax
    mov rbx,rax
    mov r15,rax
    
    lea r12, [rel _putchar]
    
_reload:
    lea rsi, [byte(_txt-_putchar)+r12]
_loop:
    lodsb
    cmp al, 0
    jg _char
    cbw
    cwde
    cdqe
    add rax, r12
    jmp rax
_char:
    call r12
    jmp _loop
_exit:
    mov rsi, r10
    mov rdx, rbx
    sub rdx, r10
    push byte 1
    pop rdi
    mov rax, rdi
    syscall
    
    xor rdi, rdi
    push byte 60
    pop rax
    syscall
_nomore:
    push rsi
    mov r13b, 7
    lea rsi, [rel _nomore_txt]
    
_nomore_loop:
    LODSB
    CALL r12
    DEC r13b
    JNE _nomore_loop
    POP rsi
    JMP _loop
_plural:
    CMP dl, 1
    JE _loop
    MOV al, 's'
    CALL r12
    JMP _loop
_restart:
    CMP dl, 0
    JE _loop
    JMP _reload
_sub:
    dec edx
    CMP dl, 0
    JE _nomore
_num:
    MOV eax, edx
    MOV cl, 10
    DIV cl
    CMP al, 0
    JE _ignore0
    PUSH rax
    ADD al, '0'
    CALL r12
    POP rax
_ignore0:
    MOV al, ah
    ADD al, '0'
    CALL r12
    JMP _loop
_putchar:
    MOV ebp, eax
    CMP r15, rbx ; Need more mem?
    JG _putchar_ok
    LEA rdi, [0x1000 + r15] ; New max (one page at a time...)
    MOV r15, rdi
    PUSH BYTE 12
    POP rax ; SYS_brk
    SYSCALL
    
;_getComp:
 ;   MOV eax, edx
  ;  MOV cl, 10
;    DIV cl
;    CMP al, 0
;    JE _ignore1
;    PUSH rax
;    ADD al, '0'
;    CALL r12
;    POP rax
;_ignore1:
;    MOV al, ah
;    ADD al, '0'
;    CALL r12
;    JMP _loop
;_Comchar:
;    MOV ebp, eax
;    CMP r15, rbx ; Need more mem?
;    JG _putchar_ok
;    LEA rdi, [0x1000 + r15] ; New max (one page at a time...)
;    MOV r15, rdi
;    PUSH BYTE 12
;    POP rax ; SYS_brk
;    SYSCALL
    

    
_putchar_ok:
    MOV [rbx], bpl
    INC rbx
    RET
_txt:
    DB _num-_putchar, " memory, ", 0x0a
;    DB  _getComp-_Comchar, " 1's comp stored.",0x0a
    DB _sub-_putchar, " next memory",  0x0a, 0x0a
    DB _restart-_putchar
_nomore_txt:
    DB _exit-_putchar        
