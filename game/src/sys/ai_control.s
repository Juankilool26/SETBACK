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
;; AI CONTROL SYSTEM
;;

.include "man/entity.h.s"
.include "physics.h.s"
.include "ai_control.h.s"
.include "assets/assets.h.s"




;; CONSTANTES
;_add_op = 0xC6                  ; Operacion de suma al registro A
;_sub_op = 0xD6                  ; Operacion de resta al registro A




;; Actualiza la posicion de un enemigo
;; INPUTS
;;      IY: puntero a la entidad actualizar
;; DESTROYS
;;      AF, DE
;; RETURN
;;      0
sys_ai_control_update_one_entity::

    call    sys_physics_calculate_previous_position     ; Calculamos la instancia previa

    ;; COMPRUEBA EL SENTIDO DEL RECORRIDO

    ;;; IZQUIERDA
    ;;_operation = _add_op                                ; Especificamos la operacion de movimiento
    ;;e_eje = e_x                                         ; Especificamos el eje en el que nos movemos
    ;ld      a, e_x(iy)
    ;ld      (_axis_movement), a
    ;ld      d, #-1                                       ; D = Desplazamiento dentro del rango permitido
    ;ld      e, #-1                                       ; E = Desplazamiento en su posicion real
    ;ld      e_sp_l(iy), #_tiles_sp_4                    ; Asociamos el sprite para la direccion y sentido del npc
    ;ld      a, e_walking(iy)                            ; A = Velocidad del enemigo
    ;inc     a
    ;jr      z, _ai_check_side
    ;
    ;;; DERECHA
   ;; _operation = _sub_op
    ;ld      d, #1
    ;ld      e, #1
    ;ld      e_sp_l(iy), #_tiles_sp_5
    ;ld      a, e_walking(iy)
    ;dec     a
    ;jr      z, _ai_check_side2
;
    ;;; ARRIBA
    ;;_operation = _sub_op
    ;;e_eje = e_y
    ;ld      h, #e_y
    ;ld      d, #-1
    ;ld      e, #-1
    ;ld      e_sp_l(iy), #_tiles_sp_4
    ;ld      a, e_walking(iy)
    ;inc     a
    ;inc     a
    ;jr      z, _ai_check_side
    ;
    ;;; ARRIBA RAPIDO
    ;ld      e, #-2
    ;inc     a
    ;jr      z, _ai_check_side
;
    ;;; ABAJO
    ;;_operation = _add_op
    ;ld      d, #1
    ;ld      e, #1
    ;ld      e_sp_l(iy), #_tiles_sp_5
    ;ld      a, e_walking(iy)
    ;dec     a
    ;dec     a
    ;jr      z, _ai_check_side2
;
    ;;; ABAJO RAPIDO
    ;ld      e, #2
    ;jr      z, _ai_check_side2
    ;



;_ai_check_side:
;
;    ;ld      a, (_operation)
;    ;ld      (_operation_code), a                   ; Registramos la operacion a realizar
;    ld      a, e_vx(iy)                             ; A = Posicion dentro del rango de movimiento
;
;    ;; Modificamos la posicion de los enemigos los enemigos
;;_operation_code = .
;    add     e_distance(iy)                          ; Comprobamos si hemos alcanzado el limite del rango de movimiento
;    jr      z, _ai_change_side                      ; y cambiamos el sentido
;
;    ;; Rango de movimiento de patrulla
;    ld      a, e_vx(iy)                             ; A = Posicion dentro del rango de movimiento
;    add     a, d                                    ; Modificamos la posicion dentro del rango de movimiento
;    ld      e_vx(iy), a
;
;    ;; Posicion real del npc
;_axis_movement = . + 1
;    ld      a, #00                                  ; Hacemos lo propio con la posicion real del personaje
;    add     a, e
;    ld     (_axis_movement), a
;
;    jr      _ai_finish_check
;_ai_change_side:
;
;    ;; Cambiamos el sentido del movimiento
;    ld      a, e_walking(iy)
;    neg                                             ; Cambiar el sentido es el mismo pero negado (cambiado de signo)
;    ld      e_walking(iy), a
;    jr      _ai_finish_check


    ;; Comprueba el sentido del recorrido
    ld      a, e_walking(iy)                            ; A = Velocidad del enemigo
    add     #-1
    jp      z, _ai_check_right

    ld      a, e_walking(iy)
    add     #1
    jp      z, _ai_check_left

    ld      a, e_walking(iy)
    add     #-2
    jp      z, _ai_check_bot

    dec     a
    jp      z, _ai_check_bot_fast

    ld      a, e_walking(iy)
    add     #2
    jp      z, _ai_check_top

    inc     a
    jp      z, _ai_check_top_fast


    ;; Modificamos los enemigos
    ;; IZQUIERDA
_ai_check_left:
    ld      a, e_vx(iy)
    add     e_distance(iy)
    jr      z, _ai_change_right
    dec     e_vx(iy)
    dec     e_x(iy)
    jp      _ai_finish_check
_ai_change_right:
    ld      hl, #_tiles_sp_05
    ld      e_sp_l(iy), l
    ld      e_sp_h(iy), h
    ld      e_walking(iy), #1
    jp      _ai_finish_check

    ;; DERECHA
_ai_check_right:
    ld      a, e_vx(iy)
    cp      e_distance(iy)
    jr      z, _ai_change_left
    inc     e_vx(iy)
    inc     e_x(iy)
    jp      _ai_finish_check
_ai_change_left:
    ld      hl, #_tiles_sp_04
    ld      e_sp_l(iy), l
    ld      e_sp_h(iy), h
    ld      e_walking(iy), #-1
    jp      _ai_finish_check

    ;; ARRIBA
_ai_check_top:
    ld      a, e_vy(iy)
    add     e_distance(iy)
    jr      z, _ai_change_bot
    dec     e_vy(iy)
    dec     e_y(iy)
    jp      _ai_finish_check
_ai_change_bot:
    ld      hl, #_tiles_sp_07
    ld      e_sp_l(iy), l
    ld      e_sp_h(iy), h
    ld      e_walking(iy), #2
    jr      _ai_finish_check

    ;; ABAJO
_ai_check_bot:
    ld      a, e_vy(iy)
    cp      e_distance(iy)
    jr      z, _ai_change_top
    inc     e_vy(iy)
    inc     e_y(iy)
    jr      _ai_finish_check
_ai_change_top:
    ld      hl, #_tiles_sp_06
    ld      e_sp_l(iy), l
    ld      e_sp_h(iy), h
    ld      e_walking(iy), #-2
    jp      _ai_finish_check


    ;; ARRIBA RAPIDO
_ai_check_top_fast:
    ld      a, e_vy(iy)
    add     e_distance(iy)
    jr      z, _ai_change_bot_fast
    dec     e_vy(iy)
    dec     e_y(iy)
    dec     e_y(iy)
    jr      _ai_finish_check
_ai_change_bot_fast:
    ld      hl, #_tiles_sp_08
    ld      e_sp_l(iy), l
    ld      e_sp_h(iy), h
    ld      e_walking(iy), #3
    jr      _ai_finish_check

    ;; ABAJO LENTO
_ai_check_bot_fast:
    ld      a, e_vy(iy)
    cp      e_distance(iy)
    jr      z, _ai_change_top_fast
    inc     e_vy(iy)
    inc     e_y(iy)
    inc     e_y(iy)
    jr      _ai_finish_check
_ai_change_top_fast:
    ld      hl, #_tiles_sp_09
    ld      e_sp_l(iy), l
    ld      e_sp_h(iy), h
    ld      e_walking(iy), #-3



_ai_finish_check:
    ret









;; Actualiza la posicion de todos los enemigos que poseen IA
;; INPUTS
;;      0
;; DESTROYS
;;      AF, BC, HL, IX, IY
;; RETURN
;;      HL: Posicion anterior
sys_ai_control_update::

    ld     hl, #sys_ai_control_update_one_entity
    ld      a, #e_type_alive_mask                       ; Todos los enemigos que se mueven estan vivos
    call    man_entity_update_forall_matching
    ret

