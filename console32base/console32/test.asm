; Example assembly language program -- adds 158 to number in memory
; Author:  R. Detmer
; Date:    6/2013

.586
.MODEL FLAT

.STACK  4096            ; reserve 4096-byte stack

.DATA                   ; reserve storage for data
number  DWORD   480
diff    DWORD   ?

.CODE                           ; start of main program code
main    PROC
        mov     eax, number     ; first number to EAX
        sub     eax, 1000       ; add 74
        mov     diff, eax       ; sum to memory

        mov   eax, 0            ; exit with return code 0
        ret
main    ENDP

END                             ; end of source code
