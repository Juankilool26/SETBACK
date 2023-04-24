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
;; ENTITY MANAGER
;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.globl man_entity_init
.globl man_entity_create
.globl man_entity_getPlayer_IX
.globl man_entity_get_from_idx_IY
.globl man_entity_update_forall
.globl man_entity_update_forall_matching
.globl man_entity_calculate_screen_position
.globl man_entity_set4destruction
.globl man_entity_destroy_one
.globl man_entity_empty_array







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; DEFINICIONES MACROS ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Entity definicion anonima de macro
.macro DefineEntityAnnonimous _type, _x, _y, _vx, _vy, _w, _h, _sprite, _jump, _lastPtr, _state, _walking, _distance
   .db _type
   .db _x
   .db _y
   .db _vx
   .db _vy
   .db _w
   .db _h
   .dw _sprite
   .db _jump
   .dw _lastPtr
   .db _state        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                     ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   .db _walking      ; y para guardar el estado de la IA de los enemigos
   .db _distance     ; Maxima distancia recorrida por los enemigos
                     ; y booleano para comprobar si es una plataforma o una estrella
.endm


;; Definimos una entidad identificada por su etiqueta nombre
.macro DefineEntity _name, _type, _x, _y, _vx, _vy, _w, _h, _sprite, _jump, _lastPtr, _state, _walking, _distance
_name::
   DefineEntityAnnonimous _type, _x, _y, _vx, _vy, _w, _h, _sprite, _jump, _lastPtr, _state, _walking, _distance
.endm


;; Definimos un array de entidades anonimas
.macro DefineEntityArray _name, _N
_name::
   .rept _N
      DefineEntityAnnonimous 0x00, 0xDE, 0xAD, 0xDE, 0xAD, 0xDE, 0xAD, 0xDE00, 0xAD, 0xC000, 0x00, 0x00, 0x00
   .endm
.endm







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; TIPOS DE ENTIDADES ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Numero de bits para la mascara
e_type_alive_bit    = 7
e_type_physics_bit  = 6
e_type_render_bit   = 5
e_type_collider_bit = 4
e_type_input_bit    = 3
e_type_dead_bit     = 2
e_type_portal_bit   = 1

;; Tipos de entidades (mascaras)
e_type_invalid      = 0x00
e_type_alive_mask   = (1 << e_type_alive_bit)
e_type_physics_mask = (1 << e_type_physics_bit)
e_type_render_mask  = (1 << e_type_render_bit)
e_type_collide_mask = (1 << e_type_collider_bit)
e_type_input_mask   = (1 << e_type_input_bit)
e_type_dead_mask    = (1 << e_type_dead_bit)
e_type_portal_mask  = (1 << e_type_portal_bit)


;; Entidades especificas
e_type_character = e_type_physics_mask | e_type_collide_mask | e_type_render_mask
e_type_player    = e_type_character | e_type_input_mask
e_type_trap      = e_type_collide_mask
e_type_platform  = e_type_trap | e_type_input_mask
e_type_enemy     = e_type_trap | e_type_alive_mask | e_type_render_mask
e_type_portal    = e_type_trap | e_type_portal_mask
e_type_star      = e_type_platform | 1






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; CONSTANTES ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constantes para posicionar cada componente de la entidad usando los registros IX e IY
e_type     = 0
e_x        = 1
e_y        = 2
e_vx       = 3
e_vy       = 4
e_w        = 5
e_h        = 6
e_sp_l     = 7
e_sp_h     = 8
e_jump     = 9
e_lastPtr  = 10
e_state    = 12
e_walking  = 13
e_distance = 14
sizeof_e   = 15
