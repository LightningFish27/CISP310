; Programming Assignment 3: Count Differences; counts the differences between two strings
; Author:  G. Williams
; Date:    11-29-2025

.586
.MODEL FLAT

INCLUDE io.h            ; header file for input/output

.STACK 4096

.DATA
; Prompts and buffers
prompt1 BYTE    "Enter first string", 0
prompt2 BYTE    "Enter second string", 0

string1  BYTE    40 DUP (?)
string2  BYTE    40 DUP (?)

resultLbl BYTE  "Number of Differences", 0
diff     BYTE    11 DUP (?), 0

.CODE
_MainProc PROC
        input   prompt1, string1, 40    ; read ASCII characters
        lea     eax, string1            ; get address
        push    eax                     ; push for function call (first number)

        input   prompt2, string2, 40    ; repeat for second number
        lea     eax, string2           
        push    eax
        
        call   countDifferences         ; call function to count differences
        add     esp, 8                  ; clean up stack (2 parameters)


        dtoa    diff, eax               ; convert to ASCII characters
        output  resultLbl, diff         ; output label and sum

        mov     eax, 0  ; exit with return code 0
        ret
_MainProc ENDP

countDifferences PROC
        ; Parameters: 
        ;   string1 - pointer to first string
        ;   string2 - pointer to second string
        ; Returns:
        ;   eax - number of differing characters
        push    ebp
        mov     ebp, esp
        mov     esi, [ebp + 8]   ; pointer to string1
        mov     edi, [ebp + 12]  ; pointer to string2
        xor     ecx, ecx         ; difference count = 0

        compare_loop:
        mov     al, [esi]      ; load byte from string1
        mov     bl, [edi]      ; load byte from string2

        cmp     al, 0          ; check for null terminator
        je      done_compare    ; if end of string1, done
        cmp     bl, 0          ; check for null terminator
        je      done_compare    ; if end of string2, done

        cmp     al, bl         ; compare characters
        jne     inc_diff        ; if different, increment count
        jmp     next_char

        inc_diff:
        inc     ecx             ; increment difference count

        next_char:
        inc     esi             ; move to next character in string1
        inc     edi             ; move to next character in string2
        jmp     compare_loop

        done_compare:
        mov     eax, ecx        ; move difference count to eax
        pop     ebp
        ret

countDifferences ENDP

END                             ; end of source code

