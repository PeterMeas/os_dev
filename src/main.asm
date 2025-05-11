org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ; macro for endlinequ 

start:
    jmp main
; Prints string to screen
; PARAMS:
;   ds:si points to string

puts:
    ; save registers that will be modified
    push si
    push ax

.loop:
    lodsb   ; load next char in al
    or al, al ; verify if next char is null?
    jz .done
    

    mov ah, 0x0e ; bios interrupt
    mov bh, 0
    int 0x10 ; interrupt for video
    jmp .loop
.done:
    pop ax
    pop si
    ret


main:
    ; data segments
    mov ax, 0 
    mov ds, ax
    mov es, ax
    ; set up stack
    mov ss, ax
    mov sp, 0x7C00 ; stack point to the start
    
    ; print message
    mov si, msg_hw
    call puts
    hlt

.halt:
    jmp .halt

msg_hw: db 'Welcome to my OS', ENDL, 0
 
times 510-($-$$) db 0
dw 0AA55h