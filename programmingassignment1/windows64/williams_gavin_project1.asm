; Calculate total value of coins
; Author:  G. Williams
; Date:    10/08/25

INCLUDE io.h            ; header file for input/output

.DATA               ; reserve storage for data
totalValueCents     DWORD   ?
numberOfCoins       DWORD   ?
numDollars          DWORD   ?
numCents            DWORD   ?

penniesPrompt       BYTE    "Enter number of pennies", 0
nickelsPrompt       BYTE    "Enter number of nickels", 0
dimesPrompt         BYTE    "Enter number of dimes", 0
quartersPrompt      BYTE    "Enter number of quarters", 0
fiftyCentsPrompt    BYTE    "Enter number of 50-cent pieces", 0
dollarsPrompt       BYTE    "Enter number of dollars", 0

string              BYTE    40 DUP (?)
outputHeaderLbl     BYTE    "Coin Information", 0
numLbl              BYTE    "Number of coins:", 0
dLbl                BYTE    "Dollars:", 0
cLbl                BYTE    "Cents:", 0

; String versions of numbers for output purposes
numCoinsAsString        BYTE    11 DUP(?), 0
numDollarsAsString      BYTE    11 DUP(?), 0
numCentsAsString        BYTE    11 DUP(?), 0
outputString            BYTE    50 DUP(?), 0

.CODE

MainProc  PROC
          sub     rsp, 120        ; reserve stack space for MainProc

          mov     eax, 0            ; clear eax

          ; Get user input in following section

          input   penniesPrompt, string, 40     ; read ASCII characters
          atod    string                        ; convert to integer
          mov     numberOfCoins, eax            ; store in memory, starting numberOfCoins
          mov	  ebx, 1						; store value of penny in ebx
          mul	  ebx						    ; multiply eax by value of penny (ebx), then store in eax
          add	  totalValueCents, eax          ; add value in pennies to totalValueCents

          input   nickelsPrompt, string, 40     ; read ASCII characters
          atod    string                        ; convert to integer
          add     numberOfCoins, eax            ; add to numberOfCoins
          mov	  ebx, 5						; store value of nickel in ebx
          mul	  ebx						    ; multiply eax by value of nickel (ebx), then store in eax
          add	  totalValueCents, eax          ; add value in nickels to totalValueCents

          input   dimesPrompt, string, 40       ; read ASCII characters
          atod    string                        ; convert to integer
          add     numberOfCoins, eax            ; add to numberOfCoins
          mov	  ebx, 10						; store value of dime in ebx
          mul	  ebx						    ; multiply eax by value of dime (ebx), then store in eax
          add	  totalValueCents, eax          ; add value in dimes to totalValueCents

          input   quartersPrompt, string, 40    ; read ASCII characters
          atod    string                        ; convert to integer
          add     numberOfCoins, eax            ; add to numberOfCoins
          mov	  ebx, 25						; store value of quarter in ebx
          mul	  ebx						    ; multiply eax by value of quarter (ebx), then store in eax
          add	  totalValueCents, eax          ; add value in quarters to totalValueCents

          input   fiftyCentsPrompt, string, 40  ; read ASCII characters
          atod    string                        ; convert to integer
          add     numberOfCoins, eax            ; add to numberOfCoins
          mov	  ebx, 50						; store value of fifty cent piece in ebx
          mul	  ebx						    ; multiply eax by value of fifty cent piece (ebx), then store in eax
          add	  totalValueCents, eax          ; add value in fifty cent pieces to totalValueCents

          input   dollarsPrompt, string, 40     ; read ASCII characters
          atod    string                        ; convert to integer
          add     numberOfCoins, eax            ; add to numberOfCoins
          mov	  ebx, 100						; store value of dollar in ebx
          mul	  ebx						    ; multiply eax by value of dollar (ebx), then store in eax
          add	  totalValueCents, eax          ; add value in dollars to totalValueCents


          ; Output results in following section

        
          mov     eax, numberOfCoins            ; store numberOfCoins in eax
          dtoa    numCoinsAsString, eax         ; convert to ASCII characters

          mov     ecx, 100                      ; prepare to divide by 100 to finds cents and dollars
          xor     edx, edx                      ; clear edx prior to dividing
          div     ecx                           ; divide eax by 100, quotient in eax, remainder in edx
          mov     numDollars, eax               ; store number of dollars
          mov     numCents, edx                 ; store number of cents

          mov     eax, numCents                 ; store numCents in eax
          dtoa    numCentsAsString, eax         ; convert to ASCII characters
          mov	  eax, numDollars               ; store numDollars in eax
          dtoa    numDollarsAsString, eax       ; convert to ASCII characters

          ; At this point, all calculations are done, and all values have been converted to strings for output
          ; Output all results below


          ; Now outputString is ready for output
          output numLbl, numCoinsAsString       ; Output window for number of coins
          output dLbl, numDollarsAsString       ; Output window for number of dollars
          output cLbl, numCentsAsString         ; Output window for number of cents

          add     rsp, 120        ; restore stack
          mov     rax, 0          ; value to return (0)
          ret
MainProc ENDP
END



