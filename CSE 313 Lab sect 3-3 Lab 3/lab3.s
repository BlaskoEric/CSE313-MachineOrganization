
section .data
    msg1: db " to Hex = ",0                                     ;expected values
    SA: dd 500.312                                              ;43FA27F0
    DA: dq 500.312                                              ;407F44FDF3B645A2
    SPI: dd 3.1415927                                           ;40490FDB
    DPI: dq 3.141592653589793                                   ;400921FB54442D18
    SB: dd 1.456e6                                              ;49B1BC00
    DP: dq 1.456e6                                              ;4136378000000000
    SC: dd 0                                                    ;4E2DAD52
    hex: db "0123456789ABCFEF",0                                ;used as a reference to convert to hex
    bin: db "01",0                                              ;used as a reference to convert to binary
    strSA: db "500.312 single precision to Hex = ",0            ;Strings to dispaly to console
    strDA: db "500.312 double precision to Hex = ",0
    strSPI: db "pi single precision to Hex = ",0
    strDPI: db "pi double precision to Hex = ",0
    strSB: db "1.456e6 single precision to Hex = ",0
    strBin1: db "1.456e6 single precision in Binary = ",0
    str2sBin1: db "1.456e6 single precision in 2's complement = ",0
    streq1: db " = -3.073597e6 ",0
    streq2: db " = -3.07359733e6 ",0
    strDP: db "1.456e6 double precision to Hex = ",0
    strBin2: db "1.456e6 double precision in Binary = ",0
    str2sBin2: db "1.456e6 double precision in 2's complement = ",0
    strSC: db "500.312 * 1.456e6 = 7.284543E8 In Hex = ",0
    newLine: db "",10,0                                         ;moves to next line
section .bss
    outstr1: resb 16                 ;these hold the Hex values for each variable
    outstr2: resb 16
    outstr3: resb 16
    outstr4: resb 16
    outstr5: resb 16
    outstr6: resb 16
    bin1:    resb 32                ;these hold the Binary values for the SB and DP variables
    bin2:    resb 64

section .text
    global _start

_start:
    
    mov rax, strSA                  ;print the first string
    call _printMsg

    mov rax, [SA]                   ;convert SA to hex
    mov rdi, outstr1    
    call _DW2Hex

    mov rsi, outstr1                ;print hex value of SA
    call _printSingle

    call _newLine                   ;start new line
    
    mov rax, strDA                  ;print the second string
    call _printMsg

    mov rax, [DA]                   ;convert DA to hex
    mov rdi, outstr2    
    call _QW2Hex

    mov rsi, outstr2                ;print hex value of DA
    call _printDouble

    call _newLine                   ;start new line
    call _newLine
    
    mov rax, strSPI                 ;print the third string
    call _printMsg
    
    mov rax, [SPI]                  ;convert SPI to hex
    mov rdi, outstr3    
    call _DW2Hex

    mov rsi, outstr3                ;print hex value of SPI
    call _printSingle

    call _newLine                   ;start new line
    
    mov rax, strDPI                 ;print the fourth string
    call _printMsg

    mov rax, [DPI]                  ;convert DPI to hex
    mov rdi, outstr4        
    call _QW2Hex

    mov rsi, outstr4                ;print hex value of DPI
    call _printDouble

    call _newLine                   ;start new line
    call _newLine
    
    mov rax, strSB                  ;print the fifth string
    call _printMsg
    
    mov rax, [SB]                   ;convert SB to hex
    mov rdi, outstr5    
    call _DW2Hex

    mov rsi, outstr5                ;print hex value of SB
    call _printSingle

    call _newLine                   ;start new line
                                    
    mov rax, strDP                  ;print the sixth string
    call _printMsg
    
    mov rax, [DP]                   ;convert DP to hex
    mov rdi, outstr6        
    call _QW2Hex

    mov rsi, outstr6                ;print hex value of DP
    call _printDouble    

    call _newLine                   ;start new line
    call _newLine

    mov rax, strSC                  ;print the seventh string
    call _printMsg

    finit                           ;ready float register
    fld dword[SA]                   ;push SA to float register
    fld dword[SB]                   ;push SB to float register
    fmulp                           ;add the top two values and push results
    fstp dword[SC]                  ;move results to SC

    mov rax, [SC]                   ;convert SC to hex
    mov rdi, outstr1
    call _DW2Hex

    mov rsi, outstr1                ;print hex value of SC
    call _printSingle

    call _newLine                   ;start new line
    call _newLine

    mov rax, strBin1                ;print string for binary     
    call _printMsg
    
    mov eax, [SB]                   ;convert SB to binary
    mov edi, bin1
    call _DWORD2Bin

    mov rsi, bin1                   ;print binary number
    call _printSingleBin

    call _newLine                   ;new line

    mov rax, str2sBin1              ;print string for 2's complement
    call _printMsg

    mov eax, [SB]                   ;move value of SB to eax
    NOT eax                         ;get the ones complement
    add eax, 00000001b              ;add 1 binary digit to get 2's complement
    mov [SB], eax                   ;save new value

    mov eax, [SB]                   ;get binary representation
    mov edi, bin1
    call _DWORD2Bin
    
    mov rsi, bin1                   ;print 2's complement
    call _printSingleBin

    call _newLine                   ;start new line
    
    mov rsi, bin1                   ;print string for bin1
    call _printSingleBin
    
    mov rax, streq1                 ;print second string for bin1
    call _printMsg
    
    call _newLine                   ;newline
    call _newLine

    mov rax, strBin2                ;print string for bin2
    call _printMsg

    mov rax, [DP]                   ;convert SB to binary
    mov rdi, bin2
    call _DQWORD2Bin

    mov rsi, bin2                   ;print binary number
    call _printDoubleBin

    call _newLine                   ;new line

    mov rax, str2sBin2              ;print string for 2's complement
    call _printMsg

    mov rax, [DP]                   ;move DP to rax
    NOT rax                         ;get 1's complement
    add rax, 00000001b              ;add 1 binary to get 2's complement
    mov [DP], rax                   ;save new value

    mov rax, [DP]                   ;get 2's complement 
    mov rdi, bin2
    call _DQWORD2Bin

    mov rsi, bin2                   ;print 2's complement
    call _printDoubleBin
    
    call _newLine                   ;start a new line
    
    mov rsi, bin2                   ;print 2's complement again
    call _printDoubleBin
    
    mov rax, streq2                 ;print bin2 eauation string
    call _printMsg
    
    call _newLine                   ;get new line
        
    mov eax, 60                     ;exit
    mov edi, 0   
    syscall

;***************************************************************
;* _newLine:
;* this function simply sets up the registers to print a string
;* which only contains a newline character
;***************************************************************
_newLine:
    mov rax, 1
    mov rdi, 1
    mov rsi, newLine         ;moves empty string with 10 after 
    mov rdx, 1  
    syscall             ;call print from syscall

    ret    

;***************************************************************
;*_printSingle:
;* this function prints the contents of the single precision
;* float in hex form or binary form. The variable should be moved 
;* to the esi prior to calling this function
;**************************************************************
_printSingle:
    mov eax, 1
    mov edi, 1
    mov edx, 8
    syscall

    ret

_printSingleBin:
    mov eax, 1
    mov edi, 1
    mov edx, 32
    syscall
    ret
;**************************************************************
;* _printDouble:
;* this function prints the contents of the double precision
;* float in hex form or binary form. The variable should be 
;* moved to the esi prior to calling this function
;*************************************************************

_printDouble:
    mov eax, 1
    mov edi, 1
    mov edx, 16
    syscall

    ret
    
_printDoubleBin:
    mov eax, 1
    mov edi, 1
    mov edx, 64
    syscall

    ret
;**************************************************************
;*_printMsg:
;* This function prints the entire contents of a string. The
;* first part loops through to count the length of the string.
;* After completing the count, a syscall prints the message
;**************************************************************
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

;**************************************************************
;*_DW2Hex:
;* this function converts a floating point value of single
;* precision and converts it to hex. This is done by shifting
;* four bits at a time into the esi. based on the four bits
;* the value is changed to hex and added to the edi
;*************************************************************
_DW2Hex:
    xor esi, esi
    mov ecx, 8
_L1:
    xor sil, sil
    shld esi, eax, 4
    shl eax, 4
    mov dl, [hex + esi]
    mov [edi], dl
    add edi, 1
    loop _L1

    ret

;***************************************************************
;* _QW2Hex:
;* this function converts a floating point value of single
;* precision and converts it to hex. This is done by shifting
;* four bits at a time into the esi. Based on the four bits
;* the value is changed to hex and added to the edi
;**************************************************************
_QW2Hex:
    xor rsi, rsi
    mov rcx, 16
_L2:
    xor sil, sil
    shld rsi, rax, 4
    shl rax, 4
    mov dl, [hex + rsi]
    mov [rdi], dl
    add rdi, 1
    loop _L2

    ret

;**************************************************************
;* _DWORD2Bin:
;* This function takes a variable in single precision floating
;* point and provides a printable string of its binary form
;*************************************************************
_DWORD2Bin:
    xor esi, esi
    mov ecx, 32
_loop1:
    xor sil, sil
    shld esi, eax, 1
    shl eax, 1
    
    mov dl, [bin+esi]
    mov [edi], dl
    add edi, 1
    loop _loop1

    ret

;*************************************************************
;* _DQWORD2Bin
;* This function takes a variable in double precision floating
;* point and provides a printable string of its binary form
;*************************************************************
_DQWORD2Bin:
    xor rsi, rsi
    mov rcx, 64
_loop2:
    xor sil, sil
    shld rsi, rax, 1
    shl rax, 1

    mov dl, [bin+esi]
    mov [edi],dl
    add edi, 1
    loop _loop2

    ret

