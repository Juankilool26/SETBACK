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
;; INPUT SYSTEM
;;

.include "input.h.s"
.include "man/entity.h.s"
.include "cpctelera_functions.h.s"
.include "cpctelera.h.s"







;; Inicializa el sistema de input
;sys_input_init::
;    ret





;; Actualiza el sistema de input
;; INPUTS
;;      IX: Puntero a la entidad del player
;; DESTROYS
;;      A, D, BC, HL
;; RETURN
;;      0
sys_input_update::

    ;; Resetea las velocidades
    ld      e_vx(ix), #0


    ;; Escanea el teclado
    call cpct_scanKeyboard_f_asm    ; Guarda la informacion en un buffer y es un poco mas rapida que la funcion normal


    ;; MOVIMIENTO A LA IZQUIERDA
    ;; Comprobamos si las teclas estan pulsadas
    ld      hl, #Key_O              ; Carga el codigo de la tecla O
    call cpct_isKeyPressed_asm      ; Devuelve 0 si no esta pulsada y 1 si lo esta
    jr      z, O_NotPressed
O_Pressed:
    ld      e_vx(ix), #-1           ; Velocidad negativa
    ld      e_state(ix), #-1        ; El estado del jugador es mirando hacia la izquierda
O_NotPressed:

    ld      hl, #Joy0_Left            ; Carga el codigo de la tecla A
    call cpct_isKeyPressed_asm      ; Devuelve 0 si no esta pulsada y 1 si lo esta
    jr      z, Joy0_Left_NotPressed
Joy0_Left_Pressed:
    ld      e_vx(ix), #-1           ; Velocidad negativa
    ld      e_state(ix), #-1        ; El estado del jugador es mirando hacia la izquierda
Joy0_Left_NotPressed:


    ;; MOVIMIENTO A LA DERECHA
    ld      hl, #Key_P              ; Carga el codigo de la tecla P
    call cpct_isKeyPressed_asm      ; Devuelve 0 si no esta pulsada y 1 si lo esta
    jr      z, P_NotPressed
P_Pressed:
    ld      e_vx(ix), #1            ; Velocidad negativa
    ld      e_state(ix), #1         ; El estado del jugador es mirando hacia la derecha
P_NotPressed:

    ld      hl, #Joy0_Right         ; Carga el codigo de la tecla D
    call cpct_isKeyPressed_asm      ; Devuelve 0 si no esta pulsada y 1 si lo esta
    jr      z, Joy0_Right_NotPressed
Joy0_Right_Pressed:
    ld      e_vx(ix), #1            ; Velocidad negativa
    ld      e_state(ix), #1         ; El estado del jugador es mirando hacia la derecha
Joy0_Right_NotPressed:


    ;; MOVIMIENTO HACIA ARRIBA
    dec     e_jump(ix)              ; Decrementamos el bool del salto
    ret    nz                       ; if e_jump = 0 puede saltar

    ld      hl, #Key_Q              ; Carga el codigo de la tecla Q
    call cpct_isKeyPressed_asm      ; Devuelve 0 si no esta pulsada y 1 si lo esta
    jr      z, Q_NotPressed
Q_Pressed:
    ld      e_vy(ix), #gravity_acc  ; Velocidad negativa
Q_NotPressed:

    ld      hl, #Joy0_Fire1         ; Carga el codigo de la tecla Fire1
    call cpct_isKeyPressed_asm      ; Devuelve 0 si no esta pulsada y 1 si lo esta
    jr      z, Joy0_Fire1_NotPressed
Joy0_Fire1_Pressed:
    ld      e_vy(ix), #gravity_acc  ; Velocidad negativa
Joy0_Fire1_NotPressed:

    ret