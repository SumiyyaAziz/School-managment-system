; ---------- STUDENT MANAGEMENT SYSTEM ----------
; EMU8086 Assembly Language Project
; Features: Add Student, Display Students, Exit

.model small              ; small memory model (single code + data segment)
.stack 100h               ; stack size 256 bytes

.data                     ; data segment starts

title_msg db 13,10,'==== STUDENT MANAGEMENT SYSTEM ====',13,10,'$'
; Title message (CR LF added)

menu_msg db '1.Add Student  2.Display  3.Exit',13,10,'$'
; Menu options

choice_msg db 'Enter choice: $'
; Prompt for menu choice

name_msg db 13,10,'Enter Student Name: $'
reg_msg db 13,10,'Enter Registration No: $'
grade_msg db 13,10,'Enter Grade (A/B/C): $'

saved_msg db 13,10,'Student Saved!',13,10,'$'
no_data_msg db 13,10,'No Records Found!',13,10,'$'

; ---------- DATA STORAGE ----------
names  db 3*20 dup(0)     ; 3 names, each max 20 chars
regs   db 3*10 dup(0)     ; 3 reg numbers, each max 10 chars
grades db 3 dup(0)        ; 3 grades
count  db 0               ; number of students stored

.code
main proc
    mov ax,@data          ; load data segment address
    mov ds,ax             ; initialize DS

; ---------- MAIN MENU ----------
menu:
    lea dx,title_msg      ; load address of title message
    mov ah,9              ; DOS print string function
    int 21h

    lea dx,menu_msg       ; print menu
    mov ah,9
    int 21h

    lea dx,choice_msg     ; print choice prompt
    mov ah,9
    int 21h

    mov ah,1              ; read single character
    int 21h

    cmp al,'1'            ; if choice = 1
    je add_student

    cmp al,'2'            ; if choice = 2
    je display_all

    cmp al,'3'            ; if choice = 3
    je exit_prog

    jmp menu              ; invalid input ? show menu again

; ---------- ADD STUDENT ----------
add_student:
    mov al,[count]        ; load student count
    cmp al,3              ; max 3 students
    jae menu              ; if >=3, go back to menu

    ; ----- NAME OFFSET CALCULATION -----
    mov bl,[count]        ; BL = student index
    mov bh,0              ; clear BH
    mov cx,20             ; max 20 chars
    mov si, offset names  ; base address of names array

    mov ax,bx             ; AX = index
    mov dx,20             ; record size = 20
    mul dx                ; AX = index * 20
    add si,ax             ; SI points to correct name slot

    lea dx,name_msg       ; ask for name
    mov ah,9
    int 21h

input_name:
    mov ah,1              ; read character
    int 21h
    cmp al,13             ; Enter key?
    je done_name
    mov [si],al           ; store character
    inc si                ; move to next position
    loop input_name       ; repeat until CX = 0

done_name:

    ; ----- REGISTRATION OFFSET CALCULATION -----
    mov bl,[count]        ; student index
    mov bh,0
    mov cx,10             ; max 10 chars
    mov si, offset regs   ; base of regs array

    mov ax,bx
    mov dx,10             ; record size = 10
    mul dx
    add si,ax             ; correct reg slot

    lea dx,reg_msg        ; ask for registration number
    mov ah,9
    int 21h

input_reg:
    mov ah,1
    int 21h
    cmp al,13
    je done_reg
    mov [si],al
    inc si
    loop input_reg

done_reg:

    ; ----- STORE GRADE -----
    lea dx,grade_msg
    mov ah,9
    int 21h

    mov ah,1              ; read grade
    int 21h

    mov bl,[count]
    mov si, offset grades
    add si,bx             ; SI points to grade slot
    mov [si],al           ; store grade

    inc byte ptr [count]  ; increment student count

    lea dx,saved_msg      ; show confirmation
    mov ah,9
    int 21h

    jmp menu              ; return to menu

; ---------- DISPLAY STUDENTS ----------
display_all:
    mov al,[count]
    cmp al,0              ; if no students
    je no_data

    mov bl,0              ; start from first student

next_record:
    ; ----- PRINT NAME -----
    mov al,bl
    mov ah,0
    mov dx,20
    mul dx                ; index * 20
    mov si,offset names
    add si,ax

    mov dl,13             ; new line
    mov ah,2
    int 21h
    mov dl,10
    int 21h

    mov cx,20
print_name:
    mov dl,[si]
    cmp dl,0
    je after_name
    mov ah,2
    int 21h
    inc si
    loop print_name

after_name:

    ; ----- PRINT REG -----
    mov al,bl
    mov ah,0
    mov dx,10
    mul dx
    mov si,offset regs
    add si,ax

    mov dl,' '
    mov ah,2
    int 21h

    mov cx,10
print_reg:
    mov dl,[si]
    cmp dl,0
    je after_reg
    mov ah,2
    int 21h
    inc si
    loop print_reg

after_reg:

    ; ----- PRINT GRADE -----
    mov si,offset grades
    add si,bx
    mov dl,' '
    mov ah,2
    int 21h
    mov dl,[si]
    int 21h

    inc bl                ; next student
    cmp bl,[count]
    jb next_record

    jmp menu

; ---------- NO DATA ----------
no_data:
    lea dx,no_data_msg
    mov ah,9
    int 21h
    jmp menu

; ---------- EXIT ----------
exit_prog:
    mov ah,4Ch            ; terminate program
    int 21h

main endp
end main