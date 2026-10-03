; Example assembly language program -- adds two numbers
; Author:  R. Detmer
; Date:    1/2008

INCLUDE io.h                        ; header file for input/output

.DATA                               ; reserve storage for data
; Define variables
number1   DWORD   ?
number2   DWORD   ?

; These three are for the algorithm. I could have used number1 and number2 directly, but this is cleaner.
gcd	      DWORD   ?
remainder DWORD   ?
dividend  DWORD   ?

; input/output prompts and storage
prompt1   BYTE    "Enter first number", 0
prompt2   BYTE    "Enter second number", 0
string    BYTE    40 DUP (?)
resultLbl BYTE    "The GCD is", 0
gcdOut    BYTE    11 DUP(?), 0

.CODE
MainProc  PROC
          sub     rsp, 120              ; reserve stack space for MainProc


          input   prompt1, string, 40   ; read ASCII characters
          atod    string                ; convert to integer
          mov     number1, eax          ; store in memory

          input   prompt2, string, 40   ; repeat for second number
          atod    string
          mov     number2, eax

          mov     eax, number1          ; load first number
          mov     ebx, number2          ; load second number

gcd_loop:
          cmp     ebx, 0                ; check if number2 is 0
          je      gcd_done              ; if so, we are done

          mov     edx, 0                ; clear edx before div
          div     ebx                   ; eax = number1 / number2, edx = remainder
          mov     remainder, edx        ; store remainder

          mov     eax, ebx              ; move number2 to number1
          mov     ebx, remainder        ; move remainder to number2
          jmp     gcd_loop              ; repeat loop

gcd_done:
          mov     gcd, eax              ; store GCD
                
          mov     eax, gcd              ; store GCD in eax
          dtoa    gcdOut, eax           ; convert to ASCII characters
          output  resultLbl, gcdOut     ; output label and gcd


          add     rsp, 120              ; restore stack
          mov     rax, 0                ; value to return (0)
          ret
MainProc ENDP
END

