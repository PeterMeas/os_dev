org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ; macro for endlinequ 


;
; FAT12 boot sector header
;

jmp short start ; SKIP over BIOS PARAMETER BLOCK
nop

bdb_oem:                    db 'MSWIN4.1' ; 8 bytes
bdb_bytes_per_sector:       dw 512        ; each sector is 512 bytes
bdb_sectores_per_cluster:   db 1            
bdb_reserved_sectors:       dw 1          ; reserved for boot sector
bdb_fat_count:              db 2        ; 2 file allocation tables STANDARD IN FAT12/16 formats
bdb_dir_entries_count:      dw 0E0h     ; how many entries can exist in root, 
                                        ; 1 entry = 32 bytes
                                        ; occupies 14 sectors standard for FAT12 1.44MB floppy disks
                                        ; 224 entries * 32 bytes = 7168 bytes
                                        ; 7168/512 = 14 sectors
bdb_total_sectors:          dw 2880        ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h         ; 3.5" floppy disk
bdb_sectors_per_fat:        dw 9            ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

;
; extended boot record
;
ebr_drive_number:          db 0 ; 0x00 = floppy, 0x80 hdd
                           db 0 ; reserved
ebr_signature:             db 29h
ebr_volume_id:             db 12h, 34h, 56h, 78h  ; serial
ebr_volume_label:          db 'KEYNO OS   ' ; 11 bytes                           
ebr_system_id:             db 'FAT12   ' ; 8 bytes

;
; CODE
;   


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


;
; Disk routine
;

;Converts an LBA address to a CHS address
; Params:
;   - ax: LBA address 
; Returns:
;   cylinder - 
;   cx [bits 0 - 5]: sector number
;   cx [bits 6 - 15]: cylinder
;   dh: head

lba_to_chs:
    
    push ax
    push dx

    xor dx, dx      ;dx = 0
    div word [bdb_sectors_per_track]    
;   divs 32b number in DX:AX , Quotient -> AX, remainder -> DX
;
                             ; ax = LBA / SectorsPerTrack
                             ; dx = LBA % SectorsPerTrack

    inc dx                              ; increment dx++, dx will = (LBA % sectorspertrack + 1) = sector
    move cx, dx             ; cx = sector 

    xor dx, dx              ; dx = 0
    div word [bdb_heads]    ; ax = (LBA / SectorsPerTrack) / Heads = cylinder
                            ; dx = (LBA / SectorsPerTrack) % Heads = head

    mov dh, dl ; move lower 8 bits of dx into dh
                ; dh = head
    mov ch, al ; move lower 8 bits of ax
                ; ch = cylinder
    shl ah, 6
    or cl, ah ; upper 2 bits of cylinder in CL

    pop ax
    mov dl, al
    pop ax

    ret

;
;Read sector from Disk
;   PARAMS:
; -ax = LBA ADDRESS
; -cl = NUMBER OF SECTORS TO READ (128 LIMIT)
; -dl = DRIVE NUBMER
; -es:bx: = MEMORY ADDRESS TO STORE/READ DATA

disk_read:
    push cx ; save original cx (sector count)
    call lba_to_chs ; compute CHS , CX overwritten
    pop ax ; AL = number sectors to read, original count restored

msg_hw: db 'Welcome to my OS', ENDL, 0
 
times 510-($-$$) db 0
dw 0AA55h