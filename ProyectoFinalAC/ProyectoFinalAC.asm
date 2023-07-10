; multi-segment executable file template.
 include 'emu8086.inc'
 
data segment
;aqui van las variables del programa-----------------------------------------------------------------
   
    ; mensajes
    divisible db " YES", 10,13,"$"
    no_divisible db " NO", 10,13,"$"
    saltoLinea db "", 0Dh,0Ah, "$"
    msg1 db  "Introduzca la cantidad de datos a analizar, precione ENTER para continuar: $"
    msg2 db 10,13, "Introduzca los valores segun valla analizando el programa: $"
    msg3 db         175,175,,175,"      YA HA ANALIZADO TODOS SUS DATOS      " ,174,,174,,174,"$"
    msg4 db 10,13, 175,175,,175,"   GRACIAS POR UTILIZAR NUESTRO PROGRAMA   " ,174,,174,,174,"$"
    ;datos  
    ult_digito db ?
    mayor_digito db ?
    menor_digito db 9
    digito db ? 
    cantNumeros db ? 
    numero db 100 dup("$")
    
    ;aux
    px db 0
    py db 3 
     
;------------------------------------------------------------------------------------------------    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

; aqui va el codigo del programa-----------------------------------------------------------------
          
    
  ;recibe la cantidad de numeros que va a tener el arreglo y lo guarda en la variable cantNumeros   
      
    
    
    lea dx, msg1 
    mov ah, 09h
    int 21h
   
    mov cx,0
   leer_cant_casos:
    
    mov ah,7
    int 21h
    
    cmp al,13 
    
    je fin_leer_cant_casos 
    
     mov ah,2
     mov dl,al
     int 21h
    
    sub al,30h
    add cl,al
    mov al,cl
    mov bl,10
    mul bl
    mov cx,ax
    
  jmp leer_cant_casos 
     
   fin_leer_cant_casos:
   mov ax,cx
   mov bl,10
   div bl
   mov cantNumeros,al  
         
   lea dx, saltoLinea
   mov ah, 9
   int 21h
      
   
   
;recibir los numeros a comparar----------------------------------------------------------
    lea dx, msg2 
    mov ah, 09h
    int 21h
    
    lea dx, saltoLinea
    mov ah, 9
    int 21h
  
        
    mov si,0
    mov cx,0
    mov cl,cantNumeros
    mov di,0
    
  leer_numero:
   
   push cx 
   
       
       
  mov ah, 7h
  int 21h 
  cmp al,13
  je fin_leer_numero 
  
  mov numero[si],al
    inc si
     
     mov ah,2
     mov dl,al
     int 21h 
        
  jmp leer_numero
  
  fin_leer_numero: 
   
  
 ;obtener los dos ultimos digitos del numero---------------------------------------------------
   mov cx,0
   obt_ult_digito:
   dec si
   cmp si,0
   je un_digito
   dec si
   un_digito:
   mov al,numero[si]
   sub al, 30h
   cmp si,0
   je un
   inc si
   mov bl,10
   mul bl
   mov cl,al
   mov al,numero[si]
   sub al, 30h
   un:   
   add cl,al 
   mov ult_digito,cl   
     
                   
;obtener el mayor y menor digito del numero----------------------------------------------------------
    mov si,0
   
   mov al, numero[si]
   sub al, 30h
   inc si 
   mov mayor_digito,al
   mov menor_digito,al
    
   obt_digito: 
   cmp numero[si], 36
   je fin_obt_digito
   
   mov al, numero[si]
   sub al, 30h
   inc si
    
    cmp al,menor_digito
    jl obt_menor_digito 
    cmp al,mayor_digito
    jg obt_mayor_digito
    jmp obt_digito
    
   obt_mayor_digito:
   mov mayor_digito,al 
   jmp obt_digito
   
   obt_menor_digito:
   mov menor_digito,al 
   jmp obt_digito  
      
    fin_obt_digito:  
    
; hacer sonar la vocina un tiempo en segundos igual al mayor digito-----------------------------

 ;beep:
 ;       mov cx,0
  ;      mov dx,0
   ;     mov cl, mayor_digito
         
   ; beepFor:     
    ;    mov dl, 7h
     ;   mov ah, 2
      ;  int 21h
    ;loop beepFor 
    
;imprime cada numero por consola----------------------------------------------------------------   
    
   
   
   
    mov si,0 
   
    imprimir_numero:
    
   
    
    cmp numero[si], 36
    je fin_imprimir
    mov al,numero[si]
    mov digito,al
    sub al,30h
           

           
    cmp al, menor_digito
    je imprimir_menor_digito
    
    cmp al, mayor_digito
    je imprimir_mayor_digito 
     
     mov al, 1
     mov bl, 0000_0111b
     mov cx, 1 
     mov dl, px
     mov dh, py
     mov bp, offset digito
     mov ah, 13h
     int 10h
     
     jmp fin_imprimir_digito 
     
        
   
        
        
    imprimir_menor_digito:
   
     mov al, 1
     mov bl, 0100_1111b
     mov cx, 1 
     mov dl, px
     mov dh, py
     mov bp, offset digito
     mov ah, 13h
     int 10h
     
     jmp fin_imprimir_digito 
    
    imprimir_mayor_digito:
    
     mov al, 1
     mov bl, 0000_0001b
     mov cx, 1 
     mov dl, px
     mov dh, py
     mov bp, offset digito
     mov ah, 13h
     int 10h
     
     jmp fin_imprimir_digito
     
      fin_imprimir_digito: 
      
      inc px
      inc si 
      
      jmp imprimir_numero
     
     fin_imprimir:
     mov si,0
     inc px 
     
;comprobar si el numero es divisible por 4-----------------------------------------------------
  mov ax,0
  mov cx,0
  mov al, ult_digito
  mov bl,4
  div bl
       
  cmp ah,0
  je es_divisible
  jmp no_es_divisible   
     
   
   
   es_divisible: 
     
    mov al, 1
    mov bl, 0000_1111b
    mov cx, 1 
    mov dl, px
    mov dh, py
    mov bp, offset divisible[1]
    mov ah, 13h
    int 10h 
    
    inc px
    
    mov bl,0000_0001b
    mov dl ,px
    mov bp, offset divisible[2] 
    int 10h
    
    inc px
    
    mov bl,0000_1111b
    mov dl ,px
    mov bp, offset divisible[3] 
    int 10h
    
   jmp vaciar_numero
   
   no_es_divisible:
   
    mov al, 1
    mov bl, 0000_1111b
    mov cx, 1 
    mov dl, px
    mov dh, py
    mov bp, offset no_divisible[1]
    mov ah, 13h
    int 10h 
    
    inc px
    
    mov bl,0000_0001b
    mov dl ,px
    mov bp, offset no_divisible[2] 
    int 10h
    
    jmp vaciar_numero 
     
    mov si,0
    vaciar_numero: 
    mov ult_digito ,0
    mov mayor_digito,0
    mov menor_digito ,9
      
    vaciar_digitos:.  
    cmp numero[si],"$"
    je proximo
    mov numero[si],"$"
    inc si
    jmp vaciar_digitos: 
    
    proximo:
   lea dx, saltoLinea
   mov ah, 9
   int 21h
   
   mov si,0
   mov px,0
   inc py
   mov cx,0
   pop cx
        
   loop leer_numero
         
        
       
   
        
       
;-----------------------------------------------------------------------------------------------    
;----------------------------------------------------------------------------------------------- 
    
      lea dx, saltoLinea
   mov ah, 9
   int 21h

    lea dx, msg3 
    mov ah, 09h
    int 21h
    
     
      lea dx, saltoLinea
   mov ah, 9
   int 21h

    lea dx, msg4 
    mov ah, 09h
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
 ends 
 

end start ; set entry point and stop the assembler.
