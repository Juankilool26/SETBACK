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
;; RENDER SYSTEM
;;

.include "cpctelera_functions.h.s"
.include "man/entity.h.s"
.include "render.h.s"
.include "assets/assets.h.s"
.include "cpctelera.h.s"






;; Definimos la paleta de colores
;; PALETTE_FIRMWARE=0 1 2 3     6 9 11 12       13 15 16 18     20 24 25 26
;palette:
;    .db HW_BLACK        ,   HW_BLUE             ,   HW_BRIGHT_BLUE      ,   HW_RED
;    .db HW_BRIGHT_RED   ,   HW_GREEN            ,   HW_SKY_BLUE         ,   HW_YELLOW
;    .db HW_WHITE        ,   HW_ORANGE           ,   HW_PINK             ,   HW_BRIGHT_GREEN
;    .db HW_BRIGHT_CYAN  ,   HW_BRIGHT_YELLOW    ,   HW_PASTEL_YELLOW    ,   HW_BRIGHT_WHITE







;; Inicializa el sistema de render
;; INPUT
;;      0
;; DESTROY
;;      C, HL, DE
;; RETURN
;;      0
sys_render_init::

    ;; Cambia a MODE 0
    ld      c, #0
    call cpct_setVideoMode_asm

    ;; BORDER 13, SET PALETTE
    cpctm_setBorder_asm  HW_BLACK                  ; Macro de la libreria de CPCTelera
    ld      hl, #_protagonista_pal                 ; Cragamos la paleta del marcianito
    ld      de, #16
    call    cpct_setPalette_asm
    ret









;; Renderiza la entidad pasada por parametro con color de fondo
;; INPUT
;;      IY: Posicion de la entidad a renderizar
;; DESTROY
;;      AF, DE, BC, HL
;; RETURN
;;      0
sys_render_update_one_entity_clear::

    ld      e, e_lastPtr  (iy)      ; Cargamos en DE el puntero a la anterior instancia pintada
    ld      d, e_lastPtr+1(iy)
    ld      a, #0x00                ; Cargamos en A el color de fondo
    ld      c, e_w(iy)              ; Ancho/Width
    ld      b, e_h(iy)              ; Alto/Height
    call cpct_drawSolidBox_asm
    ret









;; Renderiza la entidad pasada por parametro
;; INPUT
;;      IY: Posicion de la entidad a renderizar
;; DESTROY
;;      AF, DE, BC, HL
;; RETURN
;;      0
sys_render_update_one_entity::


    ;; Comprobamos si la entidad es una estrella de fondo
    ld      a, e_type(iy)                                   ; A = e_type
    xor     #(e_type_render_mask | e_type_star)             ; Estrella renderizada renderizada
    jr     nz, _render_update_entity                       ; Si = 0 no es una plataforma

    ;; ESTRELLA DETECTADA
    ld      a, e_distance(iy)
    dec     a
    jr     nz, _render_mark_star
    dec     e_distance(iy)
    jr      _stop_render_entity
_render_mark_star:
    inc     e_distance(iy)

    
_render_update_entity:

    ;; Eliminamos la instacia previa con el color de fondo
    call    sys_render_update_one_entity_clear


    ;; Obtenemos el HL el puntero a la posicion de memoria a pintar
    ld     de, #screen_start                                ; Cargamos en DE la posicion inicial de la pantalla
    ld      c, e_x(iy)                                      ; X
    ld      b, e_y(iy)                                      ; Y
    call cpct_getScreenPtr_asm                              ; Calculate video memory location and return it in HL
    

    ;; Dibujamos la nueva posicion
    ex     de, hl
    ld      l, e_sp_l(iy)
    ld      h, e_sp_h(iy)
    ld      c, e_w(iy)                                      ; Ancho/Width
    ld      b, e_h(iy)                                      ; Alto/Height
    call cpct_drawSprite_asm                                ; Rutina de cpctelera que realiza 3 push y 1 pop


    ;; Comprobamos si es una plataforma y dejamos de pintarla
_render_check_platform:
    ld      a, e_type(iy)                                   ; A = e_type
    xor     #(e_type_render_mask | e_type_platform)         ; Plataforma renderizada
    jr     nz, _stop_render_entity                          ; Si = 0 no es una plataforma

    ;; PLATAFORMA DETECTADA
    ld      a, e_type(iy)
    xor     #e_type_render_mask                             ; Quitamos su capacidad de renderizado
    ld      e_type(iy), a

_stop_render_entity:
    ret










;; Renderiza todas las entidades
;; INPUT
;;      0
;; DESTROY
;;      AF, BC, HL, IX, IY
;; RETURN
;;      IX: Puntero a primera entidad libre del array
sys_render_update_all::
    ld      hl, #sys_render_update_one_entity                   ; Guardamos en IY un puntero a la rutina
    call    man_entity_update_forall                            ; Renderizamos todas las entidades
    ret








;; Renderiza solo las entidades que se superponen (plataformas y jugador)
;; INPUT
;;      0
;; DESTROY
;;      AF, BC, HL, IX, IY
;; RETURN
;;      IX: Puntero a primera entidad libre del array
sys_render_update::

    ;; Renderizamos todas las entidades de ambiente
    ld      hl, #sys_render_update_one_entity                   ; Guardamos en IY un puntero a la rutina
    ld       a, #1                                              ; Actualizamos la colision con las estrellas
    call    man_entity_update_forall_matching                   ; Llamamos a la funcion de actualizar

    ;; Renderizamos al player
    ld      a, #0
    call    man_entity_get_from_idx_IY
    call    sys_render_update_one_entity

    ;; Renderizamos todas las entidades de interaccion
    ld      hl, #sys_render_update_one_entity                   ; Guardamos en IY un puntero a la rutina
    ld       a, #e_type_render_mask                             ; Actualizamos la colision con las plataformas
    call    man_entity_update_forall_matching                   ; Llamamos a la funcion de actualizar
    ret








;; Borra el player y las entidades muertas (enemigos)
;; INPUT
;;      0
;; DESTROY
;;      AF, BC, HL, IX, IY
;; RETURN
;;      IX: Puntero a primera entidad libre del array
sys_render_update_clear::

    ;; Borramos al enemigo
    ld      a, #0
    call    man_entity_get_from_idx_IY
    call    sys_render_update_one_entity_clear

    ;; Borramos las entidades muertas
    ld      hl, #sys_render_update_one_entity_clear             ; Guardamos en IY un puntero a la rutina
    ld       a, #e_type_dead_mask                             ; Actualizamos la colision con las plataformas
    call    man_entity_update_forall_matching                   ; Llamamos a la funcion de actualizar
    ret