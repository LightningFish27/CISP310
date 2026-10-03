; Example assembly language program -- adds 158 to number in memory
; Author:  R. Detmer
; Date:    6/2013

.586
.MODEL FLAT

.STACK  4096            ; reserve 4096-byte stack

; Constants
DWORD_SIZE    EQU 4             ; size of a DWORD in bytes
SENTINEL      EQU 0FFFFFFFFh    ; a value larger than any valid array element
INDEX_INIT    EQU 0             ; 0-indexed arrays

.DATA                   ; reserve storage for data

; Allocate space for 6 DWORDs but initialize only 5 values.
arr1 DWORD 1,3,5,7,9,?      ; Leave last element uninitialized
count1 DWORD 5              ; Size  of first array not counting uninitialized element
arr2 DWORD 2,4,6,8,10,?     ; Same for second array
count2 DWORD 5           
arr3 DWORD 10 DUP (?)        ; Output array for merged result. Length is sum of arr1_size and arr2_size

; Indexes (initialize to INDEX_INIT)
index1 DWORD INDEX_INIT
index2 DWORD INDEX_INIT
index3 DWORD INDEX_INIT

.CODE                           ; start of main program code
main    PROC
        ; Push parameters for arrmerge in reverse order
        push  OFFSET arr3     ; push pointer to output array
        push  DWORD PTR [count2] ; push size of second array
        push  OFFSET arr2     ; push pointer to second array
        push  DWORD PTR [count1] ; push size of first array
        push  OFFSET arr1     ; push pointer to first array

        call  arrmerge        ; call the merge function
        add   esp, 20         ; clean up the stack (5 parameters * 4 bytes each)
        ; Note that ebx is the output array pointer.


        mov   eax, 0            ; exit with return code 0
        ret
main    ENDP

; Merges two sorted arrays into a single sorted array
; Takes in 5 parameters:
; 1. pointer to first array
; 2. size of first array
; 3. pointer to second array
; 4. size of second array
; 5. pointer to output array
arrmerge PROC
        push ebp
        mov  ebp, esp
        ; Initialize pointers and counters
        mov  esi, [ebp + 8]      ; pointer to first array
        mov  ecx, [ebp + 12]     ; size of first array
        mov  edi, [ebp + 16]     ; pointer to second array
        mov  edx, [ebp + 20]     ; size of second array
        mov  ebx, [ebp + 24]     ; pointer to output array

        ; Set sentinels after each array: arr[count] = SENTINEL
        mov eax, ecx             ; copy count1 to eax
        mov DWORD PTR [esi + eax*DWORD_SIZE], SENTINEL ; set sentinel in arr1[count]
        mov eax, edx             ; copy count2 to eax
        mov DWORD PTR [edi + eax*DWORD_SIZE], SENTINEL ; set sentinel in arr2[count]

merge_loop:
            ; Compare total length to current output index
            mov eax, ecx        ; Set eax to count1(ecx)
            add eax, edx        ; add count2(edx)
            cmp eax, index3     ; compare idx3 to count1+count2
            jle end_merge_loop

            ; load index variables into registers
            mov  eax, DWORD PTR [index1]                ; eax = idx1
            mov  ecx, DWORD PTR [index2]                ; ecx = idx2
            ; load elements using regs as scaled indexes
            mov  eax, DWORD PTR [esi + eax*DWORD_SIZE]  ; edx = arr1[idx1]
            mov  ecx, DWORD PTR [edi + ecx*DWORD_SIZE]  ; ecx = arr2[idx2]
            ; now compare registers
            cmp  eax, ecx
            mov  ecx, [ebp + 12]     ; reload size of first array since it was just overwritten
            jge greater_than

            ; Copy from first array
            mov eax, DWORD PTR [index1]
            mov ecx, DWORD PTR [index3]
            mov eax, DWORD PTR [esi + eax*DWORD_SIZE]   ; load arr1[idx1] into eax
            mov DWORD PTR [ebx + ecx*DWORD_SIZE], eax   ; store into arr3[idx3]
            mov  ecx, [ebp + 12]     ; reload size of first array since it was just overwritten
            inc index1
            inc index3
            jmp merge_loop

greater_than:
            ; Copy from second array (fixed to use index2)
            mov eax, DWORD PTR [index2]
            mov ecx, DWORD PTR [index3]
            mov eax, DWORD PTR [edi + eax*DWORD_SIZE]
            mov DWORD PTR [ebx + ecx*DWORD_SIZE], eax
            inc index2
            inc index3
            jmp merge_loop

end_merge_loop:

        mov esp, ebp
        pop ebp
        ret
arrmerge ENDP

END                             ; end of source code
