; Lab 8 -- GCD as procedure
; Author:   G. Williams
; Date:     10/2025
; Notes:    I find it very interesting that assembly passes arguments in the way that it does. It's not incredibly hard to follow, but it's definitely different from higher-level languages.

.586
.MODEL FLAT

INCLUDE io.h            ; header file for input/output

.STACK 4096

.DATA
; Define variables. These two are optional, as we could use registers only.
number1   DWORD   ?           ; first input number
number2   DWORD   ?           ; second input number

; input/output prompts and storage
prompt1   BYTE    "Enter first number", 0
prompt2   BYTE    "Enter second number", 0
string    BYTE    40 DUP (?)
resultLbl BYTE    "The GCD is", 0
gcdOut    BYTE    11 DUP(?), 0

.CODE
_MainProc PROC
        input   prompt1, string, 40      ; read ASCII characters
        atod    string                   ; convert to integer
        mov     number1, eax                 ; load into register for procedure call

        input   prompt2, string, 40      ; repeat for second number
        atod    string                   ; convert to integer
        mov     number2, eax                 ; load into register for procedure call

        ; When pushing arguments for a call, push right-to-left. They will be popped left-to-right in the called procedure.
        push    DWORD PTR number2        ; push second number onto stack
        push    DWORD PTR number1        ; push first number onto stack
        call    GCDProc                  ; call GCD procedure
        add     esp, 8                   ; clean up stack (2 DWORDs = 8 bytes)
        
        dtoa    gcdOut, eax              ; convert result to ASCII
        output  resultLbl, gcdOut        ; output result

        mov     eax, 0  ; exit with return code 0
        ret
_MainProc ENDP

; GCD Procedure: computes GCD of two numbers
GCDProc PROC
          ; Note: we first save base pointer on the stack, then set base pointer to current stack pointer. This means there is a DWORD argument at [ebp+4], and our first argument is at [ebp+8], second at [ebp+12], etc.
          push   ebp                         ; standard prologue
          mov    ebp, esp                    ; set base pointer
          push   ebx                         ; save registers that will be used

          ; Input: number1 in eax, number2 in ebx
          mov     eax, DWORD PTR [ebp+8]              ; load first number into eax
          mov     ebx, DWORD PTR [ebp+12]             ; load second number into ebx

          ; This loop is essentially the same as it was for last week, though I am using the registers directly rather than variables in memory.
    gcd_loop:
          cmp     ebx, 0                ; check if number2 is 0
          je      gcd_done              ; if so, we are done

          xor     edx, edx              ; clear edx before div. Note, I saw online that xor is faster than mov for this.
          div     ebx                   ; eax = number1 / number2, edx = remainder
          mov     edx, edx              ; store remainder
          mov     eax, ebx              ; eax = old divisor (number2)
          mov     ebx, edx              ; ebx = remainder
          jmp     gcd_loop              ; repeat loop
gcd_done:
          ; Note there is no need to save eax, as it is the return value register
          pop     ebx                   ; restore registers
          mov     esp, ebp              ; standard epilogue
          pop     ebp
          ret
GCDProc ENDP

END                             ; end of source code

