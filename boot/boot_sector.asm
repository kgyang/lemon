;
; A boot sector
;

org 0x7c00 ;The code is loaded to 0x7c00

mov [BOOT_DRIVE], dl    ; BIOS stores boot drive in dl, so it's
                        ; best to remember this for later.

mov bp, 0x8000          ; Here we set our stack safely out of
mov sp, bp              ; the way, at 0x8000

call bios_load_kernel

mov bx, WELCOME_MSG
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

; bios load kernel
bios_load_kernel:
    mov bx, 0x9000
    mov dl, [BOOT_DRIVE]   ; drive
    mov dh, 0x00           ; head 0
    mov ch, 0x00           ; cylinder 0
    mov cl, 0x02           ; start reading from second sector
    mov ah, 0x02           ; BIOS read sector function
    mov al, 0x05           ; read 5 sectors
    int 0x13

    jc disk_error
    cmp al, 0x05           ; has read 5 sectors?
    jne disk_error
    mov bx, LOAD_KERNEL_DONE
    call bios_print
    ret

disk_error:
    mov bx, DISK_ERROR_MSG
    call bios_print
    jmp $

; data
BOOT_DRIVE: db 0

WELCOME_MSG:
    db 'Welcome to Lemon', 0x0d, 0x0a, 0 ; followed by \r\n

DISK_ERROR_MSG:
    db 'Disk read error!', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_KERNEL_DONE:
    db 'Kernel is loaded', 0x0d, 0x0a, 0 ; followed by \r\n

; padding and magic number
times 510-($-$$) db 0

dw 0xaa55

; fill 5 sectors to test disk read
times 256 dw 0xdada
times 256 dw 0xface
times 256 dw 0xdada
times 256 dw 0xface
times 256 dw 0xdada
