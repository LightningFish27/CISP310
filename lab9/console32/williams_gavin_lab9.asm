; Lab 9: Selection Sort Algorithm as a procedure
; With no way to see output, I can only hope that this works properly.
; Author:  G. Williams
; Date:    11/08/2025

.586
.MODEL FLAT

.STACK  4096                     ; reserve 4096-byte stack

.DATA                            ; reserve storage for data
arr       DWORD   4 DUP(?)       ; array of 4 DWORDs

.CODE                            ; start of main program code
main    PROC
        ; Initialize array with unsorted values
        mov     DWORD PTR [arr], 64
        mov     DWORD PTR [arr + 4], 25
        mov     DWORD PTR [arr + 8], 12
        mov     DWORD PTR [arr + 12], 37

        mov eax, arr

        ; Call selection sort procedure
        lea     edi, arr        ; load address of array into EDI
        mov     ecx, 4         ; number of elements in array
        call    selSort         ; call selection sort procedure

        mov   eax, 0             ; exit with return code 0
        ret
main    ENDP

; Selection Sort Procedure
; Input: EDI = pointer to array
;        ECX = number of elements in array
; Affects: EAX, EDX, EBX, ESI
selSort PROC
        push    ebx             ; save registers
        push    edi
        push    edx

        cmp     ecx, 2          ; if number of elements <= 1, no sort needed
        jl     endOuterLoop

        mov    edx, 1          ; edx = outer loop index i = 1
    outerLoop:
        cmp     edx, ecx        ; for i = 1 to numElements - 1
        jge     endOuterLoop      
        
        mov     ebx, edx                            ; ebx = smallSpot variable from pseudocode
        mov     esi, DWORD PTR [edi + edx*4]        ; esi = arr[i]. Makes sense because esi is for holding addresses

        push    edx                 ; save edx so we can re-use in inner loop

        mov     eax, edx
        inc     eax
    innerLoop:
        cmp     eax, ecx        ; for j = i + 1 to numElements - 1
        jge     endInnerLoop
        mov     edx, DWORD PTR [edi + eax*4] ; edx = arr[j]
        cmp     edx, esi
        jge     skipUpdate
        mov     esi, edx       ; smallVal = arr[j] (as registers)
        mov     ebx, eax       ; smallSpot = j (as registers)

    skipUpdate:
        inc     eax
        jmp     innerLoop

    endInnerLoop:
        pop edx				 ; restore edx for swapping

        mov     eax, DWORD PTR [edi + edx*4]    ; eax = arr[i]
        mov     DWORD PTR [edi + ebx*4], eax    ; arr[smallSpot] = arr[i]
        mov     DWORD PTR [edi + edx*4], esi    ; arr[i] = smallVal

        inc     edx
        jmp     outerLoop


    endOuterLoop:
        pop     edx             ; restore registers
        pop     edi
        pop     ebx
        ret
selSort ENDP

END                             ; end of source code
