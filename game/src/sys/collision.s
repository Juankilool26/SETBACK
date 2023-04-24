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
;; PHYSICS COLLISION
;;

.include "man/entity.h.s"
.include "input.h.s"




;; Comprueba la colision del personaje con una entidad pasada por parametro
;; INPUTS
;;      IX: Puntero a la entidad del player
;;      IY: Puntero a la entidad con la que colisiona
;; DESTROYS
;;      A, BC, D
;; RETURN
;;      0
sys_collision_update_one_entity::

    ;; COLISIONES BOUNDING BOX

_bounding_box_check:
    ;; (x sprite 1 + anchura sprite 1) > x sprite 2
    ld      a, e_x(ix)                                          ; Cargamos en A la posicion x del jugador
    add     e_w(ix)                                             ; Le sumamos su ancho
    dec     a                                                   ; Ajustamos la anchura del bounding box
    sub     e_x(iy)
    jr      c, _no_collision                                    ; Si A - e_x(iy) < 0 No hay colision

    ;; (y sprite 1 + altura sprite 1) > y sprite 2
    ld      a, e_y(ix)
    add     e_h(ix)
    dec     a
    sub     e_y(iy)
    jr      c, _no_collision

    ;; (x sprite 2 + anchura sprite 2) > x sprite 1
    ld      a, e_x(iy)
    add     a, e_w(iy)
    ld      b, e_x(ix)
    inc     b
    cp      b
    jr      c, _no_collision

    ;; (y sprite 2 + altura sprite 2) > y sprite 1
    ld      a, e_y(iy)
    add     a, e_h(iy)
    ld      b, e_y(ix)
    inc     b
    cp      b
    jr      c, _no_collision
    
_si_colision:

    ;; Comprobamos si hemos colisionado con una plataforma
    ld      a, e_type(iy)                                       ; A = Entity type
    and     #e_type_platform                                    ; Comprobamos si el tipo es exactamente una plataforma
    sub     #e_type_platform
    jr     nz, _destroy_entity                                  ; Si no es = 0 el player pierde vida porque es una enemigo o trampa
    ;; PLATAFORMA DETECTADA

    ;; Comprobamos si la plataforma es colisionable o es de ambiente
    ld      a, e_type(iy)
    and     #1                                                  ; Comprobamos si tiene la marca de entidad de ambiente
    call    z, sys_collision_correct_position                   ; Si no la tiene entonce corrige la posicion a la plataforma
    ld      e_state(iy), #1                                     ; Marcamos la entidad que esta colisionando
    
    ;; Marcamos la entidad para renderizar
_platform_detected:
    ld      a, e_type(iy)
    or      #e_type_render_mask                                 ; Le asociamos la componente de render
    ld      e_type(iy), a
    jr      _no_collision_check
    
_destroy_entity:

    ;; Comprobamos si hemos colisionado con el portal
    ld      a, e_type(iy)
    xor     #e_type_portal                                      ; XOR con el portal
    jr     nz, _destroy_player                                  ; if A=0
    ld      e_type(iy), #e_type_dead_mask                       ; Destruimos portal y pasamos de nivel
    jr      _no_collision_check
_destroy_player:
    ld      e_type(ix), #e_type_dead_mask                       ; e_type = e_type_dead_mask para el player
    call    man_entity_set4destruction                          ; Marcamos la trampa como muerta y renderizable tambien
    jr      _no_collision_check

_no_collision:

    ld      a, e_state(iy)
    dec     a
    ret    nz
    ld      e_state(iy), #0
    jr      _platform_detected
_no_collision_check:
    ret






;; Corrige la posicion del personaje colisionado con respecto a la otra entidad para caer sobre una plataforma
;; INPUTS
;;      IY: Puntero a la entidad con la que colisiona
;;      HL: Posicion anterior de la entidad (h=y and l=x)
;; DESTROYS
;;      0
;; RETURN
;;      0
sys_collision_correct_position::

    ;; Comprobamos que el personaje se situa arriba de la plataforma
    ld      a, e_y(ix)
    ;add     a, e_h(ix)
    ld      b, e_y(iy)
    cp      b
    jr     nc, finish_check

    ;; Comprobamos que la gravedad es positiva (hacia abajo)
    ld      a, #gravity_acc
    add     e_vy(ix)
    jr      c, finish_check

    ;; Corregimos la posicion del personaje
correct_top:
    ld      a, e_y(iy)
    sub     e_h(ix)
    ld      e_y(ix), a
    ld      e_vy(ix), #0
    ld      e_jump(ix), #1
    
finish_check:
    ret







;; Comprueba la colision del personaje con las demas entidades
;; INPUTS
;;      IX: Puntero a la entidad a dibujar
;; DESTROYS
;;      A, BC, DE
;; RETURN
;;      HL: Posicion anterior
sys_collision_update::

    ;; Colision del personaje con las plataformas, trampas y enemigos
    ld      hl, #sys_collision_update_one_entity                ; Guardamos en IY un puntero a la rutina
    ld       a, #e_type_collide_mask                            ; Actualizamos la colision con las plataformas
    call    man_entity_update_forall_matching                   ; Llamamos a la funcion de actualizar

    ret