; williams_gavin_lab5.asm -- add three numbers inputted by the user
; Author:  Gavin Williams
; Date:    09/30/2025

; BASED ON CODE BY:
    ; Example assembly language program -- adds two numbers
    ; Author:  R. Detmer
    ; Date:    1/2008

.586
.MODEL FLAT

INCLUDE io.h            ; header file for input/output

.STACK 4096

.DATA
number1 DWORD   ?
number2 DWORD   ?
number3 DWORD   ?                           ; it would work to store this in EAX, then add the others to that, but this is clearer

prompt1 BYTE    "Enter first number", 0     ; use the io.h header macros to get user input from windows
prompt2 BYTE    "Enter second number", 0
prompt3 BYTE    "Enter third number", 0

string  BYTE    40 DUP (?)
resultLbl BYTE  "The sum is", 0
sum     BYTE    11 DUP (?), 0

.CODE
_MainProc PROC
        ; NOTE: EAX, ECX, EDX are used by atod and dtoa
        ; The process of receiving input, converting it, and storing it is the same for each number
        ; NOTE ALSO: There is NO input validation performed. I was able to enter "hello", 
        ; and the program executed as though it were a number.

        input   prompt1, string, 40     ; read ASCII characters
        atod    string                  ; convert to integer (stores in EAX)
        mov     number1, eax            ; store in memory

        input   prompt2, string, 40     ; repeat for second number
        atod    string                  ; convert to integer (stores in EAX))
        mov     number2, eax            ; store in memory
        
        input   prompt3, string, 40     ; repeat for second number
        atod    string                  ; convert to integer (stores in EAX))
        mov     number3, eax            ; store in memory

        mov     eax, number1            ; first number to EAX
        add     eax, number2            ; add second number
        add     eax, number3            ; add third number  
        dtoa    sum, eax                ; convert to ASCII characters
        output  resultLbl, sum          ; output label and sum

        mov     eax, 0  ; exit with return code 0
        ret
_MainProc ENDP
END                             ; end of source code

