; williams_gavin_lab11.asm -- approximate cube root of a float using Newton's method
; Author:  G. Williams
; Date:    12/2025

.586
.MODEL FLAT

INCLUDE io.h            ; header file for input/output

.STACK 4096

.DATA
x               DWORD   ?
prompt1         BYTE    "Enter a number: ", 0
string          BYTE    40 DUP (?)
resultLbl       BYTE    "The cube root is ", 0
root            BYTE    11 DUP (?), 0
smallValue      DWORD   ?           ; storage for 0.001
two             DWORD   ?           ; storage for 2.0
three           DWORD   ?           ; storage for 3.0
initialRoot     DWORD   ?           ; storage for 1.0

.CODE
_MainProc PROC
        ; Initialize constants
        push    1073741824      ; 2.0 in IEEE 754 format
        pop     two
        push    1077936128      ; 3.0 in IEEE 754 format  
        pop     three
        push    1065353216      ; 1.0 in IEEE 754 format
        pop     initialRoot
        push    1008981770      ; 0.001 in IEEE 754 format
        pop     smallValue

        ; Input
        input   prompt1, string, 40     ; read ASCII characters
        atofproc string                 ; convert to floating-point, result in ST(0)
        fstp    x                       ; store in variable x

        ; Calculate cube root using the algorithm
        fld     initialRoot             ; load 1.0, ST(0) = 1.0
        
cubeRootLoop:
        fst     ST(1)                   ; copy current root to ST(1) (oldRoot)
        
        ; Calculate new root: (2.0*root + x/(root*root)) / 3.0
        fld     ST(0)                   ; ST(0) = root, ST(1) = root, ST(2) = oldRoot
        fmul    ST(0), ST(0)            ; ST(0) = root*root
        fld     x                       ; ST(0) = x, ST(1) = root*root
        fdiv    ST(0), ST(1)            ; ST(0) = x/(root*root)
        fstp    ST(1)                   ; ST(0) = x/(root*root), ST(1) = root, ST(2) = oldRoot
        
        fld     two                     ; ST(0) = 2.0, ST(1) = x/(root*root), ST(2) = root
        fmul    ST(0), ST(2)            ; ST(0) = 2.0*root
        fadd    ST(0), ST(1)            ; ST(0) = 2.0*root + x/(root*root)
        fld     three                   ; ST(0) = 3.0, ST(1) = numerator
        fdivr   ST(1), ST(0)            ; ST(1) = numerator/3.0
        fstp    ST(0)                   ; ST(0) = new root, ST(1) = oldRoot

        ; Check convergence: |root - oldRoot| < smallValue
        fld     ST(0)                   ; ST(0) = root, ST(1) = root, ST(2) = oldRoot
        fsub    ST(0), ST(2)            ; ST(0) = root - oldRoot
        fabs                            ; ST(0) = |root - oldRoot|
        fld     smallValue              ; ST(0) = smallValue, ST(1) = |difference|
        fcompp                          ; compare and pop both values
        fstsw   ax                      ; store FPU status word
        sahf                            ; transfer to CPU flags
        ja      cubeRootLoop            ; if |difference| > smallValue, continue loop
        
        fstp    ST(1)                   ; clean up stack, keep final root in ST(0)

        ; Output 
        ftoaproc root                   ; convert float in ST(0) to ASCII characters
        output  resultLbl, root         ; output label and result

        mov     eax, 0                  ; exit with return code 0
        ret
_MainProc ENDP

atofproc PROC
        ; Convert ASCII string to floating-point number
        ; Input: address of string on stack
        ; Result: floating-point value in ST(0)
        
        push    ebp
        mov     ebp, esp
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        
        mov     esi, [ebp+8]            ; get string address
        fldz                            ; initialize value to 0.0
        
        ; Check for negative sign
        mov     bl, 0                   ; flag for negative (0 = positive, 1 = negative)
        mov     al, [esi]               ; get first character
        cmp     al, '-'
        jne     convertDigits
        mov     bl, 1                   ; set negative flag
        inc     esi                     ; skip the '-' character
        
convertDigits:
        mov     al, [esi]               ; get source character
        cmp     al, '0'                 ; check if character is a digit
        jb      convertDone
        cmp     al, '9'
        ja      convertDone
        
        ; Convert ASCII digit to 2's complement digit
        sub     al, '0'
        movzx   eax, al
        mov     [digit], eax
        
        ; value := 10*value + float(digit)
        fild    dword ptr [ten]         ; load 10
        fmul                            ; 10 * value
        fild    dword ptr [digit]       ; load digit
        fadd                            ; 10*value + digit
        
        ; Point at next character of source string
        inc     esi
        jmp     convertDigits
        
convertDone:
        ; If negative flag is set, negate the result
        cmp     bl, 1
        jne     exitProc
        fchs                            ; change sign
        
exitProc:
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        pop     ebp
        ret     4

ten     DWORD   10
digit   DWORD   ?

atofproc ENDP

ftoaproc PROC
        ; Convert floating-point number in ST(0) to ASCII string in scientific notation
        ; Input: address of target string on stack
        ; Floating-point value in ST(0)
        
        push    ebp
        mov     ebp, esp
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    edi
        
        mov     edi, [ebp+8]            ; get string address
        
        ; Check for zero
        ftst
        fstsw   ax
        sahf
        jne     notZero
        
        ; Put blank for zero
        mov     byte ptr [edi], ' '
        mov     byte ptr [edi+1], 0
        jmp     ftoapDone
        
notZero:
        ; Check sign
        ftst
        fstsw   ax
        sahf
        jae     positive2
        
        ; Negative: store minus and make positive
        mov     byte ptr [edi], '-'
        fchs                            ; make positive
        jmp     signDone
        
positive2:
        ; Positive: store blank (space)
        mov     byte ptr [edi], ' '
        
signDone:
        inc     edi                     ; point at next destination byte
        
        ; Initialize exponent to 0
        mov     dword ptr [exponent], 0
        
        ; Check if value >= 10
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = value
        fcomip  st(0), st(1)            ; compare 10.0 with value, pop 10.0
        jae     checkSmall              ; if value < 10, check if < 1
        
        ; Value >= 10: divide by 10 until value < 10
divideLoop:
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = value
        fdivr                           ; ST(0) = value/10.0
        inc     dword ptr [exponent]    ; add 1 to exponent
        
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = value
        fcomip  st(0), st(1)            ; compare 10.0 with value
        jb      divideLoop              ; if value >= 10, continue
        jmp     normalize_done
        
checkSmall:
        ; Check if value < 1
        fld     dword ptr [one_float]   ; ST(0) = 1.0, ST(1) = value
        fcomip  st(0), st(1)            ; compare 1.0 with value, pop 1.0
        jbe     normalize_done          ; if value >= 1, done
        
        ; Value < 1: multiply by 10 until value >= 1
multiplyLoop:
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = value
        fmul                            ; ST(0) = value*10.0
        dec     dword ptr [exponent]    ; subtract 1 from exponent
        
        fld     dword ptr [one_float]   ; ST(0) = 1.0, ST(1) = value
        fcomip  st(0), st(1)            ; compare 1.0 with value
        ja      multiplyLoop            ; if value < 1, continue
        
normalize_done:
        ; Add 0.000005 for rounding
        fld     dword ptr [rounding]    ; ST(0) = 0.000005, ST(1) = value
        fadd                            ; ST(0) = value + 0.000005
        
        ; Check if value >= 10 after rounding
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = value
        fcomip  st(0), st(1)            ; compare 10.0 with value
        jae     extractDigits           ; if value < 10, continue
        
        ; Divide by 10 and add 1 to exponent
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = value
        fdivr                           ; ST(0) = value/10.0
        inc     dword ptr [exponent]    ; add 1 to exponent
        
extractDigits:
        ; Extract first digit
        fld     st(0)                   ; ST(0) = value, ST(1) = value
        frndint                         ; ST(0) = int(value)
        fistp   dword ptr [tempInt]     ; store integer part
        mov     eax, [tempInt]
        add     al, '0'                 ; convert to ASCII
        stosb                           ; store digit
        
        ; Store decimal point
        mov     al, '.'
        stosb
        
        ; Extract 5 fractional digits
        mov     ecx, 5
        
fractionalLoop:
        ; value := 10 * (value - float(digit))
        fild    dword ptr [tempInt]     ; ST(0) = digit, ST(1) = value
        fsubr                           ; ST(0) = value - digit
        fld     dword ptr [ten_float]   ; ST(0) = 10.0, ST(1) = remainder
        fmul                            ; ST(0) = 10 * remainder
        
        ; digit := int(value)
        fld     st(0)                   ; duplicate
        frndint                         ; ST(0) = int(value)
        fistp   dword ptr [tempInt]     ; store digit
        mov     eax, [tempInt]
        add     al, '0'                 ; convert to ASCII
        stosb                           ; store digit
        
        loop    fractionalLoop
        
        ; Store 'E'
        mov     al, 'E'
        stosb
        
        ; Handle exponent sign
        mov     eax, [exponent]
        test    eax, eax
        jns     positiveExp
        
        ; Negative exponent
        mov     byte ptr [edi], '-'
        neg     eax                     ; make positive
        jmp     expSignDone
        
positiveExp:
        mov     byte ptr [edi], '+'
        
expSignDone:
        inc     edi
        
        ; Convert exponent to two decimal digits
        mov     ecx, 100
        cmp     eax, ecx
        jb      lessThan100
        
        ; Handle exponents >= 100 (store 99)
        mov     eax, 99
        
lessThan100:
        ; Store tens digit
        mov     ecx, 10
        xor     edx, edx
        div     ecx                     ; eax = tens, edx = ones
        add     al, '0'
        stosb
        
        ; Store ones digit
        mov     al, dl
        add     al, '0'
        stosb
        
        ; Null terminate
        mov     byte ptr [edi], 0
        
        ; Clean up FPU stack
        fstp    st(0)
        
ftoapDone:
        pop     edi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        pop     ebp
        ret     4

; Constants
ten_float   DWORD   1092616192      ; 10.0 in IEEE 754
one_float   DWORD   1065353216      ; 1.0 in IEEE 754
rounding    DWORD   953267991       ; 0.000005 in IEEE 754
exponent    DWORD   ?
tempInt     DWORD   ?

ftoaproc ENDP

END                             ; end of source code