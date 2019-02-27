       segment .data
msg:   db      'Hello World!',0x0a     
len:   equ     $-msg               

       segment .text
       global  main                   
       extern  write, exit
main:
       push    rbp
       mov     rbp, rsp  
                                                                                                      
       mov     edx, len               
       lea     rsi, [msg]             
       mov     edi, 1                  
       call    write
         
       xor     edi, edi               
       call    exit
