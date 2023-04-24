;; This file is part of SETBACK.
;; Copyright (C) 2020 TCore (@TCore14)
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see https://www.gnu.org/licenses/.

;;
;; PHYSICS SYSTEM
;;

.include "cpctelera_functions.h.s"
.include "man/entity.h.s"
.include "render.h.s"
.include "input.h.s"




;; CONSTANTS
screen_width  = 80
screen_height = 200






;; Actualiza las fisicas de la entidad pasada por parametro
;; INPUTS
;;      IY: puntero a la entidad actualizar
;; DESTROYS
;;      AF, BC, DE
;; RETURN
;;      HL: Posicion anterior
sys_physics_calculate_previous_position::

    ;; Averiguamos la posicion de memoria anterior que se pinta para borrarla en el render
    ld     de, #screen_start      ; DE = Pointer to start of the screen
    ld      c, e_x(iy)            ; x
    ld      b, e_y(iy)            ; y
    call   cpct_getScreenPtr_asm
    ld     e_lastPtr  (iy), l
    ld     e_lastPtr+1(iy), h
    ret









;; Actualiza las fisicas de la entidad pasada por parametro
;; INPUTS
;;      IY: puntero a la entidad actualizar
;; DESTROYS
;;      AF, BC, DE
;; RETURN
;;      HL: Posicion anterior
sys_physics_update_one_entity::

    ;; Guardamos la posicion de memoria anterior
    call    sys_physics_calculate_previous_position
    
    ;; Devolvemos la posicion actual en Y
    ld      h, e_y(iy)           ; y

    ;; ACTUALIZAMOS X
    ;; Comprobamos la posicion en el eje x que puede moverse como maximo
    ld      a, #screen_width
    sub     e_w(iy)
    ld      c, a                ; C contiene la maxima posicion x

    ld      a, e_x(iy)          ; Guardamos en A la posicion
    add     e_vx(iy)            ; Le sumamos la velocidad
    cp      c                   ; y le restamos el total del ancho de la ventana
    jr      nc, invalid_x       ; Si produce acarreo es una posicion valida
valid_x:
    ld      e_x(iy), a          ; Nos guardamos la nueva posicion
    jr      endif_x
invalid_x:                      ; Si no produce accarreo comprobamos el borde
    ld      a, e_vx(iy)
    ld      b, e_vx(iy)         ; Guardamos en B y A la velocidad para resetear posiciones
    add     a, b                ; Sumamos velocidades
    jr      c, start_x          ; Produce acarreo si la velocidad es negativa
end_x:
    ld      e_x(iy), c
    jr      endif_x
start_x:
    ld      e_x(iy), #0
endif_x:


    ;; ACTUALIZAMOS Y
    inc     e_vy(iy)            ; Incrementamos la velocidad del jugador en y

    ;; Cambiamos la posicion
    ld      a, e_y(iy)          ; Cargamos en A la velocidad
    add     e_vy(iy)            ; Le sumamos la velocidad para dar el efecto de gravedad y movimiento
    ld      e_y(iy), a          ; Guardamos la nueva posicion para renderizar
    ld      c, a                ; Guardamos la nueva posicion en C temporalmente


    ;; Aseguramos que la gravedad no aumente la velocidad para siempre
    ld      a, e_vy(iy)
    add     #gravity_acc        ; Si v_actual-v_inicial != 0
    jr     nz, _keep_speed      ; No decrementes la velocidad
_change_speed:
    dec     e_vy(iy)
_keep_speed:


    ;; Comprobamos que no salga de la pantalla
    ;; if  e_y < (screen_height - e_h) Se sale por abajo
    ld      a, #screen_height           ; Guardamos en A el alto de la pantalla
    sub     e_h(iy)                     ; Le restamos el alto del personaje
    ld      b, a                        ; y lo guardamos en B
    ld      a, #256                     ; Guardamos en A el total de valores representado con un byte (0-255 -> 256)
    sub     b                           ; Le restamos la maxima posicion en y que puede alcanzar el pj guardado en B
    add     c                           ; Le sumamos la nueva posicion del objeto
    ret     nc                          ; Si la operacion no produce acarreo entonces es valida e_y

    ;; Comprobamos si el personaje ha salido de la pantalla por arriba o por abajo
    ld      a, h                        ; A = Anterior posicion en Y
    cp      #100                        ; A = A - 100 (mitad de alto de la pantalla)
    jr     nc, _invalid_y_bottom

_invalid_y_top:
    ld      e_y(iy),#0
    ld      e_vy(iy), #0                ; Cambiamos la velocidad a 0 para que no se pueda mover
    jr      _end_update_physics

_invalid_y_bottom:
    ld      e_vy(iy), #0                ; Cambiamos la velocidad a 0 para que no se pueda mover
    ld      a, b                        ; Y posicionamos al fondo de la pantalla
    ld      e_y(iy), a
    ld      e_jump(iy), #1              ; Permitimos al player saltar

_end_update_physics:
    ret







;; Actualiza las fisicas de todas las entidades
;; INPUT
;;      0
;; DESTROY
;;      AF, BC, HL, IX, IY
;; RETURN
;;      IX: Puntero a la primera entidad libre del array
sys_physics_update::

    ;; Actualizamos las fisicas del jugador
    ld      a, #0                                               ; Posicion del player en el array
    call    man_entity_get_from_idx_IY                          ; Guardamos su puntero en IY
    call    sys_physics_update_one_entity

    ;; Actualizamos las fisicas de las entidades
    ;ld      hl, #sys_physics_update_one_entity                  ; Guardamos en IY un puntero a la rutina
    ;ld       a, #e_type_physics_mask                            ; Actualizamos las fisicas de los personajes
    ;call    man_entity_update_forall_matching                   ; Llamamos a la funcion de actualizar
    ret