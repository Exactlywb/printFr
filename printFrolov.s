bits 64

;--------------------------
;(c) Frolov Daniil 2021
;
;@ExactlyWb
;
;Asm for (;;)
;--------------------------

section .text

global  printFr
printFr:  

    %macro symbOut 1

        mov rax, 1
        mov rdx, %1
        mov rdi, 1
        syscall

    %endmacro

    pop r14                                 ; ret adress

    push r9
    push r8
    push rcx
    push rdx
    push rsi        
    push rdi

    mov rsi, rdi

    mov r10, rsp
    add r10, 8
    
    jmp HandleFormatStr

HandleFormatStr:

    mov al, [rsi]               

    cmp al, 0
    je Exit

    cmp al, '%'
    je HandleCommand

    cmp al, '\'
    je HandleEscs

    call PrintSymb

    jmp HandleFormatStr

;--------------------------------------------------------------------------------
;Print our symbol
;^^^^^^^^^^^^^^^^
;Entry: rsi
;^^^^^
;Destr: rax, rdx, rdi, rsi
;^^^^^
;--------------------------------------------------------------------------------
PrintSymb:

    symbOut 1

    inc rsi
    ret

HandleCommand:

    inc rsi
    call SwitchForCommandType

    jmp HandleFormatStr

SwitchForCommandType:

    xor rax, rax
    mov al, [rsi]

    xor rbx, rbx

    mov rbx, [branchTable + rax * 8]

    jmp rbx

HandleEscs:
    
    inc rsi
    call SwitchForEscType

    jmp HandleFormatStr

Print_line_break:

    mov r9, rsi

    mov rsi, 0dh
    symbOut 1 

    mov rsi, r9
    inc rsi

    jmp HandleFormatStr

Print_tab:

    mov r9, rsi

    mov rsi, 9
    symbOut 1 

    mov rsi, r9
    inc rsi

    jmp HandleFormatStr    

SwitchForEscType:

    xor rax, rax
    mov al,  [rsi]

    xor rbx, rbx

    mov rbx, [branchTableEsc + rax * 8]

    jmp rbx

CommandErr:

    mov rsi, typeErrMsg
    symbOut typeErrLength

    jmp Exit

Print_char:

    mov r9, rsi     ;save data

    mov rsi, r10
    add r10, 8

    symbOut 1
    
    mov rsi, r9     ;return data

    inc rsi
    jmp HandleFormatStr

Print_str:

    mov r9, rsi     ;save data

    mov rsi, [r10]
    add r10, 8

    PrintTillNotEnd:
        mov al, [rsi]
        cmp al, 0
        je  Print_str_back

        symbOut 1
        
        inc rsi
        jmp PrintTillNotEnd

    Print_str_back:

        mov rsi, r9

        inc rsi
        jmp HandleFormatStr

;--------------------------------------------------------------------------------hex

Print_hex:
    mov r9, rsi     
    call ConvertToHex

    mov rbx, rcx                ;this line is an asshole.
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

;--------------------------------------------------------------------------------
;Convert into hex (16)
;^^^^^^^^^^^^^^^^
;Entry:r10
;^^^^^
;
;Destr:r10, rbx, rcx, r11
;^^^^^
;--------------------------------------------------------------------------------
ConvertToHex:

    mov rax, [r10]
    add r10, 8
    xor rcx, rcx

    BuildNumHex:
        mov rbx, rax
        and rax, 15

        mov r8, buf
        add r8, rcx
        inc rcx

        mov rdx, rax
        add rdx, alph

        mov r11, [rdx]
        mov [r8], r11

        mov rax, rbx
        shr rax, 4
        
        cmp rax, 0
        jne BuildNumHex

    dec rcx

    mov rsi, buf                ;Set our rsi at the end to out inverse string
    add rsi, rcx                ;

    inc rcx

    ret  

;--------------------------------------------------------------------------------

;-------------------------------------------------------------------------------- Octal

Print_oct:
    mov r9, rsi     
    call ConvertToOct

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

;--------------------------------------------------------------------------------
;Convert into oct (8)
;^^^^^^^^^^^^^^^^
;Entry:r10
;^^^^^
;
;Destr:r10, rbx, rcx, r11
;^^^^^
;--------------------------------------------------------------------------------
ConvertToOct:

    mov rax, [r10]
    add r10, 8
    xor rcx, rcx

    BuildNumOct:
        mov rbx, rax
        and rax, 7

        mov r8, buf
        add r8, rcx
        inc rcx

        mov rdx, rax
        add rdx, alph

        mov r11, [rdx]
        mov [r8], r11

        mov rax, rbx
        shr rax, 3
        
        cmp rax, 0
        jne BuildNumOct

    dec rcx

    mov rsi, buf                ;Set our rsi at the end to out inverse string
    add rsi, rcx                ;

    inc rcx

    ret  

;--------------------------------------------------------------------------------

Print_perc:

    symbOut 1

    inc rsi
    jmp HandleFormatStr

Print_bin:
    mov r9, rsi     
    call ConvertToBinary

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

;--------------------------------------------------------------------------------
;Convert into bin (2)
;^^^^^^^^^^^^^^^^
;Entry:r10
;^^^^^
;
;Destr:r10, rbx, rcx, r11
;^^^^^
;--------------------------------------------------------------------------------
ConvertToBinary:

    mov rax, [r10]
    add r10, 8
    xor rcx, rcx

    BuildNumBin:
        mov rbx, rax
        and rax, 1

        mov r8, buf
        add r8, rcx
        inc rcx

        mov rdx, rax
        add rdx, alph

        mov r11, [rdx]
        mov [r8], r11

        mov rax, rbx
        shr rax, 1
        
        cmp rax, 0
        jne BuildNumBin

    dec rcx

    mov rsi, buf                ;Set our rsi at the end to out inverse string
    add rsi, rcx                ;

    inc rcx

    ret    

Print_int:
    mov r9, rsi                 ;save data

    call ConvertToDecimal

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

;--------------------------------------------------------------------------------
;Convert into dec (10)
;^^^^^^^^^^^^^^^^
;Entry:r10
;^^^^^
;
;Destr:r10, rbx, rcx, r11
;^^^^^
;--------------------------------------------------------------------------------
ConvertToDecimal:

    mov rax, [r10]
    add r10, 8

    mov rbx, 10

    xor rcx, rcx

    BuildNumDec:
        xor rdx, rdx
        div rbx

        mov r8, buf             ;
        add r8, rcx             ;Here we set next buf symb to write into
        inc rcx                 ;

        add rdx, alph           ;Here we got our num symbol

        mov r11, [rdx]
        mov [r8], r11
        
        cmp rax, 0
        jne BuildNumDec

    dec rcx

    mov rsi, buf            ;Set our rsi at the end to out inverse string
    add rsi, rcx            ;

    inc rcx

    ret

;--------------------------------------------------------------------------------
;Here we print our builded num from rsi
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;Entry: rsi, rbx 
;^^^^^
;Destr: rax, rdx, rdi, rsi, rbx
;^^^^^
;--------------------------------------------------------------------------------
PrintBuildedNum:
    symbOut 1

    dec rsi

    cmp rbx, 0
    dec rbx
    jne PrintBuildedNum

    ret

Exit:

    push r14

    ret

;--------------------------------------------------------------------------------
;Our data 
;^^^^^^^^
;Note : here we put our constants
;^^^^
;--------------------------------------------------------------------------------
section .data

    alph                db      '0123456789ABCDEF'

    typeErrMsg          db      0dh, 0x1B, '[1', 59, '31mUnexpected symbol', 0x1B, '[0m', 0dh   ;\e[1;31mUnexpected symbol \e[0m <- for red color string
    typeErrLength       equ     $ - typeErrMsg

    branchTable         times ('%')             dq CommandErr
                                                dq Print_perc
                        times ('a' - '%')       dq CommandErr                    
                                                dq Print_bin
                                                dq Print_char
                                                dq Print_int
                        times ('g' - 'd')       dq CommandErr 
                                                dq Print_hex
                        times ('n' - 'h')       dq CommandErr
                                                dq Print_oct
                        times ('r' - 'o')       dq CommandErr
                                                dq Print_str
                        times (255 - 's')       dq CommandErr                                        

    branchTableEsc      times (9)               dq CommandErr                                   ;9 - tab ascii number
                                                dq Print_tab
                        times ('m' - 9)         dq CommandErr
                                                dq Print_line_break
                        times (255 - 'n')       dq CommandErr                        

section .bss
    
    buf                 resb                    64
