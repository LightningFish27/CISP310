    ; load index variables into regs
    mov  eax, DWORD PTR [index1]        ; eax = idx1
    mov  ecx, DWORD PTR [index2]        ; ecx = idx2

    ; load elements using regs as scaled indexes
    mov  edx, DWORD PTR [esi + eax*DWORD_SIZE]  ; edx = arr1[idx1]
    mov  ebx, DWORD PTR [edi + ecx*DWORD_SIZE]  ; ebx = arr2[idx2]

    ; now compare registers (legal)
    cmp  edx, ebx
    jge  greater_than