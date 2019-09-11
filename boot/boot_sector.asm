;
; A boot sector
;

org 0x7c00 ;The code is loaded to 0x7c00

mov bx, WELCOME_MSG
call bios_print

jmp $

bios_print:
    pusha
    mov ah, 0x0e
bios_print_loop:
    mov al, [bx]
    cmp al, 0
    je bios_print_done
    int 0x10
    inc bx
    jmp bios_print_loop
bios_print_done:
    popa
    ret

WELCOME_MSG:
    db 'Welcome to Lemon', 0

times 510-($-$$) db 0

dw 0xaa55
