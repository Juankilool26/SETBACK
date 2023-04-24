ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 ;; This file is part of SETBACK.
                              2 ;; Copyright (C) 2020 TCore (@TCore14)
                              3 ;;
                              4 ;; This program is free software: you can redistribute it and/or modify
                              5 ;; it under the terms of the GNU General Public License as published by
                              6 ;; the Free Software Foundation, either version 3 of the License, or
                              7 ;; (at your option) any later version.
                              8 ;;
                              9 ;; This program is distributed in the hope that it will be useful,
                             10 ;; but WITHOUT ANY WARRANTY; without even the implied warranty of
                             11 ;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             12 ;; GNU General Public License for more details.
                             13 ;;
                             14 ;; You should have received a copy of the GNU General Public License
                             15 ;; along with this program.  If not, see https://www.gnu.org/licenses/.
                             16 
                             17 ;;
                             18 ;; ENTITY MANAGER
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl man_entity_init
                             27 .globl man_entity_create
                             28 .globl man_entity_getPlayer_IX
                             29 .globl man_entity_get_from_idx_IY
                             30 .globl man_entity_update_forall
                             31 .globl man_entity_update_forall_matching
                             32 .globl man_entity_calculate_screen_position
                             33 .globl man_entity_set4destruction
                             34 .globl man_entity_destroy_one
                             35 .globl man_entity_empty_array
                             36 
                             37 
                             38 
                             39 
                             40 
                             41 
                             42 
                             43 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             44 ;;;;;;;;;;; DEFINICIONES MACROS ;;;;;;;;;;;;;;
                             45 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             46 
                             47 ;; Entity definicion anonima de macro
                             48 .macro DefineEntityAnnonimous _type, _x, _y, _vx, _vy, _w, _h, _sprite, _jump, _lastPtr, _state, _walking, _distance
                             49    .db _type
                             50    .db _x
                             51    .db _y
                             52    .db _vx
                             53    .db _vy
                             54    .db _w
                             55    .db _h
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             56    .dw _sprite
                             57    .db _jump
                             58    .dw _lastPtr
                             59    .db _state        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             60                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
                             61    .db _walking      ; y para guardar el estado de la IA de los enemigos
                             62    .db _distance     ; Maxima distancia recorrida por los enemigos
                             63                      ; y booleano para comprobar si es una plataforma o una estrella
                             64 .endm
                             65 
                             66 
                             67 ;; Definimos una entidad identificada por su etiqueta nombre
                             68 .macro DefineEntity _name, _type, _x, _y, _vx, _vy, _w, _h, _sprite, _jump, _lastPtr, _state, _walking, _distance
                             69 _name::
                             70    DefineEntityAnnonimous _type, _x, _y, _vx, _vy, _w, _h, _sprite, _jump, _lastPtr, _state, _walking, _distance
                             71 .endm
                             72 
                             73 
                             74 ;; Definimos un array de entidades anonimas
                             75 .macro DefineEntityArray _name, _N
                             76 _name::
                             77    .rept _N
                             78       DefineEntityAnnonimous 0x00, 0xDE, 0xAD, 0xDE, 0xAD, 0xDE, 0xAD, 0xDE00, 0xAD, 0xC000, 0x00, 0x00, 0x00
                             79    .endm
                             80 .endm
                             81 
                             82 
                             83 
                             84 
                             85 
                             86 
                             87 
                             88 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             89 ;;;;;;;;;;; TIPOS DE ENTIDADES ;;;;;;;;;;;;;;;
                             90 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             91 
                             92 ;; Numero de bits para la mascara
                     0007    93 e_type_alive_bit    = 7
                     0006    94 e_type_physics_bit  = 6
                     0005    95 e_type_render_bit   = 5
                     0004    96 e_type_collider_bit = 4
                     0003    97 e_type_input_bit    = 3
                     0002    98 e_type_dead_bit     = 2
                     0001    99 e_type_portal_bit   = 1
                            100 
                            101 ;; Tipos de entidades (mascaras)
                     0000   102 e_type_invalid      = 0x00
                     0080   103 e_type_alive_mask   = (1 << e_type_alive_bit)
                     0040   104 e_type_physics_mask = (1 << e_type_physics_bit)
                     0020   105 e_type_render_mask  = (1 << e_type_render_bit)
                     0010   106 e_type_collide_mask = (1 << e_type_collider_bit)
                     0008   107 e_type_input_mask   = (1 << e_type_input_bit)
                     0004   108 e_type_dead_mask    = (1 << e_type_dead_bit)
                     0002   109 e_type_portal_mask  = (1 << e_type_portal_bit)
                            110 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                            111 
                            112 ;; Entidades especificas
                     0070   113 e_type_character = e_type_physics_mask | e_type_collide_mask | e_type_render_mask
                     0078   114 e_type_player    = e_type_character | e_type_input_mask
                     0010   115 e_type_trap      = e_type_collide_mask
                     0018   116 e_type_platform  = e_type_trap | e_type_input_mask
                     00B0   117 e_type_enemy     = e_type_trap | e_type_alive_mask | e_type_render_mask
                     0012   118 e_type_portal    = e_type_trap | e_type_portal_mask
                     0019   119 e_type_star      = e_type_platform | 1
                            120 
                            121 
                            122 
                            123 
                            124 
                            125 
                            126 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            127 ;;;;;;;;;;;;;;; CONSTANTES ;;;;;;;;;;;;;;;;;;;
                            128 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            129 
                            130 ;; Constantes para posicionar cada componente de la entidad usando los registros IX e IY
                     0000   131 e_type     = 0
                     0001   132 e_x        = 1
                     0002   133 e_y        = 2
                     0003   134 e_vx       = 3
                     0004   135 e_vy       = 4
                     0005   136 e_w        = 5
                     0006   137 e_h        = 6
                     0007   138 e_sp_l     = 7
                     0008   139 e_sp_h     = 8
                     0009   140 e_jump     = 9
                     000A   141 e_lastPtr  = 10
                     000C   142 e_state    = 12
                     000D   143 e_walking  = 13
                     000E   144 e_distance = 14
                     000F   145 sizeof_e   = 15
