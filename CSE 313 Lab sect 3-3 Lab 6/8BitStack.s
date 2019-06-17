section .data
    msgPush: db "Pushed to 8bit stack",0
    msgPop:  db "Popped from 8bit stack",0
    value:   db  0xf
section .bss

    valueHex: resb 32
    valueHexPos: resb 32

section .text
    global _start
    
_start:
    mov rax, value
    call _pushStack8
    
    mov rax, 60
    mov rdi, 0
    syscall
    
_pushStack8:
  ;;  call _printHex
 ;;   push ax
    
    mov rax, [msgPush]
    call _printMsg

_printMsg:
    push rax
    mov rbx, 0

_printLoop:
    inc rax
    inc rbx
    mov cl, [rax]
    cmp cl, 0
    jne _printLoop
    mov rax, 1
    mov rdi, 1
    pop rsi
    mov rdx, rbx
    syscall

        ret
 _printHex:
    mov rcx, valueHex                   ;move valueHex to rcx
    mov rbx, 10
    mov [rcx], rbx
    inc rcx                             ;get first char
    mov [valueHexPos], rcx              ;store in valueHexPos

_loop5:
    mov rdx, 0
    mov rbx, 16d                        ;move 16 to rbx
    div rbx                             ;divide rax by rbx. remainder goes to rdx
    push rax                            ;push value of rax to stack
    add rdx, 48                         ;add 48 to get ascii char

    cmp rdx, '9'                        ;compare if value is less than the ascii char for 9
    jbe _finish                         ;if it is skip next line
    add rdx, 7                          ;if its not, add 7 to get ascii value for A-F

_finish:

    mov rcx, [valueHexPos]              ;store char to valueHexPos
    mov [rcx], dl
    inc rcx                             ;get next char
    mov [valueHexPos], rcx

    pop rax                             ;get value from stack and put back to rax
    cmp rax, 0                          ;see if rax is zero
    jne _loop5                          ;loop until it is zero
_loop6:
    mov rcx, [valueHexPos]              ;get char from valueHexPos
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall                             ;print char

    mov rcx, [valueHexPos]   
    dec rcx
    mov [valueHexPos], rcx

    cmp rcx, valueHex                   ;loop until valueHex equals valueBinPos
    jge _loop6
    ret

