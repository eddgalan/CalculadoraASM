ImprimeCadena MACRO cadena
    mov dx,offset cadena    ;Asigna a DX la posicion inicial de cadena
    mov ah,09               ;Usa la funcion 09H
    int 21H                 ;De la interrupcion de 21H
ENDM           
LimpiaPantalla MACRO
    mov ah,0FH              ;Usa la funcion 0FH
    int 10H                 ;De la interrupcion 21H
    mov AH,0                ;Usa la funcion 0H
    int 10H                 ;De la interrupcion 21H
ENDM 
EntradaOperandos MACRO
    call EntradaNum         ;Llama al proceso de entrada. Al final del procedimiento de entrada el valor insertado se queda en AX
    mov num1,ax             ;Asigna a num1 el valor de AX
    call EntradaNum         ;Llama al proceso de entrada. Al final del procedimiento de entrada el valor insertado se queda en AX
    mov num2,ax             ;Asigna a num2 el valor de AX
    mov ax,num1             ;Asigna num1 en AX
    mov bx,num2             ;Asigna num2 en BX
    mov cl, num1neg         ;Asigna a CX el valor de Num1Neg
    mov dl, num2neg         ;Asigna a DX el valor de Num1Neg
ENDM
pila    segment para    stack   'stack'
    db 64 dup(0)
pila    ends
datos   segment para    'data'
    ;Mensajes:
    menu    db  '       Menu    ',10,10,13
            db  'Calculadora de: +,-,*,/$'
    opciones    db  10,10,13
            db  '1.Suma',10,13,'2.Resta',10,13
            db  '3.Multiplicacion',10,13,'4.Division',13,10,'5.Salir$'
    pregunta    db  10,13,10,13,'¨Que operacion desea realizar? $'
    novalida db 10,10,13,'Opcion no valida. Inserte una opcion del 1 al 5.',10,13,'Precione cualquier tecla para continuar...$'
    pnum1   db  10,13,'Dame un numero: $'
    pnum2   db  10,13,'Dame otro numero: $'
    msjSuma db '       Suma',13,10,'$' 
    msjResta db '      Resta',13,10,'$'
    msjMulti db '      Multiplicacion',13,10,'$'
    msjDiv db '        Division',13,10,'$'
    msjContinuar   db  10,13,10,13,'Desea continuar (y=1/n=0): $'
    msjResul   db  10,13,10,13,'El resultado es: $'    
    msjDivProhibida db 'Division NO permitida. El divisor no puede ser 0.$'
    ;Variables
    contador db  ?               ;Se usa para contar cuantos numeros han entrado. Puede ser numero
    num1neg db  ?                ;Guarda el signo del numero 1 (1=Negativo, 0=Positivo).
    num2neg db  ?                ;Guarda el signo del numero 2 (1=Negativo, 0=Positivo).
    aux dw  ?                    ;Se usa en la entrada de datos.
    num1 dw ?                    ;Guarda el Numero1 que se va a operar.
    num2 dw ?                    ;Guarda el Numero2 que se va a operar.
    signoResultado db ?          ;Guarda el signo del resultado de la operacion que se va a realizar (Suma, Resta, Multiplicacion, Divicion).
    numHexadecimal1 dw ?         ;Se usa para Guardar el numero1 convertido en Hexadecimal en el proceso de Multiplicacion
    numHexadecimal2 dw ?         ;Se usa para Guardar el numero2 convertido en Hexadecimal en el proceso de Multiplicacion
    dividendo   dw  ?            ;Guarda el dividendo
    divisor dw  ?                ;Guarda el divisor                                                   
datos   ends
codigo  segment para 'code'
    assume cs:codigo,ds:datos,ss:pila
    inicio proc far
        mov ax,datos                ;Asignacion del segmento de datos 
        mov ds,ax                   ;Al DS
        ImprimeMenu:                ;Inicia a imprimir el menu
        ImprimeCadena menu          ;Llama a la macro ImprimeCadena y manda menu como argumento  
        ImprimeCadena opciones      ;Llama a la macro ImprimeCadena y manda opciones como argumento
        ImprimeCadena pregunta      ;Llama a la macro ImprimeCadena y manda pregunta como argumento
        ;Lee la opcion elegida por el usuario
        mov ah,01H
        int 21H                     ;Lee la tecla del usuario
        cmp al,'1'                  ;Si la opcion insertada es 1
        jz  Suma                    ;Salta a LlamaSuma
        cmp al,'2'                  ;Si la opcion insertada es 2
        jz  Resta                   ;Salta a LlamaResta
        cmp al,'3'                  ;Si la opcion insertada es 3
        jz  Multiplicacion          ;Salta a LlamaMulti
        cmp al,'4'                  ;Si la opcion insertada es 4                  
        jz  Division                ;Salta a LlamaDiv
        cmp al,'5'                  ;Si la opcion insertada es 5
        jz  Salir                   ;Salta a Salir
        ;Opcion no valida
        ImprimeCadena novalida      ;Llama a la MACRO ImprimeCadena para imprimir el mensaje novalida
        mov ah,01
        int 21H                     ;Lee una tecla para poder hacer una pausa y mostrar el mensaje en pantalla
        LimpiaPantalla              ;Llama a la MACRO limpia pantalla
        jmp ImprimeMenu
        Suma:                       ;Etiqueta Suma
        LimpiaPantalla              ;Llama a la MACRO LimpiarPantalla
        ImprimeCadena msjSuma       ;Llama a la MACRO ImprimeCaden mandando msjSUMA                  
        EntradaOperandos            ;Llama a la MACRO EntradaOperandos                               
        cmp cl,dl                   ;Compara los signos de los numeros si son iguales
        jz SumaSignosIguales        ;Salta a SumaSignosIguales
        jmp SumaSignosDiferentes        
        SumaSignosIguales:          ;Suma de dos numeros con signos iguales
        add al,bl                   ;Suma AL y BL
        daa                         ;Ajuste a decimal        
        mov dl,al                   ;Asigna el resultado a DL 
        mov al,ah                   ;Asigna a AL la parte Entera del numero1 que estaba en CX
        adc al,bh                   ;Suma con acarreo
        daa                         ;Ajuste a decimal
        mov dh,al                   ;Pone la parte entera del resultado en DH. Ya tenemos el numero completo en el registro DX
        mov cx,dx                   ;Pasa el resultado de la operacion a CX
        mov al,num1neg
        mov signoResultado,al       ;Indica que no se va a imprimir el signo (-).
        jmp FinSuma                 ;Salta al fin de la suma
        SumaSignosDiferentes:
        cmp ax,bx         ;Compara para saber cual es mayor
        jb bxMayor        ;Salta si BX es mayor
        jmp axMayor       ;Salta a axMayor
        axMayor:
        sub al,bl         ;Resta los decimales. El resultado se queda en AL
        das               ;Ajuste Decimal
        mov dl,al         ;Guarda el resultado en DL
        mov al,ah         ;Asigna a AL la parte Entera del Num1 que estaba en CX
        sbb al,bh         ;Resta con prestamo
        das               ;Ajuste Decimal
        mov dh,al         ;Pone la parte Decimal en el DL. Ya tenemos el numero completo en DX
        mov cx,dx         ;Pasa el resultado a CX
        mov al,num1neg
        mov signoResultado,al ;Se conserva el signo (+ o -) Del numero mayor (NUM1).
        jmp FinSuma 
        bxMayor:
        sub bl,al         ;Resta los decimales. El resultado se queda en BL
        mov al,bl         ;Mueve el resultado a AL para hacer el ajuste
        das               ;Ajuste Decimal.                             
        mov bl,al         ;Regresa el numero ajustado a BL.
        mov dl,bl         ;Guarda el resultado en DL
        mov al,bh         ;Asigna a AL la parte Entera del Num1
        sbb al,ah         ;Resta con prestamo
        das               ;Ajuste decimal
        mov dh,al         ;Pone la parte Decimal en DL
        mov cx,dx         ;Pasa el numero completo (Resultado) a CX.
        mov al,num2neg
        mov signoResultado,al ;Se conserta el signo (+ o -) Del numero Mayor (NUM2).
        FinSuma:
        call ImprimeResultado       ;Llama al procedimiento de Imprimir resultado
        jmp PreguntaContinuar       ;Salta a pregunta continuar.
        
        Resta:
        LimpiaPantalla              ;Llama a la MACRO LimpiarPantalla
        ImprimeCadena msjResta      ;Llama a la MACRO ImprimeCaden mandando msjResta
        EntradaOperandos            ;Llama a la MACRO EntradaOperandos
        cmp cl,dl
        je  Num1PositivoR     
        cmp cl,1          ;Compara si es Negativo (1=Negativo)
        jz Num1NegativoR  ;Si los signos son iguales salta a RestaSignosIguales
        jmp Num1PositivoR ;Salta a Num1Positivo        
        Num1NegativoR:
        add al,bl         ;Suma los decimales
        daa               ;Ajuste Decimal
        mov cl,al         ;Guarda en CL el resultado        
        mov al,ah         ;Asigna a Al AH
        adc al,bh         ;Suma con acarreo
        daa               ;Ajuste Decimal
        mov ch,al         ;Guarda el CH el resultado (El numero completo ya esta en CX)
        mov signoResultado,1    ;Se asigna a que el resultado es negativo (1=Negativo).
        call ImprimeResultado   ;Llama al procedimiento ImprimeResultado
        jmp PreguntaContinuar   ;Salta a PreguntaContinuar     
        Num1PositivoR:
        cmp ax,bx          ;Compara AX con BX (Num1 con Num2)
        je  NumIguales     ;Salta si los numeros son iguales
        jb  bxMayorR       ;Salta a bxMayorR si bx es mayor
        jmp axMayorR       ;Salta a axMayor
        NumIguales:
        mov cx,00          ;Debido a que los numeros son iguales, la resta dara 0, pone a 0 Cx
        call ImprimeResultado   ;Llama al procedimiento ImprimeResultado
        jmp PreguntaContinuar   ;Salta a PreguntaContinuar
        axMayorR:
        cmp cl,dl               ;Compara los signos
        je  SignosIguales       ;Si son iguales, salta a SignosIguales
        sumar:
        add al,bl         ;Resta los decimales. El resultado se queda en AL
        daa               ;Ajuste Decimal
        mov cl,al         ;Guarda el resultado en CL        
        mov al,ah         ;Asigna a AL la parte Entera del Num1 que estaba en CX
        adc al,bh         ;Resta con prestamo las partes Enteras
        daa               ;Ajuste Decimal
        mov ch,al         ;Pone la parte Entera en el CL. Ya tenemos el numero completo en CX
        mov al,num1neg    ;Asigna a Al el signo resultante
        mov signoResultado,al ;Se conserva el signo + (0=Positivo)
        call ImprimeResultado
        jmp PreguntaContinuar 
        SignosIguales:
        sub al,bl         ;Resta los decimales. El resultado se queda en AL
        das               ;Ajuste Decimal
        mov cl,al         ;Guarda el resultado en CL        
        mov al,ah         ;Asigna a AL la parte Entera del Num1 que estaba en CX
        sbb al,bh         ;Resta con prestamo las partes Enteras
        das               ;Ajuste Decimal
        mov ch,al         ;Pone la parte Entera en el CL. Ya tenemos el numero completo en CX
        mov al,num1neg    ;Asigna a Al el signo resultante
        mov signoResultado,al ;Se conserva el signo + (0=Positivo)
        call ImprimeResultado   ;Llama a Imprime resultado
        jmp PreguntaContinuar   ;Salta a PreguntaContinuar
        bxMayorR:
        cmp cl,1                ;Compara cl con 1
        jz  SigCmp              ;Si es 1 salta a SigCmp
        SigCmp: 
        cmp dl,1                ;Compara dl con 1
        jz  CamSigno            ;Si es 1 salta a CamSigno
        sub bl,al               ;Resta los decimales. El resultado se queda en BL
        das                     ;Ajuste Decimal.
        mov cl,bl               ;Guarda el resultado en CL        
        mov al,bh               ;Asigna a AL la parte Entera del Num2
        sbb al,ah               ;Resta con prestamo
        das                     ;Ajuste decimal
        mov ch,al               ;Pone la parte Entera en CH
        mov signoResultado,1    ;Se inserta el signo - (1=Negativo)
        jmp Fin                 ;Salta a Fin
        CamSigno: 
        cmp cl,0                ;Compara Cl con 0
        jz  sumar               ;Si es 0 salta a sumar
        sub bl,al               ;Resta los decimales. El resultado se queda en BL
        das                     ;Ajuste Decimal.
        mov cl,bl               ;Guarda el resultado en CL        
        mov al,bh               ;Asigna a AL la parte Entera del Num2
        sbb al,ah               ;Resta con prestamo
        das                     ;Ajuste decimal
        mov ch,al               ;Pone la parte Entera en CH
        mov signoResultado,0 
        Fin:
        call ImprimeResultado       ;Llama el procedimiento ImprimeResultado
        jmp PreguntaContinuar       ;Salta a la pregunta si desea continuar
        
        Multiplicacion:
        LimpiaPantalla              ;Llama a la MACRO LimpiarPantalla
        ImprimeCadena msjMulti      ;Llama a la MACRO ImprimeCaden mandando msjMulti
        EntradaOperandos            ;Llama a la MACRO EntradaOperandos     
        cmp ah,bh                   ;Compara AH con BH
        ja continuaMultiplicacion   ;Si AH es mayor salta a continuaMultiplicacion
        mov num1,bx                 ;Asigna a num1 el contenido de BX
        mov num2,ax                 ;Asigna a num2 el contenido de AX
        mov ax,num1                 ;Asigna a AX el contenido de la localidad de memoria num1
        mov bx,num2                 ;Asigna a BX el contenido de la localidad de memoria num2
        continuaMultiplicacion:
        call ConvierteHexadecimal   ;Llama al procedimiento ConvierteHexadecimal para convertir el numero que se encuentre en AL
        push AX                     ;Guardamos el numero convertido en la pila
        mov ax,num1                 ;Asignamos a AX el numero 1
        mov al,ah                   ;Movemos la parte entera del numero a AL para convertirno
        call ConvierteHexadecimal   ;Llama al procedimiento ConvierteHexadecimal para convertir el numero que se encuentre en AL
        mov ah,al                   ;Mueve el hexadecimal a la parte alta
        pop BX                      ;Saca la parte decimal convertida en hexa de la pila
        mov al,bl                   ;Mueve los decimales a AL
        mov numHexadecimal1,AX      ;Guarda el numero1 completo convertido a Hexadecimal en la pila.
        mov ax,num2                 ;Asigna a AX el numero2
        call ConvierteHexadecimal   ;Convierte el numero2 a hexadecimal
        push AX                     ;Guarda el numero convertido en la pila (Numero decimal)
        mov ax,num2                 ;Asigna a AX el numero2
        mov al,ah                   ;Mueve los enteros al registro AL.
        call ConvierteHexadecimal   ;Convierte los enteros a Hexadecimal. Se queda convertidos en AL.
        pop BX                      ;Saca los decimales y los pone en BX.
        mov bh,al                   ;Mueve a BH los enteros.
        mov numHexadecimal2,bx      ;Guarda el numero2 convertido a Hexadecimal en localidad de memoria numHexadecimal2
        mov ax,numHexadecimal1      ;Asigna a AX el numHexadecimal1.
        ;Inicia la multiplicacion del Num1 por los decimales del Num2.
        mov ah,00                   ;Limpiamos a AH para multiplicar
        mul bl                      ;Multiplicamos por BL los decimales del Num1
        ;Inicia procedimiento para convertir Hexadecimal a decimal.
        mov cl,64H                  ;Asigna a CL 64H para dividir
        div cl                      ;Divide AX entre CL
        aam                         ;Ajuste ASCII despues de la multiplicacion
        mov ch,10H                  ;Asignamos a CH 10H
        mov dl,al                   ;Asigna las unidades del numero a DL
        mov al,ah                   ;Mueve las decenas a AL
        mov ah,00                   ;Limpia AH
        mul ch                      ;Multiplica el numero por 10H
        add al,dl                   ;Suma el numero y ya lo tenemos en hexadecimal.
        mov dl,al                   ;Mueve el numero convertido a decimal a DL
        ;Ya tenemos el producto de los decimalesNum1 por los decimalesNum2
        mov ax,numHexadecimal1      ;Asigna a Ax el numero1 convertido en Hexadecimal.
        ;Multiplica la parte entera del Num1 por los decimales del Num2.
        mov al,ah                   ;Asigna la parte Alta a la parte baja
        mov ah,00                   ;Limpia AH
        mul bl                      ;Multiplica por BL y ya tenemos el segundo producto en hexadecimal
        div cl                      ;Divide AX entre Cl
        cmp al,09H                  ;Compara AL con 09H
        ja ContinuaAjuste           ;Si AL es mayor de 09H salta a ContinuaAjuste
        mov bl,al                   ;Mueve el contenido de Al a Bl.
        mov dh,ah                   ;Mueve el numero que se va a convertir a DH.
        jmp ConvierteResiduo        ;Salta a ConvierteResiduo para convertirlo a decimal.                
        ContinuaAjuste:
        mov dh,ah                   ;Asigna a DH el contenido de AH
        aam                         ;Realiza ajuste
        mov bh,al                   ;Movemos las unidades a BH
        mov al,ah                   ;Mueve el numero de las decenas a AL para convertirlo
        mov ah,00                   ;Limpiamos AH
        mul ch                      ;Multiplica AL por CH para obtener el numero de las decenas
        add al,bh                   ;Suma AL con BH para obtener el numero completo
        mov bl,al                   ;Guarda el numero ya en decimal en BL
        ConvierteResiduo:
        mov al,dh                   ;Asigna el otro digito que falta convertir a AL
        aam                         ;Realiza ajuste para empaquetar el numero
        mov dh,al                   ;Mueve las unidades a DH
        mov al,ah                   ;Mueve las decenas a AL
        mov ah,00                   ;Limpia AH
        mul ch                      ;Multiplica AL por CH
        add al,dh                   ;Suma las decenas con las unidades. Ya tenemos el otro producto
        ;Suma los productos de la multiplicacion de Num1 por decimales de Num2
        mov ah,bl                   ;Asigna a AH el contenido de BL. Ya esta el producto del otro numero en AX
        mov bh,00                   ;Limpia BH
        add al,dl                   ;Suma los numeros.
        daa                         ;Ajuste decimal despues de la suma
        adc ah,bh                   ;Suma con acarreo
        push ax                     ;Ya tenemos el producto del Num1 por la parte decimal del Num2. Lo guardamos en la pila.
        ;Inicia la multiplicacion del Num1 por la parte entera del Num2
        mov ax,numHexadecimal1      ;Asigna a AX el numHexadecimal1
        mov bx,numHexadecimal2      ;Asigna a BX el numHexadecimal2
        mov bl,bh                   ;Asigna a BL la parte entera del numHexadecimal2 para multiplicarlo.
        mov ah,00                   ;Limpiamos a AH para multiplicar
        mul bl                      ;Multiplicamos por BL los decimales del Num1
        ;Inicia procedimiento para convertir Hexadecimal a decimal.
        div cl                      ;Divide AX entre CL
        mov dh,al                   ;Mueve a DL el contenido de AL ===============
        mov al,ah                   ;Asigna a AL el residuo de la division para convertirlo a decimal.
        mov ah,00                   ;Limpia AH
        aam                         ;Ajuste ASCII despues de la multiplicacion para desempaquetar
        mov dl,al                   ;Asigna a AL las unidades
        mov al,ah                   ;Mueve a AL las decenas para multiplicar
        mov ah,00                   ;Limpia AH
        mul ch                      ;Multiplica por 10
        add al,dl                   ;Suma AL con DL y ya tenemos el numero convertido.
        mov dl,al                   ;Mueve el numero convertido a decimal a DL
        push dx                     ;Guardamos el producto en la pila para poder operarlo despues.
        mov ax,numHexadecimal1      ;Asigna a Ax el numero1 convertido en Hexadecimal.        
        mov al,ah                   ;Asigna la parte Alta a la parte baja
        mov ah,00                   ;Limpia AH
        mul bl                      ;Multiplica por BL y ya tenemos el segundo producto en hexadecimal
        div cl                      ;Divide AX entre Cl
        mov dh,ah                   ;Asigna a DH el contenido de AH
        aam                         ;Realiza ajuste
        mov bh,ah                   ;Movemos las unidades a BH
        mov ah,00                   ;Limpiamos AH
        mul ch                      ;Multiplica AL por CH para obtener el numero de las decenas
        add al,bh                   ;Suma AL con BH para obtener el numero completo
        mov bl,al                   ;Guarda el numero ya en decimal en BL        
        mov al,dh                   ;Asigna el otro digito que falta convertir a AL
        aam                         ;Realiza ajuste para empaquetar el numero
        mov dh,al                   ;Mueve las unidades a DH
        mov al,ah                   ;Mueve las decenas a AL
        mov ah,00                   ;Limpia AH
        mul ch                      ;Multiplica AL por CH
        add al,dh                   ;Suma las decenas con las unidades. Ya tenemos el otro producto
        mov ah,al                   ;Mueve el contenido de Al a Ah
        mov al,00                   ;Limpia AL
        pop bx                      ;Saca el producto Guardado en la pila y lo pone en BX
        add al,bl                   ;Suma los decimales
        daa                         ;Realiza ajuste decimal.
        adc ah,bh                   ;Suma con acarreo los enteros.
        mov bh,al                   ;Guarda los decimales de la primera suma en BH
        mov al,ah                   ;Mueve los enteros en AH para realizar ajuste
        daa                         ;Realiza ajuste decimal.
        mov ah,al                   ;Mueve el numero ajustado a AH
        mov al,bh                   ;Mueve el numero guardado en BH a AL. 
        pop bx                      ;Saca el producto anterior y lo pone en BX
        add al,bl                   ;Suma decimales
        daa                         ;Realiza ajuste decimal
        mov dl,al                   ;Mueve el resultado de la suma a DL
        adc ah,bh                   ;Suma con acarreo
        mov al,ah                   ;Mueve el contenido de Ah a Al para realizar el ajuste
        daa                         ;Realiza ajuste
        mov dh,al                   ;Mueve el resultado de la operacion a DH
        mov cx,dx                   ;Mueve el resultado de CX para poder imprimirlo
        call LeyDeSignos            ;Llama al procedimiento que realiza la ley de signos
        call ImprimeResultado       ;Llama al procedimiento que ImprimeResultado
        jmp PreguntaContinuar       ;Salta a la pregunta si desea continuar
        
        Division:
        LimpiaPantalla              ;Llama a la MACRO LimpiarPantalla
        ImprimeCadena msjDiv        ;Llama a la MACRO ImprimeCaden mandando msjDiv
        EntradaOperandos            ;Llama a la MACRO EntradaOperandos     
        cmp ax,0                    ;Compara AX con 0
        jz NoPermitido              ;Si Num2=0 La division no esta permitida (El divisor no puede ser 0)
        jmp ComienzaDivision        ;Salta a comienza Division
        NoPermitido:
        ImprimeCadena msjDivProhibida
        mov ah,1                    ;Leemos un digito 
        int 21H                     ;Para hacer una pausa y lograr mostrar el mensaje
        jmp Division                ;Regresa al comienzo de la division
        ComienzaDivision:
        ;Comienza el proceso de division
        call ConvierteHexadecimalCompleto   ;Llama al procedimiento ConvierteHexadecimalCompleto
        mov dividendo,ax                    ;Asigna a la localidad de memoria dividendo el contenido de AX
        mov ax,num2                         ;Asigna a AX el numero2 para convertirlo a Hexadecimal.
        call convierteHexadecimalCompleto   ;Llama al procedimiento ConvierteHexadecimalCompleto    
        mov divisor,ax                      ;Asigna a la localidad de memoria divisor el contenido de AX
        cmp dividendo,ax                    ;Compara dividendo y divisor
        ja DividendoMayor                   ;Si el dividendo es mayor que el divisor salta a DividendoMayor 
        jb  DivisorMayor
        Dividir:
        mov ax,dividendo                    ;Asigna el dividendo a AX
        mov cx,10d                          ;Asigna 10H a CH
        mul cx                              ;Multiplica el dividendo por 10H
        cwd                                 ;Convierte palabra a palabra doble
        div divisor                         ;Divide entre divisor
        mov bl,al                           ;Guarda el cociente en BL
        mov ax,dx                           ;Mueve el residuo a AX
        mul cx                              ;Multiplica el residuo por 10D para volver a dividir
        cwd                                 ;Convierte Palabra a Palabra Doble
        div divisor                         ;Divide AX entre el Divisor
        mov dx,ax                           ;Mueve el cociente a DX
        mov al,bl                           ;Mueve el primer digito del resultado a AL
        mov cx,10H                          ;Asigna 10H a CX para multiplicar
        mul cl                              ;Multiplica AL por CL
        add al,dl                           ;Suma y ya tenemos el resultado en AL
        mov cx,ax                           ;Asigna el resultado de la division a CX para imprimirlo
        jmp FinDivision                     ;Salta a fin de division
        DivisorMayor:
        
        DividendoMayor:
        mov ax,dividendo                    ;Asigna a AX el dividendo
        cwd                                 ;Convierte palabra a palabra doble
        div divisor                         ;Divide AX entre el divisor
        aam                                 ;Realiza ajuste para empaquetar el numero
        mov bl,al                   ;Mueve las unidades a BL
        mov al,ah                   ;Mueve las decenas a AL
        mov ah,00                   ;Limpia AH
        mov ch,10H                  
        mul ch                      ;Multiplica las decenas por 10H
        add al,bl                   ;Suma las unidades con las decenas
        mov bh,al                   ;Mueve la parte entera del resultado a BH
        mov ax,dx                   ;Mueve el residuo de la division anterior a AX
        mov cx,10D
        mul cx                      ;Multiplica por 10H para volver a dividir
        div divisor                 ;Vuelve a dividir el numero entre el divisor
        mov ch,10H                  ;Asigna a CH 10H
        mul ch                      ;Multiplica el cociente por CH
        mov bl,al                   ;Mueve el numero a BL
        mov ax,dx                   ;Mueve el residuo de la division anterior a AX
        mov cx,0AH                  ;Asigna 0AH a CX
        mul cx                      ;Multiplica el residuo por CL
        div divisor                 ;Divide AX entre el numero divisor
        add bl,al                   ;Suma Bl con Al
        mov cx,bx                   ;Mueve el cociente decimal a CX
        FinDivision:
        call LeyDeSignos            ;Llama al procedimiento que realiza la ley de signos
        call ImprimeResultado       ;Llama al procedimiento que ImprimeResultado
        PreguntaContinuar:          ;Pregunta si se desea hacer otra operacion
        ImprimeCadena msjContinuar  ;Llama a la MACRO ImprimeCadena para mostrar el mensaje si desea continuar con otra operacion.
        mov ah,01H
        int 21h                     ;Lee la opcion insertada por el usuario
        cmp al,31H                  ;Si se inserta 1
        jz LimpiaRegistros          ;Salta a LimpiaRegistros
        jmp Salir                   ;Salta al fin del programa
        LimpiaRegistros:            ;Limpiando registros y datos para ser usados de nuevo. Asigna Registros y Datos a 0.
        mov ax,0                    ;Limpia AX
        mov bx,0                    ;Limpia BX
        mov cx,0                    ;Limpia CX
        mov dx,0                    ;Limpia DX
        mov contador,0              ;Limpia contador
        mov num1neg,0               ;Limpia num1neg
        mov num2neg,0               ;Limpia num2neg
        mov aux,0                   ;Limpia aux
        mov num1,0                  ;Limpia num1
        mov num2,0                  ;Limpia num2
        mov signoResultado,0        ;Limpia signoResultado
        LimpiaPantalla              ;Llama a la Macro Limpia Pantalla
        jmp ImprimeMenu             ;Regresa al Menu 
        Salir:                      ;Etiqueta de fin del programa
        mov ah,4CH
        int 21H                     ;Devuelve el control al DOS
    inicio endp
    EntradaNum proc near ;Inicia proceso de entrada de numeros    
        cmp contador,0   ;Compara el contador con 0 
        je PideNumero1   ;Si es 0 salta a PideNumero1
        ImprimeCadena pnum2         ;Imprime la cadena de pnum2
        jmp ContinuaConLaEntrada    ;Salta a continua con la entrada
        PideNumero1:
        ImprimeCadena pnum1         ;Pide Primer Numero
        ContinuaConLaEntrada:
        mov dx,0000                 ;Asigna a DX 0
        Entrada:
        mov ah,1
        int 21h                     ;Entra un digito
        cmp al,2DH                  ;Compara si se inserto el signo (-).
        jz Signo                    ;Si se inserta signo salta a signo.
        cmp al,0DH                  ;Compara que no se precione la tecla [ENTER]
        jz FinEntrada               ;Si se preciona [ENTER] Va al fin de la entrada
        cmp al,2EH                  ;Compara que no se precione la tecla "." (Punto).
        jz EntradaDecimales         ;Si se inserta el "." va a la entrada de decimales
        ;Si no inserto [ENTER] Ni punto decimal
        add dl,1                    ;Le suma 1 a DL indicando que entro un digito
        mov ah,0                    ;Limpia la parte alta de AX para agregar el dato a la pila
        PUSH ax                     ;Mueve el dato insertado a la pila
        jmp Entrada                 ;Regresa a la entrada para insertar mas digitos
        Signo:
        mov cl,contador
        cmp cl,0                ;Si es cero quiere decir que es Num1
        jz Num1Negativo
        cmp cl,1                ;Si es 1 quiere decir que es Num2
        jz Num2Negativo
        Num1Negativo:
        mov num1neg,1           ;1=Indica que num1 es negativo
        jmp Entrada             ;Regresa a la entrada para insertar mas digitos
        Num2Negativo:
        mov num2neg,1           ;1=Indica que num2 es negativo
        jmp Entrada             ;Regresa a la entrada para insertar mas digitos
        FinEntrada:
        cmp dl,1                ;Si entro un numero de un solo digito
        jz EntroUnSoloDigito    ;Salta a EntroUnSoloDigito
        cmp dl,2   
        jz EntraronDosDigitos   ;Salta a EntraronDosDigitos
        jmp FinEntradaNumeros
        EntroUnSoloDigito:
        pop cx                  ;Saca el unico numero insertado a CX
        sub cx,30H              ;and cx,0f0fh ;Hace el ajuste y ya tenemos un numero de un digito. Se puede hacer el ajuste restando 3030H
        mov ah,cl
        mov al,00
        jmp FinEntradaNumeros
        EntraronDosDigitos:
        pop cx                  ;Saca el digito menos significativo
        pop dx                  ;Saca el digito mas significativo
        mov al,dl    
        sub al,30H              ;Le resta 30 a AL y tenemos el numero en decimal
        mov bl,10h              ;Agrega el 10 a BL
        mul bl                  ;Multiplica AL*BL
        sub cl,30H              ;Le resta 30 a CL para poder sumarlo a AL y tener el numero
        add al,cl               ;Tenemos el numero completo en AX
        mov ah,al               ;Movemos el numero a AH
        mov al,00H              ;Limpiamos AL para poder tener el numero completo en el registro AX
        jmp FinEntradaNumeros   ;Va al fin de la entrada de numeros
        EntradaDecimales:
        cmp dl,1                    ;Si entro un numero de un solo digito
        jz EntroUnSoloDigitoEntero  ;Salta a EntroUnSoloEntero
        cmp dl,2   
        jz EntraronDosDigitosEnteros;Salta a EntraronDosEnteros
        EntroUnSoloDigitoEntero:
        pop cx       ;Saca el unico numero insertado a CX
        and cx,0f0fh ;Hace el ajuste y ya tenemos un numero de un digito. Se puede hacer el ajuste restando 3030H
        mov ah,cl
        mov al,00    
        mov aux,ax   ;Guarda la parte entera del numero en un auxiliar
        mov dx,0     ;Reinicia el contador      
        jmp pideDecimales
        EntraronDosDigitosEnteros:
        pop cx                  ;Saca el digito menos significativo
        pop dx                  ;Saca el digito mas significativo
        mov al,dl    
        sub al,30H              ;Le resta 30 a AL y tenemos el numero en decimal
        mov bl,10h              ;Agrega el 10 a BL
        mul bl                  ;Multiplica AL*BL
        sub cl,30H              ;Le resta 30 a CL para poder sumarlo a AL y tener el numero
        add al,cl               ;Tenemos el numero completo en AX
        mov ah,al               ;Movemos el numero a AH
        mov al,00H              ;Limpiamos AL para poder mandar el numero a la pila
        mov aux,ax              ;Guarda la parte entera del numero en un auxiliar
        mov dx,0                ;Reinicia el contador      
        pideDecimales:
        mov ah,01
        int 21H                 ;Entra un digito
        cmp al,0DH              ;Compara que no se precione la tecla [ENTER]
        jz FinEntradaDecimales  ;Si se preciona [ENTER] Va al fin de la entrada
        add dl,1                ;Le suma 1 a DL indicando que entro un digito decimal
        mov ah,0                ;Limpia la parte alta de AX para agregar el dato a la pila
        PUSH ax                 ;Mueve el dato insertado a la pila
        jmp pideDecimales       ;Regresa a pideDecimales para insertar otro digito
        FinEntradaDecimales:
        cmp dl,1                    ;Compara dl con 1
        jz EntroUnSoloDigitoDecimal ;Si es 1 salta a EntroUnSoloDigitoDecimal        
        cmp dl,2
        jz EntraronDosDigitosDecimales
        EntroUnSoloDigitoDecimal:
        pop ax                  ;Saca el unico numero insertado a AX
        and ax,0f0fh            ;Hace el ajuste y ya tenemos un numero de un digito. Se puede hacer el ajuste restando 3030H
        mov bl,10h  
        mul bl                  ;Multiplica ALx10
        mov bl,al
        mov ax,aux              ;Saca la parte entera del numero entero antes insertado
        mov al,bl               ;Inserta la parte decimal al registro AX (Parte menor).
        jmp FinEntradaNumeros
        ;El numero completo ya se encuentra en AX
        EntraronDosDigitosDecimales:
        pop cx       ;Saca el digito menos significativo
        pop dx       ;Saca el digito mas significativo
        mov al,dl    
        sub al,30H   ;Le resta 30 a AL y tenemos el numero en decimal
        mov bl,10h   ;Agrega el 10 a BL
        mul bl       ;Multiplica AL*BL
        sub cl,30H   ;Le resta 30 a CL para poder sumarlo a AL y tener el numero
        add cl,al    ;Tenemos el numero completo en CX
        mov ax,aux   ;Asignamos a AX la parte entera del numero
        mov al,cl    ;Ponemos la parte decimal al numero
        ;Ya tenemos el numero completo en AX        
        FinEntradaNumeros:
        inc contador ;Le suma 1 al contador que indica cuantos numeros se han insertado
     ret
     ImprimeResultado proc near
        ;Antes de llamar este procedimiento el Numero debe estar en CX
        ImprimeCadena msjResul      ;Llama a la Macro ImprimeCadena para imprimir msjResul  
        cmp cx,0                    ;Compara CX con 0
        jz ImprimeCero              ;Salta a imprime 0
        jmp ContinuaImprimiendo     ;Salta a ContinuaImprimiendo
        ImprimeCero:
        mov dl,30H                  ;Asigna el 0 ASCII a DL
        mov ah,02                   ;Con la funcion 02 de la Int21
        int 21H                     ;Imprime el Cero
        jmp FinImpresion
        ContinuaImprimiendo:
        mov al,signoResultado ;Asigna a AX el signo (0=+ 1=-)
        cmp al,0            ;Compara AL con 0
        jnz ImpSigno        ;Si no es 0 indica que es un numero negativo
        jmp IniciaImpresion
        ImpSigno:
        mov dl,2DH          ;Asigna a DL el caracter -
        mov ah,02
        int 21h             ;Imprime el signo negativo        
        IniciaImpresion:
        mov ax,0            ;Limpia el registro.
        mov al,ch           ;Asigna a AH la parte Entera del resultado
        mov bl,10H          ;Asigna 10 a BL
        div bl              ;Divida AX entre 10 AL=Cociente,AH=Residuo
        mov bl,ah           ;Mueve el residuo a BL
        mov ah,00H          ;Limpia AH
        push ax             ;Mete el 1er digito Entero a la pila
        mov bh,00H          ;Limpia la parte BH 
        push bx             ;Mete el 2do digito Entero a la pila    
        ImprimeEnteros:
        mov bl,cl           ;Pone los decimales en BL
        pop cx              ;Saca el 1er digito del numero y lo asigna a BX
        pop dx              ;Saca el 2do digito del numero y lo asigna a CX    
        add cx,30H          ;Hace el ajuste a ASCII
        add dx,30H          ;Hace el ajuste a ASCII
        mov ah,02    
        cmp dl,30H          ;Compara que no sea 0
        jz Imprime2doEntero ;Si es 0 no lo imprime y imprime el otro
        int 21h             ;Saca el 1er digito.    
        Imprime2doEntero:
        mov dl,cl            ;Mete el otro digito a DL para imprimirlo
        int 21h              ;Saca el 2do digito.    
        cmp bl,00H           ;Compara si hay decimales
        jnz ImprimeDecimales ;Si hay decimales salta a ImprimeDecimales
        jmp FinImpresion     ;Si no hay decimales Finaliza la impresion    
        ImprimeDecimales:
        mov dl,2EH    ;Asigna a DL=2E (El ".")
        mov ah,02
        int 21H       ;Imprime el punto (".").
        mov ax,0      ;Limpia AX
        mov al,bl     ;Mueve los decimales a AL
        mov bl,10H    ;Asigna 10 a BL
        div bl        ;Divide AL/BL AL=Cociente,AH=Residuo
        mov bl,ah     ;Mueve el residuo a BL
        mov dl,al     ;Mete el digito para imprimirlo
        add dl,30H    ;Hace el ajuste ASCII
        mov ah,02  
        int 21h       ;Imprime el 1er digito.
        mov dl,bl     ;Mueve el segundo decimal a DL
        add dl,30H    ;Convierte a ASCII para imprimir.
        int 21H
        FinImpresion:
        ret;Finaliza el procedimiento de Impresion         
     endp
     ConvierteHexadecimal proc near
        ;Convierte a Digitos un numero de 2 bytes
        mov cl,10H          ;Asigna a CL 10 Hexadecimal.
        mov ch,10D          ;Asigna a CH 10 Decimal
        mov ah,00           ;Limpia AL
        div cl              ;Divide AL entre AH
        mov dl,ah           ;Guarda las unidades en DL
        mov ah,00           ;Limpia AH
        mul ch              ;Multiplica las decenas por 10D
        add al,dl           ;Suma para generar el numero en Hexadecimal.           
        ret
     endp
     ConvierteHexadecimalCompleto proc near
        push ax             ;Guarda el numero a convertir a Hexadecimal en la pila
        mov al,ah           ;Asigna los enteros a AL
        mov ah,00           ;Limpia AH
        mov cl,10H          ;Asigna a CL 10 Hexadecimal.
        div cl              ;Divide Aentre 10H
        mov bl,ah           ;Guarda las unidades en BL
        mov cx,10D          ;Asigna a CH 10 Decimal   
        mov ah,00           ;Limpia AH
        mul cx              ;Multiplica las decenas por 10D
        mul cx              ;Multiplica las decenas por 10D nuevamente
        mul cx              ;Multiplica las decenas por 10D una vez mas
        push ax             ;Guarda el numero en la pila
        mov al,bl           ;Mueve la otra parte del numero a AL
        mov ah,00           ;Limpia AH
        mul cx              ;Multiplica el numero por 10H
        mul cx              ;Multiplica el numero por 10H nuevamente
        pop dx              ;Saca el numero guardado y lo pone en DX
        add dx,ax           ;Suma el numero
        pop ax              ;Asigna a AX el numero que se esta convirtiendo
        mov ah,00           ;Limpia AH
        mov cl,10H          ;Asigna a CL 10H
        div cl              ;Divide AL entre 10H
        mov bl,ah           ;Guarda las decimas menos significativas en BL
        mov cx,10D          ;Asigna a CH 10 Decimal
        push dx             ;Guarda DX en la pila para que no se borre con la multiplicacion
        mov ah,00           ;Limpia AH para poder multiplicar
        mul cx              ;Multiplica las decimas mas significativas por 10D
        pop dx              ;Regresa a DX el dato guardado en la pila
        add al,bl           ;Suma las decimas menos significativas con el producto de las mas significativas
        add ax,dx           ;Suma el numero completo.
        ret
     endp 
     LeyDeSignos proc near
        mov al,num1neg                 ;Asigna a AL el signo del numero1
        mov bl,num2neg                 ;Asigna a BL el signo del numero1
        cmp al,bl                      ;Compara los signos
        jz signosmultiguales           ;Salta si los signos son iguales a signosmultiiguales
        mov signoResultado,1           ;Asigna 1 a signoResultado
        jmp FinLeyDeSignos             ;Salta a FinLeyDeSignos
        signosmultiguales:
        mov signoResultado,0           ;Asigna el signo resultante igual a 0 (0=Positivo).
        FinLeyDeSignos:
        ret
     endp
codigo  ends
    end inicio