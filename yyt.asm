; ============================================
; MÓDULO: Validador de Acceso Condicional
; PROBLEMA: Decidir qué mensaje mostrar según comparación
; SOLUCIÓN: cmp + je + dos ramas de ejecución
; ============================================

; ################################################################################
; [ZONA DE ALMACENAMIENTO] - SECTION .DATA
; Aquí guardamos los letreros de madera ya escritos antes de activar el circuito.
; ################################################################################

section .data

    ;#############################################################################################################
    ; db (Define Byte): Creas un letrero de madera con textO rl '10' es un bloque de aire abajo (salto de línea).
    ;#############################################################################################################
    
    msg_ok      db "Codigo correcto", 10  
    
    ;###########################################################################################
    ; equ: Calcula los bloques de espacio que ocupará el texto en el chat para que no se buguee.
    ;###########################################################################################
    
    len_ok      equ $ - msg_ok        

    msg_err     db "Codigo incorrecto", 10
    len_err     equ $ - msg_err

; ################################################################################
; [ZONA DE MECANISMOS] - SECTION .TEXT                                         #
; Esta es la fila de Command Blocks.                                           #
; La Redstone pasará por aquí activando un bloque tras otro.                   #
; ################################################################################

section .text

    ;###############################################################################################################
    ; # global _start: Es la palanca o boton principal del mapa. Le dice al juego dónde inicia el mecanismo        #
    ; # esto es un puto de entrada total mente obligatorio                                                         #
    ;###############################################################################################################
    
    global _start                     

_start: ; <-- ¡Aquí se presiona la palanca e inicia la señal de Redstone!

    ; ###########################################################################################
    ; FASE 1: SLOT DE LA HOTBAR (Configuración de objetos)                                      #
    ; Usamos 'mov' como el comando /item replace para poner papeles con la contraseña en tu mano#
    ; RAX y RBX son los Slots 1 y 2 de tu Barra de acceso rápido.                               #
    ; ###########################################################################################
    
    mov rax, 1926       ; Pones un papel con la contraseña maestra (1234) en el Slot RAX (Slot 1).
    mov rbx, 1926       ; El jugador presiona botones y pone un papel con el número 1234 en el Slot RBX (Slot 2).
    mov rbx, 1245       ; ¡Espera! Cambió de opinión, borró el anterior y metió un papel con el número 9999 en el Slot RBX.
    
    ; ############################################################################
    ; FASE 2:Comparador de Redstone  (Comparación)                               #
    ; 'cmp' es un Comparador físico de Redstone pegado a tus dos manos RAX y RBX.#
    ; Compara si los números de los dos papeles son idénticos.                   #
    ; ############################################################################
    
    cmp rax, rbx              ;CPU calcula: rax - rbx y guarda el resultado en flags
                              ;Si son iguales → Flag ZF (Zero Flag) = 1
                              ;Si son diferentes → Flag ZF = 0
    ; #######################################################################################
    ; FASE 3: PISTÓN DE DESVÍO (Decisión)                                                   #
    ; 'je' es un Pistón Adhesivo que reacciona a la energía del Comparador de arriba.       #
    ; Si el comparador estuviera encendido (códigos iguales), el pistón empujaría un bloque.#
    ; #######################################################################################
    
    je codigo_correcto  ; je = "Jump if Equal": salta a la etiqueta si ZF = 1
                        ; Si coinciden, salta a la sección de éxito

    ; #######################################################################################
    ; [Rama A] - RAMA DE ERROR (Código Incorrecto)
    ; La Redstone camina por aquí porque el pistón NO se movió (los códigos no coincidieron).
    ; #######################################################################################
    
    mov rax, 1          ; Número de syscall: 1 = write (manda instruccion de enviar texto al chat)
    mov rdi, 1          ; Primer argumento: 1 = stdout (mandarlo al chat publico (pantalla) )
    mov rsi, msg_err    ; Segundo argumento: dirección del mensaje(Abre el cofre de datos y saca el letrero que dice "Codigo incorrecto")
    mov rdx, len_err    ; Tercer argumento: cuántos bytes escribir(medidas del taamaño de el letrero)
    syscall             ; ¡Ejecuta la petición al kernel de Linux!(manda el texto al chat)

    jmp fin_programa    ; Un camino de Redstone directo que te saca del circuito para no activar el texto  "correcto".

; ###########################################################################################
; [Rama B] - RAMA DE ERROR (Código Correcto)
;  El pistón de desvío 'je' mandaría la energía directo aquí si la contraseña fuera idéntica.#
; ###########################################################################################
codigo_correcto:
   mov rax, 1          ; syscall: write(Enviar texto al chat)
    mov rdi, 1          ; stdout(Destino: Chat público del servidor)
    mov rsi, msg_ok     ; dirección del mensaje de éxito(Abre el cofre de datos y saca el letrero que dice "Codigo correcto")
    mov rdx, len_ok     ; longitud calculada(calcula el tamaño de le letrero)
    syscall             ; Imprime codigo correcto

; ##############################################################################
; FASE 4: APAGAR EL SERVIDOR DE FORMA SEGURA (Finalización)                    #
; Aquí se vuelven a juntar los caminos de Redstone. Si el circuito no se corta,#
; los bloques se quedan en un bucle infinito, causan lag y tiran el servidor.  #
; ##############################################################################
fin_programa:
    mov rax, 60         ; Número de syscall: 60 = exit (terminar)
    mov rdi, 0          ; Argumento: 0 = éxito (código de salida)
    syscall             ; Notifica al SO que terminó y libera recursos