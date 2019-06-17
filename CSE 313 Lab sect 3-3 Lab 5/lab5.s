bits 64 
%idefine rip rel $

section .text
    global _start
_start:
    xor edi, edi
    push byte 12
    pop rax
    syscall
    
    push byte 99
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
    mov eax, edi
    syscall
    
    xor edi, edi
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
    DEC edx
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
    CMP r15, rbx                    ; Need more mem?
    JG _putchar_ok
    LEA rdi, [0x1000 + r15]         ; New max (one page at a time...)
    MOV r15, rdi
    PUSH BYTE 12
    POP rax                         ; SYS_brk
    SYSCALL
_putchar_ok:
    MOV [rbx], bpl
    INC rbx
    RET
_txt:
    DB _num-_putchar, " bottle", _plural-_putchar, " of beer on the wall, "
    DB _num-_putchar, " bottle", _plural-_putchar, " of beer.", 0x0a
    DB "Take one down and pass it around, "
    DB _sub-_putchar, " bottle", _plural-_putchar, " of beer on the wall.", 0x0a, 0x0a
    DB _restart-_putchar
    DB "No more bottles of beer on the wall, "
_nomore_txt:
    DB "no more bottles of beer.", 0x0a
    DB "Go to the store and buy some more, 99 bottles of beer on the wall.", 0x0a
    DB _exit-_putchar        
