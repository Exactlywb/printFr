bits 64

;--------------------------
;(c) Frolov Daniil 2021
;
;@ExactlyWb
;
;Asm for (;;)
;--------------------------

section .text
global  _start
_start:

    mov rsi, formatStr                     ; our string-format
    
    push 3802
    push 3802
    push 3802
    push 3802
    push outputStr
    push 'I'
    
    mov r10, rsp
    
    jmp HandleFormatStr

HandleFormatStr:

    mov al, [rsi]               ;мб есть смысл в функцию MyLoad, но мб это медленно
    call SwitchForSymbType

    jmp HandleFormatStr


SwitchForSymbType:
    cmp al, 0
    je Exit

    cmp al, '%'
    je HandleCommand

    call PrintSymb

    ret

PrintSymb:

    mov rax, 1
    mov rdx, 1
    mov rdi, 1
    syscall
    inc rsi
    ret

HandleCommand:
    
    inc si
    call SwitchForCommandType

    jmp HandleFormatStr

SwitchForCommandType:
    mov al, [rsi]

    cmp al, 'c'
    je Print_char

    cmp al, 's'
    je Print_str

    cmp al, 'd'
    je Print_int

    cmp al, 'b'
    je Print_bin

    cmp al, 'o'
    je Print_oct

    cmp al, 'x'
    je Print_hex

    jmp CommandErr

CommandErr:

    mov rsi, typeErrMsg

    mov rax, 1
    mov rdi, 1
    mov rdx, typeErrLength

    syscall

    jmp Exit

Print_char:

    mov r9, rsi     ;save data

    mov rsi, r10
    add r10, 8

    mov rax, 1      ;<---O
    mov rdi, 1      ;    U   
    mov rdx, 1      ;    T
    syscall         ;<---
    
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

        mov rax, 1
        mov rdi, 1
        mov rdx, 1
        syscall
        
        inc rsi
        jmp PrintTillNotEnd

    ;mov rax, 1
    ;mov rdi, 1
    ;mov rdx, 4      ;length
    ;syscall

    Print_str_back:

        mov rsi, r9

        inc rsi
        jmp HandleFormatStr

;---------------------HEX

Print_hex:
    mov r9, rsi     
    call ConvertToHex

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

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

    mov rsi, buf        ;Set our rsi at the end to out inverse string
    add rsi, rcx        ;

    inc rcx

    ret  

;------------------------------------------

;---------------------Octal

Print_oct:
    mov r9, rsi     
    call ConvertToOct

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

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

    mov rsi, buf        ;Set our rsi at the end to out inverse string
    add rsi, rcx        ;

    inc rcx

    ret  

;------------------------------------------

Print_bin:
    mov r9, rsi     
    call ConvertToBinary

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

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

    mov rsi, buf        ;Set our rsi at the end to out inverse string
    add rsi, rcx        ;

    inc rcx

    ret    

Print_int:
    mov r9, rsi     ;save data

    call ConvertToDecimal

    mov rbx, rcx
    call PrintBuildedNum

    mov rsi, r9

    inc rsi
    jmp HandleFormatStr

ConvertToDecimal:

    mov rax, [r10]
    add r10, 8

    mov rbx, 10

    xor rcx, rcx

    BuildNumDec:
        xor rdx, rdx
        div rbx

        mov r8, buf         ;
        add r8, rcx         ;Here we set next buf symb to write into
        inc rcx             ;

        add rdx, alph       ;Here we got our num symbol

        mov r11, [rdx]
        mov [r8], r11
        
        cmp rax, 0
        jne BuildNumDec

    dec rcx

    mov rsi, buf        ;Set our rsi at the end to out inverse string
    add rsi, rcx        ;

    inc rcx

    ret

PrintBuildedNum:
    mov rax, 1
    mov rdx, 1
    mov rdi, 1
    syscall

    dec rsi

    cmp rbx, 0
    dec rbx
    jne PrintBuildedNum

    ret

Exit:
    mov rax, 60
    xor rdi, rdi
    syscall
    ret    

section .data

formatStr           db      '%c %s %d is %b, %o, %x', 0    
outputStr           db      'love the fact that', 0

alph                db      '0123456789ABCDEF'
buf                 resb    64

typeErrMsg          db      0dh, 'Unexpected symbol after %'
typeErrLength       equ     $ - typeErrMsg
