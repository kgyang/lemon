;
; A boot sector
;
SETUPLEN equ 4
BOOTSEG equ 0x07c0
INITSEG equ 0x9000
SETUPSEG equ 0x9020
SYSSEG equ 0x1000
ENDSEG equ 0x4000

start:
    mov ax, BOOTSEG
    mov ds, ax
    mov [BOOT_DRIVE], dl    ; BIOS stores boot drive in dl, so it's
    mov ax, INITSEG
    mov es, ax
    mov cx, 256
    sub si, si
    sub di, di
    cld
    rep movsw
    jmp INITSEG:go
go: mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFF00
    mov bx, WELCOME_MSG
    call bios_print

load_setup:
    mov dl, [BOOT_DRIVE]   ; drive
    mov dh, 0x00           ; head 0
    ;mov dx, 0x0000    ; driver 0, head 0
    mov cx, 0x0002    ; sector 2, cylinder 0
    mov bx, 0x0200    ; address = 512, in INITSEG
    mov ax, 0x0200+SETUPLEN
    int 0x13          ; read it
    jnc ok_load_setup
    mov bx, LOAD_SETUP_FAIL
    call bios_print
    jmp $
ok_load_setup:
    mov bx, LOAD_SETUP_DONE
    call bios_print
    jmp $

; bios print function
bios_print:
    pusha
    mov ah, 0x0e    ; int=10/ah=0x0e -> BIOS tele-type output
bios_print_loop:
    mov al, [bx]
    cmp al, 0
    je bios_print_done
    int 0x10        ; print the character in al
    inc bx
    jmp bios_print_loop
bios_print_done:
    popa
    ret

; data

BOOT_DRIVE: db 0

WELCOME_MSG:
    db 'Welcome to Lemon', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_SETUP_DONE:
    db 'Setup load success', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_SETUP_FAIL:
    db 'Setup load fail', 0x0d, 0x0a, 0 ; followed by \r\n

; padding and magic number
times 510-($-$$) db 0

dw 0xaa55

; fill 5 sectors to test disk read
times 256 dw 0xdada
times 256 dw 0xface
times 256 dw 0xdada
times 256 dw 0xface
