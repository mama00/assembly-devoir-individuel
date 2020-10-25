;8086 programme pour afficher un nombre decimal sur 16 bit 
.MODEL SMALL 
.STACK 100H 
.DATA 
d1 dw 6550
message_bienvenue db 'BONJOUR BIENVENUE DANS LE PROGRAMME','$'
message1 db 'Veuillez entrer le nombre: ','$'
message2 db 'Le nombre entre est: ','$'    

.CODE            

;affiche une valeur de AL et avance la position du curseur
affiche_carac    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm  

NOUVELLE_LIGNE MACRO
        PUSH AX
        MOV AL, 0AH
        MOV AH, 0EH
        INT 10H
     
        MOV AL, 0DH
        MOV AH, 0EH
        INT 10H
        POP AX
ENDM



 SCANF        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reinitialise le flag:
        MOV     CS:make_minus, 0

prochain_nombre:

        ; recupere la valeur du clavier dans AL

        MOV     AH, 00h
        INT     16h
        ;afficher:
        MOV     AH, 0Eh
        INT     10h

        ; verifie si - :
        CMP     AL, '-'
        JE      remove_not_digit

        ; enter pressed:
        CMP     AL, 0Dh  
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        affiche_carac    " "                     ; clear position.
        affiche_carac    8                       ; backspace again.
        JMP     prochain_nombre
backspace_checked:
        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        affiche_carac    8       ; backspace.
        affiche_carac    ' '     ; clear last entered not digit.
        affiche_carac    8       ; backspace again.        
        JMP     prochain_nombre ; wait for next input.       
ok_digit:
        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     prochain_nombre


too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        affiche_carac    8       ; backspace.
        affiche_carac    ' '     ; clear last entered digit.
        affiche_carac    8       ; backspace again.        
        JMP     prochain_nombre ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
;flag
make_minus      DB      ?       
SCANF        ENDP
; used as multiplier/divider by SCANF & PRINT_NUM_UNS.
ten             DW      10       

;PROGRAMME PRINCIPAL

MAIN PROC FAR 
	MOV AX,@DATA 
	MOV DS,AX	 	 
	LEA DX,message_bienvenue
	MOV AH,09h
	INT 21h
	NOUVELLE_LIGNE
	NOUVELLE_LIGNE
	
	LEA DX,message1
	MOV AH,09h
	int 21h
	
	CALL SCANF
	
	NOUVELLE_LIGNE   
	 
    LEA DX,message2
	MOV AH,09h
	INT 21h  
    MOV AX,CX
    
	CALL PRINT	 
					
	;exit		
	MOV AH,4CH 
	INT 21H 

MAIN ENDP  


PRINT PROC		 
	
	;initilize count 
	mov cx,0 
	mov dx,0 
	label1:
	;permet de recuperer chaque digit du nombre  
		cmp ax,0 
		je print1	 
		mov bx,10		 
		div bx				 
		push dx			 
		inc cx			 
		mov dx,0 
		jmp label1 
	print1: 
        ;si pas de nombre afficher exit
		cmp cx,0 
		je exit
		
		;pop the top of stack 
		pop dx 
		
		;convertir en ascii pour afficher
		add dx,48 
		
		;afficher le caractere

		mov ah,02h 
		int 21h 
		
		;decrementer cx
		dec cx 
		jmp print1 
exit: 
ret 
PRINT ENDP 
END MAIN 
