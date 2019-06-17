;*************************************************************************************************
;* Converting User input to Binary, Octal, and Hex
;* the purpose of this program is to take users input in the form of a string of char and convert
;* it into Binary, Octal and Hex. The program converts the string into an integer which then can
;* be divided by the radux of which its being converted to. The final results will be displayed 
;* to console for each type 
;************************************************************************************************
section .data
    msg    dw "Value Entered: ",10,0            ;strings to be displayed to console
    msg1   dw "Value In Binary: ",0
    msg2   dw "Value In Octal: ",0
    msg3   dw "Value In Hex: ",0
    newLine dw  "      ",10,0    
    buffer: db 0                                ;will hold integer value of converted string

section .bss
    value: resw 1               ;stores user input
    valueend: resw 1            ;pos of end of value variable
    shift: resw 1               ;value that will be multiplied to get conversion from ascii to int
    valueBin: resb 32           ;stores conversion in ascii
    valueOct: resb 32
    valueHex: resb 32
    valueBinPos: resb 32        ;stores pos of value
    valueOctPos: resb 32
    valueHexPos: resb 32
section .text
    global _start
_start:

    mov rax, 1                  
    mov [shift], rax            ;moving value of one into shift

    mov rax, msg
    call _printMsg              ;Printing Prompt msg to console

    call _getValue              ;getting users input

    mov rax, newLine
    call _printMsg              ;Printing a new line

    mov rax, msg1
    call _printMsg              ;Pring Binary msg to console

    mov rbx, valueend
    call _atoi                  ;calling function to convert ascii
                                ;String to integer
    xor rax, rax
    add eax, [buffer]
    call _Dec2Bin               ;Function converts integer to binary
                                ;and prints to screen
    mov rax, msg2
    call _printMsg              ;Print Octal msg to console

    xor rax, rax
    add eax, [buffer]
    call _Dec2Oct               ;Function converts integer to octal
                                ;and prints to screen
    mov rax, msg3
    call _printMsg              ;Print Hex msg to console
    
    xor rax, rax
    add eax, [buffer]
    call _Dec2Hex               ;Function converts integer to Hex
                                ;and prints to screen
    mov rax, 60
    mov rdi, 0
    syscall                     ;end program

;****************************************************************
;*_getValue:
;* This function moves user input into variable 'value'. it is 
;* stored as a string which can be up to 16 characters in lenght.
;****************************************************************
_getValue:
    mov rax, 0
    mov rdi, 0
    mov rsi, value
    mov rdx, 16
    syscall
    ret

;****************************************************************
;*_printMsg:
;* This function prints a string of any lenght. A loop iterates 
;* through the given string, comparing after each loop. Once
;* cl is equal to zero, the length and string are moved and a 
;* system call prints the string
;***************************************************************
_printMsg:                  
    push rax                    ;push string to stack
    mov rbx, 0                  
_loop:
    inc rax
    inc rbx
    mov cl, [rax]               ;moves char into cl
    cmp cl, 0                   ;comer char to 0
    jne _loop                   ;loop if not equal
   
    mov rax, 1
    mov rdi, 1
    pop rsi                     ;move string from stack to rsi
    mov rdx, rbx                ;move lenght into rdx
    syscall
    ret

;****************************************************************
;*_atoi:
;* This function converts a string of ascii char to integers. 
;* By having an empty variable after value, we can access the
;* string in value from right to left. From there we can substract
;* 0x30 from each character to get the integer value. The value
;* in shift contains value of one at start and is multiplied by
;* 10 each loop. That value to multiplied by the interger from the
;* value string and added to the buffer. Buffer will hold the
;* final integer value of the string
;*****************************************************************
_atoi:
    xor rax, rax                        ;clear registers
    xor r8, r8
_Set:    
    movzx rcx,byte [rbx]                ;mov a char to rcx
    cmp rcx, 0                          ;compare it to 0 "null terminated'
    je _dec                             ;jump to loop to decrement
    cmp rcx, 10                         ;compare it to 10 "new line"
    je _dec                             ;jump to loop to decrement
    cmp rcx, 13                         ;compare it to 13 "cariage return'
    je _dec                             ;jump to loop to decrement
    dec rbx                             ;once pasted previous coditions decrement once more
_top:

    cmp rcx, '0'                        ;check if the characters value is less than 0x30
    jb _done                            ;if it is we are done
    cmp rcx, '9'                        ;check if the characters value is more than 0x39
    ja _done                            ;if it is we are done
    sub rcx, '0'                        ;else subtract 0x30
    
    mov rdx, rcx                        ;add that value to rdx
    mov rax, rcx                        ;and also rax
    mov r8, [shift]                     ;move value of shift to r8 (starts at 1)
    mul r8                              ;multiply r8 with rax

    add rax, [buffer]                   ;add contents of buffer to rax
    mov [buffer], rax                   ;and move value back to buffer variable
    
    mov rax, [shift]                    ;mov shift value to rax
    mov r8, 10                          ;move r8 value of 10
    mul r8                              ;multiply r8 and rax 
    mov [shift], rax                    ;store the value back to shift
    movzx rcx, byte [rbx]               ;get the next character
    dec rbx                             ;decrement rbx

    jmp _top                            ;loop until comparason results in _done
    
_dec:
    dec rbx                             ;decrement  and jumps back to _set
    jmp _Set
_done:                                  ;once conversions done return to main
    ret

;******************************************************************************
;*_Dec2Bin:
;* This function converts an integer by dividing the number by 2. The quotent
;* will be stored in the rax, while the remander is stored in the rdx. The
;* value in the rdx will have 48 added to is value to get the ascii char back.
;* This value will then be stored in the valueBin to be printed in the last 
;* loop
;******************************************************************************
_Dec2Bin:
    mov rcx, valueBin                   ;set valueBin to rcx
    mov rbx, 10                         ;mov newline char to ebx
    mov [rcx], rbx                      ;add newline to rcx
    inc rcx                             
    mov [valueBinPos], rcx              ;move that value into ValueBinPos

_loop1:
    mov rdx, 0
    mov rbx, 2                          
    div rbx                             ;divideds rax by rbx
    push rax                            ;mov rax to stack
    add rdx, 48                         ;add 48 to get asscii char

    mov rcx, [valueBinPos]              ;move valueBinPos to rcx
    mov [rcx], dl                       ;store results from the dl
    inc rcx                             
    mov [valueBinPos], rcx              ;get next char

    pop rax                             ;retrieve value from stack
    cmp rax, 0                          ;check if rax it a zero (end of conversion)
    jne _loop1                          ;loop until rax is zero
_loop2:
    mov rcx, [valueBinPos]              ;get the last value from valueBinPos
    mov rax, 1                      
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall                             ;print char to console

    mov rcx, [valueBinPos]              
    dec rcx
    mov [valueBinPos], rcx              ;get next char

    cmp rcx, valueBin                   ;Once valueBin and valueBinPos are equal we are done
    jge _loop2                          ;loop if not
    ret
    
;******************************************************************************************
;*_Dec2Oct:
;* This function takes the value from the buffer which is a decimal integer and converts it
;* to Octal form. This is done by dividing the value by 8 and storing the remainder. This
;* is done until rax is zero. The results from the remainder are then converted to ascii
;* and printed to console
;******************************************************************************************
_Dec2Oct:
    mov rcx, valueOct                   ;set valueOct to rcx
    mov rbx, 10                         
    mov [rcx], rbx
    inc rcx                             ;increase position
    mov [valueOctPos], rcx              ;store in valueOctPos

_loop3:
    mov rdx, 0
    mov rbx, 0x08                       ;move 8 to rbx
    div rbx                             ;divide rax by rbx, remainder stored in rdx
    push rax                            ;push rax to stack
    add rdx, 48                         ;add 48 to get ascii char

    mov rcx, [valueOctPos]              ;store remaider in edx in ascii to valueOctPos
    mov [rcx], dl
    inc rcx                             ;get next char
    mov [valueOctPos], rcx

    pop rax                             ;get value back from stack
    cmp rax, 0                          ;compare rax to zero
    jne _loop3                          ;loop until rax reaches zero
_loop4:
    mov rcx, [valueOctPos]              ;get char from valueOctPos
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall                             ;print char to console

    mov rcx, [valueOctPos]              ;get next char from valueOctPos
    dec rcx
    mov [valueOctPos], rcx

    cmp rcx, valueOct                   ;compare valueOct to valueOctPos
    jge _loop4                          ;loop until they are equal
    ret
    
;***************************************************************************************
;*_Dec2Hex:
;* This function takes the value from buffer which is an Integer and converts it to 
;* Hex. This is done by divinding the integer by 16 and adding 0x30 to get its ascii
;* value. If the result is from A-F, add another 7 to get their proper ascii code. 
;* after conversion print each char to console
;***************************************************************************************
 _Dec2Hex:
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

    mov rcx, [valueHexPos]              ;get next char
    dec rcx
    mov [valueHexPos], rcx

    cmp rcx, valueHex                   ;loop until valueHex equals valueBinPos
    jge _loop6
    ret
