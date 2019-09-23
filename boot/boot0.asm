;
; A boot sector
;
BOOT0START equ 0x7c00
BOOT1START equ 0x1000
BOOT1LEN equ 0x2200
STACKTOP equ 0x7000

org BOOT0START
start:
;disable interrupt
    cli
;canonicalize %CS:%IP
    jmp 0:go
go:
;loading segment registers
    mov ax, cs
    mov ds, ax
    mov es, ax
;set the stack pointer
    mov sp, STACKTOP
;enable interrupts
    sti
;reset hard disk controller
    mov ax, 0x00
    mov dl, 0x80           ; drive 0x80
    INT 0x13
;read boot1 sectors from the hard
    mov bx, BOOT1START
    mov dl, 0x80           ; drive 0x80
    mov dh, 0x00           ; head 0
    mov ch, 0x00           ; cylinder 0
    mov cl, 0x02           ; start reading from second sector
    mov ah, 0x02           ; BIOS read sector function
    mov al, 0x01           ; read 17 sectors
    mov ah, 0x02
    INT 0x13
    jnc load_boot1_done
    mov bx, LOAD_BOOT1_FAIL
    call bios_print
    jmp $
load_boot1_done:
    mov bx, LOAD_BOOT1_DONE
    call bios_print
;jump to boot1 code
    jmp 0:BOOT1START

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
LOAD_BOOT1_DONE:
    db 'Load Boot1 Success', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_BOOT1_FAIL:
    db 'Load Boot1 Fail', 0x0d, 0x0a, 0 ; followed by \r\n

; padding
times 510-($-$$) db 0

;magic number
dw 0xaa55
