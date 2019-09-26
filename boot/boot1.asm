;
; A boot sector
;
KERNELLOWER equ 0x9000
KERNELUPPER equ 0x100000
BOOT1START equ 0x1000
STACKTOP equ 0x7000

org BOOT1START
start:
;set the stack pointer
    mov sp, STACKTOP
;query the BIOS for the size of lower memory
;query the BIOS for the size of upper memory
;read kernel sectors from the hard disk into lower memory, each time 64KB due to segment limitation
    mov word [LBA_ADDR+2], 0x0080 ;128 blocks
    mov word [LBA_ADDR+6], 0x0900 ;destination segment
    mov dword [LBA_ADDR+8], 0x00000012 ;start from the 19th block
repeat:
    mov si, LBA_ADDR
    mov ah, 0x42
    mov dl, 0x80 ; hard disck, drive 0
    int 0x13
    jc load_kernel_done
    add word [LBA_ADDR+6], 0x1000
    add dword [LBA_ADDR+8], 0x00000080
    jmp repeat

load_kernel_done:

;enable the A20 gate
    mov ah, 0x24
    int 0x15

;disable interrupt
    cli
;load the Global Descriptor Table
    xor ax, ax
    mov ds, ax
    lgdt [GDTR]
;switch to protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:pmmain

bits 32
pmmain:
    mov ax, 0x10 ;data segment
    mov ds, ax
    mov ss, ax

    mov byte [0xB8000], 'P' ; display P in left-up corner
    mov byte [0xB8001], 0x1B

    jmp $
;invoke the multiboot loader
;begin execution of the kernel

; data
LBA_ADDR:
    dw 0x0010 ; packet size
    dw 0x0000 ; block number
    dw 0x0000 ; destination offset
    dw 0x0000 ; destination segment
    dd 0x00000000 ; block start
    dd 0x00000000 ; padding

LOAD_KERNEL_DONE:
    db 'Load Kernel Success', 0x0d, 0x0a, 0 ; followed by \r\n

LOAD_KERNEL_FAIL:
    db 'Load Kernel Fail', 0x0d, 0x0a, 0 ; followed by \r\n

GDT:
    dw 0,0,0,0 ;dummy

    dw 0xFFFF  ;limit 0:15
    dw 0x0000  ;base 0:15
    dw 0x9A00  ;code read/exec access byte: present=1, privilege=0: base16:23
    dw 0x00CF  ;granularity=4096 base24:31,flags, limit16:19

    dw 0xFFFF  ;limit 0:15
    dw 0x0000  ;base 0:15
    dw 0x9200  ;data read/write access byte: present=1, privilege=0: base16:23
    dw 0x00CF  ;granularity=4096 base24:31,flags, limit16:19
GDT_END:

GDTR:
    dw GDT_END - GDT
    dw GDT

; padding
times 512*17-($-$$) db 0
