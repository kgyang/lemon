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
    mov dx, 0x0080    ; DH = 0 (head), drive = 80h (0th hard disk)
    mov cx, 0x0002    ; sector 2, cylinder 0
    mov bx, 0x0200    ; address = 512, in INITSEG
    mov al, SETUPLEN  ; setup sectors
    mov ah, 0x02
    int 0x13          ; read it
    jnc ok_load_setup
    mov bx, LOAD_SETUP_FAIL
    call bios_print
    jmp $
ok_load_setup:
    mov bx, LOAD_SETUP_DONE
    call bios_print

load_sys:
DAPACK:
    db 0x10    ;packet size
    db 0
    dw 52    ;number of blocks
    dw 0       ;destination offset
    dw SYSSEG  ;destination segment
    dd SETUPLEN   ;start lba block
    dd 0

    mov si, DAPACK
    mov ah, 0x42
    mov dl, 0x80 ; hard disck, drive 0
    int 0x13

    jnc ok_load_sys

    mov bx, LOAD_SYS_FAIL
    call bios_print
    jmp $
ok_load_sys:
    mov bx, LOAD_SYS_DONE
    call bios_print

    mov bx, SYSSEG
    mov ds, bx
    mov bx, 0
    call bios_print
    mov bx, INITSEG
    mov ds, bx

    jmp $
    ;jmp SETUPSEG:0

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

WELCOME_MSG:
    db 'Welcome to Lemon', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_SETUP_DONE:
    db 'Setup load success', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_SETUP_FAIL:
    db 'Setup load fail', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_SYS_DONE:
    db 'System load success', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_SYS_FAIL:
    db 'System load fail', 0x0d, 0x0a, 0 ; followed by \r\n

; padding
times 510-($-$$) db 0

;magic number
dw 0xaa55

; fill 4 sectors to test setup load
times 512 db 'abc',0
; fill 64 sectors to test system load
times 512*16 db 'def',0
