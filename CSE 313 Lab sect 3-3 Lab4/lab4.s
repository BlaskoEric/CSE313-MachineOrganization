%use altreg

section .data
    str1: db "Enter 8-bit binary number      : ", 0         ;Strings to print Msgs
    str2: db "Binary number with parity bits : ",0
    str3: db "Generating 1-bit error         : ",0
    str4: db "Detecting and correcting error : ",0   
    newLine dw  "      ",10,0
    buffer: dw 0                                            ;holds int value from string
    temp1: db 0                                             ;used as temp storage for R0 
    temp2: db 0
    temp3: db 0
    temp4: db 0
section .bss
    value: resb 2                                           ;stores user input
    valueend resw 1
    valueBin resw 12                                        ;holds binary value of input
    valueBinPos resb 12                                     ;holds position of valueBin

section .text

    global _start

_start:
    
    mov rax, str1                       ;Print first String
    call _printMsg

    call _getValue                      ;gets users input

    mov rbx, value                      ;Converts user input to integer
    call _atoi


;****************************************************************************************
; Starting at this point we load the starting value, then do bit position manipulation
; to make space for the parity bits. The R0-R7 registers are actually the rax-rdi 
; registers. I used a register rename function at the begining to make the calculations
; easier for myself
;***************************************************************************************

    ; Load the value into R1

    xor     R0,     R0
    XOR     R1,     R1
    XOR     R2,     R2
    MOV     R3,     R3
    mov     R1,     [buffer]


    ; Begin by expanding the 8-bit value to 12-bits, inserting
    ; zeros in the positions for the four check bits (bit 0, bit 1, bit 3
    ; and bit 7).

    xor     r8,     r8          ;Clear all bits apart from d0
    mov     r8,     0x1
    mov     r9,     r1
    and     r8,     r9
    mov     r2,     r8

    xor     r8,     r8          ;Align data bit d0
    mov     r8,     r2
    shl     r8,     2
    mov     r0,     r8

    xor     r8,     r8          ;clear all bits apart from d1, d2, & d3
    mov     r8,     0xE
    mov     r9,     r1
    and     r8,     r9
    mov     r2,     r8

    xor     r8,     r8          ;Align data bits d1, d2 & d3. Combine with d0
    mov     r8,     r2
    shl     r8,     3
    mov     r9,     r0
    or      r8,     r9
    mov     r0,     r8

    xor     r8,     r8          ;Clear all bits apart from d3-d7
    mov     r8,     0xF0
    mov     r9,     r1
    and     r8,     r9
    mov     r2,     r8

    xor     r8,     r8          ;Align data bits d4-d7 and combine with d0-d3
    mov     r8,     r2
    shl     r8,     4
    mov     r9,     r0
    or      r8,     r9
    mov     r0,     r8

;******************************************************************************
; We now have a 12-bit value in R0 with empty (0) check bits in
; the correct positions. Positions look like 
; B B B B P B B B P B P P
; Where B = bit
;       P = Parity bit (set to zero)
;******************************************************************************

    ; Generate check bit c0
    
    XOR     R8,     R8          ;Generate c0 parity bit using parity trees
    MOV     R8,     R0          
    SHR     R8,     2
    MOV     R9,     R0
    XOR     R8,     R9
    MOV     R2,     R8   

    XOR     R8,     R8          ;Second iteration
    MOV     R8,     R2
    SHR     R8,     4
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     r8

    XOR     R8,     R8          ;final iteration
    MOV     R8,     R2
    SHR     R8,     8
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8
   
    XOR     R8,     R8          ;Clear all but check bit c0
    MOV     R8,     0X1
    MOV     R9,     R2  
    AND     R8,     R9
    MOV     R2,     R8
    XOR     R8,     R8

    MOV     R8,     R2          ;Combine check bit c0 with results
    MOV     R9,     R0
    OR      R8,     R9      
    MOV     R0,     R8      

    ; Generate check bit c1
    
    XOR     R8,     R8              ;Generate c1 parity bit using parity tree
    MOV     R8,     R0
    SHR     R8,     1
    MOV     R9,     R0
    XOR     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;Second iteration
    MOV     R8,     R2
    SHR     R8,     4
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;final iteration
    MOV     R8,     R2
    SHR     R8,     8
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;Clear all but check bit c1
    MOV     R8,     0X2
    MOV     R9,     R2  
    AND     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;Combine check bit c1 with result
    MOV     R8,     R2
    MOV     R9,     R0
    OR      R8,     R9      
    MOV     R0,     R8 

    ; Generate check bit c2
    
    XOR     R8,     R8              ;Generate c2 parity bit using parity tree
    MOV     R8,     R0
    SHR     R8,     1
    MOV     R9,     R0
    XOR     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;second iteration
    MOV     R8,     R2
    SHR     R8,     2
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;final iteration
    MOV     R8,     R2
    SHR     R8,     8
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;clear all but check bit c2
    MOV     R8,     0X8
    MOV     R9,     R2  
    AND     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;Combine check bit c2 with results
    MOV     R8,     R2
    MOV     R9,     R0
    OR      R8,     R9      
    MOV     R0,     R8 
    
    ; Generate check bit c3

    XOR     R8,     R8              ;Generate c3 parity bit using parity tree
    MOV     R8,     R0   
    SHR     R8,     1
    MOV     R9,     R0
    XOR     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;second iteration
    MOV     R8,     R2
    SHR     R8,     2
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8

    XOR     R8,     R8              ;final iteration
    MOV     R8,     R2
    SHR     R8,     4
    MOV     R9,     R2
    XOR     R8,     R9
    MOV     R2,     R8
    
    XOR     R8,     R8              ;Clear all but check bit c3
    MOV     R8,     0X80
    MOV     R9,     R2  

    AND     R8,     R9              ;Combine check bit c3 with results
    MOV     R2,     R8
    XOR     R8,     R8
    MOV     R8,     R2
    MOV     R9,     R0
    OR      R8,     R9      
    MOV     R0,     R8 

;*******************************************************************************
; At this point be now have a 12-bit value with the Hamming code check bits.
; c0 was gererated by 1,3,5,7,9,11 positions
; c1 was generated by 2-3,6-7,10-11 positions
; c2 was generated by 4-7,12 positions
; c3 was generated by 8-12 positions
;*******************************************************************************
    mov     [temp1],r0              ;store r0 so it can be retrieved after printMsg
    mov     rax,    str2            ;Print String 2
    call _printMsg  

    mov     r0,     [temp1]         ;Print value from r0
    call _printNumber

    mov     r0,     [temp1]         ;move original value back to r0


;*******************************************************************************
; The next section will create an artificial error by fliiping a single bit.
;****************************************************************************** 
    
    XOR     R8,     R8              ;Flip bit 8 to test
    MOV     R8,     0X100
    MOV     R9,     R0
    XOR     R8,     R9   
    MOV     R0,     R8  

    mov     [temp1],r0              ;store r0 so it can be retrieved after print

    mov     rax,    str3            ;print third string
    call _printMsg
    mov     r0,     [temp1]
        
    call _printNumber               ;Print value

    mov     r0,     [temp1]         ;move original value back to r0

    MOV     R8,     R0              ;Clear bits c0,c1,c2 and c3
    mov     R3,     0XFFFFFF74
    MOV     R9,     R3
    AND     R9,     R8
    MOV     R3,     R9

;*****************************************************************************
; This section will recreate the parity bits that was done above. This allows
; us to compare the correct value to the value that was generated with the
; error
;*****************************************************************************

    ; Generate check bit c0
    
    XOR     R8,     R8              ;Generate c0 parity bit using parity tree
    MOV     R8,     R3
    shr     R8,     2    
    MOV     R9,     R3
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;second iteration
    MOV     R8,     R2
    shr     R8,     4
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;final iteration
    MOV     R8,     R2
    shr     R8,     8
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;clear all but check bit c0
    MOV     R8,     0X1
    MOV     R9,     R2
    AND     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;combine check bit c0 with results
    MOV     R8,     R2
    MOV     R9,     R3
    OR      R8,     R9
    MOV     R3,     R8

    ; Generate check bit c1

    XOR     R8,     R8              ;Generate c1 parity bit using parity tree
    MOV     R8,     R3
    shr     R8,     1
    MOV     R9,     R3
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;second iteration
    MOV     R8,     R2
    shr     R8,     4
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;third iteration
    MOV     R8,     R2
    shr     R8,     8
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;clear all but check bit c1
    MOV     R8,     0X2
    MOV     R9,     R2
    AND     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;combine check bit c1 with results
    MOV     R8,     R2
    MOV     R9,     R3
    OR      R8,     R9
    MOV     R3,     R8

    ; Generate check bit c2

    XOR     R8,     R8              ;Generate c2 parity bit using parity tree
    MOV     R8,     R3
    shr     R8,     1
    MOV     R9,     R3
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;second iteration
    MOV     R8,     R2
    shr     R8,     2
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;third iteration
    MOV     R8,     R2
    shr     R8,     8
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;clear all but check bit c2
    MOV     R8,     0X8
    MOV     R9,     R2
    AND     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;combine check bit c2 with results
    MOV     R8,     R2
    MOV     R9,     R3
    OR      R8,     R9
    MOV     R3,     R8

    ; Generate check bit c3
    
    XOR     R8,     R8              ;Generate c3 parity bit using parity tree
    MOV     R8,     R3
    shr     R8,     1
    MOV     R9,     R3
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;second iteration
    MOV     R8,     R2
    shr     R8,     2
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
            
    XOR     R8,     R2              ;third iteration
    MOV     R8,     R2
    shr     R8,     4
    MOV     R9,     R2
    XOR     R8,     R9  
    MOV     R2,     R8
          
    XOR     R8,     R8              ;clear all but check bit c3
    MOV     R8,     0X80
    MOV     R9,     R2
    AND     R8,     R9
    MOV     R2,     R8
          
    XOR     R8,     R8              ;combine check bit c3 with result
    MOV     R8,     R2   
    MOV     R9,     R3
    OR      R8,     R9
    MOV     R3,     R8

;********************************************************************************
; We will now Compare the original value (with error) and the recalculated 
; value using exclusive-OR
;********************************************************************************

    XOR     R8,     R8
    MOV     R8,     R3
    MOV     R9,     R0
    XOR     R8,     R9
    MOV     R1,     R8

    ;Isolate the results of the EOR operatation to result in a 4-bit calculation
    ;Clearing all bits apart from c7 and shifting bit 4 positions right

    mov     R10,    0X80
    XOR     R8,     R8
    MOV     R8,     R1
    MOV     R9,     R10
    AND     R8,     R9
    MOV     R10,    R8 
    shr     R10,    4

    ;Clearing all bits apart from c3 and shifting the 3rd bit 1 position right

    mov     R5,     0X8
    XOR     R8,     R8
    MOV     R8,     R1
    MOV     R9,     R5
    AND     R8,     R9
    MOV     R5,     R8
    shr     R5,     1 

    ;Clearing all bits apart from c0 and c1  
    
    mov     R6,     0X3
    XOR     R8,     R8
    MOV     R8,     R6
    MOV     R9,     R1
    AND     R8,     R9
    MOV     R6,     R8

    ;Adding the 4 registers together 
    XOR     R8,     R8
    MOV     R8,     R10
    MOV     R9,     R5
    ADD     R8,     R9
    MOV     R1,     R8
    
    XOR     R8,     R8
    MOV     R8,     R6
    MOV     R9,     R1
    ADD     R8,     R9
    MOV     R1,     R8

    ;Subtracting 1 from R1 to determine the bit position of the error

    SUB     R1,     1

    ;Store tmp register with binary 1. Then moves the 1, 8 bit positions left.  We use '8' because R1 contains 8 bits

    mov     R7,     0X1
    shl     R7,     8

    ;Flips the bit in bit 8 of R0

    XOR     R8,     R8
    MOV     R8,     R7
    MOV     R9,     R0
    XOR     R8,     R9
    MOV     R0,     R8
  
    mov     [temp1],    r0              ;Store the value of r0 to retrive after print

    mov     rax,    str4                ;Print last string
    call _printMsg
    mov     r0,     [temp1]
     
    call _printNumber                   ;Print final value

    mov     rax,    60                  ;exit
    mov     rdi,    0
    syscall
          
          
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
    movzx rcx, byte [rbx]                ;mov a char to rcx
    cmp rcx, 0                          ;compare it to 0 "null terminated'
    je _inc                             ;jump to loop to inc
    cmp rcx, 10                         ;compare it to 10 "new line"
    je _inc                             ;jump to loop to inc
    cmp rcx, 13                         ;compare it to 13 "cariage return'
    je _inc                             ;jump to loop to inc
    inc rbx                             ;once pasted previous coditions inc once more
_top:

    cmp rcx, '0'                        ;check if the characters value is less than 0x30
    jb _done                            ;if it is we are done
    cmp rcx, '9'                        ;check if the characters value is more than 0x39
    ja _done                            ;if it is we are done
    sub rcx, '0'                        ;else subtract 0x30

   mov rdx, rcx                         ;mov rcx to rdx
    add rdx,[buffer]                    ;add contents of buffer to rax
    mov [buffer], rdx                   ;and move value back to buffer variable

    movzx rcx, byte [rbx]               ;get the next character
    inc rbx                             ;inc rbx

    mov rdx, [buffer]
    shl rdx, 1
    mov [buffer], rdx  
    jmp _top                            ;loop until comparason results in _done

_inc:
    inc rbx                             ;inc and jumps back to _set
    jmp _Set
_done:                                  ;once conversions done return to main
    mov rdx, [buffer]
    shr rdx, 1
    mov [buffer], rdx
    
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
;*_getValue:
;* This function moves user input into variable 'value'. it is
;* stored as a string which can be up to 16 characters in lenght.
;****************************************************************
_getValue:
    mov rax, 0
    mov rdi, 0
    mov rsi, value
    mov rdx, 8
    syscall
    ret
    
    
    
;****************************************************************
;_printNumber:
; this function prints the integer value that is stored in the 
; rax. Since we are printing in Binary, the integer value is
; divided by two and the remainder is stored. After completion
; of the division each remainder is printed to console
;**************************************************************** 
_printNumber:
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
              
