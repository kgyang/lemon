;
; A boot sector
;
BOOT1START equ 0x1000
STACKTOP equ 0x7000

org BOOT1START
start:
;set the stack pointer
    mov sp, STACKTOP
;query the BIOS for the size of lower memory
;query the BIOS for the size of upper memory
;read kernel sectors from the hard disk into lower memory
    mov bx, LOAD_KERNEL_DONE
    call bios_print
    jmp $
;enable the A20 gate
;disable interrupt
    cli
;load the Global Descriptor Table
;switch to protected mode
;invoke the multiboot loader
;begin execution of the kernel

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
LOAD_KERNEL_DONE:
    db 'Load Kernel Success', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_KERNEL_FAIL:
    db 'Load Kernel Fail', 0x0d, 0x0a, 0 ; followed by \r\n

; padding
times 512*16-($-$$) db 0
