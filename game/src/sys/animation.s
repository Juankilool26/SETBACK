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
;; ANIMATION SYSTEM
;;

.include "man/entity.h.s"
.include "assets/assets.h.s"






;sys_animation_init::
;    ret






;; Funcion para actualizar la animacion del player
;; INPUTS
;;      IX: Puntero a la entidad del player
;; DESTROYS
;;      A
;; RETURN
;;      0
sys_animation_update::

    ;; Comprobamos si el jugador ha muerto y cambiamos su animacion
    ld      a, e_type(ix)
    xor     #e_type_dead_mask
    jr     nz, _check_animation
    ld      hl, #_protagonista_sp_3
    ld      e_sp_l(ix), l                 ; Cambiamos a la animacion de muerte
    ld      e_sp_h(ix), h
    jr      _finish_animation


    ;; Cambiamos la animacion para el movimiento del player
_check_animation:
    ld      a, e_jump(ix)                                     ; Si no tiene la capacidad de saltar entonces esta en el aire
    dec     a
    jr      z, _check_side
    ld      hl, #_protagonista_sp_2
    ld      e_sp_l(ix), l                 ; Cambiamos a la animacion de salto
    ld      e_sp_h(ix), h                  ; Sprite de salto
    jr      _finish_animation
_check_side:
    ld      a, e_state(ix)                                    ; Comprobamos si gira a la derecha
    dec     a
    jr     nz, _check_right
    ld      hl, #_protagonista_sp_0
    ld      e_sp_l(ix), l                 ; Cambiamos a la animacion de izquierda
    ld      e_sp_h(ix), h                   ; Sprite derecha
    jr      _finish_animation
_check_right:
    ld      hl, #_protagonista_sp_1
    ld      e_sp_l(ix), l                 ; Cambiamos a la animacion de derecha
    ld      e_sp_h(ix), h                   ; Sprite izquierda

_finish_animation:
    ret