; Compute x - 2y + 4z in EAX based on user input using windows64 framework
; Author:  G. Williams
; Date:    10/08/25

INCLUDE io.h            ; header file for input/output

.DATA               ; reserve storage for data
x       DWORD       ?
y       DWORD       ?
z       DWORD       ?
prompt1   BYTE    "Enter x", 0
prompt2   BYTE    "Enter y", 0
prompt3   BYTE    "Enter z", 0

string    BYTE    40 DUP (?)
resultLbl BYTE    "The value of the function x - 2y + 4z is:", 0
sum       BYTE    11 DUP(?), 0

.CODE
MainProc  PROC
          sub     rsp, 120              ; reserve stack space for MainProc

          mov eax, 0                    ; clear EAX

          input   prompt1, string, 40   ; read ASCII characters
          atod    string                ; convert to integer
          mov     x, eax                ; store in memory

          input   prompt2, string, 40   ; read ASCII characters
          atod    string                ; convert to integer
          mov     y, eax                ; store in memory

          input   prompt3, string, 40   ; read ASCII characters
          atod    string                ; convert to integer
          mov     z, eax                ; store in memory
        
          mov     eax, x                ; Put x in EAX
          mov     ebx, y                ; Put y in EBX
          shl     ebx, 1                ; Multiply y by 2
          sub     eax, ebx              ; Subtract 2y from x
          mov     ebx, z                ; Put z in EBX
          shl     ebx, 2                ; Multiply z by 4
          add     eax, ebx              ; Add 4z to result

          dtoa    sum, eax              ; convert result to ASCII

          output  resultLbl, sum        ; output label and sum


          add     rsp, 120              ; restore stack
          mov     rax, 0                ; value to return (0)
          ret
MainProc ENDP
END

