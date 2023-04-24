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
                             18 ;; GAME MANAGER
                             19 ;;
                             20 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             21 .include "entity.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                             55    .db _h
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                            110 
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                             22 .include "sys/animation.h.s"
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
                             18 ;; ANIMATION SYSTEM
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl sys_animation_update
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             23 .include "sys/render.h.s"
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
                             18 ;; RENDER SYSTEM
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl sys_render_init
                             27 .globl sys_render_update_all
                             28 .globl sys_render_update
                             29 .globl sys_render_update_clear
                             30 .globl sys_render_update_one_entity
                             31 
                             32 
                             33 
                             34 
                             35 
                             36 
                             37 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             38 ;;;;;;;;;;;;;;; CONSTANTES ;;;;;;;;;;;;;;;;;;;
                             39 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             40 
                     C000    41 screen_start = 0xC000           ; Inicio de la pantalla
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                             24 .include "sys/physics.h.s"
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
                             18 ;; PHYSICS SYSTEM
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl sys_physics_calculate_previous_position
                             27 .globl sys_physics_update_one_entity
                             28 .globl sys_physics_update
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                             25 .include "sys/input.h.s"
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
                             18 ;; INPUT SYSTEM
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 ;.globl sys_input_init
                             27 .globl sys_input_update
                             28 
                             29 
                             30 
                             31 
                             32 
                             33 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             34 ;;;;;;;;;;;;;;; CONSTANTES ;;;;;;;;;;;;;;;;;;;
                             35 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             36 
                     FFFFFFF7    37 gravity_acc == -9           ; Aceleracion maxima de la gravedad
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



                             26 .include "sys/collision.h.s"
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
                             18 ;; PHYSICS COLLISION
                             19 ;;
                             20 
                             21 
                             22 
                             23 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             25 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             26 
                             27 .globl sys_collision_update_one_entity
                             28 .globl sys_collision_correct_position
                             29 .globl sys_collision_update
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



                             27 .include "sys/ai_control.h.s"
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
                             18 ;; AI CONTROL SYSTEM
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl sys_ai_control_update
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



                             28 .include "game.h.s"
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
                             18 ;; GAME MANAGER
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl man_game_init
                             27 .globl man_game_run
                             28 .globl man_game_restart
                             29 .globl man_game_getNumGames_A
                             30 .globl man_game_continue_level
                             31 .globl man_game_next_play
                             32 
                             33 
                             34 
                             35 
                             36 
                             37 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             38 ;;;;;;;;;;;;;;; CONSTANTES ;;;;;;;;;;;;;;;;;;;
                             39 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             40 
                     0013    41 _total_levels = 19
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 12.
Hexadecimal [16-Bits]



                             29 .include "assets/assets.h.s"
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
                             17 .globl _floor_ceiling_sp_0
                             18 .globl _walls_sp_0
                             19 .globl _protagonista_sp_0                 ;; Derecha
                             20 .globl _protagonista_sp_1                 ;; Izquierda
                             21 .globl _protagonista_sp_2                 ;; Muerte
                             22 .globl _protagonista_sp_3                 ;; Salto
                             23 .globl _delimitador_sp_0 ;;Suelo de la pantalla
                             24 .globl _tiles_sp_00 ;;Sprite de bloque normal
                             25 .globl _tiles_sp_01 ;;Sprite de trampa
                             26 .globl _tiles_sp_02 ;;Sprite de reloj/portal
                             27 .globl _tiles_sp_03 ;;Sprite de bloque delimitador
                             28 .globl _tiles_sp_04 ;;Sprite de alien naranja izquierda
                             29 .globl _tiles_sp_05 ;;Sprite de alien naranja derecha
                             30 .globl _tiles_sp_06 ;;Sprite de alien azul izquierda
                             31 .globl _tiles_sp_07 ;;Sprite de alien azul derecha
                             32 .globl _tiles_sp_08 ;;Sprite de alien rojo izquierda
                             33 .globl _tiles_sp_09 ;;Sprite de alien rojo derecha
                             34 .globl _linea_pin_sp
                             35 .globl _tierra_sp_0
                             36 .globl _song_menu
                             37 .globl _song_ingame
                             38 .globl _screenmenu_z_end
                             39 .globl _screenhistory_z_end
                             40 .globl _screencredits_z_end
                             41 .globl _screencontrols_z_end
                             42 .globl _screenwin_z_end
                             43 
                             44 
                             45 ;;
                             46 ;; PALETAS
                             47 ;;
                             48 
                             49 .globl _protagonista_pal
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 13.
Hexadecimal [16-Bits]



                             30 .include "cpctelera_functions.h.s"
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
                             18 ;; CPCTELERA FUNCTIONS
                             19 ;;
                             20 
                             21 
                             22 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             23 ;;;;;;;;;;; FUNCIONES PUBLICAS ;;;;;;;;;;;;;;;
                             24 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             25 
                             26 .globl cpct_getScreenPtr_asm
                             27 .globl cpct_drawSolidBox_asm
                             28 .globl cpct_disableFirmware_asm
                             29 .globl cpct_waitVSYNC_asm
                             30 .globl cpct_scanKeyboard_f_asm
                             31 .globl cpct_isKeyPressed_asm
                             32 .globl cpct_setVideoMode_asm
                             33 .globl cpct_setPalette_asm
                             34 .globl cpct_drawStringM0_asm
                             35 .globl cpct_setDrawCharM0_asm
                             36 .globl cpct_drawSprite_asm
                             37 .globl cpct_limpiarPantalla_asm
                             38 .globl cpct_akp_musicInit_asm
                             39 .globl cpct_interrupt_flow
                             40 .globl cpct_akp_musicPlay_asm
                             41 .globl cpct_akp_stop_asm
                             42 .globl cpct_zx7b_decrunch_s_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 14.
Hexadecimal [16-Bits]



                             31 
                             32 
                             33 
                             34 
                             35 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             36 ;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;
                             37 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             38 
   489D 00                   39 _num_games:: .db    0
                             40 
                             41 
                             42 
                             43 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             44 ;;;;;;;;;;;;;;; TEMPLATES ;;;;;;;;;;;;;;;;;;;;
                             45 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             46 
                             47 
                             48 ;; Para asociar una entidad como enemigo, es necesario tener en cuenta que:
                             49     ; 1. El ultimo parametro es el rango en el que se puede mover la patrulla del enemigo (Ej: 7   -7------0------+7)
                             50     ; 2. El penultimo parametro define la direccion y sentido en el que se mueve (1: Derecha, -1: Izquierda, 2 y 3: Abajo, -2 y -3: Arriba)
                             51     ; 3. La diferencia entre el parametro 2 y 3, es la velocidad a la que se mueve y la distancia que recorre (3 > 2 obv)
                             52     ; 4. Se puede modificar desde donde se empieza dentro del recorrido, modificando los parametros de _vx y _vy, siempre y cuando este dentro del rango.
                             53     ; 5. Hay un limite sobre la cantidad de enemigos que se puede poner que puede afectar al render. No rebasar el limite.
                             54 ;; Para asociar una entidad como estrella, es necesario tener en cuenta que:
                             55     ; 1. Hay que asignarle el type e_type_star
                             56     ; 2. El ultimo parametro llamado _distance tiene que tener el valor 0
                             57     
                             58  ;;SUELO
   489E                      59 DefineEntity suelo1, e_type_platform, 0, 190, 0, 0, 40, 10, _delimitador_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0001                       1 suelo1::
   0001                       2    DefineEntityAnnonimous e_type_platform, 0, 190, 0, 0, 40, 10, _delimitador_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   489E 18                    1    .db e_type_platform
   489F 00                    2    .db 0
   48A0 BE                    3    .db 190
   48A1 00                    4    .db 0
   48A2 00                    5    .db 0
   48A3 28                    6    .db 40
   48A4 0A                    7    .db 10
   48A5 EA 1A                 8    .dw _delimitador_sp_0
   48A7 00                    9    .db 0
   48A8 00 00                10    .dw 0x0000
   48AA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   48AB 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   48AC 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   48AD                      60 DefineEntity suelo2, e_type_platform, 40, 190, 0, 0, 40, 10, _delimitador_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0010                       1 suelo2::
   0010                       2    DefineEntityAnnonimous e_type_platform, 40, 190, 0, 0, 40, 10, _delimitador_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   48AD 18                    1    .db e_type_platform
   48AE 28                    2    .db 40
   48AF BE                    3    .db 190
   48B0 00                    4    .db 0
   48B1 00                    5    .db 0
   48B2 28                    6    .db 40
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 15.
Hexadecimal [16-Bits]



   48B3 0A                    7    .db 10
   48B4 EA 1A                 8    .dw _delimitador_sp_0
   48B6 00                    9    .db 0
   48B7 00 00                10    .dw 0x0000
   48B9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   48BA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   48BB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                             61 ;;FIN DE SUELO
                             62 
   48BC                      63 DefineEntity player, e_type_player, 0, 180, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
   001F                       1 player::
   001F                       2    DefineEntityAnnonimous e_type_player, 0, 180, 0, 0, 5, 10, _protagonista_sp_0, 0, 0x0000, 0x01, 0x00, 0x00
   48BC 78                    1    .db e_type_player
   48BD 00                    2    .db 0
   48BE B4                    3    .db 180
   48BF 00                    4    .db 0
   48C0 00                    5    .db 0
   48C1 05                    6    .db 5
   48C2 0A                    7    .db 10
   48C3 82 28                 8    .dw _protagonista_sp_0
   48C5 00                    9    .db 0
   48C6 00 00                10    .dw 0x0000
   48C8 01                   11    .db 0x01        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   48C9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   48CA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                             64 
                             65 ;; NIVEL INICIAL
   48CB                      66 DefineEntity portal000, e_type_portal,   50, 130, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   002E                       1 portal000::
   002E                       2    DefineEntityAnnonimous e_type_portal, 50, 130, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   48CB 12                    1    .db e_type_portal
   48CC 32                    2    .db 50
   48CD 82                    3    .db 130
   48CE 00                    4    .db 0
   48CF 00                    5    .db 0
   48D0 05                    6    .db 5
   48D1 0A                    7    .db 10
   48D2 82 20                 8    .dw _tiles_sp_02
   48D4 00                    9    .db 0
   48D5 00 00                10    .dw 0x0000
   48D7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   48D8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   48D9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   48DA                      67 DefineEntity platah001, e_type_platform, 20, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   003D                       1 platah001::
   003D                       2    DefineEntityAnnonimous e_type_platform, 20, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   48DA 18                    1    .db e_type_platform
   48DB 14                    2    .db 20
   48DC A0                    3    .db 160
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 16.
Hexadecimal [16-Bits]



   48DD 00                    4    .db 0
   48DE 00                    5    .db 0
   48DF 0F                    6    .db 15
   48E0 0A                    7    .db 10
   48E1 B6 25                 8    .dw _floor_ceiling_sp_0
   48E3 00                    9    .db 0
   48E4 00 00                10    .dw 0x0000
   48E6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   48E7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   48E8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   48E9                      68 DefineEntity platah002, e_type_platform, 40, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   004C                       1 platah002::
   004C                       2    DefineEntityAnnonimous e_type_platform, 40, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   48E9 18                    1    .db e_type_platform
   48EA 28                    2    .db 40
   48EB 8C                    3    .db 140
   48EC 00                    4    .db 0
   48ED 00                    5    .db 0
   48EE 0F                    6    .db 15
   48EF 0A                    7    .db 10
   48F0 B6 25                 8    .dw _floor_ceiling_sp_0
   48F2 00                    9    .db 0
   48F3 00 00                10    .dw 0x0000
   48F5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   48F6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   48F7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   48F8                      69 DefineEntity tierra, e_type_platform, 60, 30, 0, 0, 15, 30, _tierra_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   005B                       1 tierra::
   005B                       2    DefineEntityAnnonimous e_type_platform, 60, 30, 0, 0, 15, 30, _tierra_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   48F8 18                    1    .db e_type_platform
   48F9 3C                    2    .db 60
   48FA 1E                    3    .db 30
   48FB 00                    4    .db 0
   48FC 00                    5    .db 0
   48FD 0F                    6    .db 15
   48FE 1E                    7    .db 30
   48FF EA 18                 8    .dw _tierra_sp_0
   4901 00                    9    .db 0
   4902 00 00                10    .dw 0x0000
   4904 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4905 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4906 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                             70 
                             71 ;; NIVEL 0
   4907                      72 DefineEntity portal00, e_type_portal,   10, 50, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   006A                       1 portal00::
   006A                       2    DefineEntityAnnonimous e_type_portal, 10, 50, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4907 12                    1    .db e_type_portal
   4908 0A                    2    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 17.
Hexadecimal [16-Bits]



   4909 32                    3    .db 50
   490A 00                    4    .db 0
   490B 00                    5    .db 0
   490C 05                    6    .db 5
   490D 0A                    7    .db 10
   490E 82 20                 8    .dw _tiles_sp_02
   4910 00                    9    .db 0
   4911 00 00                10    .dw 0x0000
   4913 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4914 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4915 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4916                      73 DefineEntity platah01, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0079                       1 platah01::
   0079                       2    DefineEntityAnnonimous e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4916 18                    1    .db e_type_platform
   4917 0A                    2    .db 10
   4918 A0                    3    .db 160
   4919 00                    4    .db 0
   491A 00                    5    .db 0
   491B 0F                    6    .db 15
   491C 0A                    7    .db 10
   491D B6 25                 8    .dw _floor_ceiling_sp_0
   491F 00                    9    .db 0
   4920 00 00                10    .dw 0x0000
   4922 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4923 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4924 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4925                      74 DefineEntity platah02, e_type_platform, 30, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0088                       1 platah02::
   0088                       2    DefineEntityAnnonimous e_type_platform, 30, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4925 18                    1    .db e_type_platform
   4926 1E                    2    .db 30
   4927 8C                    3    .db 140
   4928 00                    4    .db 0
   4929 00                    5    .db 0
   492A 0F                    6    .db 15
   492B 0A                    7    .db 10
   492C B6 25                 8    .dw _floor_ceiling_sp_0
   492E 00                    9    .db 0
   492F 00 00                10    .dw 0x0000
   4931 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4932 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4933 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4934                      75 DefineEntity platah03, e_type_platform, 50, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0097                       1 platah03::
   0097                       2    DefineEntityAnnonimous e_type_platform, 50, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4934 18                    1    .db e_type_platform
   4935 32                    2    .db 50
   4936 78                    3    .db 120
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 18.
Hexadecimal [16-Bits]



   4937 00                    4    .db 0
   4938 00                    5    .db 0
   4939 0F                    6    .db 15
   493A 0A                    7    .db 10
   493B B6 25                 8    .dw _floor_ceiling_sp_0
   493D 00                    9    .db 0
   493E 00 00                10    .dw 0x0000
   4940 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4941 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4942 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4943                      76 DefineEntity platah04, e_type_platform, 30, 87, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   00A6                       1 platah04::
   00A6                       2    DefineEntityAnnonimous e_type_platform, 30, 87, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4943 18                    1    .db e_type_platform
   4944 1E                    2    .db 30
   4945 57                    3    .db 87
   4946 00                    4    .db 0
   4947 00                    5    .db 0
   4948 0F                    6    .db 15
   4949 0A                    7    .db 10
   494A B6 25                 8    .dw _floor_ceiling_sp_0
   494C 00                    9    .db 0
   494D 00 00                10    .dw 0x0000
   494F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4950 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4951 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4952                      77 DefineEntity platah05, e_type_platform, 10, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   00B5                       1 platah05::
   00B5                       2    DefineEntityAnnonimous e_type_platform, 10, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4952 18                    1    .db e_type_platform
   4953 0A                    2    .db 10
   4954 3C                    3    .db 60
   4955 00                    4    .db 0
   4956 00                    5    .db 0
   4957 0F                    6    .db 15
   4958 0A                    7    .db 10
   4959 B6 25                 8    .dw _floor_ceiling_sp_0
   495B 00                    9    .db 0
   495C 00 00                10    .dw 0x0000
   495E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   495F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4960 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                             78 
                             79 ; NIVEL 1
   4961                      80 DefineEntity portal11, e_type_portal, 0, 30, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   00C4                       1 portal11::
   00C4                       2    DefineEntityAnnonimous e_type_portal, 0, 30, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4961 12                    1    .db e_type_portal
   4962 00                    2    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 19.
Hexadecimal [16-Bits]



   4963 1E                    3    .db 30
   4964 00                    4    .db 0
   4965 00                    5    .db 0
   4966 05                    6    .db 5
   4967 0A                    7    .db 10
   4968 82 20                 8    .dw _tiles_sp_02
   496A 00                    9    .db 0
   496B 00 00                10    .dw 0x0000
   496D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   496E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   496F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4970                      81 DefineEntity platah11, e_type_platform, 10, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   00D3                       1 platah11::
   00D3                       2    DefineEntityAnnonimous e_type_platform, 10, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4970 18                    1    .db e_type_platform
   4971 0A                    2    .db 10
   4972 9E                    3    .db 158
   4973 00                    4    .db 0
   4974 00                    5    .db 0
   4975 0F                    6    .db 15
   4976 0A                    7    .db 10
   4977 B6 25                 8    .dw _floor_ceiling_sp_0
   4979 00                    9    .db 0
   497A 00 00                10    .dw 0x0000
   497C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   497D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   497E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   497F                      82 DefineEntity platah12, e_type_platform, 37, 136, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   00E2                       1 platah12::
   00E2                       2    DefineEntityAnnonimous e_type_platform, 37, 136, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   497F 18                    1    .db e_type_platform
   4980 25                    2    .db 37
   4981 88                    3    .db 136
   4982 00                    4    .db 0
   4983 00                    5    .db 0
   4984 0F                    6    .db 15
   4985 0A                    7    .db 10
   4986 B6 25                 8    .dw _floor_ceiling_sp_0
   4988 00                    9    .db 0
   4989 00 00                10    .dw 0x0000
   498B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   498C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   498D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   498E                      83 DefineEntity platah13, e_type_platform, 65,  135, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   00F1                       1 platah13::
   00F1                       2    DefineEntityAnnonimous e_type_platform, 65, 135, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   498E 18                    1    .db e_type_platform
   498F 41                    2    .db 65
   4990 87                    3    .db 135
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 20.
Hexadecimal [16-Bits]



   4991 00                    4    .db 0
   4992 00                    5    .db 0
   4993 0F                    6    .db 15
   4994 0A                    7    .db 10
   4995 B6 25                 8    .dw _floor_ceiling_sp_0
   4997 00                    9    .db 0
   4998 00 00                10    .dw 0x0000
   499A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   499B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   499C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   499D                      84 DefineEntity platah14, e_type_platform, 75, 103, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0100                       1 platah14::
   0100                       2    DefineEntityAnnonimous e_type_platform, 75, 103, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   499D 18                    1    .db e_type_platform
   499E 4B                    2    .db 75
   499F 67                    3    .db 103
   49A0 00                    4    .db 0
   49A1 00                    5    .db 0
   49A2 05                    6    .db 5
   49A3 0A                    7    .db 10
   49A4 1E 20                 8    .dw _tiles_sp_00
   49A6 00                    9    .db 0
   49A7 00 00                10    .dw 0x0000
   49A9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   49AA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   49AB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   49AC                      85 DefineEntity platah15, e_type_platform, 50, 73, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, #-1, #9                                      ; ENEMIGO
   010F                       1 platah15::
   010F                       2    DefineEntityAnnonimous e_type_platform, 50, 73, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, #-1, #9
   49AC 18                    1    .db e_type_platform
   49AD 32                    2    .db 50
   49AE 49                    3    .db 73
   49AF 00                    4    .db 0
   49B0 00                    5    .db 0
   49B1 0F                    6    .db 15
   49B2 0A                    7    .db 10
   49B3 B6 25                 8    .dw _floor_ceiling_sp_0
   49B5 00                    9    .db 0
   49B6 00 00                10    .dw 0x0000
   49B8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   49B9 FF                   13    .db #-1      ; y para guardar el estado de la IA de los enemigos
   49BA 09                   14    .db #9     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   49BB                      86 DefineEntity platah16, e_type_platform, 20, 73, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   011E                       1 platah16::
   011E                       2    DefineEntityAnnonimous e_type_platform, 20, 73, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   49BB 18                    1    .db e_type_platform
   49BC 14                    2    .db 20
   49BD 49                    3    .db 73
   49BE 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 21.
Hexadecimal [16-Bits]



   49BF 00                    5    .db 0
   49C0 0F                    6    .db 15
   49C1 0A                    7    .db 10
   49C2 B6 25                 8    .dw _floor_ceiling_sp_0
   49C4 00                    9    .db 0
   49C5 00 00                10    .dw 0x0000
   49C7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   49C8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   49C9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   49CA                      87 DefineEntity platah17, e_type_platform, 0,  40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   012D                       1 platah17::
   012D                       2    DefineEntityAnnonimous e_type_platform, 0, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   49CA 18                    1    .db e_type_platform
   49CB 00                    2    .db 0
   49CC 28                    3    .db 40
   49CD 00                    4    .db 0
   49CE 00                    5    .db 0
   49CF 0F                    6    .db 15
   49D0 0A                    7    .db 10
   49D1 B6 25                 8    .dw _floor_ceiling_sp_0
   49D3 00                    9    .db 0
   49D4 00 00                10    .dw 0x0000
   49D6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   49D7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   49D8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                             88 
                             89 ;NIVEL 2
   49D9                      90 DefineEntity portal20, e_type_portal, 75, 110, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   013C                       1 portal20::
   013C                       2    DefineEntityAnnonimous e_type_portal, 75, 110, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   49D9 12                    1    .db e_type_portal
   49DA 4B                    2    .db 75
   49DB 6E                    3    .db 110
   49DC 00                    4    .db 0
   49DD 00                    5    .db 0
   49DE 05                    6    .db 5
   49DF 0A                    7    .db 10
   49E0 82 20                 8    .dw _tiles_sp_02
   49E2 00                    9    .db 0
   49E3 00 00                10    .dw 0x0000
   49E5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   49E6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   49E7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   49E8                      91 DefineEntity platah21, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   014B                       1 platah21::
   014B                       2    DefineEntityAnnonimous e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   49E8 18                    1    .db e_type_platform
   49E9 0A                    2    .db 10
   49EA A0                    3    .db 160
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 22.
Hexadecimal [16-Bits]



   49EB 00                    4    .db 0
   49EC 00                    5    .db 0
   49ED 0F                    6    .db 15
   49EE 0A                    7    .db 10
   49EF B6 25                 8    .dw _floor_ceiling_sp_0
   49F1 00                    9    .db 0
   49F2 00 00                10    .dw 0x0000
   49F4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   49F5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   49F6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   49F7                      92 DefineEntity platah22, e_type_platform, 25, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   015A                       1 platah22::
   015A                       2    DefineEntityAnnonimous e_type_platform, 25, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   49F7 18                    1    .db e_type_platform
   49F8 19                    2    .db 25
   49F9 82                    3    .db 130
   49FA 00                    4    .db 0
   49FB 00                    5    .db 0
   49FC 05                    6    .db 5
   49FD 0A                    7    .db 10
   49FE 1E 20                 8    .dw _tiles_sp_00
   4A00 00                    9    .db 0
   4A01 00 00                10    .dw 0x0000
   4A03 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A04 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A05 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A06                      93 DefineEntity platah23, e_type_platform, 10, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0169                       1 platah23::
   0169                       2    DefineEntityAnnonimous e_type_platform, 10, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4A06 18                    1    .db e_type_platform
   4A07 0A                    2    .db 10
   4A08 64                    3    .db 100
   4A09 00                    4    .db 0
   4A0A 00                    5    .db 0
   4A0B 05                    6    .db 5
   4A0C 0A                    7    .db 10
   4A0D 1E 20                 8    .dw _tiles_sp_00
   4A0F 00                    9    .db 0
   4A10 00 00                10    .dw 0x0000
   4A12 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A13 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A14 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A15                      94 DefineEntity platah24, e_type_platform, 20, 80, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0178                       1 platah24::
   0178                       2    DefineEntityAnnonimous e_type_platform, 20, 80, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4A15 18                    1    .db e_type_platform
   4A16 14                    2    .db 20
   4A17 50                    3    .db 80
   4A18 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 23.
Hexadecimal [16-Bits]



   4A19 00                    5    .db 0
   4A1A 0F                    6    .db 15
   4A1B 0A                    7    .db 10
   4A1C B6 25                 8    .dw _floor_ceiling_sp_0
   4A1E 00                    9    .db 0
   4A1F 00 00                10    .dw 0x0000
   4A21 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A22 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A23 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A24                      95 DefineEntity platah25, e_type_platform, 50, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0187                       1 platah25::
   0187                       2    DefineEntityAnnonimous e_type_platform, 50, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4A24 18                    1    .db e_type_platform
   4A25 32                    2    .db 50
   4A26 50                    3    .db 80
   4A27 00                    4    .db 0
   4A28 00                    5    .db 0
   4A29 05                    6    .db 5
   4A2A 0A                    7    .db 10
   4A2B 1E 20                 8    .dw _tiles_sp_00
   4A2D 00                    9    .db 0
   4A2E 00 00                10    .dw 0x0000
   4A30 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A31 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A32 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A33                      96 DefineEntity platah26, e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0196                       1 platah26::
   0196                       2    DefineEntityAnnonimous e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4A33 18                    1    .db e_type_platform
   4A34 41                    2    .db 65
   4A35 78                    3    .db 120
   4A36 00                    4    .db 0
   4A37 00                    5    .db 0
   4A38 0F                    6    .db 15
   4A39 0A                    7    .db 10
   4A3A B6 25                 8    .dw _floor_ceiling_sp_0
   4A3C 00                    9    .db 0
   4A3D 00 00                10    .dw 0x0000
   4A3F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A40 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A41 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                             97 
                             98 ; NIVEL 3
   4A42                      99 DefineEntity portal30, e_type_portal, 30, 20, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   01A5                       1 portal30::
   01A5                       2    DefineEntityAnnonimous e_type_portal, 30, 20, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4A42 12                    1    .db e_type_portal
   4A43 1E                    2    .db 30
   4A44 14                    3    .db 20
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 24.
Hexadecimal [16-Bits]



   4A45 00                    4    .db 0
   4A46 00                    5    .db 0
   4A47 05                    6    .db 5
   4A48 0A                    7    .db 10
   4A49 82 20                 8    .dw _tiles_sp_02
   4A4B 00                    9    .db 0
   4A4C 00 00                10    .dw 0x0000
   4A4E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A4F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A50 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A51                     100 DefineEntity platah31, e_type_platform, 20, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   01B4                       1 platah31::
   01B4                       2    DefineEntityAnnonimous e_type_platform, 20, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4A51 18                    1    .db e_type_platform
   4A52 14                    2    .db 20
   4A53 9E                    3    .db 158
   4A54 00                    4    .db 0
   4A55 00                    5    .db 0
   4A56 0F                    6    .db 15
   4A57 0A                    7    .db 10
   4A58 B6 25                 8    .dw _floor_ceiling_sp_0
   4A5A 00                    9    .db 0
   4A5B 00 00                10    .dw 0x0000
   4A5D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A5E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A5F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A60                     101 DefineEntity platah32, e_type_platform, 45, 148, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   01C3                       1 platah32::
   01C3                       2    DefineEntityAnnonimous e_type_platform, 45, 148, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4A60 18                    1    .db e_type_platform
   4A61 2D                    2    .db 45
   4A62 94                    3    .db 148
   4A63 00                    4    .db 0
   4A64 00                    5    .db 0
   4A65 05                    6    .db 5
   4A66 0A                    7    .db 10
   4A67 1E 20                 8    .dw _tiles_sp_00
   4A69 00                    9    .db 0
   4A6A 00 00                10    .dw 0x0000
   4A6C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A6D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A6E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A6F                     102 DefineEntity platah33, e_type_platform, 60, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   01D2                       1 platah33::
   01D2                       2    DefineEntityAnnonimous e_type_platform, 60, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4A6F 18                    1    .db e_type_platform
   4A70 3C                    2    .db 60
   4A71 9E                    3    .db 158
   4A72 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 25.
Hexadecimal [16-Bits]



   4A73 00                    5    .db 0
   4A74 0F                    6    .db 15
   4A75 0A                    7    .db 10
   4A76 B6 25                 8    .dw _floor_ceiling_sp_0
   4A78 00                    9    .db 0
   4A79 00 00                10    .dw 0x0000
   4A7B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A7C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A7D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A7E                     103 DefineEntity platah34, e_type_platform, 75, 126, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   01E1                       1 platah34::
   01E1                       2    DefineEntityAnnonimous e_type_platform, 75, 126, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4A7E 18                    1    .db e_type_platform
   4A7F 4B                    2    .db 75
   4A80 7E                    3    .db 126
   4A81 00                    4    .db 0
   4A82 00                    5    .db 0
   4A83 05                    6    .db 5
   4A84 0A                    7    .db 10
   4A85 1E 20                 8    .dw _tiles_sp_00
   4A87 00                    9    .db 0
   4A88 00 00                10    .dw 0x0000
   4A8A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A8B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A8C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A8D                     104 DefineEntity platah35, e_type_platform, 50, 94, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   01F0                       1 platah35::
   01F0                       2    DefineEntityAnnonimous e_type_platform, 50, 94, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4A8D 18                    1    .db e_type_platform
   4A8E 32                    2    .db 50
   4A8F 5E                    3    .db 94
   4A90 00                    4    .db 0
   4A91 00                    5    .db 0
   4A92 0F                    6    .db 15
   4A93 0A                    7    .db 10
   4A94 B6 25                 8    .dw _floor_ceiling_sp_0
   4A96 00                    9    .db 0
   4A97 00 00                10    .dw 0x0000
   4A99 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4A9A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4A9B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4A9C                     105 DefineEntity platah36, e_type_platform, 32, 94, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   01FF                       1 platah36::
   01FF                       2    DefineEntityAnnonimous e_type_platform, 32, 94, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4A9C 18                    1    .db e_type_platform
   4A9D 20                    2    .db 32
   4A9E 5E                    3    .db 94
   4A9F 00                    4    .db 0
   4AA0 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 26.
Hexadecimal [16-Bits]



   4AA1 05                    6    .db 5
   4AA2 0A                    7    .db 10
   4AA3 1E 20                 8    .dw _tiles_sp_00
   4AA5 00                    9    .db 0
   4AA6 00 00                10    .dw 0x0000
   4AA8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4AA9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4AAA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4AAB                     106 DefineEntity platah37, e_type_platform, 10, 62, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   020E                       1 platah37::
   020E                       2    DefineEntityAnnonimous e_type_platform, 10, 62, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4AAB 18                    1    .db e_type_platform
   4AAC 0A                    2    .db 10
   4AAD 3E                    3    .db 62
   4AAE 00                    4    .db 0
   4AAF 00                    5    .db 0
   4AB0 0F                    6    .db 15
   4AB1 0A                    7    .db 10
   4AB2 B6 25                 8    .dw _floor_ceiling_sp_0
   4AB4 00                    9    .db 0
   4AB5 00 00                10    .dw 0x0000
   4AB7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4AB8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4AB9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4ABA                     107 DefineEntity platah38, e_type_platform, 30, 30, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   021D                       1 platah38::
   021D                       2    DefineEntityAnnonimous e_type_platform, 30, 30, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4ABA 18                    1    .db e_type_platform
   4ABB 1E                    2    .db 30
   4ABC 1E                    3    .db 30
   4ABD 00                    4    .db 0
   4ABE 00                    5    .db 0
   4ABF 05                    6    .db 5
   4AC0 0A                    7    .db 10
   4AC1 1E 20                 8    .dw _tiles_sp_00
   4AC3 00                    9    .db 0
   4AC4 00 00                10    .dw 0x0000
   4AC6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4AC7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4AC8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4AC9                     108 DefineEntity tramp31, e_type_trap, 20, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   022C                       1 tramp31::
   022C                       2    DefineEntityAnnonimous e_type_trap, 20, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   4AC9 10                    1    .db e_type_trap
   4ACA 14                    2    .db 20
   4ACB B4                    3    .db 180
   4ACC 00                    4    .db 0
   4ACD 00                    5    .db 0
   4ACE 32                    6    .db 50
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 27.
Hexadecimal [16-Bits]



   4ACF 0A                    7    .db 10
   4AD0 1A 1E                 8    .dw _linea_pin_sp
   4AD2 00                    9    .db 0
   4AD3 00 00                10    .dw 0x0000
   4AD5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4AD6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4AD7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4AD8                     109 DefineEntity tramp32, e_type_trap, 39, 94, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   023B                       1 tramp32::
   023B                       2    DefineEntityAnnonimous e_type_trap, 39, 94, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4AD8 10                    1    .db e_type_trap
   4AD9 27                    2    .db 39
   4ADA 5E                    3    .db 94
   4ADB 00                    4    .db 0
   4ADC 00                    5    .db 0
   4ADD 05                    6    .db 5
   4ADE 0A                    7    .db 10
   4ADF 50 20                 8    .dw _tiles_sp_01
   4AE1 00                    9    .db 0
   4AE2 00 00                10    .dw 0x0000
   4AE4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4AE5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4AE6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            110 
                            111 ;; NIVEL 4
   4AE7                     112 DefineEntity portal40, e_type_portal, 65, 60, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   024A                       1 portal40::
   024A                       2    DefineEntityAnnonimous e_type_portal, 65, 60, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4AE7 12                    1    .db e_type_portal
   4AE8 41                    2    .db 65
   4AE9 3C                    3    .db 60
   4AEA 00                    4    .db 0
   4AEB 00                    5    .db 0
   4AEC 05                    6    .db 5
   4AED 0A                    7    .db 10
   4AEE 82 20                 8    .dw _tiles_sp_02
   4AF0 00                    9    .db 0
   4AF1 00 00                10    .dw 0x0000
   4AF3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4AF4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4AF5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4AF6                     113 DefineEntity platah41, e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0259                       1 platah41::
   0259                       2    DefineEntityAnnonimous e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4AF6 18                    1    .db e_type_platform
   4AF7 41                    2    .db 65
   4AF8 A0                    3    .db 160
   4AF9 00                    4    .db 0
   4AFA 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 28.
Hexadecimal [16-Bits]



   4AFB 0F                    6    .db 15
   4AFC 0A                    7    .db 10
   4AFD B6 25                 8    .dw _floor_ceiling_sp_0
   4AFF 00                    9    .db 0
   4B00 00 00                10    .dw 0x0000
   4B02 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B03 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B04 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B05                     114 DefineEntity platah42, e_type_platform, 45, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0268                       1 platah42::
   0268                       2    DefineEntityAnnonimous e_type_platform, 45, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4B05 18                    1    .db e_type_platform
   4B06 2D                    2    .db 45
   4B07 82                    3    .db 130
   4B08 00                    4    .db 0
   4B09 00                    5    .db 0
   4B0A 0F                    6    .db 15
   4B0B 0A                    7    .db 10
   4B0C B6 25                 8    .dw _floor_ceiling_sp_0
   4B0E 00                    9    .db 0
   4B0F 00 00                10    .dw 0x0000
   4B11 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B12 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B13 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B14                     115 DefineEntity platah43, e_type_platform, 30, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0277                       1 platah43::
   0277                       2    DefineEntityAnnonimous e_type_platform, 30, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4B14 18                    1    .db e_type_platform
   4B15 1E                    2    .db 30
   4B16 82                    3    .db 130
   4B17 00                    4    .db 0
   4B18 00                    5    .db 0
   4B19 0F                    6    .db 15
   4B1A 0A                    7    .db 10
   4B1B B6 25                 8    .dw _floor_ceiling_sp_0
   4B1D 00                    9    .db 0
   4B1E 00 00                10    .dw 0x0000
   4B20 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B21 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B22 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B23                     116 DefineEntity platah44, e_type_platform, 12, 125, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0286                       1 platah44::
   0286                       2    DefineEntityAnnonimous e_type_platform, 12, 125, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4B23 18                    1    .db e_type_platform
   4B24 0C                    2    .db 12
   4B25 7D                    3    .db 125
   4B26 00                    4    .db 0
   4B27 00                    5    .db 0
   4B28 05                    6    .db 5
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 29.
Hexadecimal [16-Bits]



   4B29 0A                    7    .db 10
   4B2A 1E 20                 8    .dw _tiles_sp_00
   4B2C 00                    9    .db 0
   4B2D 00 00                10    .dw 0x0000
   4B2F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B30 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B31 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B32                     117 DefineEntity platah45, e_type_platform, 0, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0295                       1 platah45::
   0295                       2    DefineEntityAnnonimous e_type_platform, 0, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4B32 18                    1    .db e_type_platform
   4B33 00                    2    .db 0
   4B34 64                    3    .db 100
   4B35 00                    4    .db 0
   4B36 00                    5    .db 0
   4B37 05                    6    .db 5
   4B38 0A                    7    .db 10
   4B39 1E 20                 8    .dw _tiles_sp_00
   4B3B 00                    9    .db 0
   4B3C 00 00                10    .dw 0x0000
   4B3E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B3F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B40 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B41                     118 DefineEntity platah46, e_type_platform, 10, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   02A4                       1 platah46::
   02A4                       2    DefineEntityAnnonimous e_type_platform, 10, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4B41 18                    1    .db e_type_platform
   4B42 0A                    2    .db 10
   4B43 46                    3    .db 70
   4B44 00                    4    .db 0
   4B45 00                    5    .db 0
   4B46 0F                    6    .db 15
   4B47 0A                    7    .db 10
   4B48 B6 25                 8    .dw _floor_ceiling_sp_0
   4B4A 00                    9    .db 0
   4B4B 00 00                10    .dw 0x0000
   4B4D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B4E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B4F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B50                     119 DefineEntity platah47, e_type_platform, 25, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   02B3                       1 platah47::
   02B3                       2    DefineEntityAnnonimous e_type_platform, 25, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4B50 18                    1    .db e_type_platform
   4B51 19                    2    .db 25
   4B52 46                    3    .db 70
   4B53 00                    4    .db 0
   4B54 00                    5    .db 0
   4B55 0F                    6    .db 15
   4B56 0A                    7    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 30.
Hexadecimal [16-Bits]



   4B57 B6 25                 8    .dw _floor_ceiling_sp_0
   4B59 00                    9    .db 0
   4B5A 00 00                10    .dw 0x0000
   4B5C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B5D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B5E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B5F                     120 DefineEntity platah48, e_type_platform, 40, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   02C2                       1 platah48::
   02C2                       2    DefineEntityAnnonimous e_type_platform, 40, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4B5F 18                    1    .db e_type_platform
   4B60 28                    2    .db 40
   4B61 46                    3    .db 70
   4B62 00                    4    .db 0
   4B63 00                    5    .db 0
   4B64 0F                    6    .db 15
   4B65 0A                    7    .db 10
   4B66 B6 25                 8    .dw _floor_ceiling_sp_0
   4B68 00                    9    .db 0
   4B69 00 00                10    .dw 0x0000
   4B6B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B6C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B6D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B6E                     121 DefineEntity platah49, e_type_platform, 55, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   02D1                       1 platah49::
   02D1                       2    DefineEntityAnnonimous e_type_platform, 55, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4B6E 18                    1    .db e_type_platform
   4B6F 37                    2    .db 55
   4B70 46                    3    .db 70
   4B71 00                    4    .db 0
   4B72 00                    5    .db 0
   4B73 0F                    6    .db 15
   4B74 0A                    7    .db 10
   4B75 B6 25                 8    .dw _floor_ceiling_sp_0
   4B77 00                    9    .db 0
   4B78 00 00                10    .dw 0x0000
   4B7A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B7B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B7C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B7D                     122 DefineEntity tramp41, e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   02E0                       1 tramp41::
   02E0                       2    DefineEntityAnnonimous e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4B7D 10                    1    .db e_type_trap
   4B7E 14                    2    .db 20
   4B7F B4                    3    .db 180
   4B80 00                    4    .db 0
   4B81 00                    5    .db 0
   4B82 05                    6    .db 5
   4B83 0A                    7    .db 10
   4B84 50 20                 8    .dw _tiles_sp_01
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 31.
Hexadecimal [16-Bits]



   4B86 00                    9    .db 0
   4B87 00 00                10    .dw 0x0000
   4B89 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B8A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B8B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B8C                     123 DefineEntity tramp42, e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   02EF                       1 tramp42::
   02EF                       2    DefineEntityAnnonimous e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4B8C 10                    1    .db e_type_trap
   4B8D 2D                    2    .db 45
   4B8E B4                    3    .db 180
   4B8F 00                    4    .db 0
   4B90 00                    5    .db 0
   4B91 05                    6    .db 5
   4B92 0A                    7    .db 10
   4B93 50 20                 8    .dw _tiles_sp_01
   4B95 00                    9    .db 0
   4B96 00 00                10    .dw 0x0000
   4B98 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4B99 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4B9A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4B9B                     124 DefineEntity tramp43, e_type_trap, 40, 120, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   02FE                       1 tramp43::
   02FE                       2    DefineEntityAnnonimous e_type_trap, 40, 120, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4B9B 10                    1    .db e_type_trap
   4B9C 28                    2    .db 40
   4B9D 78                    3    .db 120
   4B9E 00                    4    .db 0
   4B9F 00                    5    .db 0
   4BA0 05                    6    .db 5
   4BA1 0A                    7    .db 10
   4BA2 50 20                 8    .dw _tiles_sp_01
   4BA4 00                    9    .db 0
   4BA5 00 00                10    .dw 0x0000
   4BA7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4BA8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4BA9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4BAA                     125 DefineEntity tramp44, e_type_trap, 45, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   030D                       1 tramp44::
   030D                       2    DefineEntityAnnonimous e_type_trap, 45, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4BAA 10                    1    .db e_type_trap
   4BAB 2D                    2    .db 45
   4BAC 3C                    3    .db 60
   4BAD 00                    4    .db 0
   4BAE 00                    5    .db 0
   4BAF 05                    6    .db 5
   4BB0 0A                    7    .db 10
   4BB1 50 20                 8    .dw _tiles_sp_01
   4BB3 00                    9    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 32.
Hexadecimal [16-Bits]



   4BB4 00 00                10    .dw 0x0000
   4BB6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4BB7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4BB8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4BB9                     126 DefineEntity tramp45, e_type_trap, 25, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   031C                       1 tramp45::
   031C                       2    DefineEntityAnnonimous e_type_trap, 25, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4BB9 10                    1    .db e_type_trap
   4BBA 19                    2    .db 25
   4BBB 3C                    3    .db 60
   4BBC 00                    4    .db 0
   4BBD 00                    5    .db 0
   4BBE 05                    6    .db 5
   4BBF 0A                    7    .db 10
   4BC0 50 20                 8    .dw _tiles_sp_01
   4BC2 00                    9    .db 0
   4BC3 00 00                10    .dw 0x0000
   4BC5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4BC6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4BC7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            127 
                            128 ; NIVEL 5
   4BC8                     129 DefineEntity portal50, e_type_portal, 40, 40, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   032B                       1 portal50::
   032B                       2    DefineEntityAnnonimous e_type_portal, 40, 40, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4BC8 12                    1    .db e_type_portal
   4BC9 28                    2    .db 40
   4BCA 28                    3    .db 40
   4BCB 00                    4    .db 0
   4BCC 00                    5    .db 0
   4BCD 05                    6    .db 5
   4BCE 0A                    7    .db 10
   4BCF 82 20                 8    .dw _tiles_sp_02
   4BD1 00                    9    .db 0
   4BD2 00 00                10    .dw 0x0000
   4BD4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4BD5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4BD6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4BD7                     130 DefineEntity platah51, e_type_platform, 47, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   033A                       1 platah51::
   033A                       2    DefineEntityAnnonimous e_type_platform, 47, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4BD7 18                    1    .db e_type_platform
   4BD8 2F                    2    .db 47
   4BD9 A0                    3    .db 160
   4BDA 00                    4    .db 0
   4BDB 00                    5    .db 0
   4BDC 05                    6    .db 5
   4BDD 0A                    7    .db 10
   4BDE 1E 20                 8    .dw _tiles_sp_00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 33.
Hexadecimal [16-Bits]



   4BE0 00                    9    .db 0
   4BE1 00 00                10    .dw 0x0000
   4BE3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4BE4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4BE5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4BE6                     131 DefineEntity platah52, e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0349                       1 platah52::
   0349                       2    DefineEntityAnnonimous e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4BE6 18                    1    .db e_type_platform
   4BE7 41                    2    .db 65
   4BE8 A0                    3    .db 160
   4BE9 00                    4    .db 0
   4BEA 00                    5    .db 0
   4BEB 0F                    6    .db 15
   4BEC 0A                    7    .db 10
   4BED B6 25                 8    .dw _floor_ceiling_sp_0
   4BEF 00                    9    .db 0
   4BF0 00 00                10    .dw 0x0000
   4BF2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4BF3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4BF4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4BF5                     132 DefineEntity platah53, e_type_platform, 70, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0358                       1 platah53::
   0358                       2    DefineEntityAnnonimous e_type_platform, 70, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4BF5 18                    1    .db e_type_platform
   4BF6 46                    2    .db 70
   4BF7 87                    3    .db 135
   4BF8 00                    4    .db 0
   4BF9 00                    5    .db 0
   4BFA 05                    6    .db 5
   4BFB 0A                    7    .db 10
   4BFC 1E 20                 8    .dw _tiles_sp_00
   4BFE 00                    9    .db 0
   4BFF 00 00                10    .dw 0x0000
   4C01 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C02 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C03 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C04                     133 DefineEntity platah54, e_type_platform, 20, 105, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0367                       1 platah54::
   0367                       2    DefineEntityAnnonimous e_type_platform, 20, 105, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4C04 18                    1    .db e_type_platform
   4C05 14                    2    .db 20
   4C06 69                    3    .db 105
   4C07 00                    4    .db 0
   4C08 00                    5    .db 0
   4C09 0F                    6    .db 15
   4C0A 0A                    7    .db 10
   4C0B B6 25                 8    .dw _floor_ceiling_sp_0
   4C0D 00                    9    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 34.
Hexadecimal [16-Bits]



   4C0E 00 00                10    .dw 0x0000
   4C10 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C11 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C12 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C13                     134 DefineEntity platah55, e_type_platform, 50, 105, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0376                       1 platah55::
   0376                       2    DefineEntityAnnonimous e_type_platform, 50, 105, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4C13 18                    1    .db e_type_platform
   4C14 32                    2    .db 50
   4C15 69                    3    .db 105
   4C16 00                    4    .db 0
   4C17 00                    5    .db 0
   4C18 0F                    6    .db 15
   4C19 0A                    7    .db 10
   4C1A B6 25                 8    .dw _floor_ceiling_sp_0
   4C1C 00                    9    .db 0
   4C1D 00 00                10    .dw 0x0000
   4C1F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C20 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C21 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C22                     135 DefineEntity platah56, e_type_platform, 15, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0385                       1 platah56::
   0385                       2    DefineEntityAnnonimous e_type_platform, 15, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4C22 18                    1    .db e_type_platform
   4C23 0F                    2    .db 15
   4C24 46                    3    .db 70
   4C25 00                    4    .db 0
   4C26 00                    5    .db 0
   4C27 05                    6    .db 5
   4C28 0A                    7    .db 10
   4C29 1E 20                 8    .dw _tiles_sp_00
   4C2B 00                    9    .db 0
   4C2C 00 00                10    .dw 0x0000
   4C2E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C2F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C30 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C31                     136 DefineEntity platah57, e_type_platform, 30, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0394                       1 platah57::
   0394                       2    DefineEntityAnnonimous e_type_platform, 30, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4C31 18                    1    .db e_type_platform
   4C32 1E                    2    .db 30
   4C33 32                    3    .db 50
   4C34 00                    4    .db 0
   4C35 00                    5    .db 0
   4C36 0F                    6    .db 15
   4C37 0A                    7    .db 10
   4C38 B6 25                 8    .dw _floor_ceiling_sp_0
   4C3A 00                    9    .db 0
   4C3B 00 00                10    .dw 0x0000
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 35.
Hexadecimal [16-Bits]



   4C3D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C3E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C3F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C40                     137 DefineEntity platav58, e_type_platform, 20, 180, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   03A3                       1 platav58::
   03A3                       2    DefineEntityAnnonimous e_type_platform, 20, 180, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4C40 18                    1    .db e_type_platform
   4C41 14                    2    .db 20
   4C42 B4                    3    .db 180
   4C43 00                    4    .db 0
   4C44 00                    5    .db 0
   4C45 05                    6    .db 5
   4C46 0A                    7    .db 10
   4C47 1E 20                 8    .dw _tiles_sp_00
   4C49 00                    9    .db 0
   4C4A 00 00                10    .dw 0x0000
   4C4C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C4D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C4E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C4F                     138 DefineEntity platav59, e_type_platform, 30, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   03B2                       1 platav59::
   03B2                       2    DefineEntityAnnonimous e_type_platform, 30, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4C4F 18                    1    .db e_type_platform
   4C50 1E                    2    .db 30
   4C51 A0                    3    .db 160
   4C52 00                    4    .db 0
   4C53 00                    5    .db 0
   4C54 05                    6    .db 5
   4C55 1E                    7    .db 30
   4C56 22 22                 8    .dw _walls_sp_0
   4C58 00                    9    .db 0
   4C59 00 00                10    .dw 0x0000
   4C5B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C5C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C5D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C5E                     139 DefineEntity tramp51, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   03C1                       1 tramp51::
   03C1                       2    DefineEntityAnnonimous e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4C5E 10                    1    .db e_type_trap
   4C5F 19                    2    .db 25
   4C60 B4                    3    .db 180
   4C61 00                    4    .db 0
   4C62 00                    5    .db 0
   4C63 05                    6    .db 5
   4C64 0A                    7    .db 10
   4C65 50 20                 8    .dw _tiles_sp_01
   4C67 00                    9    .db 0
   4C68 00 00                10    .dw 0x0000
   4C6A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 36.
Hexadecimal [16-Bits]



                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C6B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C6C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C6D                     140 DefineEntity tramp52, e_type_trap, 35, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   03D0                       1 tramp52::
   03D0                       2    DefineEntityAnnonimous e_type_trap, 35, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4C6D 10                    1    .db e_type_trap
   4C6E 23                    2    .db 35
   4C6F B4                    3    .db 180
   4C70 00                    4    .db 0
   4C71 00                    5    .db 0
   4C72 05                    6    .db 5
   4C73 0A                    7    .db 10
   4C74 50 20                 8    .dw _tiles_sp_01
   4C76 00                    9    .db 0
   4C77 00 00                10    .dw 0x0000
   4C79 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C7A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C7B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C7C                     141 DefineEntity tramp53, e_type_trap, 47, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   03DF                       1 tramp53::
   03DF                       2    DefineEntityAnnonimous e_type_trap, 47, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4C7C 10                    1    .db e_type_trap
   4C7D 2F                    2    .db 47
   4C7E 96                    3    .db 150
   4C7F 00                    4    .db 0
   4C80 00                    5    .db 0
   4C81 05                    6    .db 5
   4C82 0A                    7    .db 10
   4C83 50 20                 8    .dw _tiles_sp_01
   4C85 00                    9    .db 0
   4C86 00 00                10    .dw 0x0000
   4C88 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4C89 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C8A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C8B                     142 DefineEntity tramp54, e_type_trap, 70, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   03EE                       1 tramp54::
   03EE                       2    DefineEntityAnnonimous e_type_trap, 70, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4C8B 10                    1    .db e_type_trap
   4C8C 46                    2    .db 70
   4C8D 96                    3    .db 150
   4C8E 00                    4    .db 0
   4C8F 00                    5    .db 0
   4C90 05                    6    .db 5
   4C91 0A                    7    .db 10
   4C92 50 20                 8    .dw _tiles_sp_01
   4C94 00                    9    .db 0
   4C95 00 00                10    .dw 0x0000
   4C97 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 37.
Hexadecimal [16-Bits]



   4C98 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4C99 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4C9A                     143 DefineEntity tramp55, e_type_trap, 20, 95, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x002
   03FD                       1 tramp55::
   03FD                       2    DefineEntityAnnonimous e_type_trap, 20, 95, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x002
   4C9A 10                    1    .db e_type_trap
   4C9B 14                    2    .db 20
   4C9C 5F                    3    .db 95
   4C9D 00                    4    .db 0
   4C9E 00                    5    .db 0
   4C9F 05                    6    .db 5
   4CA0 0A                    7    .db 10
   4CA1 50 20                 8    .dw _tiles_sp_01
   4CA3 00                    9    .db 0
   4CA4 00 00                10    .dw 0x0000
   4CA6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4CA7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4CA8 02                   14    .db 0x002     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            144 
                            145 ;;NIVEL 6
   4CA9                     146 DefineEntity portal60, e_type_portal, 30, 70, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   040C                       1 portal60::
   040C                       2    DefineEntityAnnonimous e_type_portal, 30, 70, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4CA9 12                    1    .db e_type_portal
   4CAA 1E                    2    .db 30
   4CAB 46                    3    .db 70
   4CAC 00                    4    .db 0
   4CAD 00                    5    .db 0
   4CAE 05                    6    .db 5
   4CAF 0A                    7    .db 10
   4CB0 82 20                 8    .dw _tiles_sp_02
   4CB2 00                    9    .db 0
   4CB3 00 00                10    .dw 0x0000
   4CB5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4CB6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4CB7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4CB8                     147 DefineEntity platah61, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   041B                       1 platah61::
   041B                       2    DefineEntityAnnonimous e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4CB8 18                    1    .db e_type_platform
   4CB9 0A                    2    .db 10
   4CBA A0                    3    .db 160
   4CBB 00                    4    .db 0
   4CBC 00                    5    .db 0
   4CBD 0F                    6    .db 15
   4CBE 0A                    7    .db 10
   4CBF B6 25                 8    .dw _floor_ceiling_sp_0
   4CC1 00                    9    .db 0
   4CC2 00 00                10    .dw 0x0000
   4CC4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 38.
Hexadecimal [16-Bits]



                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4CC5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4CC6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4CC7                     148 DefineEntity platah62, e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   042A                       1 platah62::
   042A                       2    DefineEntityAnnonimous e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4CC7 18                    1    .db e_type_platform
   4CC8 23                    2    .db 35
   4CC9 8C                    3    .db 140
   4CCA 00                    4    .db 0
   4CCB 00                    5    .db 0
   4CCC 0F                    6    .db 15
   4CCD 0A                    7    .db 10
   4CCE B6 25                 8    .dw _floor_ceiling_sp_0
   4CD0 00                    9    .db 0
   4CD1 00 00                10    .dw 0x0000
   4CD3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4CD4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4CD5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4CD6                     149 DefineEntity platah63, e_type_platform, 60, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0439                       1 platah63::
   0439                       2    DefineEntityAnnonimous e_type_platform, 60, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4CD6 18                    1    .db e_type_platform
   4CD7 3C                    2    .db 60
   4CD8 87                    3    .db 135
   4CD9 00                    4    .db 0
   4CDA 00                    5    .db 0
   4CDB 05                    6    .db 5
   4CDC 0A                    7    .db 10
   4CDD 1E 20                 8    .dw _tiles_sp_00
   4CDF 00                    9    .db 0
   4CE0 00 00                10    .dw 0x0000
   4CE2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4CE3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4CE4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4CE5                     150 DefineEntity platah64, e_type_platform, 75, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0448                       1 platah64::
   0448                       2    DefineEntityAnnonimous e_type_platform, 75, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4CE5 18                    1    .db e_type_platform
   4CE6 4B                    2    .db 75
   4CE7 A0                    3    .db 160
   4CE8 00                    4    .db 0
   4CE9 00                    5    .db 0
   4CEA 05                    6    .db 5
   4CEB 0A                    7    .db 10
   4CEC 1E 20                 8    .dw _tiles_sp_00
   4CEE 00                    9    .db 0
   4CEF 00 00                10    .dw 0x0000
   4CF1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 39.
Hexadecimal [16-Bits]



   4CF2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4CF3 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4CF4                     151 DefineEntity platah65, e_type_platform, 70, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0457                       1 platah65::
   0457                       2    DefineEntityAnnonimous e_type_platform, 70, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4CF4 18                    1    .db e_type_platform
   4CF5 46                    2    .db 70
   4CF6 82                    3    .db 130
   4CF7 00                    4    .db 0
   4CF8 00                    5    .db 0
   4CF9 05                    6    .db 5
   4CFA 0A                    7    .db 10
   4CFB 1E 20                 8    .dw _tiles_sp_00
   4CFD 00                    9    .db 0
   4CFE 00 00                10    .dw 0x0000
   4D00 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D01 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D02 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D03                     152 DefineEntity platah66, e_type_platform, 65, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0466                       1 platah66::
   0466                       2    DefineEntityAnnonimous e_type_platform, 65, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4D03 18                    1    .db e_type_platform
   4D04 41                    2    .db 65
   4D05 64                    3    .db 100
   4D06 00                    4    .db 0
   4D07 00                    5    .db 0
   4D08 05                    6    .db 5
   4D09 0A                    7    .db 10
   4D0A 1E 20                 8    .dw _tiles_sp_00
   4D0C 00                    9    .db 0
   4D0D 00 00                10    .dw 0x0000
   4D0F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D10 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D11 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D12                     153 DefineEntity platah67, e_type_platform, 40, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0475                       1 platah67::
   0475                       2    DefineEntityAnnonimous e_type_platform, 40, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4D12 18                    1    .db e_type_platform
   4D13 28                    2    .db 40
   4D14 46                    3    .db 70
   4D15 00                    4    .db 0
   4D16 00                    5    .db 0
   4D17 0F                    6    .db 15
   4D18 0A                    7    .db 10
   4D19 B6 25                 8    .dw _floor_ceiling_sp_0
   4D1B 00                    9    .db 0
   4D1C 00 00                10    .dw 0x0000
   4D1E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D1F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 40.
Hexadecimal [16-Bits]



   4D20 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D21                     154 DefineEntity platah68, e_type_platform, 15, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0484                       1 platah68::
   0484                       2    DefineEntityAnnonimous e_type_platform, 15, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4D21 18                    1    .db e_type_platform
   4D22 0F                    2    .db 15
   4D23 3C                    3    .db 60
   4D24 00                    4    .db 0
   4D25 00                    5    .db 0
   4D26 0F                    6    .db 15
   4D27 0A                    7    .db 10
   4D28 B6 25                 8    .dw _floor_ceiling_sp_0
   4D2A 00                    9    .db 0
   4D2B 00 00                10    .dw 0x0000
   4D2D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D2E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D2F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D30                     155 DefineEntity tramp61, e_type_trap, 10, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0493                       1 tramp61::
   0493                       2    DefineEntityAnnonimous e_type_trap, 10, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D30 10                    1    .db e_type_trap
   4D31 0A                    2    .db 10
   4D32 B4                    3    .db 180
   4D33 00                    4    .db 0
   4D34 00                    5    .db 0
   4D35 05                    6    .db 5
   4D36 0A                    7    .db 10
   4D37 50 20                 8    .dw _tiles_sp_01
   4D39 00                    9    .db 0
   4D3A 00 00                10    .dw 0x0000
   4D3C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D3D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D3E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D3F                     156 DefineEntity tramp62, e_type_trap, 15, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04A2                       1 tramp62::
   04A2                       2    DefineEntityAnnonimous e_type_trap, 15, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D3F 10                    1    .db e_type_trap
   4D40 0F                    2    .db 15
   4D41 96                    3    .db 150
   4D42 00                    4    .db 0
   4D43 00                    5    .db 0
   4D44 05                    6    .db 5
   4D45 0A                    7    .db 10
   4D46 50 20                 8    .dw _tiles_sp_01
   4D48 00                    9    .db 0
   4D49 00 00                10    .dw 0x0000
   4D4B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D4C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D4D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 41.
Hexadecimal [16-Bits]



                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D4E                     157 DefineEntity tramp63, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04B1                       1 tramp63::
   04B1                       2    DefineEntityAnnonimous e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D4E 10                    1    .db e_type_trap
   4D4F 19                    2    .db 25
   4D50 B4                    3    .db 180
   4D51 00                    4    .db 0
   4D52 00                    5    .db 0
   4D53 05                    6    .db 5
   4D54 0A                    7    .db 10
   4D55 50 20                 8    .dw _tiles_sp_01
   4D57 00                    9    .db 0
   4D58 00 00                10    .dw 0x0000
   4D5A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D5B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D5C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D5D                     158 DefineEntity tramp64, e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04C0                       1 tramp64::
   04C0                       2    DefineEntityAnnonimous e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D5D 10                    1    .db e_type_trap
   4D5E 1E                    2    .db 30
   4D5F B4                    3    .db 180
   4D60 00                    4    .db 0
   4D61 00                    5    .db 0
   4D62 05                    6    .db 5
   4D63 0A                    7    .db 10
   4D64 50 20                 8    .dw _tiles_sp_01
   4D66 00                    9    .db 0
   4D67 00 00                10    .dw 0x0000
   4D69 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D6A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D6B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D6C                     159 DefineEntity tramp65, e_type_trap, 40, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04CF                       1 tramp65::
   04CF                       2    DefineEntityAnnonimous e_type_trap, 40, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D6C 10                    1    .db e_type_trap
   4D6D 28                    2    .db 40
   4D6E 82                    3    .db 130
   4D6F 00                    4    .db 0
   4D70 00                    5    .db 0
   4D71 05                    6    .db 5
   4D72 0A                    7    .db 10
   4D73 50 20                 8    .dw _tiles_sp_01
   4D75 00                    9    .db 0
   4D76 00 00                10    .dw 0x0000
   4D78 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D79 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D7A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 42.
Hexadecimal [16-Bits]



   4D7B                     160 DefineEntity tramp66, e_type_trap, 60, 125, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04DE                       1 tramp66::
   04DE                       2    DefineEntityAnnonimous e_type_trap, 60, 125, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D7B 10                    1    .db e_type_trap
   4D7C 3C                    2    .db 60
   4D7D 7D                    3    .db 125
   4D7E 00                    4    .db 0
   4D7F 00                    5    .db 0
   4D80 05                    6    .db 5
   4D81 0A                    7    .db 10
   4D82 50 20                 8    .dw _tiles_sp_01
   4D84 00                    9    .db 0
   4D85 00 00                10    .dw 0x0000
   4D87 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D88 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D89 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D8A                     161 DefineEntity tramp67, e_type_trap, 50, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04ED                       1 tramp67::
   04ED                       2    DefineEntityAnnonimous e_type_trap, 50, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D8A 10                    1    .db e_type_trap
   4D8B 32                    2    .db 50
   4D8C B4                    3    .db 180
   4D8D 00                    4    .db 0
   4D8E 00                    5    .db 0
   4D8F 05                    6    .db 5
   4D90 0A                    7    .db 10
   4D91 50 20                 8    .dw _tiles_sp_01
   4D93 00                    9    .db 0
   4D94 00 00                10    .dw 0x0000
   4D96 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4D97 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4D98 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4D99                     162 DefineEntity tramp68, e_type_trap, 40, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   04FC                       1 tramp68::
   04FC                       2    DefineEntityAnnonimous e_type_trap, 40, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4D99 10                    1    .db e_type_trap
   4D9A 28                    2    .db 40
   4D9B 3C                    3    .db 60
   4D9C 00                    4    .db 0
   4D9D 00                    5    .db 0
   4D9E 05                    6    .db 5
   4D9F 0A                    7    .db 10
   4DA0 50 20                 8    .dw _tiles_sp_01
   4DA2 00                    9    .db 0
   4DA3 00 00                10    .dw 0x0000
   4DA5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4DA6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4DA7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4DA8                     163 DefineEntity tramp69, e_type_trap, 25, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 43.
Hexadecimal [16-Bits]



   050B                       1 tramp69::
   050B                       2    DefineEntityAnnonimous e_type_trap, 25, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4DA8 10                    1    .db e_type_trap
   4DA9 19                    2    .db 25
   4DAA 32                    3    .db 50
   4DAB 00                    4    .db 0
   4DAC 00                    5    .db 0
   4DAD 05                    6    .db 5
   4DAE 0A                    7    .db 10
   4DAF 50 20                 8    .dw _tiles_sp_01
   4DB1 00                    9    .db 0
   4DB2 00 00                10    .dw 0x0000
   4DB4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4DB5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4DB6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            164 
                            165 ;;NIVEL 7
   4DB7                     166 DefineEntity portal70, e_type_portal, 75, 30, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   051A                       1 portal70::
   051A                       2    DefineEntityAnnonimous e_type_portal, 75, 30, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4DB7 12                    1    .db e_type_portal
   4DB8 4B                    2    .db 75
   4DB9 1E                    3    .db 30
   4DBA 00                    4    .db 0
   4DBB 00                    5    .db 0
   4DBC 05                    6    .db 5
   4DBD 0A                    7    .db 10
   4DBE 82 20                 8    .dw _tiles_sp_02
   4DC0 00                    9    .db 0
   4DC1 00 00                10    .dw 0x0000
   4DC3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4DC4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4DC5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4DC6                     167 DefineEntity platah71, e_type_platform, 30, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0529                       1 platah71::
   0529                       2    DefineEntityAnnonimous e_type_platform, 30, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4DC6 18                    1    .db e_type_platform
   4DC7 1E                    2    .db 30
   4DC8 96                    3    .db 150
   4DC9 00                    4    .db 0
   4DCA 00                    5    .db 0
   4DCB 0F                    6    .db 15
   4DCC 0A                    7    .db 10
   4DCD B6 25                 8    .dw _floor_ceiling_sp_0
   4DCF 00                    9    .db 0
   4DD0 00 00                10    .dw 0x0000
   4DD2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4DD3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4DD4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 44.
Hexadecimal [16-Bits]



   4DD5                     168 DefineEntity platah72, e_type_platform, 5, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0538                       1 platah72::
   0538                       2    DefineEntityAnnonimous e_type_platform, 5, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4DD5 18                    1    .db e_type_platform
   4DD6 05                    2    .db 5
   4DD7 A0                    3    .db 160
   4DD8 00                    4    .db 0
   4DD9 00                    5    .db 0
   4DDA 0F                    6    .db 15
   4DDB 0A                    7    .db 10
   4DDC B6 25                 8    .dw _floor_ceiling_sp_0
   4DDE 00                    9    .db 0
   4DDF 00 00                10    .dw 0x0000
   4DE1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4DE2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4DE3 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4DE4                     169 DefineEntity platah73, e_type_platform, 45, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0547                       1 platah73::
   0547                       2    DefineEntityAnnonimous e_type_platform, 45, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4DE4 18                    1    .db e_type_platform
   4DE5 2D                    2    .db 45
   4DE6 96                    3    .db 150
   4DE7 00                    4    .db 0
   4DE8 00                    5    .db 0
   4DE9 0F                    6    .db 15
   4DEA 0A                    7    .db 10
   4DEB B6 25                 8    .dw _floor_ceiling_sp_0
   4DED 00                    9    .db 0
   4DEE 00 00                10    .dw 0x0000
   4DF0 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4DF1 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4DF2 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4DF3                     170 DefineEntity platah74, e_type_platform, 60, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0556                       1 platah74::
   0556                       2    DefineEntityAnnonimous e_type_platform, 60, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4DF3 18                    1    .db e_type_platform
   4DF4 3C                    2    .db 60
   4DF5 96                    3    .db 150
   4DF6 00                    4    .db 0
   4DF7 00                    5    .db 0
   4DF8 0F                    6    .db 15
   4DF9 0A                    7    .db 10
   4DFA B6 25                 8    .dw _floor_ceiling_sp_0
   4DFC 00                    9    .db 0
   4DFD 00 00                10    .dw 0x0000
   4DFF 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E00 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E01 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E02                     171 DefineEntity platah75, e_type_platform, 75, 150, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 45.
Hexadecimal [16-Bits]



   0565                       1 platah75::
   0565                       2    DefineEntityAnnonimous e_type_platform, 75, 150, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4E02 18                    1    .db e_type_platform
   4E03 4B                    2    .db 75
   4E04 96                    3    .db 150
   4E05 00                    4    .db 0
   4E06 00                    5    .db 0
   4E07 05                    6    .db 5
   4E08 0A                    7    .db 10
   4E09 1E 20                 8    .dw _tiles_sp_00
   4E0B 00                    9    .db 0
   4E0C 00 00                10    .dw 0x0000
   4E0E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E0F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E10 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E11                     172 DefineEntity platah76, e_type_platform, 60, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0574                       1 platah76::
   0574                       2    DefineEntityAnnonimous e_type_platform, 60, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E11 18                    1    .db e_type_platform
   4E12 3C                    2    .db 60
   4E13 78                    3    .db 120
   4E14 00                    4    .db 0
   4E15 00                    5    .db 0
   4E16 0F                    6    .db 15
   4E17 0A                    7    .db 10
   4E18 B6 25                 8    .dw _floor_ceiling_sp_0
   4E1A 00                    9    .db 0
   4E1B 00 00                10    .dw 0x0000
   4E1D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E1E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E1F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E20                     173 DefineEntity platah77, e_type_platform, 40, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0583                       1 platah77::
   0583                       2    DefineEntityAnnonimous e_type_platform, 40, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E20 18                    1    .db e_type_platform
   4E21 28                    2    .db 40
   4E22 5A                    3    .db 90
   4E23 00                    4    .db 0
   4E24 00                    5    .db 0
   4E25 0F                    6    .db 15
   4E26 0A                    7    .db 10
   4E27 B6 25                 8    .dw _floor_ceiling_sp_0
   4E29 00                    9    .db 0
   4E2A 00 00                10    .dw 0x0000
   4E2C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E2D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E2E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E2F                     174 DefineEntity platah78, e_type_platform, 25, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0592                       1 platah78::
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 46.
Hexadecimal [16-Bits]



   0592                       2    DefineEntityAnnonimous e_type_platform, 25, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E2F 18                    1    .db e_type_platform
   4E30 19                    2    .db 25
   4E31 5A                    3    .db 90
   4E32 00                    4    .db 0
   4E33 00                    5    .db 0
   4E34 0F                    6    .db 15
   4E35 0A                    7    .db 10
   4E36 B6 25                 8    .dw _floor_ceiling_sp_0
   4E38 00                    9    .db 0
   4E39 00 00                10    .dw 0x0000
   4E3B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E3C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E3D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E3E                     175 DefineEntity platah79, e_type_platform, 0, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   05A1                       1 platah79::
   05A1                       2    DefineEntityAnnonimous e_type_platform, 0, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E3E 18                    1    .db e_type_platform
   4E3F 00                    2    .db 0
   4E40 46                    3    .db 70
   4E41 00                    4    .db 0
   4E42 00                    5    .db 0
   4E43 0F                    6    .db 15
   4E44 0A                    7    .db 10
   4E45 B6 25                 8    .dw _floor_ceiling_sp_0
   4E47 00                    9    .db 0
   4E48 00 00                10    .dw 0x0000
   4E4A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E4B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E4C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E4D                     176 DefineEntity platah710, e_type_platform, 15, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   05B0                       1 platah710::
   05B0                       2    DefineEntityAnnonimous e_type_platform, 15, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E4D 18                    1    .db e_type_platform
   4E4E 0F                    2    .db 15
   4E4F 28                    3    .db 40
   4E50 00                    4    .db 0
   4E51 00                    5    .db 0
   4E52 0F                    6    .db 15
   4E53 0A                    7    .db 10
   4E54 B6 25                 8    .dw _floor_ceiling_sp_0
   4E56 00                    9    .db 0
   4E57 00 00                10    .dw 0x0000
   4E59 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E5A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E5B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E5C                     177 DefineEntity platah711, e_type_platform, 35, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   05BF                       1 platah711::
   05BF                       2    DefineEntityAnnonimous e_type_platform, 35, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 47.
Hexadecimal [16-Bits]



   4E5C 18                    1    .db e_type_platform
   4E5D 23                    2    .db 35
   4E5E 28                    3    .db 40
   4E5F 00                    4    .db 0
   4E60 00                    5    .db 0
   4E61 0F                    6    .db 15
   4E62 0A                    7    .db 10
   4E63 B6 25                 8    .dw _floor_ceiling_sp_0
   4E65 00                    9    .db 0
   4E66 00 00                10    .dw 0x0000
   4E68 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E69 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E6A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E6B                     178 DefineEntity platah712, e_type_platform, 50, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   05CE                       1 platah712::
   05CE                       2    DefineEntityAnnonimous e_type_platform, 50, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E6B 18                    1    .db e_type_platform
   4E6C 32                    2    .db 50
   4E6D 28                    3    .db 40
   4E6E 00                    4    .db 0
   4E6F 00                    5    .db 0
   4E70 0F                    6    .db 15
   4E71 0A                    7    .db 10
   4E72 B6 25                 8    .dw _floor_ceiling_sp_0
   4E74 00                    9    .db 0
   4E75 00 00                10    .dw 0x0000
   4E77 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E78 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E79 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E7A                     179 DefineEntity platah713, e_type_platform, 65, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   05DD                       1 platah713::
   05DD                       2    DefineEntityAnnonimous e_type_platform, 65, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4E7A 18                    1    .db e_type_platform
   4E7B 41                    2    .db 65
   4E7C 28                    3    .db 40
   4E7D 00                    4    .db 0
   4E7E 00                    5    .db 0
   4E7F 0F                    6    .db 15
   4E80 0A                    7    .db 10
   4E81 B6 25                 8    .dw _floor_ceiling_sp_0
   4E83 00                    9    .db 0
   4E84 00 00                10    .dw 0x0000
   4E86 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E87 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E88 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E89                     180 DefineEntity platah714, e_type_platform, 20, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   05EC                       1 platah714::
   05EC                       2    DefineEntityAnnonimous e_type_platform, 20, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4E89 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 48.
Hexadecimal [16-Bits]



   4E8A 14                    2    .db 20
   4E8B 5A                    3    .db 90
   4E8C 00                    4    .db 0
   4E8D 00                    5    .db 0
   4E8E 05                    6    .db 5
   4E8F 0A                    7    .db 10
   4E90 1E 20                 8    .dw _tiles_sp_00
   4E92 00                    9    .db 0
   4E93 00 00                10    .dw 0x0000
   4E95 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4E96 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4E97 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4E98                     181 DefineEntity tramp71, e_type_trap, 25, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   05FB                       1 tramp71::
   05FB                       2    DefineEntityAnnonimous e_type_trap, 25, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   4E98 10                    1    .db e_type_trap
   4E99 19                    2    .db 25
   4E9A B4                    3    .db 180
   4E9B 00                    4    .db 0
   4E9C 00                    5    .db 0
   4E9D 32                    6    .db 50
   4E9E 0A                    7    .db 10
   4E9F 1A 1E                 8    .dw _linea_pin_sp
   4EA1 00                    9    .db 0
   4EA2 00 00                10    .dw 0x0000
   4EA4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4EA5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4EA6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4EA7                     182 DefineEntity tramp72, e_type_trap, 15, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   060A                       1 tramp72::
   060A                       2    DefineEntityAnnonimous e_type_trap, 15, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4EA7 10                    1    .db e_type_trap
   4EA8 0F                    2    .db 15
   4EA9 5A                    3    .db 90
   4EAA 00                    4    .db 0
   4EAB 00                    5    .db 0
   4EAC 05                    6    .db 5
   4EAD 0A                    7    .db 10
   4EAE 50 20                 8    .dw _tiles_sp_01
   4EB0 00                    9    .db 0
   4EB1 00 00                10    .dw 0x0000
   4EB3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4EB4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4EB5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4EB6                     183 DefineEntity tramp73, e_type_trap, 30, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0619                       1 tramp73::
   0619                       2    DefineEntityAnnonimous e_type_trap, 30, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4EB6 10                    1    .db e_type_trap
   4EB7 1E                    2    .db 30
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 49.
Hexadecimal [16-Bits]



   4EB8 28                    3    .db 40
   4EB9 00                    4    .db 0
   4EBA 00                    5    .db 0
   4EBB 05                    6    .db 5
   4EBC 0A                    7    .db 10
   4EBD 50 20                 8    .dw _tiles_sp_01
   4EBF 00                    9    .db 0
   4EC0 00 00                10    .dw 0x0000
   4EC2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4EC3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4EC4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4EC5                     184 DefineEntity enemyh71, e_type_enemy, 52, 140, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x17
   0628                       1 enemyh71::
   0628                       2    DefineEntityAnnonimous e_type_enemy, 52, 140, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x17
   4EC5 B0                    1    .db e_type_enemy
   4EC6 34                    2    .db 52
   4EC7 8C                    3    .db 140
   4EC8 00                    4    .db 0
   4EC9 00                    5    .db 0
   4ECA 05                    6    .db 5
   4ECB 0A                    7    .db 10
   4ECC E6 20                 8    .dw _tiles_sp_04
   4ECE 00                    9    .db 0
   4ECF 00 00                10    .dw 0x0000
   4ED1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4ED2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4ED3 17                   14    .db 0x17     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            185 
                            186 ;;NIVEL 8
                            187 
   4ED4                     188 DefineEntity portal80, e_type_portal, 5, 100, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0637                       1 portal80::
   0637                       2    DefineEntityAnnonimous e_type_portal, 5, 100, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4ED4 12                    1    .db e_type_portal
   4ED5 05                    2    .db 5
   4ED6 64                    3    .db 100
   4ED7 00                    4    .db 0
   4ED8 00                    5    .db 0
   4ED9 05                    6    .db 5
   4EDA 0A                    7    .db 10
   4EDB 82 20                 8    .dw _tiles_sp_02
   4EDD 00                    9    .db 0
   4EDE 00 00                10    .dw 0x0000
   4EE0 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4EE1 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4EE2 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4EE3                     189 DefineEntity platah81, e_type_platform, 40, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0646                       1 platah81::
   0646                       2    DefineEntityAnnonimous e_type_platform, 40, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 50.
Hexadecimal [16-Bits]



   4EE3 18                    1    .db e_type_platform
   4EE4 28                    2    .db 40
   4EE5 A0                    3    .db 160
   4EE6 00                    4    .db 0
   4EE7 00                    5    .db 0
   4EE8 05                    6    .db 5
   4EE9 0A                    7    .db 10
   4EEA 1E 20                 8    .dw _tiles_sp_00
   4EEC 00                    9    .db 0
   4EED 00 00                10    .dw 0x0000
   4EEF 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4EF0 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4EF1 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4EF2                     190 DefineEntity platah82, e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0655                       1 platah82::
   0655                       2    DefineEntityAnnonimous e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4EF2 18                    1    .db e_type_platform
   4EF3 46                    2    .db 70
   4EF4 A0                    3    .db 160
   4EF5 00                    4    .db 0
   4EF6 00                    5    .db 0
   4EF7 05                    6    .db 5
   4EF8 0A                    7    .db 10
   4EF9 1E 20                 8    .dw _tiles_sp_00
   4EFB 00                    9    .db 0
   4EFC 00 00                10    .dw 0x0000
   4EFE 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4EFF 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F00 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F01                     191 DefineEntity platah83, e_type_platform, 70, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0664                       1 platah83::
   0664                       2    DefineEntityAnnonimous e_type_platform, 70, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4F01 18                    1    .db e_type_platform
   4F02 46                    2    .db 70
   4F03 87                    3    .db 135
   4F04 00                    4    .db 0
   4F05 00                    5    .db 0
   4F06 05                    6    .db 5
   4F07 0A                    7    .db 10
   4F08 1E 20                 8    .dw _tiles_sp_00
   4F0A 00                    9    .db 0
   4F0B 00 00                10    .dw 0x0000
   4F0D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F0E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F0F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F10                     192 DefineEntity platah84, e_type_platform, 65, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0673                       1 platah84::
   0673                       2    DefineEntityAnnonimous e_type_platform, 65, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F10 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 51.
Hexadecimal [16-Bits]



   4F11 41                    2    .db 65
   4F12 6E                    3    .db 110
   4F13 00                    4    .db 0
   4F14 00                    5    .db 0
   4F15 0F                    6    .db 15
   4F16 0A                    7    .db 10
   4F17 B6 25                 8    .dw _floor_ceiling_sp_0
   4F19 00                    9    .db 0
   4F1A 00 00                10    .dw 0x0000
   4F1C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F1D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F1E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F1F                     193 DefineEntity platah85, e_type_platform, 35, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0682                       1 platah85::
   0682                       2    DefineEntityAnnonimous e_type_platform, 35, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F1F 18                    1    .db e_type_platform
   4F20 23                    2    .db 35
   4F21 6E                    3    .db 110
   4F22 00                    4    .db 0
   4F23 00                    5    .db 0
   4F24 0F                    6    .db 15
   4F25 0A                    7    .db 10
   4F26 B6 25                 8    .dw _floor_ceiling_sp_0
   4F28 00                    9    .db 0
   4F29 00 00                10    .dw 0x0000
   4F2B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F2C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F2D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F2E                     194 DefineEntity platah86, e_type_platform, 5, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0691                       1 platah86::
   0691                       2    DefineEntityAnnonimous e_type_platform, 5, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F2E 18                    1    .db e_type_platform
   4F2F 05                    2    .db 5
   4F30 6E                    3    .db 110
   4F31 00                    4    .db 0
   4F32 00                    5    .db 0
   4F33 0F                    6    .db 15
   4F34 0A                    7    .db 10
   4F35 B6 25                 8    .dw _floor_ceiling_sp_0
   4F37 00                    9    .db 0
   4F38 00 00                10    .dw 0x0000
   4F3A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F3B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F3C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            195 
   4F3D                     196 DefineEntity platah87, e_type_platform, 10, 30, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06A0                       1 platah87::
   06A0                       2    DefineEntityAnnonimous e_type_platform, 10, 30, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F3D 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 52.
Hexadecimal [16-Bits]



   4F3E 0A                    2    .db 10
   4F3F 1E                    3    .db 30
   4F40 00                    4    .db 0
   4F41 00                    5    .db 0
   4F42 0F                    6    .db 15
   4F43 0A                    7    .db 10
   4F44 B6 25                 8    .dw _floor_ceiling_sp_0
   4F46 00                    9    .db 0
   4F47 00 00                10    .dw 0x0000
   4F49 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F4A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F4B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F4C                     197 DefineEntity platah88, e_type_platform, 10, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06AF                       1 platah88::
   06AF                       2    DefineEntityAnnonimous e_type_platform, 10, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F4C 18                    1    .db e_type_platform
   4F4D 0A                    2    .db 10
   4F4E 28                    3    .db 40
   4F4F 00                    4    .db 0
   4F50 00                    5    .db 0
   4F51 0F                    6    .db 15
   4F52 0A                    7    .db 10
   4F53 B6 25                 8    .dw _floor_ceiling_sp_0
   4F55 00                    9    .db 0
   4F56 00 00                10    .dw 0x0000
   4F58 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F59 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F5A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F5B                     198 DefineEntity platah89, e_type_platform, 10, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06BE                       1 platah89::
   06BE                       2    DefineEntityAnnonimous e_type_platform, 10, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F5B 18                    1    .db e_type_platform
   4F5C 0A                    2    .db 10
   4F5D 32                    3    .db 50
   4F5E 00                    4    .db 0
   4F5F 00                    5    .db 0
   4F60 0F                    6    .db 15
   4F61 0A                    7    .db 10
   4F62 B6 25                 8    .dw _floor_ceiling_sp_0
   4F64 00                    9    .db 0
   4F65 00 00                10    .dw 0x0000
   4F67 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F68 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F69 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            199 
   4F6A                     200 DefineEntity platah810, e_type_platform, 55, 30, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06CD                       1 platah810::
   06CD                       2    DefineEntityAnnonimous e_type_platform, 55, 30, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F6A 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 53.
Hexadecimal [16-Bits]



   4F6B 37                    2    .db 55
   4F6C 1E                    3    .db 30
   4F6D 00                    4    .db 0
   4F6E 00                    5    .db 0
   4F6F 0F                    6    .db 15
   4F70 0A                    7    .db 10
   4F71 B6 25                 8    .dw _floor_ceiling_sp_0
   4F73 00                    9    .db 0
   4F74 00 00                10    .dw 0x0000
   4F76 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F77 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F78 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F79                     201 DefineEntity platah811, e_type_platform, 55, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06DC                       1 platah811::
   06DC                       2    DefineEntityAnnonimous e_type_platform, 55, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F79 18                    1    .db e_type_platform
   4F7A 37                    2    .db 55
   4F7B 28                    3    .db 40
   4F7C 00                    4    .db 0
   4F7D 00                    5    .db 0
   4F7E 0F                    6    .db 15
   4F7F 0A                    7    .db 10
   4F80 B6 25                 8    .dw _floor_ceiling_sp_0
   4F82 00                    9    .db 0
   4F83 00 00                10    .dw 0x0000
   4F85 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F86 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F87 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4F88                     202 DefineEntity platah812, e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06EB                       1 platah812::
   06EB                       2    DefineEntityAnnonimous e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F88 18                    1    .db e_type_platform
   4F89 37                    2    .db 55
   4F8A 32                    3    .db 50
   4F8B 00                    4    .db 0
   4F8C 00                    5    .db 0
   4F8D 0F                    6    .db 15
   4F8E 0A                    7    .db 10
   4F8F B6 25                 8    .dw _floor_ceiling_sp_0
   4F91 00                    9    .db 0
   4F92 00 00                10    .dw 0x0000
   4F94 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4F95 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4F96 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            203 
   4F97                     204 DefineEntity platav81, e_type_platform, 25, 140, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   06FA                       1 platav81::
   06FA                       2    DefineEntityAnnonimous e_type_platform, 25, 140, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4F97 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 54.
Hexadecimal [16-Bits]



   4F98 19                    2    .db 25
   4F99 8C                    3    .db 140
   4F9A 00                    4    .db 0
   4F9B 00                    5    .db 0
   4F9C 05                    6    .db 5
   4F9D 1E                    7    .db 30
   4F9E 22 22                 8    .dw _walls_sp_0
   4FA0 00                    9    .db 0
   4FA1 00 00                10    .dw 0x0000
   4FA3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FA4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FA5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4FA6                     205 DefineEntity platav82, e_type_platform, 55, 140, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0709                       1 platav82::
   0709                       2    DefineEntityAnnonimous e_type_platform, 55, 140, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   4FA6 18                    1    .db e_type_platform
   4FA7 37                    2    .db 55
   4FA8 8C                    3    .db 140
   4FA9 00                    4    .db 0
   4FAA 00                    5    .db 0
   4FAB 05                    6    .db 5
   4FAC 1E                    7    .db 30
   4FAD 22 22                 8    .dw _walls_sp_0
   4FAF 00                    9    .db 0
   4FB0 00 00                10    .dw 0x0000
   4FB2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FB3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FB4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4FB5                     206 DefineEntity enemy81, e_type_enemy, 40, 180, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x18
   0718                       1 enemy81::
   0718                       2    DefineEntityAnnonimous e_type_enemy, 40, 180, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x18
   4FB5 B0                    1    .db e_type_enemy
   4FB6 28                    2    .db 40
   4FB7 B4                    3    .db 180
   4FB8 00                    4    .db 0
   4FB9 00                    5    .db 0
   4FBA 05                    6    .db 5
   4FBB 0A                    7    .db 10
   4FBC E6 20                 8    .dw _tiles_sp_04
   4FBE 00                    9    .db 0
   4FBF 00 00                10    .dw 0x0000
   4FC1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FC2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FC3 18                   14    .db 0x18     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4FC4                     207 DefineEntity tramp80, e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0727                       1 tramp80::
   0727                       2    DefineEntityAnnonimous e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4FC4 10                    1    .db e_type_trap
   4FC5 19                    2    .db 25
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 55.
Hexadecimal [16-Bits]



   4FC6 82                    3    .db 130
   4FC7 00                    4    .db 0
   4FC8 00                    5    .db 0
   4FC9 05                    6    .db 5
   4FCA 0A                    7    .db 10
   4FCB 50 20                 8    .dw _tiles_sp_01
   4FCD 00                    9    .db 0
   4FCE 00 00                10    .dw 0x0000
   4FD0 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FD1 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FD2 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4FD3                     208 DefineEntity tramp81, e_type_trap, 55, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0736                       1 tramp81::
   0736                       2    DefineEntityAnnonimous e_type_trap, 55, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   4FD3 10                    1    .db e_type_trap
   4FD4 37                    2    .db 55
   4FD5 82                    3    .db 130
   4FD6 00                    4    .db 0
   4FD7 00                    5    .db 0
   4FD8 05                    6    .db 5
   4FD9 0A                    7    .db 10
   4FDA 50 20                 8    .dw _tiles_sp_01
   4FDC 00                    9    .db 0
   4FDD 00 00                10    .dw 0x0000
   4FDF 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FE0 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FE1 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            209 
                            210 ;;NIVEL 9
   4FE2                     211 DefineEntity portal90, e_type_portal, 5, 80, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0745                       1 portal90::
   0745                       2    DefineEntityAnnonimous e_type_portal, 5, 80, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   4FE2 12                    1    .db e_type_portal
   4FE3 05                    2    .db 5
   4FE4 50                    3    .db 80
   4FE5 00                    4    .db 0
   4FE6 00                    5    .db 0
   4FE7 05                    6    .db 5
   4FE8 0A                    7    .db 10
   4FE9 82 20                 8    .dw _tiles_sp_02
   4FEB 00                    9    .db 0
   4FEC 00 00                10    .dw 0x0000
   4FEE 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FEF 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FF0 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   4FF1                     212 DefineEntity platah91, e_type_platform, 10, 168, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0754                       1 platah91::
   0754                       2    DefineEntityAnnonimous e_type_platform, 10, 168, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   4FF1 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 56.
Hexadecimal [16-Bits]



   4FF2 0A                    2    .db 10
   4FF3 A8                    3    .db 168
   4FF4 00                    4    .db 0
   4FF5 00                    5    .db 0
   4FF6 05                    6    .db 5
   4FF7 0A                    7    .db 10
   4FF8 1E 20                 8    .dw _tiles_sp_00
   4FFA 00                    9    .db 0
   4FFB 00 00                10    .dw 0x0000
   4FFD 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   4FFE 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   4FFF 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5000                     213 DefineEntity platah92, e_type_platform, 20, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0763                       1 platah92::
   0763                       2    DefineEntityAnnonimous e_type_platform, 20, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5000 18                    1    .db e_type_platform
   5001 14                    2    .db 20
   5002 8C                    3    .db 140
   5003 00                    4    .db 0
   5004 00                    5    .db 0
   5005 0F                    6    .db 15
   5006 0A                    7    .db 10
   5007 B6 25                 8    .dw _floor_ceiling_sp_0
   5009 00                    9    .db 0
   500A 00 00                10    .dw 0x0000
   500C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   500D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   500E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   500F                     214 DefineEntity platah93, e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0772                       1 platah93::
   0772                       2    DefineEntityAnnonimous e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   500F 18                    1    .db e_type_platform
   5010 23                    2    .db 35
   5011 8C                    3    .db 140
   5012 00                    4    .db 0
   5013 00                    5    .db 0
   5014 0F                    6    .db 15
   5015 0A                    7    .db 10
   5016 B6 25                 8    .dw _floor_ceiling_sp_0
   5018 00                    9    .db 0
   5019 00 00                10    .dw 0x0000
   501B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   501C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   501D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   501E                     215 DefineEntity platah94, e_type_platform, 50, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0781                       1 platah94::
   0781                       2    DefineEntityAnnonimous e_type_platform, 50, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   501E 18                    1    .db e_type_platform
   501F 32                    2    .db 50
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 57.
Hexadecimal [16-Bits]



   5020 8C                    3    .db 140
   5021 00                    4    .db 0
   5022 00                    5    .db 0
   5023 0F                    6    .db 15
   5024 0A                    7    .db 10
   5025 B6 25                 8    .dw _floor_ceiling_sp_0
   5027 00                    9    .db 0
   5028 00 00                10    .dw 0x0000
   502A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   502B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   502C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   502D                     216 DefineEntity platah95, e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0790                       1 platah95::
   0790                       2    DefineEntityAnnonimous e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   502D 18                    1    .db e_type_platform
   502E 41                    2    .db 65
   502F 8C                    3    .db 140
   5030 00                    4    .db 0
   5031 00                    5    .db 0
   5032 0F                    6    .db 15
   5033 0A                    7    .db 10
   5034 B6 25                 8    .dw _floor_ceiling_sp_0
   5036 00                    9    .db 0
   5037 00 00                10    .dw 0x0000
   5039 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   503A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   503B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   503C                     217 DefineEntity platah96, e_type_platform, 75, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   079F                       1 platah96::
   079F                       2    DefineEntityAnnonimous e_type_platform, 75, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   503C 18                    1    .db e_type_platform
   503D 4B                    2    .db 75
   503E 6E                    3    .db 110
   503F 00                    4    .db 0
   5040 00                    5    .db 0
   5041 05                    6    .db 5
   5042 0A                    7    .db 10
   5043 1E 20                 8    .dw _tiles_sp_00
   5045 00                    9    .db 0
   5046 00 00                10    .dw 0x0000
   5048 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5049 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   504A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   504B                     218 DefineEntity platah97, e_type_platform, 55, 75, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   07AE                       1 platah97::
   07AE                       2    DefineEntityAnnonimous e_type_platform, 55, 75, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   504B 18                    1    .db e_type_platform
   504C 37                    2    .db 55
   504D 4B                    3    .db 75
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 58.
Hexadecimal [16-Bits]



   504E 00                    4    .db 0
   504F 00                    5    .db 0
   5050 0F                    6    .db 15
   5051 0A                    7    .db 10
   5052 B6 25                 8    .dw _floor_ceiling_sp_0
   5054 00                    9    .db 0
   5055 00 00                10    .dw 0x0000
   5057 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5058 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5059 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   505A                     219 DefineEntity platah98, e_type_platform, 40, 75, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   07BD                       1 platah98::
   07BD                       2    DefineEntityAnnonimous e_type_platform, 40, 75, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   505A 18                    1    .db e_type_platform
   505B 28                    2    .db 40
   505C 4B                    3    .db 75
   505D 00                    4    .db 0
   505E 00                    5    .db 0
   505F 0F                    6    .db 15
   5060 0A                    7    .db 10
   5061 B6 25                 8    .dw _floor_ceiling_sp_0
   5063 00                    9    .db 0
   5064 00 00                10    .dw 0x0000
   5066 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5067 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5068 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5069                     220 DefineEntity platah99, e_type_platform, 15, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   07CC                       1 platah99::
   07CC                       2    DefineEntityAnnonimous e_type_platform, 15, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5069 18                    1    .db e_type_platform
   506A 0F                    2    .db 15
   506B 32                    3    .db 50
   506C 00                    4    .db 0
   506D 00                    5    .db 0
   506E 0F                    6    .db 15
   506F 0A                    7    .db 10
   5070 B6 25                 8    .dw _floor_ceiling_sp_0
   5072 00                    9    .db 0
   5073 00 00                10    .dw 0x0000
   5075 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5076 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5077 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5078                     221 DefineEntity platah910, e_type_platform, 10, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   07DB                       1 platah910::
   07DB                       2    DefineEntityAnnonimous e_type_platform, 10, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5078 18                    1    .db e_type_platform
   5079 0A                    2    .db 10
   507A 32                    3    .db 50
   507B 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 59.
Hexadecimal [16-Bits]



   507C 00                    5    .db 0
   507D 05                    6    .db 5
   507E 0A                    7    .db 10
   507F 1E 20                 8    .dw _tiles_sp_00
   5081 00                    9    .db 0
   5082 00 00                10    .dw 0x0000
   5084 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5085 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5086 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5087                     222 DefineEntity platah911, e_type_platform, 5, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   07EA                       1 platah911::
   07EA                       2    DefineEntityAnnonimous e_type_platform, 5, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5087 18                    1    .db e_type_platform
   5088 05                    2    .db 5
   5089 32                    3    .db 50
   508A 00                    4    .db 0
   508B 00                    5    .db 0
   508C 05                    6    .db 5
   508D 0A                    7    .db 10
   508E 1E 20                 8    .dw _tiles_sp_00
   5090 00                    9    .db 0
   5091 00 00                10    .dw 0x0000
   5093 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5094 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5095 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5096                     223 DefineEntity platah912, e_type_platform, 5, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   07F9                       1 platah912::
   07F9                       2    DefineEntityAnnonimous e_type_platform, 5, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5096 18                    1    .db e_type_platform
   5097 05                    2    .db 5
   5098 5A                    3    .db 90
   5099 00                    4    .db 0
   509A 00                    5    .db 0
   509B 05                    6    .db 5
   509C 0A                    7    .db 10
   509D 1E 20                 8    .dw _tiles_sp_00
   509F 00                    9    .db 0
   50A0 00 00                10    .dw 0x0000
   50A2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50A3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50A4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            224 
   50A5                     225 DefineEntity tramp91, e_type_trap, 60, 65, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0808                       1 tramp91::
   0808                       2    DefineEntityAnnonimous e_type_trap, 60, 65, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   50A5 10                    1    .db e_type_trap
   50A6 3C                    2    .db 60
   50A7 41                    3    .db 65
   50A8 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 60.
Hexadecimal [16-Bits]



   50A9 00                    5    .db 0
   50AA 05                    6    .db 5
   50AB 0A                    7    .db 10
   50AC 50 20                 8    .dw _tiles_sp_01
   50AE 00                    9    .db 0
   50AF 00 00                10    .dw 0x0000
   50B1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50B2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50B3 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   50B4                     226 DefineEntity tramp92, e_type_trap, 45, 65, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0817                       1 tramp92::
   0817                       2    DefineEntityAnnonimous e_type_trap, 45, 65, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   50B4 10                    1    .db e_type_trap
   50B5 2D                    2    .db 45
   50B6 41                    3    .db 65
   50B7 00                    4    .db 0
   50B8 00                    5    .db 0
   50B9 05                    6    .db 5
   50BA 0A                    7    .db 10
   50BB 50 20                 8    .dw _tiles_sp_01
   50BD 00                    9    .db 0
   50BE 00 00                10    .dw 0x0000
   50C0 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50C1 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50C2 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   50C3                     227 DefineEntity tramp93, e_type_trap, 15, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0826                       1 tramp93::
   0826                       2    DefineEntityAnnonimous e_type_trap, 15, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   50C3 10                    1    .db e_type_trap
   50C4 0F                    2    .db 15
   50C5 28                    3    .db 40
   50C6 00                    4    .db 0
   50C7 00                    5    .db 0
   50C8 05                    6    .db 5
   50C9 0A                    7    .db 10
   50CA 50 20                 8    .dw _tiles_sp_01
   50CC 00                    9    .db 0
   50CD 00 00                10    .dw 0x0000
   50CF 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50D0 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50D1 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            228 
   50D2                     229 DefineEntity enemy91, e_type_enemy, 35, 130, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x7
   0835                       1 enemy91::
   0835                       2    DefineEntityAnnonimous e_type_enemy, 35, 130, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x7
   50D2 B0                    1    .db e_type_enemy
   50D3 23                    2    .db 35
   50D4 82                    3    .db 130
   50D5 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 61.
Hexadecimal [16-Bits]



   50D6 00                    5    .db 0
   50D7 05                    6    .db 5
   50D8 0A                    7    .db 10
   50D9 E6 20                 8    .dw _tiles_sp_04
   50DB 00                    9    .db 0
   50DC 00 00                10    .dw 0x0000
   50DE 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50DF 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50E0 07                   14    .db 0x7     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   50E1                     230 DefineEntity enemy92, e_type_enemy, 65, 130, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x7
   0844                       1 enemy92::
   0844                       2    DefineEntityAnnonimous e_type_enemy, 65, 130, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x7
   50E1 B0                    1    .db e_type_enemy
   50E2 41                    2    .db 65
   50E3 82                    3    .db 130
   50E4 00                    4    .db 0
   50E5 00                    5    .db 0
   50E6 05                    6    .db 5
   50E7 0A                    7    .db 10
   50E8 E6 20                 8    .dw _tiles_sp_04
   50EA 00                    9    .db 0
   50EB 00 00                10    .dw 0x0000
   50ED 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50EE 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50EF 07                   14    .db 0x7     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            231 
                            232 ;;NIVEL 10
   50F0                     233 DefineEntity portal100, e_type_portal, 15, 50, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0853                       1 portal100::
   0853                       2    DefineEntityAnnonimous e_type_portal, 15, 50, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   50F0 12                    1    .db e_type_portal
   50F1 0F                    2    .db 15
   50F2 32                    3    .db 50
   50F3 00                    4    .db 0
   50F4 00                    5    .db 0
   50F5 05                    6    .db 5
   50F6 0A                    7    .db 10
   50F7 82 20                 8    .dw _tiles_sp_02
   50F9 00                    9    .db 0
   50FA 00 00                10    .dw 0x0000
   50FC 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   50FD 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   50FE 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   50FF                     234 DefineEntity platah101, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0862                       1 platah101::
   0862                       2    DefineEntityAnnonimous e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   50FF 18                    1    .db e_type_platform
   5100 0A                    2    .db 10
   5101 A0                    3    .db 160
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 62.
Hexadecimal [16-Bits]



   5102 00                    4    .db 0
   5103 00                    5    .db 0
   5104 0F                    6    .db 15
   5105 0A                    7    .db 10
   5106 B6 25                 8    .dw _floor_ceiling_sp_0
   5108 00                    9    .db 0
   5109 00 00                10    .dw 0x0000
   510B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   510C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   510D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   510E                     235 DefineEntity platah102, e_type_platform, 10, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0871                       1 platah102::
   0871                       2    DefineEntityAnnonimous e_type_platform, 10, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   510E 18                    1    .db e_type_platform
   510F 0A                    2    .db 10
   5110 82                    3    .db 130
   5111 00                    4    .db 0
   5112 00                    5    .db 0
   5113 0F                    6    .db 15
   5114 0A                    7    .db 10
   5115 B6 25                 8    .dw _floor_ceiling_sp_0
   5117 00                    9    .db 0
   5118 00 00                10    .dw 0x0000
   511A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   511B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   511C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   511D                     236 DefineEntity platah103, e_type_platform, 25, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0880                       1 platah103::
   0880                       2    DefineEntityAnnonimous e_type_platform, 25, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   511D 18                    1    .db e_type_platform
   511E 19                    2    .db 25
   511F 82                    3    .db 130
   5120 00                    4    .db 0
   5121 00                    5    .db 0
   5122 0F                    6    .db 15
   5123 0A                    7    .db 10
   5124 B6 25                 8    .dw _floor_ceiling_sp_0
   5126 00                    9    .db 0
   5127 00 00                10    .dw 0x0000
   5129 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   512A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   512B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   512C                     237 DefineEntity platah104, e_type_platform, 50, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   088F                       1 platah104::
   088F                       2    DefineEntityAnnonimous e_type_platform, 50, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   512C 18                    1    .db e_type_platform
   512D 32                    2    .db 50
   512E 8C                    3    .db 140
   512F 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 63.
Hexadecimal [16-Bits]



   5130 00                    5    .db 0
   5131 05                    6    .db 5
   5132 0A                    7    .db 10
   5133 1E 20                 8    .dw _tiles_sp_00
   5135 00                    9    .db 0
   5136 00 00                10    .dw 0x0000
   5138 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5139 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   513A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   513B                     238 DefineEntity platah105, e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   089E                       1 platah105::
   089E                       2    DefineEntityAnnonimous e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   513B 18                    1    .db e_type_platform
   513C 41                    2    .db 65
   513D 78                    3    .db 120
   513E 00                    4    .db 0
   513F 00                    5    .db 0
   5140 0F                    6    .db 15
   5141 0A                    7    .db 10
   5142 B6 25                 8    .dw _floor_ceiling_sp_0
   5144 00                    9    .db 0
   5145 00 00                10    .dw 0x0000
   5147 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5148 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5149 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   514A                     239 DefineEntity platah106, e_type_platform, 55, 84, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   08AD                       1 platah106::
   08AD                       2    DefineEntityAnnonimous e_type_platform, 55, 84, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   514A 18                    1    .db e_type_platform
   514B 37                    2    .db 55
   514C 54                    3    .db 84
   514D 00                    4    .db 0
   514E 00                    5    .db 0
   514F 05                    6    .db 5
   5150 0A                    7    .db 10
   5151 1E 20                 8    .dw _tiles_sp_00
   5153 00                    9    .db 0
   5154 00 00                10    .dw 0x0000
   5156 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5157 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5158 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5159                     240 DefineEntity platah107, e_type_platform, 30, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   08BC                       1 platah107::
   08BC                       2    DefineEntityAnnonimous e_type_platform, 30, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5159 18                    1    .db e_type_platform
   515A 1E                    2    .db 30
   515B 3C                    3    .db 60
   515C 00                    4    .db 0
   515D 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 64.
Hexadecimal [16-Bits]



   515E 0F                    6    .db 15
   515F 0A                    7    .db 10
   5160 B6 25                 8    .dw _floor_ceiling_sp_0
   5162 00                    9    .db 0
   5163 00 00                10    .dw 0x0000
   5165 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5166 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5167 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5168                     241 DefineEntity platah108, e_type_platform, 15, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   08CB                       1 platah108::
   08CB                       2    DefineEntityAnnonimous e_type_platform, 15, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5168 18                    1    .db e_type_platform
   5169 0F                    2    .db 15
   516A 3C                    3    .db 60
   516B 00                    4    .db 0
   516C 00                    5    .db 0
   516D 0F                    6    .db 15
   516E 0A                    7    .db 10
   516F B6 25                 8    .dw _floor_ceiling_sp_0
   5171 00                    9    .db 0
   5172 00 00                10    .dw 0x0000
   5174 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5175 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5176 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            242 
   5177                     243 DefineEntity enemy101, e_type_enemy, 20, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x10
   08DA                       1 enemy101::
   08DA                       2    DefineEntityAnnonimous e_type_enemy, 20, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x10
   5177 B0                    1    .db e_type_enemy
   5178 14                    2    .db 20
   5179 96                    3    .db 150
   517A 00                    4    .db 0
   517B 00                    5    .db 0
   517C 05                    6    .db 5
   517D 0A                    7    .db 10
   517E E6 20                 8    .dw _tiles_sp_04
   5180 00                    9    .db 0
   5181 00 00                10    .dw 0x0000
   5183 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5184 01                   13    .db #1      ; y para guardar el estado de la IA de los enemigos
   5185 10                   14    .db 0x10     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5186                     244 DefineEntity enemy102, e_type_enemy, 30, 120, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x10
   08E9                       1 enemy102::
   08E9                       2    DefineEntityAnnonimous e_type_enemy, 30, 120, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x10
   5186 B0                    1    .db e_type_enemy
   5187 1E                    2    .db 30
   5188 78                    3    .db 120
   5189 00                    4    .db 0
   518A 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 65.
Hexadecimal [16-Bits]



   518B 05                    6    .db 5
   518C 0A                    7    .db 10
   518D E6 20                 8    .dw _tiles_sp_04
   518F 00                    9    .db 0
   5190 00 00                10    .dw 0x0000
   5192 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5193 FF                   13    .db #-1      ; y para guardar el estado de la IA de los enemigos
   5194 10                   14    .db 0x10     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            245 
   5195                     246 DefineEntity tramp101, e_type_trap, 70, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   08F8                       1 tramp101::
   08F8                       2    DefineEntityAnnonimous e_type_trap, 70, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5195 10                    1    .db e_type_trap
   5196 46                    2    .db 70
   5197 6E                    3    .db 110
   5198 00                    4    .db 0
   5199 00                    5    .db 0
   519A 05                    6    .db 5
   519B 0A                    7    .db 10
   519C 50 20                 8    .dw _tiles_sp_01
   519E 00                    9    .db 0
   519F 00 00                10    .dw 0x0000
   51A1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51A2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51A3 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   51A4                     247 DefineEntity tramp102, e_type_trap, 20, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0907                       1 tramp102::
   0907                       2    DefineEntityAnnonimous e_type_trap, 20, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   51A4 10                    1    .db e_type_trap
   51A5 14                    2    .db 20
   51A6 32                    3    .db 50
   51A7 00                    4    .db 0
   51A8 00                    5    .db 0
   51A9 05                    6    .db 5
   51AA 0A                    7    .db 10
   51AB 50 20                 8    .dw _tiles_sp_01
   51AD 00                    9    .db 0
   51AE 00 00                10    .dw 0x0000
   51B0 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51B1 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51B2 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   51B3                     248 DefineEntity tramp103, e_type_trap, 35, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0916                       1 tramp103::
   0916                       2    DefineEntityAnnonimous e_type_trap, 35, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   51B3 10                    1    .db e_type_trap
   51B4 23                    2    .db 35
   51B5 32                    3    .db 50
   51B6 00                    4    .db 0
   51B7 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 66.
Hexadecimal [16-Bits]



   51B8 05                    6    .db 5
   51B9 0A                    7    .db 10
   51BA 50 20                 8    .dw _tiles_sp_01
   51BC 00                    9    .db 0
   51BD 00 00                10    .dw 0x0000
   51BF 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51C0 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51C1 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            249 
                            250 
                            251 ;;NIVEL 11
   51C2                     252 DefineEntity portal110, e_type_portal, 75, 40, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0925                       1 portal110::
   0925                       2    DefineEntityAnnonimous e_type_portal, 75, 40, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   51C2 12                    1    .db e_type_portal
   51C3 4B                    2    .db 75
   51C4 28                    3    .db 40
   51C5 00                    4    .db 0
   51C6 00                    5    .db 0
   51C7 05                    6    .db 5
   51C8 0A                    7    .db 10
   51C9 82 20                 8    .dw _tiles_sp_02
   51CB 00                    9    .db 0
   51CC 00 00                10    .dw 0x0000
   51CE 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51CF 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51D0 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   51D1                     253 DefineEntity platah111, e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0934                       1 platah111::
   0934                       2    DefineEntityAnnonimous e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   51D1 18                    1    .db e_type_platform
   51D2 41                    2    .db 65
   51D3 A0                    3    .db 160
   51D4 00                    4    .db 0
   51D5 00                    5    .db 0
   51D6 0F                    6    .db 15
   51D7 0A                    7    .db 10
   51D8 B6 25                 8    .dw _floor_ceiling_sp_0
   51DA 00                    9    .db 0
   51DB 00 00                10    .dw 0x0000
   51DD 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51DE 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51DF 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   51E0                     254 DefineEntity platah112, e_type_platform, 45, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0943                       1 platah112::
   0943                       2    DefineEntityAnnonimous e_type_platform, 45, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   51E0 18                    1    .db e_type_platform
   51E1 2D                    2    .db 45
   51E2 8C                    3    .db 140
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 67.
Hexadecimal [16-Bits]



   51E3 00                    4    .db 0
   51E4 00                    5    .db 0
   51E5 0F                    6    .db 15
   51E6 0A                    7    .db 10
   51E7 B6 25                 8    .dw _floor_ceiling_sp_0
   51E9 00                    9    .db 0
   51EA 00 00                10    .dw 0x0000
   51EC 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51ED 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51EE 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   51EF                     255 DefineEntity platah113, e_type_platform, 30, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0952                       1 platah113::
   0952                       2    DefineEntityAnnonimous e_type_platform, 30, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   51EF 18                    1    .db e_type_platform
   51F0 1E                    2    .db 30
   51F1 8C                    3    .db 140
   51F2 00                    4    .db 0
   51F3 00                    5    .db 0
   51F4 0F                    6    .db 15
   51F5 0A                    7    .db 10
   51F6 B6 25                 8    .dw _floor_ceiling_sp_0
   51F8 00                    9    .db 0
   51F9 00 00                10    .dw 0x0000
   51FB 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   51FC 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   51FD 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   51FE                     256 DefineEntity platah114, e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0961                       1 platah114::
   0961                       2    DefineEntityAnnonimous e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   51FE 18                    1    .db e_type_platform
   51FF 19                    2    .db 25
   5200 8C                    3    .db 140
   5201 00                    4    .db 0
   5202 00                    5    .db 0
   5203 05                    6    .db 5
   5204 0A                    7    .db 10
   5205 1E 20                 8    .dw _tiles_sp_00
   5207 00                    9    .db 0
   5208 00 00                10    .dw 0x0000
   520A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   520B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   520C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   520D                     257 DefineEntity platah115, e_type_platform, 5, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0970                       1 platah115::
   0970                       2    DefineEntityAnnonimous e_type_platform, 5, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   520D 18                    1    .db e_type_platform
   520E 05                    2    .db 5
   520F 78                    3    .db 120
   5210 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 68.
Hexadecimal [16-Bits]



   5211 00                    5    .db 0
   5212 0F                    6    .db 15
   5213 0A                    7    .db 10
   5214 B6 25                 8    .dw _floor_ceiling_sp_0
   5216 00                    9    .db 0
   5217 00 00                10    .dw 0x0000
   5219 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   521A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   521B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   521C                     258 DefineEntity platah116, e_type_platform, 5, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   097F                       1 platah116::
   097F                       2    DefineEntityAnnonimous e_type_platform, 5, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   521C 18                    1    .db e_type_platform
   521D 05                    2    .db 5
   521E 5A                    3    .db 90
   521F 00                    4    .db 0
   5220 00                    5    .db 0
   5221 05                    6    .db 5
   5222 0A                    7    .db 10
   5223 1E 20                 8    .dw _tiles_sp_00
   5225 00                    9    .db 0
   5226 00 00                10    .dw 0x0000
   5228 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5229 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   522A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   522B                     259 DefineEntity platah117, e_type_platform, 15, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   098E                       1 platah117::
   098E                       2    DefineEntityAnnonimous e_type_platform, 15, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   522B 18                    1    .db e_type_platform
   522C 0F                    2    .db 15
   522D 5A                    3    .db 90
   522E 00                    4    .db 0
   522F 00                    5    .db 0
   5230 05                    6    .db 5
   5231 0A                    7    .db 10
   5232 1E 20                 8    .dw _tiles_sp_00
   5234 00                    9    .db 0
   5235 00 00                10    .dw 0x0000
   5237 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5238 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5239 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   523A                     260 DefineEntity platah118, e_type_platform, 5, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   099D                       1 platah118::
   099D                       2    DefineEntityAnnonimous e_type_platform, 5, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   523A 18                    1    .db e_type_platform
   523B 05                    2    .db 5
   523C 3C                    3    .db 60
   523D 00                    4    .db 0
   523E 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 69.
Hexadecimal [16-Bits]



   523F 0F                    6    .db 15
   5240 0A                    7    .db 10
   5241 B6 25                 8    .dw _floor_ceiling_sp_0
   5243 00                    9    .db 0
   5244 00 00                10    .dw 0x0000
   5246 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5247 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5248 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5249                     261 DefineEntity platah119, e_type_platform, 25, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   09AC                       1 platah119::
   09AC                       2    DefineEntityAnnonimous e_type_platform, 25, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5249 18                    1    .db e_type_platform
   524A 19                    2    .db 25
   524B 32                    3    .db 50
   524C 00                    4    .db 0
   524D 00                    5    .db 0
   524E 0F                    6    .db 15
   524F 0A                    7    .db 10
   5250 B6 25                 8    .dw _floor_ceiling_sp_0
   5252 00                    9    .db 0
   5253 00 00                10    .dw 0x0000
   5255 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5256 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5257 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5258                     262 DefineEntity platah1110, e_type_platform, 40, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   09BB                       1 platah1110::
   09BB                       2    DefineEntityAnnonimous e_type_platform, 40, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5258 18                    1    .db e_type_platform
   5259 28                    2    .db 40
   525A 32                    3    .db 50
   525B 00                    4    .db 0
   525C 00                    5    .db 0
   525D 0F                    6    .db 15
   525E 0A                    7    .db 10
   525F B6 25                 8    .dw _floor_ceiling_sp_0
   5261 00                    9    .db 0
   5262 00 00                10    .dw 0x0000
   5264 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5265 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5266 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5267                     263 DefineEntity platah1111, e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   09CA                       1 platah1111::
   09CA                       2    DefineEntityAnnonimous e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5267 18                    1    .db e_type_platform
   5268 37                    2    .db 55
   5269 32                    3    .db 50
   526A 00                    4    .db 0
   526B 00                    5    .db 0
   526C 0F                    6    .db 15
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 70.
Hexadecimal [16-Bits]



   526D 0A                    7    .db 10
   526E B6 25                 8    .dw _floor_ceiling_sp_0
   5270 00                    9    .db 0
   5271 00 00                10    .dw 0x0000
   5273 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5274 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5275 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            264 
   5276                     265 DefineEntity platah1112, e_type_platform, 70, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   09D9                       1 platah1112::
   09D9                       2    DefineEntityAnnonimous e_type_platform, 70, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5276 18                    1    .db e_type_platform
   5277 46                    2    .db 70
   5278 32                    3    .db 50
   5279 00                    4    .db 0
   527A 00                    5    .db 0
   527B 05                    6    .db 5
   527C 0A                    7    .db 10
   527D 1E 20                 8    .dw _tiles_sp_00
   527F 00                    9    .db 0
   5280 00 00                10    .dw 0x0000
   5282 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5283 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5284 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5285                     266 DefineEntity platah1113, e_type_platform, 75, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   09E8                       1 platah1113::
   09E8                       2    DefineEntityAnnonimous e_type_platform, 75, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5285 18                    1    .db e_type_platform
   5286 4B                    2    .db 75
   5287 32                    3    .db 50
   5288 00                    4    .db 0
   5289 00                    5    .db 0
   528A 05                    6    .db 5
   528B 0A                    7    .db 10
   528C 1E 20                 8    .dw _tiles_sp_00
   528E 00                    9    .db 0
   528F 00 00                10    .dw 0x0000
   5291 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5292 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5293 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5294                     267 DefineEntity platah1114, e_type_platform, 60, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   09F7                       1 platah1114::
   09F7                       2    DefineEntityAnnonimous e_type_platform, 60, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5294 18                    1    .db e_type_platform
   5295 3C                    2    .db 60
   5296 46                    3    .db 70
   5297 00                    4    .db 0
   5298 00                    5    .db 0
   5299 0F                    6    .db 15
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 71.
Hexadecimal [16-Bits]



   529A 0A                    7    .db 10
   529B B6 25                 8    .dw _floor_ceiling_sp_0
   529D 00                    9    .db 0
   529E 00 00                10    .dw 0x0000
   52A0 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52A1 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   52A2 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   52A3                     268 DefineEntity platah1115, e_type_platform, 60, 80, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0A06                       1 platah1115::
   0A06                       2    DefineEntityAnnonimous e_type_platform, 60, 80, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   52A3 18                    1    .db e_type_platform
   52A4 3C                    2    .db 60
   52A5 50                    3    .db 80
   52A6 00                    4    .db 0
   52A7 00                    5    .db 0
   52A8 0F                    6    .db 15
   52A9 0A                    7    .db 10
   52AA B6 25                 8    .dw _floor_ceiling_sp_0
   52AC 00                    9    .db 0
   52AD 00 00                10    .dw 0x0000
   52AF 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52B0 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   52B1 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   52B2                     269 DefineEntity platah1116, e_type_platform, 60, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0A15                       1 platah1116::
   0A15                       2    DefineEntityAnnonimous e_type_platform, 60, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   52B2 18                    1    .db e_type_platform
   52B3 3C                    2    .db 60
   52B4 5A                    3    .db 90
   52B5 00                    4    .db 0
   52B6 00                    5    .db 0
   52B7 0F                    6    .db 15
   52B8 0A                    7    .db 10
   52B9 B6 25                 8    .dw _floor_ceiling_sp_0
   52BB 00                    9    .db 0
   52BC 00 00                10    .dw 0x0000
   52BE 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52BF 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   52C0 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   52C1                     270 DefineEntity tramp111, e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0A24                       1 tramp111::
   0A24                       2    DefineEntityAnnonimous e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   52C1 10                    1    .db e_type_trap
   52C2 0F                    2    .db 15
   52C3 B4                    3    .db 180
   52C4 00                    4    .db 0
   52C5 00                    5    .db 0
   52C6 05                    6    .db 5
   52C7 0A                    7    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 72.
Hexadecimal [16-Bits]



   52C8 50 20                 8    .dw _tiles_sp_01
   52CA 00                    9    .db 0
   52CB 00 00                10    .dw 0x0000
   52CD 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52CE 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   52CF 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   52D0                     271 DefineEntity tramp112, e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0A33                       1 tramp112::
   0A33                       2    DefineEntityAnnonimous e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   52D0 10                    1    .db e_type_trap
   52D1 28                    2    .db 40
   52D2 B4                    3    .db 180
   52D3 00                    4    .db 0
   52D4 00                    5    .db 0
   52D5 05                    6    .db 5
   52D6 0A                    7    .db 10
   52D7 50 20                 8    .dw _tiles_sp_01
   52D9 00                    9    .db 0
   52DA 00 00                10    .dw 0x0000
   52DC 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52DD 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   52DE 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   52DF                     272 DefineEntity tramp113, e_type_trap, 10, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0A42                       1 tramp113::
   0A42                       2    DefineEntityAnnonimous e_type_trap, 10, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   52DF 10                    1    .db e_type_trap
   52E0 0A                    2    .db 10
   52E1 5A                    3    .db 90
   52E2 00                    4    .db 0
   52E3 00                    5    .db 0
   52E4 05                    6    .db 5
   52E5 0A                    7    .db 10
   52E6 50 20                 8    .dw _tiles_sp_01
   52E8 00                    9    .db 0
   52E9 00 00                10    .dw 0x0000
   52EB 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52EC 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   52ED 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   52EE                     273 DefineEntity enemy111, e_type_enemy, 40, 100, 0, 0, 5, 10, _tiles_sp_06, 0, 0x0000, 0x00, #2, 0x1E
   0A51                       1 enemy111::
   0A51                       2    DefineEntityAnnonimous e_type_enemy, 40, 100, 0, 0, 5, 10, _tiles_sp_06, 0, 0x0000, 0x00, #2, 0x1E
   52EE B0                    1    .db e_type_enemy
   52EF 28                    2    .db 40
   52F0 64                    3    .db 100
   52F1 00                    4    .db 0
   52F2 00                    5    .db 0
   52F3 05                    6    .db 5
   52F4 0A                    7    .db 10
   52F5 4A 21                 8    .dw _tiles_sp_06
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 73.
Hexadecimal [16-Bits]



   52F7 00                    9    .db 0
   52F8 00 00                10    .dw 0x0000
   52FA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   52FB 02                   13    .db #2      ; y para guardar el estado de la IA de los enemigos
   52FC 1E                   14    .db 0x1E     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            274 
                            275 ;;NIVEL 12
   52FD                     276 DefineEntity portal120, e_type_portal, 75, 30, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0A60                       1 portal120::
   0A60                       2    DefineEntityAnnonimous e_type_portal, 75, 30, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   52FD 12                    1    .db e_type_portal
   52FE 4B                    2    .db 75
   52FF 1E                    3    .db 30
   5300 00                    4    .db 0
   5301 00                    5    .db 0
   5302 05                    6    .db 5
   5303 0A                    7    .db 10
   5304 82 20                 8    .dw _tiles_sp_02
   5306 00                    9    .db 0
   5307 00 00                10    .dw 0x0000
   5309 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   530A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   530B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   530C                     277 DefineEntity platah121, e_type_platform, 20, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0A6F                       1 platah121::
   0A6F                       2    DefineEntityAnnonimous e_type_platform, 20, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   530C 18                    1    .db e_type_platform
   530D 14                    2    .db 20
   530E A0                    3    .db 160
   530F 00                    4    .db 0
   5310 00                    5    .db 0
   5311 05                    6    .db 5
   5312 0A                    7    .db 10
   5313 1E 20                 8    .dw _tiles_sp_00
   5315 00                    9    .db 0
   5316 00 00                10    .dw 0x0000
   5318 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5319 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   531A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   531B                     278 DefineEntity platah122, e_type_platform, 35, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0A7E                       1 platah122::
   0A7E                       2    DefineEntityAnnonimous e_type_platform, 35, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   531B 18                    1    .db e_type_platform
   531C 23                    2    .db 35
   531D A0                    3    .db 160
   531E 00                    4    .db 0
   531F 00                    5    .db 0
   5320 05                    6    .db 5
   5321 0A                    7    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 74.
Hexadecimal [16-Bits]



   5322 1E 20                 8    .dw _tiles_sp_00
   5324 00                    9    .db 0
   5325 00 00                10    .dw 0x0000
   5327 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5328 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5329 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   532A                     279 DefineEntity platah123, e_type_platform, 50, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0A8D                       1 platah123::
   0A8D                       2    DefineEntityAnnonimous e_type_platform, 50, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   532A 18                    1    .db e_type_platform
   532B 32                    2    .db 50
   532C A0                    3    .db 160
   532D 00                    4    .db 0
   532E 00                    5    .db 0
   532F 05                    6    .db 5
   5330 0A                    7    .db 10
   5331 1E 20                 8    .dw _tiles_sp_00
   5333 00                    9    .db 0
   5334 00 00                10    .dw 0x0000
   5336 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5337 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5338 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5339                     280 DefineEntity platah124, e_type_platform, 65, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0A9C                       1 platah124::
   0A9C                       2    DefineEntityAnnonimous e_type_platform, 65, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5339 18                    1    .db e_type_platform
   533A 41                    2    .db 65
   533B A0                    3    .db 160
   533C 00                    4    .db 0
   533D 00                    5    .db 0
   533E 05                    6    .db 5
   533F 0A                    7    .db 10
   5340 1E 20                 8    .dw _tiles_sp_00
   5342 00                    9    .db 0
   5343 00 00                10    .dw 0x0000
   5345 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5346 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5347 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5348                     281 DefineEntity platav125, e_type_platform, 70, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0AAB                       1 platav125::
   0AAB                       2    DefineEntityAnnonimous e_type_platform, 70, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5348 18                    1    .db e_type_platform
   5349 46                    2    .db 70
   534A A0                    3    .db 160
   534B 00                    4    .db 0
   534C 00                    5    .db 0
   534D 05                    6    .db 5
   534E 1E                    7    .db 30
   534F 22 22                 8    .dw _walls_sp_0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 75.
Hexadecimal [16-Bits]



   5351 00                    9    .db 0
   5352 00 00                10    .dw 0x0000
   5354 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5355 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5356 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5357                     282 DefineEntity platav126, e_type_platform, 75, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0ABA                       1 platav126::
   0ABA                       2    DefineEntityAnnonimous e_type_platform, 75, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5357 18                    1    .db e_type_platform
   5358 4B                    2    .db 75
   5359 A0                    3    .db 160
   535A 00                    4    .db 0
   535B 00                    5    .db 0
   535C 05                    6    .db 5
   535D 1E                    7    .db 30
   535E 22 22                 8    .dw _walls_sp_0
   5360 00                    9    .db 0
   5361 00 00                10    .dw 0x0000
   5363 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5364 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5365 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5366                     283 DefineEntity platah127, e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0AC9                       1 platah127::
   0AC9                       2    DefineEntityAnnonimous e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5366 18                    1    .db e_type_platform
   5367 4B                    2    .db 75
   5368 82                    3    .db 130
   5369 00                    4    .db 0
   536A 00                    5    .db 0
   536B 05                    6    .db 5
   536C 0A                    7    .db 10
   536D 1E 20                 8    .dw _tiles_sp_00
   536F 00                    9    .db 0
   5370 00 00                10    .dw 0x0000
   5372 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5373 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5374 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5375                     284 DefineEntity platah128, e_type_platform, 75, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0AD8                       1 platah128::
   0AD8                       2    DefineEntityAnnonimous e_type_platform, 75, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5375 18                    1    .db e_type_platform
   5376 4B                    2    .db 75
   5377 64                    3    .db 100
   5378 00                    4    .db 0
   5379 00                    5    .db 0
   537A 05                    6    .db 5
   537B 0A                    7    .db 10
   537C 1E 20                 8    .dw _tiles_sp_00
   537E 00                    9    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 76.
Hexadecimal [16-Bits]



   537F 00 00                10    .dw 0x0000
   5381 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5382 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5383 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5384                     285 DefineEntity platah129, e_type_platform, 70, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0AE7                       1 platah129::
   0AE7                       2    DefineEntityAnnonimous e_type_platform, 70, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5384 18                    1    .db e_type_platform
   5385 46                    2    .db 70
   5386 64                    3    .db 100
   5387 00                    4    .db 0
   5388 00                    5    .db 0
   5389 05                    6    .db 5
   538A 0A                    7    .db 10
   538B 1E 20                 8    .dw _tiles_sp_00
   538D 00                    9    .db 0
   538E 00 00                10    .dw 0x0000
   5390 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5391 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5392 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5393                     286 DefineEntity platah1210, e_type_platform, 50, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0AF6                       1 platah1210::
   0AF6                       2    DefineEntityAnnonimous e_type_platform, 50, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5393 18                    1    .db e_type_platform
   5394 32                    2    .db 50
   5395 64                    3    .db 100
   5396 00                    4    .db 0
   5397 00                    5    .db 0
   5398 05                    6    .db 5
   5399 0A                    7    .db 10
   539A 1E 20                 8    .dw _tiles_sp_00
   539C 00                    9    .db 0
   539D 00 00                10    .dw 0x0000
   539F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53A0 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53A1 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   53A2                     287 DefineEntity platah1211, e_type_platform, 40, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0B05                       1 platah1211::
   0B05                       2    DefineEntityAnnonimous e_type_platform, 40, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   53A2 18                    1    .db e_type_platform
   53A3 28                    2    .db 40
   53A4 64                    3    .db 100
   53A5 00                    4    .db 0
   53A6 00                    5    .db 0
   53A7 05                    6    .db 5
   53A8 0A                    7    .db 10
   53A9 1E 20                 8    .dw _tiles_sp_00
   53AB 00                    9    .db 0
   53AC 00 00                10    .dw 0x0000
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 77.
Hexadecimal [16-Bits]



   53AE 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53AF 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53B0 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   53B1                     288 DefineEntity platah1212, e_type_platform, 30, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0B14                       1 platah1212::
   0B14                       2    DefineEntityAnnonimous e_type_platform, 30, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   53B1 18                    1    .db e_type_platform
   53B2 1E                    2    .db 30
   53B3 64                    3    .db 100
   53B4 00                    4    .db 0
   53B5 00                    5    .db 0
   53B6 05                    6    .db 5
   53B7 0A                    7    .db 10
   53B8 1E 20                 8    .dw _tiles_sp_00
   53BA 00                    9    .db 0
   53BB 00 00                10    .dw 0x0000
   53BD 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53BE 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53BF 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   53C0                     289 DefineEntity platah1213, e_type_platform, 5, 100, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0B23                       1 platah1213::
   0B23                       2    DefineEntityAnnonimous e_type_platform, 5, 100, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   53C0 18                    1    .db e_type_platform
   53C1 05                    2    .db 5
   53C2 64                    3    .db 100
   53C3 00                    4    .db 0
   53C4 00                    5    .db 0
   53C5 0F                    6    .db 15
   53C6 0A                    7    .db 10
   53C7 B6 25                 8    .dw _floor_ceiling_sp_0
   53C9 00                    9    .db 0
   53CA 00 00                10    .dw 0x0000
   53CC 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53CD 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53CE 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   53CF                     290 DefineEntity platah1214, e_type_platform, 0, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0B32                       1 platah1214::
   0B32                       2    DefineEntityAnnonimous e_type_platform, 0, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   53CF 18                    1    .db e_type_platform
   53D0 00                    2    .db 0
   53D1 46                    3    .db 70
   53D2 00                    4    .db 0
   53D3 00                    5    .db 0
   53D4 05                    6    .db 5
   53D5 0A                    7    .db 10
   53D6 1E 20                 8    .dw _tiles_sp_00
   53D8 00                    9    .db 0
   53D9 00 00                10    .dw 0x0000
   53DB 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 78.
Hexadecimal [16-Bits]



                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53DC 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53DD 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   53DE                     291 DefineEntity platah1215, e_type_platform, 5, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0B41                       1 platah1215::
   0B41                       2    DefineEntityAnnonimous e_type_platform, 5, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   53DE 18                    1    .db e_type_platform
   53DF 05                    2    .db 5
   53E0 46                    3    .db 70
   53E1 00                    4    .db 0
   53E2 00                    5    .db 0
   53E3 05                    6    .db 5
   53E4 0A                    7    .db 10
   53E5 1E 20                 8    .dw _tiles_sp_00
   53E7 00                    9    .db 0
   53E8 00 00                10    .dw 0x0000
   53EA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53EB 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53EC 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            292 
   53ED                     293 DefineEntity platah1216, e_type_platform, 15, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0B50                       1 platah1216::
   0B50                       2    DefineEntityAnnonimous e_type_platform, 15, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   53ED 18                    1    .db e_type_platform
   53EE 0F                    2    .db 15
   53EF 28                    3    .db 40
   53F0 00                    4    .db 0
   53F1 00                    5    .db 0
   53F2 0F                    6    .db 15
   53F3 0A                    7    .db 10
   53F4 B6 25                 8    .dw _floor_ceiling_sp_0
   53F6 00                    9    .db 0
   53F7 00 00                10    .dw 0x0000
   53F9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   53FA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   53FB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   53FC                     294 DefineEntity platah1217, e_type_platform, 40, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0B5F                       1 platah1217::
   0B5F                       2    DefineEntityAnnonimous e_type_platform, 40, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   53FC 18                    1    .db e_type_platform
   53FD 28                    2    .db 40
   53FE 28                    3    .db 40
   53FF 00                    4    .db 0
   5400 00                    5    .db 0
   5401 0F                    6    .db 15
   5402 0A                    7    .db 10
   5403 B6 25                 8    .dw _floor_ceiling_sp_0
   5405 00                    9    .db 0
   5406 00 00                10    .dw 0x0000
   5408 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 79.
Hexadecimal [16-Bits]



                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5409 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   540A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   540B                     295 DefineEntity platah1218, e_type_platform, 65, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0B6E                       1 platah1218::
   0B6E                       2    DefineEntityAnnonimous e_type_platform, 65, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   540B 18                    1    .db e_type_platform
   540C 41                    2    .db 65
   540D 28                    3    .db 40
   540E 00                    4    .db 0
   540F 00                    5    .db 0
   5410 0F                    6    .db 15
   5411 0A                    7    .db 10
   5412 B6 25                 8    .dw _floor_ceiling_sp_0
   5414 00                    9    .db 0
   5415 00 00                10    .dw 0x0000
   5417 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5418 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5419 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   541A                     296 DefineEntity tramp121, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0B7D                       1 tramp121::
   0B7D                       2    DefineEntityAnnonimous e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   541A 10                    1    .db e_type_trap
   541B 19                    2    .db 25
   541C B4                    3    .db 180
   541D 00                    4    .db 0
   541E 00                    5    .db 0
   541F 05                    6    .db 5
   5420 0A                    7    .db 10
   5421 50 20                 8    .dw _tiles_sp_01
   5423 00                    9    .db 0
   5424 00 00                10    .dw 0x0000
   5426 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5427 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5428 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5429                     297 DefineEntity tramp122, e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0B8C                       1 tramp122::
   0B8C                       2    DefineEntityAnnonimous e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5429 10                    1    .db e_type_trap
   542A 1E                    2    .db 30
   542B B4                    3    .db 180
   542C 00                    4    .db 0
   542D 00                    5    .db 0
   542E 05                    6    .db 5
   542F 0A                    7    .db 10
   5430 50 20                 8    .dw _tiles_sp_01
   5432 00                    9    .db 0
   5433 00 00                10    .dw 0x0000
   5435 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 80.
Hexadecimal [16-Bits]



   5436 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5437 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5438                     298 DefineEntity tramp123, e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0B9B                       1 tramp123::
   0B9B                       2    DefineEntityAnnonimous e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5438 10                    1    .db e_type_trap
   5439 28                    2    .db 40
   543A B4                    3    .db 180
   543B 00                    4    .db 0
   543C 00                    5    .db 0
   543D 05                    6    .db 5
   543E 0A                    7    .db 10
   543F 50 20                 8    .dw _tiles_sp_01
   5441 00                    9    .db 0
   5442 00 00                10    .dw 0x0000
   5444 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5445 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5446 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5447                     299 DefineEntity tramp124, e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0BAA                       1 tramp124::
   0BAA                       2    DefineEntityAnnonimous e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5447 10                    1    .db e_type_trap
   5448 2D                    2    .db 45
   5449 B4                    3    .db 180
   544A 00                    4    .db 0
   544B 00                    5    .db 0
   544C 05                    6    .db 5
   544D 0A                    7    .db 10
   544E 50 20                 8    .dw _tiles_sp_01
   5450 00                    9    .db 0
   5451 00 00                10    .dw 0x0000
   5453 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5454 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5455 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5456                     300 DefineEntity tramp125, e_type_trap, 55, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0BB9                       1 tramp125::
   0BB9                       2    DefineEntityAnnonimous e_type_trap, 55, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5456 10                    1    .db e_type_trap
   5457 37                    2    .db 55
   5458 B4                    3    .db 180
   5459 00                    4    .db 0
   545A 00                    5    .db 0
   545B 05                    6    .db 5
   545C 0A                    7    .db 10
   545D 50 20                 8    .dw _tiles_sp_01
   545F 00                    9    .db 0
   5460 00 00                10    .dw 0x0000
   5462 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5463 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 81.
Hexadecimal [16-Bits]



   5464 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5465                     301 DefineEntity tramp126, e_type_trap, 60, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0BC8                       1 tramp126::
   0BC8                       2    DefineEntityAnnonimous e_type_trap, 60, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5465 10                    1    .db e_type_trap
   5466 3C                    2    .db 60
   5467 B4                    3    .db 180
   5468 00                    4    .db 0
   5469 00                    5    .db 0
   546A 05                    6    .db 5
   546B 0A                    7    .db 10
   546C 50 20                 8    .dw _tiles_sp_01
   546E 00                    9    .db 0
   546F 00 00                10    .dw 0x0000
   5471 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5472 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5473 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5474                     302 DefineEntity enemy121, e_type_enemy, 35, 90, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x1E
   0BD7                       1 enemy121::
   0BD7                       2    DefineEntityAnnonimous e_type_enemy, 35, 90, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x1E
   5474 B0                    1    .db e_type_enemy
   5475 23                    2    .db 35
   5476 5A                    3    .db 90
   5477 00                    4    .db 0
   5478 00                    5    .db 0
   5479 05                    6    .db 5
   547A 0A                    7    .db 10
   547B AE 21                 8    .dw _tiles_sp_08
   547D 00                    9    .db 0
   547E 00 00                10    .dw 0x0000
   5480 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5481 03                   13    .db #3      ; y para guardar el estado de la IA de los enemigos
   5482 1E                   14    .db 0x1E     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            303 
                            304 ;;NIVEL 13
   5483                     305 DefineEntity portal130, e_type_portal, 45, 10, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0BE6                       1 portal130::
   0BE6                       2    DefineEntityAnnonimous e_type_portal, 45, 10, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   5483 12                    1    .db e_type_portal
   5484 2D                    2    .db 45
   5485 0A                    3    .db 10
   5486 00                    4    .db 0
   5487 00                    5    .db 0
   5488 05                    6    .db 5
   5489 0A                    7    .db 10
   548A 82 20                 8    .dw _tiles_sp_02
   548C 00                    9    .db 0
   548D 00 00                10    .dw 0x0000
   548F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 82.
Hexadecimal [16-Bits]



   5490 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5491 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5492                     306 DefineEntity platah131, e_type_platform, 0, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0BF5                       1 platah131::
   0BF5                       2    DefineEntityAnnonimous e_type_platform, 0, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5492 18                    1    .db e_type_platform
   5493 00                    2    .db 0
   5494 A0                    3    .db 160
   5495 00                    4    .db 0
   5496 00                    5    .db 0
   5497 0F                    6    .db 15
   5498 0A                    7    .db 10
   5499 B6 25                 8    .dw _floor_ceiling_sp_0
   549B 00                    9    .db 0
   549C 00 00                10    .dw 0x0000
   549E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   549F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   54A0 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54A1                     307 DefineEntity platah132, e_type_platform, 20, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C04                       1 platah132::
   0C04                       2    DefineEntityAnnonimous e_type_platform, 20, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54A1 18                    1    .db e_type_platform
   54A2 14                    2    .db 20
   54A3 8C                    3    .db 140
   54A4 00                    4    .db 0
   54A5 00                    5    .db 0
   54A6 05                    6    .db 5
   54A7 0A                    7    .db 10
   54A8 1E 20                 8    .dw _tiles_sp_00
   54AA 00                    9    .db 0
   54AB 00 00                10    .dw 0x0000
   54AD 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   54AE 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   54AF 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54B0                     308 DefineEntity platah133, e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C13                       1 platah133::
   0C13                       2    DefineEntityAnnonimous e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54B0 18                    1    .db e_type_platform
   54B1 19                    2    .db 25
   54B2 8C                    3    .db 140
   54B3 00                    4    .db 0
   54B4 00                    5    .db 0
   54B5 05                    6    .db 5
   54B6 0A                    7    .db 10
   54B7 1E 20                 8    .dw _tiles_sp_00
   54B9 00                    9    .db 0
   54BA 00 00                10    .dw 0x0000
   54BC 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   54BD 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 83.
Hexadecimal [16-Bits]



   54BE 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54BF                     309 DefineEntity platah134, e_type_platform, 35, 120, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C22                       1 platah134::
   0C22                       2    DefineEntityAnnonimous e_type_platform, 35, 120, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54BF 18                    1    .db e_type_platform
   54C0 23                    2    .db 35
   54C1 78                    3    .db 120
   54C2 00                    4    .db 0
   54C3 00                    5    .db 0
   54C4 05                    6    .db 5
   54C5 0A                    7    .db 10
   54C6 1E 20                 8    .dw _tiles_sp_00
   54C8 00                    9    .db 0
   54C9 00 00                10    .dw 0x0000
   54CB 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   54CC 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   54CD 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54CE                     310 DefineEntity platah135, e_type_platform, 55, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C31                       1 platah135::
   0C31                       2    DefineEntityAnnonimous e_type_platform, 55, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54CE 18                    1    .db e_type_platform
   54CF 37                    2    .db 55
   54D0 AA                    3    .db 170
   54D1 00                    4    .db 0
   54D2 00                    5    .db 0
   54D3 05                    6    .db 5
   54D4 0A                    7    .db 10
   54D5 1E 20                 8    .dw _tiles_sp_00
   54D7 00                    9    .db 0
   54D8 00 00                10    .dw 0x0000
   54DA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   54DB 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   54DC 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54DD                     311 DefineEntity platah136, e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C40                       1 platah136::
   0C40                       2    DefineEntityAnnonimous e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54DD 18                    1    .db e_type_platform
   54DE 46                    2    .db 70
   54DF A0                    3    .db 160
   54E0 00                    4    .db 0
   54E1 00                    5    .db 0
   54E2 05                    6    .db 5
   54E3 0A                    7    .db 10
   54E4 1E 20                 8    .dw _tiles_sp_00
   54E6 00                    9    .db 0
   54E7 00 00                10    .dw 0x0000
   54E9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   54EA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   54EB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 84.
Hexadecimal [16-Bits]



                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54EC                     312 DefineEntity platah137, e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C4F                       1 platah137::
   0C4F                       2    DefineEntityAnnonimous e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54EC 18                    1    .db e_type_platform
   54ED 4B                    2    .db 75
   54EE 82                    3    .db 130
   54EF 00                    4    .db 0
   54F0 00                    5    .db 0
   54F1 05                    6    .db 5
   54F2 0A                    7    .db 10
   54F3 1E 20                 8    .dw _tiles_sp_00
   54F5 00                    9    .db 0
   54F6 00 00                10    .dw 0x0000
   54F8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   54F9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   54FA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   54FB                     313 DefineEntity platah138, e_type_platform, 75, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C5E                       1 platah138::
   0C5E                       2    DefineEntityAnnonimous e_type_platform, 75, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   54FB 18                    1    .db e_type_platform
   54FC 4B                    2    .db 75
   54FD 64                    3    .db 100
   54FE 00                    4    .db 0
   54FF 00                    5    .db 0
   5500 05                    6    .db 5
   5501 0A                    7    .db 10
   5502 1E 20                 8    .dw _tiles_sp_00
   5504 00                    9    .db 0
   5505 00 00                10    .dw 0x0000
   5507 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5508 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5509 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   550A                     314 DefineEntity platah139, e_type_platform, 75, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0C6D                       1 platah139::
   0C6D                       2    DefineEntityAnnonimous e_type_platform, 75, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   550A 18                    1    .db e_type_platform
   550B 4B                    2    .db 75
   550C 46                    3    .db 70
   550D 00                    4    .db 0
   550E 00                    5    .db 0
   550F 05                    6    .db 5
   5510 0A                    7    .db 10
   5511 1E 20                 8    .dw _tiles_sp_00
   5513 00                    9    .db 0
   5514 00 00                10    .dw 0x0000
   5516 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5517 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5518 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 85.
Hexadecimal [16-Bits]



   5519                     315 DefineEntity platah1310, e_type_platform, 50, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0C7C                       1 platah1310::
   0C7C                       2    DefineEntityAnnonimous e_type_platform, 50, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5519 18                    1    .db e_type_platform
   551A 32                    2    .db 50
   551B 46                    3    .db 70
   551C 00                    4    .db 0
   551D 00                    5    .db 0
   551E 0F                    6    .db 15
   551F 0A                    7    .db 10
   5520 B6 25                 8    .dw _floor_ceiling_sp_0
   5522 00                    9    .db 0
   5523 00 00                10    .dw 0x0000
   5525 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5526 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5527 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5528                     316 DefineEntity platah1311, e_type_platform, 20, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0C8B                       1 platah1311::
   0C8B                       2    DefineEntityAnnonimous e_type_platform, 20, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5528 18                    1    .db e_type_platform
   5529 14                    2    .db 20
   552A 46                    3    .db 70
   552B 00                    4    .db 0
   552C 00                    5    .db 0
   552D 0F                    6    .db 15
   552E 0A                    7    .db 10
   552F B6 25                 8    .dw _floor_ceiling_sp_0
   5531 00                    9    .db 0
   5532 00 00                10    .dw 0x0000
   5534 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5535 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5536 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5537                     317 DefineEntity platah1312, e_type_platform, 0, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0C9A                       1 platah1312::
   0C9A                       2    DefineEntityAnnonimous e_type_platform, 0, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5537 18                    1    .db e_type_platform
   5538 00                    2    .db 0
   5539 32                    3    .db 50
   553A 00                    4    .db 0
   553B 00                    5    .db 0
   553C 0F                    6    .db 15
   553D 0A                    7    .db 10
   553E B6 25                 8    .dw _floor_ceiling_sp_0
   5540 00                    9    .db 0
   5541 00 00                10    .dw 0x0000
   5543 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5544 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5545 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5546                     318 DefineEntity platah1313, e_type_platform, 15, 20, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 86.
Hexadecimal [16-Bits]



   0CA9                       1 platah1313::
   0CA9                       2    DefineEntityAnnonimous e_type_platform, 15, 20, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5546 18                    1    .db e_type_platform
   5547 0F                    2    .db 15
   5548 14                    3    .db 20
   5549 00                    4    .db 0
   554A 00                    5    .db 0
   554B 0F                    6    .db 15
   554C 0A                    7    .db 10
   554D B6 25                 8    .dw _floor_ceiling_sp_0
   554F 00                    9    .db 0
   5550 00 00                10    .dw 0x0000
   5552 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5553 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5554 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5555                     319 DefineEntity platah1314, e_type_platform, 35, 20, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0CB8                       1 platah1314::
   0CB8                       2    DefineEntityAnnonimous e_type_platform, 35, 20, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5555 18                    1    .db e_type_platform
   5556 23                    2    .db 35
   5557 14                    3    .db 20
   5558 00                    4    .db 0
   5559 00                    5    .db 0
   555A 0F                    6    .db 15
   555B 0A                    7    .db 10
   555C B6 25                 8    .dw _floor_ceiling_sp_0
   555E 00                    9    .db 0
   555F 00 00                10    .dw 0x0000
   5561 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5562 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5563 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            320 
   5564                     321 DefineEntity tramp131, e_type_trap, 30, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   0CC7                       1 tramp131::
   0CC7                       2    DefineEntityAnnonimous e_type_trap, 30, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   5564 10                    1    .db e_type_trap
   5565 1E                    2    .db 30
   5566 B4                    3    .db 180
   5567 00                    4    .db 0
   5568 00                    5    .db 0
   5569 32                    6    .db 50
   556A 0A                    7    .db 10
   556B 1A 1E                 8    .dw _linea_pin_sp
   556D 00                    9    .db 0
   556E 00 00                10    .dw 0x0000
   5570 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5571 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5572 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5573                     322 DefineEntity tramp132, e_type_trap, 30, 20, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 87.
Hexadecimal [16-Bits]



   0CD6                       1 tramp132::
   0CD6                       2    DefineEntityAnnonimous e_type_trap, 30, 20, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5573 10                    1    .db e_type_trap
   5574 1E                    2    .db 30
   5575 14                    3    .db 20
   5576 00                    4    .db 0
   5577 00                    5    .db 0
   5578 05                    6    .db 5
   5579 0A                    7    .db 10
   557A 50 20                 8    .dw _tiles_sp_01
   557C 00                    9    .db 0
   557D 00 00                10    .dw 0x0000
   557F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5580 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5581 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5582                     323 DefineEntity enemy131, e_type_enemy, 40, 70, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x10
   0CE5                       1 enemy131::
   0CE5                       2    DefineEntityAnnonimous e_type_enemy, 40, 70, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x10
   5582 B0                    1    .db e_type_enemy
   5583 28                    2    .db 40
   5584 46                    3    .db 70
   5585 00                    4    .db 0
   5586 00                    5    .db 0
   5587 05                    6    .db 5
   5588 0A                    7    .db 10
   5589 AE 21                 8    .dw _tiles_sp_08
   558B 00                    9    .db 0
   558C 00 00                10    .dw 0x0000
   558E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   558F 03                   13    .db #3      ; y para guardar el estado de la IA de los enemigos
   5590 10                   14    .db 0x10     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            324 
                            325 ;;NIVEL 14
   5591                     326 DefineEntity player140, e_type_player, 0, 160, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
   0CF4                       1 player140::
   0CF4                       2    DefineEntityAnnonimous e_type_player, 0, 160, 0, 0, 5, 10, _protagonista_sp_0, 0, 0x0000, 0x01, 0x00, 0x00
   5591 78                    1    .db e_type_player
   5592 00                    2    .db 0
   5593 A0                    3    .db 160
   5594 00                    4    .db 0
   5595 00                    5    .db 0
   5596 05                    6    .db 5
   5597 0A                    7    .db 10
   5598 82 28                 8    .dw _protagonista_sp_0
   559A 00                    9    .db 0
   559B 00 00                10    .dw 0x0000
   559D 01                   11    .db 0x01        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   559E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   559F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 88.
Hexadecimal [16-Bits]



   55A0                     327 DefineEntity portal140, e_type_portal, 75, 40, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0D03                       1 portal140::
   0D03                       2    DefineEntityAnnonimous e_type_portal, 75, 40, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   55A0 12                    1    .db e_type_portal
   55A1 4B                    2    .db 75
   55A2 28                    3    .db 40
   55A3 00                    4    .db 0
   55A4 00                    5    .db 0
   55A5 05                    6    .db 5
   55A6 0A                    7    .db 10
   55A7 82 20                 8    .dw _tiles_sp_02
   55A9 00                    9    .db 0
   55AA 00 00                10    .dw 0x0000
   55AC 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   55AD 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   55AE 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   55AF                     328 DefineEntity platah141, e_type_platform, 25, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0D12                       1 platah141::
   0D12                       2    DefineEntityAnnonimous e_type_platform, 25, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   55AF 18                    1    .db e_type_platform
   55B0 19                    2    .db 25
   55B1 A0                    3    .db 160
   55B2 00                    4    .db 0
   55B3 00                    5    .db 0
   55B4 05                    6    .db 5
   55B5 1E                    7    .db 30
   55B6 22 22                 8    .dw _walls_sp_0
   55B8 00                    9    .db 0
   55B9 00 00                10    .dw 0x0000
   55BB 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   55BC 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   55BD 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   55BE                     329 DefineEntity platah142, e_type_platform, 40, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0D21                       1 platah142::
   0D21                       2    DefineEntityAnnonimous e_type_platform, 40, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   55BE 18                    1    .db e_type_platform
   55BF 28                    2    .db 40
   55C0 A0                    3    .db 160
   55C1 00                    4    .db 0
   55C2 00                    5    .db 0
   55C3 05                    6    .db 5
   55C4 0A                    7    .db 10
   55C5 1E 20                 8    .dw _tiles_sp_00
   55C7 00                    9    .db 0
   55C8 00 00                10    .dw 0x0000
   55CA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   55CB 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   55CC 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   55CD                     330 DefineEntity platah143, e_type_platform, 55, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 89.
Hexadecimal [16-Bits]



   0D30                       1 platah143::
   0D30                       2    DefineEntityAnnonimous e_type_platform, 55, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   55CD 18                    1    .db e_type_platform
   55CE 37                    2    .db 55
   55CF A0                    3    .db 160
   55D0 00                    4    .db 0
   55D1 00                    5    .db 0
   55D2 05                    6    .db 5
   55D3 0A                    7    .db 10
   55D4 1E 20                 8    .dw _tiles_sp_00
   55D6 00                    9    .db 0
   55D7 00 00                10    .dw 0x0000
   55D9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   55DA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   55DB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   55DC                     331 DefineEntity platah144, e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0D3F                       1 platah144::
   0D3F                       2    DefineEntityAnnonimous e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   55DC 18                    1    .db e_type_platform
   55DD 46                    2    .db 70
   55DE A0                    3    .db 160
   55DF 00                    4    .db 0
   55E0 00                    5    .db 0
   55E1 05                    6    .db 5
   55E2 0A                    7    .db 10
   55E3 1E 20                 8    .dw _tiles_sp_00
   55E5 00                    9    .db 0
   55E6 00 00                10    .dw 0x0000
   55E8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   55E9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   55EA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   55EB                     332 DefineEntity platah145, e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0D4E                       1 platah145::
   0D4E                       2    DefineEntityAnnonimous e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   55EB 18                    1    .db e_type_platform
   55EC 4B                    2    .db 75
   55ED 82                    3    .db 130
   55EE 00                    4    .db 0
   55EF 00                    5    .db 0
   55F0 05                    6    .db 5
   55F1 0A                    7    .db 10
   55F2 1E 20                 8    .dw _tiles_sp_00
   55F4 00                    9    .db 0
   55F5 00 00                10    .dw 0x0000
   55F7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   55F8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   55F9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   55FA                     333 DefineEntity platah146, e_type_platform, 60, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0D5D                       1 platah146::
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 90.
Hexadecimal [16-Bits]



   0D5D                       2    DefineEntityAnnonimous e_type_platform, 60, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   55FA 18                    1    .db e_type_platform
   55FB 3C                    2    .db 60
   55FC 64                    3    .db 100
   55FD 00                    4    .db 0
   55FE 00                    5    .db 0
   55FF 05                    6    .db 5
   5600 0A                    7    .db 10
   5601 1E 20                 8    .dw _tiles_sp_00
   5603 00                    9    .db 0
   5604 00 00                10    .dw 0x0000
   5606 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5607 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5608 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5609                     334 DefineEntity platah147, e_type_platform, 30, 100, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0D6C                       1 platah147::
   0D6C                       2    DefineEntityAnnonimous e_type_platform, 30, 100, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5609 18                    1    .db e_type_platform
   560A 1E                    2    .db 30
   560B 64                    3    .db 100
   560C 00                    4    .db 0
   560D 00                    5    .db 0
   560E 0F                    6    .db 15
   560F 0A                    7    .db 10
   5610 B6 25                 8    .dw _floor_ceiling_sp_0
   5612 00                    9    .db 0
   5613 00 00                10    .dw 0x0000
   5615 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5616 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5617 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5618                     335 DefineEntity platah148, e_type_platform, 12, 75, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0D7B                       1 platah148::
   0D7B                       2    DefineEntityAnnonimous e_type_platform, 12, 75, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5618 18                    1    .db e_type_platform
   5619 0C                    2    .db 12
   561A 4B                    3    .db 75
   561B 00                    4    .db 0
   561C 00                    5    .db 0
   561D 05                    6    .db 5
   561E 0A                    7    .db 10
   561F 1E 20                 8    .dw _tiles_sp_00
   5621 00                    9    .db 0
   5622 00 00                10    .dw 0x0000
   5624 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5625 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5626 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5627                     336 DefineEntity platah149, e_type_platform, 22, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0D8A                       1 platah149::
   0D8A                       2    DefineEntityAnnonimous e_type_platform, 22, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 91.
Hexadecimal [16-Bits]



   5627 18                    1    .db e_type_platform
   5628 16                    2    .db 22
   5629 32                    3    .db 50
   562A 00                    4    .db 0
   562B 00                    5    .db 0
   562C 05                    6    .db 5
   562D 0A                    7    .db 10
   562E 1E 20                 8    .dw _tiles_sp_00
   5630 00                    9    .db 0
   5631 00 00                10    .dw 0x0000
   5633 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5634 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5635 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5636                     337 DefineEntity platah1410, e_type_platform, 35, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0D99                       1 platah1410::
   0D99                       2    DefineEntityAnnonimous e_type_platform, 35, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5636 18                    1    .db e_type_platform
   5637 23                    2    .db 35
   5638 32                    3    .db 50
   5639 00                    4    .db 0
   563A 00                    5    .db 0
   563B 0F                    6    .db 15
   563C 0A                    7    .db 10
   563D B6 25                 8    .dw _floor_ceiling_sp_0
   563F 00                    9    .db 0
   5640 00 00                10    .dw 0x0000
   5642 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5643 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5644 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5645                     338 DefineEntity platah1411, e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0DA8                       1 platah1411::
   0DA8                       2    DefineEntityAnnonimous e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5645 18                    1    .db e_type_platform
   5646 37                    2    .db 55
   5647 32                    3    .db 50
   5648 00                    4    .db 0
   5649 00                    5    .db 0
   564A 0F                    6    .db 15
   564B 0A                    7    .db 10
   564C B6 25                 8    .dw _floor_ceiling_sp_0
   564E 00                    9    .db 0
   564F 00 00                10    .dw 0x0000
   5651 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5652 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5653 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5654                     339 DefineEntity platah1412, e_type_platform, 75, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0DB7                       1 platah1412::
   0DB7                       2    DefineEntityAnnonimous e_type_platform, 75, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5654 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 92.
Hexadecimal [16-Bits]



   5655 4B                    2    .db 75
   5656 32                    3    .db 50
   5657 00                    4    .db 0
   5658 00                    5    .db 0
   5659 05                    6    .db 5
   565A 0A                    7    .db 10
   565B 1E 20                 8    .dw _tiles_sp_00
   565D 00                    9    .db 0
   565E 00 00                10    .dw 0x0000
   5660 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5661 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5662 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5663                     340 DefineEntity platah1413, e_type_platform, 0, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0DC6                       1 platah1413::
   0DC6                       2    DefineEntityAnnonimous e_type_platform, 0, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5663 18                    1    .db e_type_platform
   5664 00                    2    .db 0
   5665 AA                    3    .db 170
   5666 00                    4    .db 0
   5667 00                    5    .db 0
   5668 05                    6    .db 5
   5669 0A                    7    .db 10
   566A 1E 20                 8    .dw _tiles_sp_00
   566C 00                    9    .db 0
   566D 00 00                10    .dw 0x0000
   566F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5670 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5671 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5672                     341 DefineEntity platah1414, e_type_platform, 5, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0DD5                       1 platah1414::
   0DD5                       2    DefineEntityAnnonimous e_type_platform, 5, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5672 18                    1    .db e_type_platform
   5673 05                    2    .db 5
   5674 AA                    3    .db 170
   5675 00                    4    .db 0
   5676 00                    5    .db 0
   5677 05                    6    .db 5
   5678 0A                    7    .db 10
   5679 1E 20                 8    .dw _tiles_sp_00
   567B 00                    9    .db 0
   567C 00 00                10    .dw 0x0000
   567E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   567F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5680 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5681                     342 DefineEntity platah1415, e_type_platform, 10, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0DE4                       1 platah1415::
   0DE4                       2    DefineEntityAnnonimous e_type_platform, 10, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5681 18                    1    .db e_type_platform
   5682 0A                    2    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 93.
Hexadecimal [16-Bits]



   5683 AA                    3    .db 170
   5684 00                    4    .db 0
   5685 00                    5    .db 0
   5686 05                    6    .db 5
   5687 0A                    7    .db 10
   5688 1E 20                 8    .dw _tiles_sp_00
   568A 00                    9    .db 0
   568B 00 00                10    .dw 0x0000
   568D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   568E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   568F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            343 
   5690                     344 DefineEntity tramp141, e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0DF3                       1 tramp141::
   0DF3                       2    DefineEntityAnnonimous e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5690 10                    1    .db e_type_trap
   5691 0F                    2    .db 15
   5692 B4                    3    .db 180
   5693 00                    4    .db 0
   5694 00                    5    .db 0
   5695 05                    6    .db 5
   5696 0A                    7    .db 10
   5697 50 20                 8    .dw _tiles_sp_01
   5699 00                    9    .db 0
   569A 00 00                10    .dw 0x0000
   569C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   569D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   569E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   569F                     345 DefineEntity tramp142, e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0E02                       1 tramp142::
   0E02                       2    DefineEntityAnnonimous e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   569F 10                    1    .db e_type_trap
   56A0 14                    2    .db 20
   56A1 B4                    3    .db 180
   56A2 00                    4    .db 0
   56A3 00                    5    .db 0
   56A4 05                    6    .db 5
   56A5 0A                    7    .db 10
   56A6 50 20                 8    .dw _tiles_sp_01
   56A8 00                    9    .db 0
   56A9 00 00                10    .dw 0x0000
   56AB 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   56AC 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   56AD 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   56AE                     346 DefineEntity tramp143, e_type_trap, 30, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   0E11                       1 tramp143::
   0E11                       2    DefineEntityAnnonimous e_type_trap, 30, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
   56AE 10                    1    .db e_type_trap
   56AF 1E                    2    .db 30
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 94.
Hexadecimal [16-Bits]



   56B0 B4                    3    .db 180
   56B1 00                    4    .db 0
   56B2 00                    5    .db 0
   56B3 32                    6    .db 50
   56B4 0A                    7    .db 10
   56B5 1A 1E                 8    .dw _linea_pin_sp
   56B7 00                    9    .db 0
   56B8 00 00                10    .dw 0x0000
   56BA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   56BB 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   56BC 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   56BD                     347 DefineEntity tramp144, e_type_trap, 35, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0E20                       1 tramp144::
   0E20                       2    DefineEntityAnnonimous e_type_trap, 35, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   56BD 10                    1    .db e_type_trap
   56BE 23                    2    .db 35
   56BF 5A                    3    .db 90
   56C0 00                    4    .db 0
   56C1 00                    5    .db 0
   56C2 05                    6    .db 5
   56C3 0A                    7    .db 10
   56C4 50 20                 8    .dw _tiles_sp_01
   56C6 00                    9    .db 0
   56C7 00 00                10    .dw 0x0000
   56C9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   56CA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   56CB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   56CC                     348 DefineEntity tramp145, e_type_trap, 40, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0E2F                       1 tramp145::
   0E2F                       2    DefineEntityAnnonimous e_type_trap, 40, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   56CC 10                    1    .db e_type_trap
   56CD 28                    2    .db 40
   56CE 28                    3    .db 40
   56CF 00                    4    .db 0
   56D0 00                    5    .db 0
   56D1 05                    6    .db 5
   56D2 0A                    7    .db 10
   56D3 50 20                 8    .dw _tiles_sp_01
   56D5 00                    9    .db 0
   56D6 00 00                10    .dw 0x0000
   56D8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   56D9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   56DA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            349 
   56DB                     350 DefineEntity enemy141, e_type_enemy, 55, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x10
   0E3E                       1 enemy141::
   0E3E                       2    DefineEntityAnnonimous e_type_enemy, 55, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x10
   56DB B0                    1    .db e_type_enemy
   56DC 37                    2    .db 55
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 95.
Hexadecimal [16-Bits]



   56DD 96                    3    .db 150
   56DE 00                    4    .db 0
   56DF 00                    5    .db 0
   56E0 05                    6    .db 5
   56E1 0A                    7    .db 10
   56E2 E6 20                 8    .dw _tiles_sp_04
   56E4 00                    9    .db 0
   56E5 00 00                10    .dw 0x0000
   56E7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   56E8 01                   13    .db #1      ; y para guardar el estado de la IA de los enemigos
   56E9 10                   14    .db 0x10     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   56EA                     351 DefineEntity enemy142, e_type_enemy, 17, 50, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x8
   0E4D                       1 enemy142::
   0E4D                       2    DefineEntityAnnonimous e_type_enemy, 17, 50, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x8
   56EA B0                    1    .db e_type_enemy
   56EB 11                    2    .db 17
   56EC 32                    3    .db 50
   56ED 00                    4    .db 0
   56EE 00                    5    .db 0
   56EF 05                    6    .db 5
   56F0 0A                    7    .db 10
   56F1 AE 21                 8    .dw _tiles_sp_08
   56F3 00                    9    .db 0
   56F4 00 00                10    .dw 0x0000
   56F6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   56F7 03                   13    .db #3      ; y para guardar el estado de la IA de los enemigos
   56F8 08                   14    .db 0x8     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            352 
                            353 ;; NIVEL 18 (MULETILLA 16)
   56F9                     354 DefineEntity player16, e_type_player, 0, 150, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
   0E5C                       1 player16::
   0E5C                       2    DefineEntityAnnonimous e_type_player, 0, 150, 0, 0, 5, 10, _protagonista_sp_0, 0, 0x0000, 0x01, 0x00, 0x00
   56F9 78                    1    .db e_type_player
   56FA 00                    2    .db 0
   56FB 96                    3    .db 150
   56FC 00                    4    .db 0
   56FD 00                    5    .db 0
   56FE 05                    6    .db 5
   56FF 0A                    7    .db 10
   5700 82 28                 8    .dw _protagonista_sp_0
   5702 00                    9    .db 0
   5703 00 00                10    .dw 0x0000
   5705 01                   11    .db 0x01        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5706 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5707 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5708                     355 DefineEntity portal160, e_type_portal, 5, 18, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   0E6B                       1 portal160::
   0E6B                       2    DefineEntityAnnonimous e_type_portal, 5, 18, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   5708 12                    1    .db e_type_portal
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 96.
Hexadecimal [16-Bits]



   5709 05                    2    .db 5
   570A 12                    3    .db 18
   570B 00                    4    .db 0
   570C 00                    5    .db 0
   570D 05                    6    .db 5
   570E 0A                    7    .db 10
   570F 82 20                 8    .dw _tiles_sp_02
   5711 00                    9    .db 0
   5712 00 00                10    .dw 0x0000
   5714 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5715 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5716 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5717                     356 DefineEntity tierra16, e_type_platform, 60, 0, 0, 0, 15, 30, _tierra_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0E7A                       1 tierra16::
   0E7A                       2    DefineEntityAnnonimous e_type_platform, 60, 0, 0, 0, 15, 30, _tierra_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5717 18                    1    .db e_type_platform
   5718 3C                    2    .db 60
   5719 00                    3    .db 0
   571A 00                    4    .db 0
   571B 00                    5    .db 0
   571C 0F                    6    .db 15
   571D 1E                    7    .db 30
   571E EA 18                 8    .dw _tierra_sp_0
   5720 00                    9    .db 0
   5721 00 00                10    .dw 0x0000
   5723 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5724 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5725 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            357 
   5726                     358 DefineEntity platah161, e_type_platform, 0, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0E89                       1 platah161::
   0E89                       2    DefineEntityAnnonimous e_type_platform, 0, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5726 18                    1    .db e_type_platform
   5727 00                    2    .db 0
   5728 A0                    3    .db 160
   5729 00                    4    .db 0
   572A 00                    5    .db 0
   572B 05                    6    .db 5
   572C 0A                    7    .db 10
   572D 1E 20                 8    .dw _tiles_sp_00
   572F 00                    9    .db 0
   5730 00 00                10    .dw 0x0000
   5732 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5733 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5734 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5735                     359 DefineEntity platah162, e_type_platform, 5, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0E98                       1 platah162::
   0E98                       2    DefineEntityAnnonimous e_type_platform, 5, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5735 18                    1    .db e_type_platform
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 97.
Hexadecimal [16-Bits]



   5736 05                    2    .db 5
   5737 A0                    3    .db 160
   5738 00                    4    .db 0
   5739 00                    5    .db 0
   573A 05                    6    .db 5
   573B 0A                    7    .db 10
   573C 1E 20                 8    .dw _tiles_sp_00
   573E 00                    9    .db 0
   573F 00 00                10    .dw 0x0000
   5741 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5742 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5743 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5744                     360 DefineEntity platah163, e_type_platform, 20, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0EA7                       1 platah163::
   0EA7                       2    DefineEntityAnnonimous e_type_platform, 20, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5744 18                    1    .db e_type_platform
   5745 14                    2    .db 20
   5746 A0                    3    .db 160
   5747 00                    4    .db 0
   5748 00                    5    .db 0
   5749 0F                    6    .db 15
   574A 0A                    7    .db 10
   574B B6 25                 8    .dw _floor_ceiling_sp_0
   574D 00                    9    .db 0
   574E 00 00                10    .dw 0x0000
   5750 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5751 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5752 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5753                     361 DefineEntity platah164, e_type_platform, 35, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0EB6                       1 platah164::
   0EB6                       2    DefineEntityAnnonimous e_type_platform, 35, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5753 18                    1    .db e_type_platform
   5754 23                    2    .db 35
   5755 A0                    3    .db 160
   5756 00                    4    .db 0
   5757 00                    5    .db 0
   5758 0F                    6    .db 15
   5759 0A                    7    .db 10
   575A B6 25                 8    .dw _floor_ceiling_sp_0
   575C 00                    9    .db 0
   575D 00 00                10    .dw 0x0000
   575F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5760 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5761 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5762                     362 DefineEntity platah165, e_type_platform, 50, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0EC5                       1 platah165::
   0EC5                       2    DefineEntityAnnonimous e_type_platform, 50, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5762 18                    1    .db e_type_platform
   5763 32                    2    .db 50
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 98.
Hexadecimal [16-Bits]



   5764 A0                    3    .db 160
   5765 00                    4    .db 0
   5766 00                    5    .db 0
   5767 05                    6    .db 5
   5768 0A                    7    .db 10
   5769 1E 20                 8    .dw _tiles_sp_00
   576B 00                    9    .db 0
   576C 00 00                10    .dw 0x0000
   576E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   576F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5770 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5771                     363 DefineEntity platah166, e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0ED4                       1 platah166::
   0ED4                       2    DefineEntityAnnonimous e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5771 18                    1    .db e_type_platform
   5772 41                    2    .db 65
   5773 8C                    3    .db 140
   5774 00                    4    .db 0
   5775 00                    5    .db 0
   5776 0F                    6    .db 15
   5777 0A                    7    .db 10
   5778 B6 25                 8    .dw _floor_ceiling_sp_0
   577A 00                    9    .db 0
   577B 00 00                10    .dw 0x0000
   577D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   577E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   577F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5780                     364 DefineEntity platah167, e_type_platform, 70, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0EE3                       1 platah167::
   0EE3                       2    DefineEntityAnnonimous e_type_platform, 70, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5780 18                    1    .db e_type_platform
   5781 46                    2    .db 70
   5782 6E                    3    .db 110
   5783 00                    4    .db 0
   5784 00                    5    .db 0
   5785 05                    6    .db 5
   5786 0A                    7    .db 10
   5787 1E 20                 8    .dw _tiles_sp_00
   5789 00                    9    .db 0
   578A 00 00                10    .dw 0x0000
   578C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   578D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   578E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   578F                     365 DefineEntity platah168, e_type_platform, 50, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0EF2                       1 platah168::
   0EF2                       2    DefineEntityAnnonimous e_type_platform, 50, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   578F 18                    1    .db e_type_platform
   5790 32                    2    .db 50
   5791 5A                    3    .db 90
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 99.
Hexadecimal [16-Bits]



   5792 00                    4    .db 0
   5793 00                    5    .db 0
   5794 0F                    6    .db 15
   5795 0A                    7    .db 10
   5796 B6 25                 8    .dw _floor_ceiling_sp_0
   5798 00                    9    .db 0
   5799 00 00                10    .dw 0x0000
   579B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   579C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   579D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   579E                     366 DefineEntity platah169, e_type_platform, 0, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0F01                       1 platah169::
   0F01                       2    DefineEntityAnnonimous e_type_platform, 0, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   579E 18                    1    .db e_type_platform
   579F 00                    2    .db 0
   57A0 5A                    3    .db 90
   57A1 00                    4    .db 0
   57A2 00                    5    .db 0
   57A3 0F                    6    .db 15
   57A4 0A                    7    .db 10
   57A5 B6 25                 8    .dw _floor_ceiling_sp_0
   57A7 00                    9    .db 0
   57A8 00 00                10    .dw 0x0000
   57AA 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   57AB 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   57AC 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   57AD                     367 DefineEntity platah1610, e_type_platform, 15, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   0F10                       1 platah1610::
   0F10                       2    DefineEntityAnnonimous e_type_platform, 15, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   57AD 18                    1    .db e_type_platform
   57AE 0F                    2    .db 15
   57AF 5A                    3    .db 90
   57B0 00                    4    .db 0
   57B1 00                    5    .db 0
   57B2 0F                    6    .db 15
   57B3 0A                    7    .db 10
   57B4 B6 25                 8    .dw _floor_ceiling_sp_0
   57B6 00                    9    .db 0
   57B7 00 00                10    .dw 0x0000
   57B9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   57BA 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   57BB 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   57BC                     368 DefineEntity platah1611, e_type_platform, 30, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0F1F                       1 platah1611::
   0F1F                       2    DefineEntityAnnonimous e_type_platform, 30, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   57BC 18                    1    .db e_type_platform
   57BD 1E                    2    .db 30
   57BE 5A                    3    .db 90
   57BF 00                    4    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 100.
Hexadecimal [16-Bits]



   57C0 00                    5    .db 0
   57C1 05                    6    .db 5
   57C2 0A                    7    .db 10
   57C3 1E 20                 8    .dw _tiles_sp_00
   57C5 00                    9    .db 0
   57C6 00 00                10    .dw 0x0000
   57C8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   57C9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   57CA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   57CB                     369 DefineEntity platah1612, e_type_platform, 25, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0F2E                       1 platah1612::
   0F2E                       2    DefineEntityAnnonimous e_type_platform, 25, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   57CB 18                    1    .db e_type_platform
   57CC 19                    2    .db 25
   57CD 46                    3    .db 70
   57CE 00                    4    .db 0
   57CF 00                    5    .db 0
   57D0 05                    6    .db 5
   57D1 0A                    7    .db 10
   57D2 1E 20                 8    .dw _tiles_sp_00
   57D4 00                    9    .db 0
   57D5 00 00                10    .dw 0x0000
   57D7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   57D8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   57D9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   57DA                     370 DefineEntity platah1613, e_type_platform, 0, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0F3D                       1 platah1613::
   0F3D                       2    DefineEntityAnnonimous e_type_platform, 0, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   57DA 18                    1    .db e_type_platform
   57DB 00                    2    .db 0
   57DC 3C                    3    .db 60
   57DD 00                    4    .db 0
   57DE 00                    5    .db 0
   57DF 05                    6    .db 5
   57E0 0A                    7    .db 10
   57E1 1E 20                 8    .dw _tiles_sp_00
   57E3 00                    9    .db 0
   57E4 00 00                10    .dw 0x0000
   57E6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   57E7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   57E8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   57E9                     371 DefineEntity platah1614, e_type_platform, 0, 30, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   0F4C                       1 platah1614::
   0F4C                       2    DefineEntityAnnonimous e_type_platform, 0, 30, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   57E9 18                    1    .db e_type_platform
   57EA 00                    2    .db 0
   57EB 1E                    3    .db 30
   57EC 00                    4    .db 0
   57ED 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 101.
Hexadecimal [16-Bits]



   57EE 05                    6    .db 5
   57EF 0A                    7    .db 10
   57F0 1E 20                 8    .dw _tiles_sp_00
   57F2 00                    9    .db 0
   57F3 00 00                10    .dw 0x0000
   57F5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   57F6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   57F7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            372 
   57F8                     373 DefineEntity tramp161, e_type_trap, 10, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0F5B                       1 tramp161::
   0F5B                       2    DefineEntityAnnonimous e_type_trap, 10, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   57F8 10                    1    .db e_type_trap
   57F9 0A                    2    .db 10
   57FA B4                    3    .db 180
   57FB 00                    4    .db 0
   57FC 00                    5    .db 0
   57FD 05                    6    .db 5
   57FE 0A                    7    .db 10
   57FF 50 20                 8    .dw _tiles_sp_01
   5801 00                    9    .db 0
   5802 00 00                10    .dw 0x0000
   5804 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5805 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5806 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5807                     374 DefineEntity tramp162, e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0F6A                       1 tramp162::
   0F6A                       2    DefineEntityAnnonimous e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5807 10                    1    .db e_type_trap
   5808 0F                    2    .db 15
   5809 B4                    3    .db 180
   580A 00                    4    .db 0
   580B 00                    5    .db 0
   580C 05                    6    .db 5
   580D 0A                    7    .db 10
   580E 50 20                 8    .dw _tiles_sp_01
   5810 00                    9    .db 0
   5811 00 00                10    .dw 0x0000
   5813 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5814 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5815 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5816                     375 DefineEntity tramp163, e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0F79                       1 tramp163::
   0F79                       2    DefineEntityAnnonimous e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5816 10                    1    .db e_type_trap
   5817 14                    2    .db 20
   5818 B4                    3    .db 180
   5819 00                    4    .db 0
   581A 00                    5    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 102.
Hexadecimal [16-Bits]



   581B 05                    6    .db 5
   581C 0A                    7    .db 10
   581D 50 20                 8    .dw _tiles_sp_01
   581F 00                    9    .db 0
   5820 00 00                10    .dw 0x0000
   5822 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5823 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5824 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5825                     376 DefineEntity tramp165, e_type_trap, 75, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0F88                       1 tramp165::
   0F88                       2    DefineEntityAnnonimous e_type_trap, 75, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5825 10                    1    .db e_type_trap
   5826 4B                    2    .db 75
   5827 6E                    3    .db 110
   5828 00                    4    .db 0
   5829 00                    5    .db 0
   582A 05                    6    .db 5
   582B 0A                    7    .db 10
   582C 50 20                 8    .dw _tiles_sp_01
   582E 00                    9    .db 0
   582F 00 00                10    .dw 0x0000
   5831 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5832 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5833 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5834                     377 DefineEntity tramp166, e_type_trap, 65, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0F97                       1 tramp166::
   0F97                       2    DefineEntityAnnonimous e_type_trap, 65, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5834 10                    1    .db e_type_trap
   5835 41                    2    .db 65
   5836 6E                    3    .db 110
   5837 00                    4    .db 0
   5838 00                    5    .db 0
   5839 05                    6    .db 5
   583A 0A                    7    .db 10
   583B 50 20                 8    .dw _tiles_sp_01
   583D 00                    9    .db 0
   583E 00 00                10    .dw 0x0000
   5840 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5841 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5842 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5843                     378 DefineEntity tramp167, e_type_trap, 5, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0FA6                       1 tramp167::
   0FA6                       2    DefineEntityAnnonimous e_type_trap, 5, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5843 10                    1    .db e_type_trap
   5844 05                    2    .db 5
   5845 3C                    3    .db 60
   5846 00                    4    .db 0
   5847 00                    5    .db 0
   5848 05                    6    .db 5
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 103.
Hexadecimal [16-Bits]



   5849 0A                    7    .db 10
   584A 50 20                 8    .dw _tiles_sp_01
   584C 00                    9    .db 0
   584D 00 00                10    .dw 0x0000
   584F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5850 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5851 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5852                     379 DefineEntity tramp168, e_type_trap, 5, 30, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0FB5                       1 tramp168::
   0FB5                       2    DefineEntityAnnonimous e_type_trap, 5, 30, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5852 10                    1    .db e_type_trap
   5853 05                    2    .db 5
   5854 1E                    3    .db 30
   5855 00                    4    .db 0
   5856 00                    5    .db 0
   5857 05                    6    .db 5
   5858 0A                    7    .db 10
   5859 50 20                 8    .dw _tiles_sp_01
   585B 00                    9    .db 0
   585C 00 00                10    .dw 0x0000
   585E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   585F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5860 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5861                     380 DefineEntity tramp169, e_type_trap, 55, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0FC4                       1 tramp169::
   0FC4                       2    DefineEntityAnnonimous e_type_trap, 55, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5861 10                    1    .db e_type_trap
   5862 37                    2    .db 55
   5863 B4                    3    .db 180
   5864 00                    4    .db 0
   5865 00                    5    .db 0
   5866 05                    6    .db 5
   5867 0A                    7    .db 10
   5868 50 20                 8    .dw _tiles_sp_01
   586A 00                    9    .db 0
   586B 00 00                10    .dw 0x0000
   586D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   586E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   586F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5870                     381 DefineEntity tramp1610, e_type_trap, 60, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0FD3                       1 tramp1610::
   0FD3                       2    DefineEntityAnnonimous e_type_trap, 60, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5870 10                    1    .db e_type_trap
   5871 3C                    2    .db 60
   5872 B4                    3    .db 180
   5873 00                    4    .db 0
   5874 00                    5    .db 0
   5875 05                    6    .db 5
   5876 0A                    7    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 104.
Hexadecimal [16-Bits]



   5877 50 20                 8    .dw _tiles_sp_01
   5879 00                    9    .db 0
   587A 00 00                10    .dw 0x0000
   587C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   587D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   587E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   587F                     382 DefineEntity tramp1611, e_type_trap, 65, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0FE2                       1 tramp1611::
   0FE2                       2    DefineEntityAnnonimous e_type_trap, 65, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   587F 10                    1    .db e_type_trap
   5880 41                    2    .db 65
   5881 B4                    3    .db 180
   5882 00                    4    .db 0
   5883 00                    5    .db 0
   5884 05                    6    .db 5
   5885 0A                    7    .db 10
   5886 50 20                 8    .dw _tiles_sp_01
   5888 00                    9    .db 0
   5889 00 00                10    .dw 0x0000
   588B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   588C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   588D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   588E                     383 DefineEntity tramp1612, e_type_trap, 70, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   0FF1                       1 tramp1612::
   0FF1                       2    DefineEntityAnnonimous e_type_trap, 70, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   588E 10                    1    .db e_type_trap
   588F 46                    2    .db 70
   5890 B4                    3    .db 180
   5891 00                    4    .db 0
   5892 00                    5    .db 0
   5893 05                    6    .db 5
   5894 0A                    7    .db 10
   5895 50 20                 8    .dw _tiles_sp_01
   5897 00                    9    .db 0
   5898 00 00                10    .dw 0x0000
   589A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   589B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   589C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            384 
   589D                     385 DefineEntity enemy161, e_type_enemy, 35, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x0F
   1000                       1 enemy161::
   1000                       2    DefineEntityAnnonimous e_type_enemy, 35, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x0F
   589D B0                    1    .db e_type_enemy
   589E 23                    2    .db 35
   589F 96                    3    .db 150
   58A0 00                    4    .db 0
   58A1 00                    5    .db 0
   58A2 05                    6    .db 5
   58A3 0A                    7    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 105.
Hexadecimal [16-Bits]



   58A4 E6 20                 8    .dw _tiles_sp_04
   58A6 00                    9    .db 0
   58A7 00 00                10    .dw 0x0000
   58A9 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   58AA 01                   13    .db #1      ; y para guardar el estado de la IA de los enemigos
   58AB 0F                   14    .db 0x0F     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   58AC                     386 DefineEntity enemy162, e_type_enemy, 15, 80, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x0F
   100F                       1 enemy162::
   100F                       2    DefineEntityAnnonimous e_type_enemy, 15, 80, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x0F
   58AC B0                    1    .db e_type_enemy
   58AD 0F                    2    .db 15
   58AE 50                    3    .db 80
   58AF 00                    4    .db 0
   58B0 00                    5    .db 0
   58B1 05                    6    .db 5
   58B2 0A                    7    .db 10
   58B3 E6 20                 8    .dw _tiles_sp_04
   58B5 00                    9    .db 0
   58B6 00 00                10    .dw 0x0000
   58B8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   58B9 FF                   13    .db #-1      ; y para guardar el estado de la IA de los enemigos
   58BA 0F                   14    .db 0x0F     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            387 
                            388 ;; NIVEL 17 (MULETILLA 19)
   58BB                     389 DefineEntity player17, e_type_player, 0, 150, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
   101E                       1 player17::
   101E                       2    DefineEntityAnnonimous e_type_player, 0, 150, 0, 0, 5, 10, _protagonista_sp_0, 0, 0x0000, 0x01, 0x00, 0x00
   58BB 78                    1    .db e_type_player
   58BC 00                    2    .db 0
   58BD 96                    3    .db 150
   58BE 00                    4    .db 0
   58BF 00                    5    .db 0
   58C0 05                    6    .db 5
   58C1 0A                    7    .db 10
   58C2 82 28                 8    .dw _protagonista_sp_0
   58C4 00                    9    .db 0
   58C5 00 00                10    .dw 0x0000
   58C7 01                   11    .db 0x01        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   58C8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   58C9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   58CA                     390 DefineEntity portal170, e_type_portal, 55, 80, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   102D                       1 portal170::
   102D                       2    DefineEntityAnnonimous e_type_portal, 55, 80, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   58CA 12                    1    .db e_type_portal
   58CB 37                    2    .db 55
   58CC 50                    3    .db 80
   58CD 00                    4    .db 0
   58CE 00                    5    .db 0
   58CF 05                    6    .db 5
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 106.
Hexadecimal [16-Bits]



   58D0 0A                    7    .db 10
   58D1 82 20                 8    .dw _tiles_sp_02
   58D3 00                    9    .db 0
   58D4 00 00                10    .dw 0x0000
   58D6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   58D7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   58D8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            391 
   58D9                     392 DefineEntity platav171, e_type_platform, 0, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   103C                       1 platav171::
   103C                       2    DefineEntityAnnonimous e_type_platform, 0, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   58D9 18                    1    .db e_type_platform
   58DA 00                    2    .db 0
   58DB A0                    3    .db 160
   58DC 00                    4    .db 0
   58DD 00                    5    .db 0
   58DE 05                    6    .db 5
   58DF 1E                    7    .db 30
   58E0 22 22                 8    .dw _walls_sp_0
   58E2 00                    9    .db 0
   58E3 00 00                10    .dw 0x0000
   58E5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   58E6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   58E7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   58E8                     393 DefineEntity platah172, e_type_platform, 0, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   104B                       1 platah172::
   104B                       2    DefineEntityAnnonimous e_type_platform, 0, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   58E8 18                    1    .db e_type_platform
   58E9 00                    2    .db 0
   58EA 82                    3    .db 130
   58EB 00                    4    .db 0
   58EC 00                    5    .db 0
   58ED 05                    6    .db 5
   58EE 0A                    7    .db 10
   58EF 1E 20                 8    .dw _tiles_sp_00
   58F1 00                    9    .db 0
   58F2 00 00                10    .dw 0x0000
   58F4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   58F5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   58F6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   58F7                     394 DefineEntity platah173, e_type_platform, 0, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   105A                       1 platah173::
   105A                       2    DefineEntityAnnonimous e_type_platform, 0, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   58F7 18                    1    .db e_type_platform
   58F8 00                    2    .db 0
   58F9 64                    3    .db 100
   58FA 00                    4    .db 0
   58FB 00                    5    .db 0
   58FC 05                    6    .db 5
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 107.
Hexadecimal [16-Bits]



   58FD 0A                    7    .db 10
   58FE 1E 20                 8    .dw _tiles_sp_00
   5900 00                    9    .db 0
   5901 00 00                10    .dw 0x0000
   5903 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5904 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5905 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5906                     395 DefineEntity platah174, e_type_platform, 0, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   1069                       1 platah174::
   1069                       2    DefineEntityAnnonimous e_type_platform, 0, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5906 18                    1    .db e_type_platform
   5907 00                    2    .db 0
   5908 46                    3    .db 70
   5909 00                    4    .db 0
   590A 00                    5    .db 0
   590B 05                    6    .db 5
   590C 0A                    7    .db 10
   590D 1E 20                 8    .dw _tiles_sp_00
   590F 00                    9    .db 0
   5910 00 00                10    .dw 0x0000
   5912 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5913 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5914 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5915                     396 DefineEntity platah175, e_type_platform, 0, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   1078                       1 platah175::
   1078                       2    DefineEntityAnnonimous e_type_platform, 0, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5915 18                    1    .db e_type_platform
   5916 00                    2    .db 0
   5917 28                    3    .db 40
   5918 00                    4    .db 0
   5919 00                    5    .db 0
   591A 0F                    6    .db 15
   591B 0A                    7    .db 10
   591C B6 25                 8    .dw _floor_ceiling_sp_0
   591E 00                    9    .db 0
   591F 00 00                10    .dw 0x0000
   5921 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5922 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5923 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5924                     397 DefineEntity platah176, e_type_platform, 15, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   1087                       1 platah176::
   1087                       2    DefineEntityAnnonimous e_type_platform, 15, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5924 18                    1    .db e_type_platform
   5925 0F                    2    .db 15
   5926 50                    3    .db 80
   5927 00                    4    .db 0
   5928 00                    5    .db 0
   5929 05                    6    .db 5
   592A 0A                    7    .db 10
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 108.
Hexadecimal [16-Bits]



   592B 1E 20                 8    .dw _tiles_sp_00
   592D 00                    9    .db 0
   592E 00 00                10    .dw 0x0000
   5930 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5931 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5932 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5933                     398 DefineEntity platah177, e_type_platform, 20, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   1096                       1 platah177::
   1096                       2    DefineEntityAnnonimous e_type_platform, 20, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5933 18                    1    .db e_type_platform
   5934 14                    2    .db 20
   5935 50                    3    .db 80
   5936 00                    4    .db 0
   5937 00                    5    .db 0
   5938 05                    6    .db 5
   5939 0A                    7    .db 10
   593A 1E 20                 8    .dw _tiles_sp_00
   593C 00                    9    .db 0
   593D 00 00                10    .dw 0x0000
   593F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5940 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5941 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5942                     399 DefineEntity platah178, e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   10A5                       1 platah178::
   10A5                       2    DefineEntityAnnonimous e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5942 18                    1    .db e_type_platform
   5943 19                    2    .db 25
   5944 8C                    3    .db 140
   5945 00                    4    .db 0
   5946 00                    5    .db 0
   5947 05                    6    .db 5
   5948 0A                    7    .db 10
   5949 1E 20                 8    .dw _tiles_sp_00
   594B 00                    9    .db 0
   594C 00 00                10    .dw 0x0000
   594E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   594F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5950 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5951                     400 DefineEntity platah179, e_type_platform, 30, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   10B4                       1 platah179::
   10B4                       2    DefineEntityAnnonimous e_type_platform, 30, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5951 18                    1    .db e_type_platform
   5952 1E                    2    .db 30
   5953 8C                    3    .db 140
   5954 00                    4    .db 0
   5955 00                    5    .db 0
   5956 05                    6    .db 5
   5957 0A                    7    .db 10
   5958 1E 20                 8    .dw _tiles_sp_00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 109.
Hexadecimal [16-Bits]



   595A 00                    9    .db 0
   595B 00 00                10    .dw 0x0000
   595D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   595E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   595F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5960                     401 DefineEntity platah1716, e_type_platform, 35, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   10C3                       1 platah1716::
   10C3                       2    DefineEntityAnnonimous e_type_platform, 35, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5960 18                    1    .db e_type_platform
   5961 23                    2    .db 35
   5962 8C                    3    .db 140
   5963 00                    4    .db 0
   5964 00                    5    .db 0
   5965 05                    6    .db 5
   5966 0A                    7    .db 10
   5967 1E 20                 8    .dw _tiles_sp_00
   5969 00                    9    .db 0
   596A 00 00                10    .dw 0x0000
   596C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   596D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   596E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   596F                     402 DefineEntity platah1710, e_type_platform, 65, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   10D2                       1 platah1710::
   10D2                       2    DefineEntityAnnonimous e_type_platform, 65, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   596F 18                    1    .db e_type_platform
   5970 41                    2    .db 65
   5971 96                    3    .db 150
   5972 00                    4    .db 0
   5973 00                    5    .db 0
   5974 0F                    6    .db 15
   5975 0A                    7    .db 10
   5976 B6 25                 8    .dw _floor_ceiling_sp_0
   5978 00                    9    .db 0
   5979 00 00                10    .dw 0x0000
   597B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   597C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   597D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   597E                     403 DefineEntity platah1711, e_type_platform, 10, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   10E1                       1 platah1711::
   10E1                       2    DefineEntityAnnonimous e_type_platform, 10, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   597E 18                    1    .db e_type_platform
   597F 0A                    2    .db 10
   5980 B4                    3    .db 180
   5981 00                    4    .db 0
   5982 00                    5    .db 0
   5983 0F                    6    .db 15
   5984 0A                    7    .db 10
   5985 B6 25                 8    .dw _floor_ceiling_sp_0
   5987 00                    9    .db 0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 110.
Hexadecimal [16-Bits]



   5988 00 00                10    .dw 0x0000
   598A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   598B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   598C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   598D                     404 DefineEntity platah1712, e_type_platform, 25, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   10F0                       1 platah1712::
   10F0                       2    DefineEntityAnnonimous e_type_platform, 25, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   598D 18                    1    .db e_type_platform
   598E 19                    2    .db 25
   598F B4                    3    .db 180
   5990 00                    4    .db 0
   5991 00                    5    .db 0
   5992 0F                    6    .db 15
   5993 0A                    7    .db 10
   5994 B6 25                 8    .dw _floor_ceiling_sp_0
   5996 00                    9    .db 0
   5997 00 00                10    .dw 0x0000
   5999 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   599A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   599B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   599C                     405 DefineEntity platah1713, e_type_platform, 55, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   10FF                       1 platah1713::
   10FF                       2    DefineEntityAnnonimous e_type_platform, 55, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   599C 18                    1    .db e_type_platform
   599D 37                    2    .db 55
   599E B4                    3    .db 180
   599F 00                    4    .db 0
   59A0 00                    5    .db 0
   59A1 0F                    6    .db 15
   59A2 0A                    7    .db 10
   59A3 B6 25                 8    .dw _floor_ceiling_sp_0
   59A5 00                    9    .db 0
   59A6 00 00                10    .dw 0x0000
   59A8 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   59A9 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   59AA 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   59AB                     406 DefineEntity platah1714, e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   110E                       1 platah1714::
   110E                       2    DefineEntityAnnonimous e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   59AB 18                    1    .db e_type_platform
   59AC 41                    2    .db 65
   59AD 78                    3    .db 120
   59AE 00                    4    .db 0
   59AF 00                    5    .db 0
   59B0 0F                    6    .db 15
   59B1 0A                    7    .db 10
   59B2 B6 25                 8    .dw _floor_ceiling_sp_0
   59B4 00                    9    .db 0
   59B5 00 00                10    .dw 0x0000
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 111.
Hexadecimal [16-Bits]



   59B7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   59B8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   59B9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   59BA                     407 DefineEntity platah1715, e_type_platform, 55, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   111D                       1 platah1715::
   111D                       2    DefineEntityAnnonimous e_type_platform, 55, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   59BA 18                    1    .db e_type_platform
   59BB 37                    2    .db 55
   59BC 5A                    3    .db 90
   59BD 00                    4    .db 0
   59BE 00                    5    .db 0
   59BF 0F                    6    .db 15
   59C0 0A                    7    .db 10
   59C1 B6 25                 8    .dw _floor_ceiling_sp_0
   59C3 00                    9    .db 0
   59C4 00 00                10    .dw 0x0000
   59C6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   59C7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   59C8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            408 
   59C9                     409 DefineEntity tramp171, e_type_trap, 15, 70, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   112C                       1 tramp171::
   112C                       2    DefineEntityAnnonimous e_type_trap, 15, 70, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   59C9 10                    1    .db e_type_trap
   59CA 0F                    2    .db 15
   59CB 46                    3    .db 70
   59CC 00                    4    .db 0
   59CD 00                    5    .db 0
   59CE 05                    6    .db 5
   59CF 0A                    7    .db 10
   59D0 50 20                 8    .dw _tiles_sp_01
   59D2 00                    9    .db 0
   59D3 00 00                10    .dw 0x0000
   59D5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   59D6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   59D7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   59D8                     410 DefineEntity tramp172, e_type_trap, 20, 70, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   113B                       1 tramp172::
   113B                       2    DefineEntityAnnonimous e_type_trap, 20, 70, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   59D8 10                    1    .db e_type_trap
   59D9 14                    2    .db 20
   59DA 46                    3    .db 70
   59DB 00                    4    .db 0
   59DC 00                    5    .db 0
   59DD 05                    6    .db 5
   59DE 0A                    7    .db 10
   59DF 50 20                 8    .dw _tiles_sp_01
   59E1 00                    9    .db 0
   59E2 00 00                10    .dw 0x0000
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 112.
Hexadecimal [16-Bits]



   59E4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   59E5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   59E6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   59E7                     411 DefineEntity tramp173, e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   114A                       1 tramp173::
   114A                       2    DefineEntityAnnonimous e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   59E7 10                    1    .db e_type_trap
   59E8 19                    2    .db 25
   59E9 82                    3    .db 130
   59EA 00                    4    .db 0
   59EB 00                    5    .db 0
   59EC 05                    6    .db 5
   59ED 0A                    7    .db 10
   59EE 50 20                 8    .dw _tiles_sp_01
   59F0 00                    9    .db 0
   59F1 00 00                10    .dw 0x0000
   59F3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   59F4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   59F5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   59F6                     412 DefineEntity tramp174, e_type_trap, 30, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1159                       1 tramp174::
   1159                       2    DefineEntityAnnonimous e_type_trap, 30, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   59F6 10                    1    .db e_type_trap
   59F7 1E                    2    .db 30
   59F8 82                    3    .db 130
   59F9 00                    4    .db 0
   59FA 00                    5    .db 0
   59FB 05                    6    .db 5
   59FC 0A                    7    .db 10
   59FD 50 20                 8    .dw _tiles_sp_01
   59FF 00                    9    .db 0
   5A00 00 00                10    .dw 0x0000
   5A02 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A03 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A04 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A05                     413 DefineEntity tramp1719, e_type_trap, 35, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1168                       1 tramp1719::
   1168                       2    DefineEntityAnnonimous e_type_trap, 35, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A05 10                    1    .db e_type_trap
   5A06 23                    2    .db 35
   5A07 82                    3    .db 130
   5A08 00                    4    .db 0
   5A09 00                    5    .db 0
   5A0A 05                    6    .db 5
   5A0B 0A                    7    .db 10
   5A0C 50 20                 8    .dw _tiles_sp_01
   5A0E 00                    9    .db 0
   5A0F 00 00                10    .dw 0x0000
   5A11 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 113.
Hexadecimal [16-Bits]



                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A12 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A13 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A14                     414 DefineEntity tramp175, e_type_trap, 5, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1177                       1 tramp175::
   1177                       2    DefineEntityAnnonimous e_type_trap, 5, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A14 10                    1    .db e_type_trap
   5A15 05                    2    .db 5
   5A16 B4                    3    .db 180
   5A17 00                    4    .db 0
   5A18 00                    5    .db 0
   5A19 05                    6    .db 5
   5A1A 0A                    7    .db 10
   5A1B 50 20                 8    .dw _tiles_sp_01
   5A1D 00                    9    .db 0
   5A1E 00 00                10    .dw 0x0000
   5A20 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A21 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A22 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A23                     415 DefineEntity tramp176, e_type_trap, 5, 170, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1186                       1 tramp176::
   1186                       2    DefineEntityAnnonimous e_type_trap, 5, 170, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A23 10                    1    .db e_type_trap
   5A24 05                    2    .db 5
   5A25 AA                    3    .db 170
   5A26 00                    4    .db 0
   5A27 00                    5    .db 0
   5A28 05                    6    .db 5
   5A29 0A                    7    .db 10
   5A2A 50 20                 8    .dw _tiles_sp_01
   5A2C 00                    9    .db 0
   5A2D 00 00                10    .dw 0x0000
   5A2F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A30 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A31 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A32                     416 DefineEntity tramp177, e_type_trap, 5, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1195                       1 tramp177::
   1195                       2    DefineEntityAnnonimous e_type_trap, 5, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A32 10                    1    .db e_type_trap
   5A33 05                    2    .db 5
   5A34 96                    3    .db 150
   5A35 00                    4    .db 0
   5A36 00                    5    .db 0
   5A37 05                    6    .db 5
   5A38 0A                    7    .db 10
   5A39 50 20                 8    .dw _tiles_sp_01
   5A3B 00                    9    .db 0
   5A3C 00 00                10    .dw 0x0000
   5A3E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 114.
Hexadecimal [16-Bits]



   5A3F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A40 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A41                     417 DefineEntity tramp178, e_type_trap, 5, 140, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11A4                       1 tramp178::
   11A4                       2    DefineEntityAnnonimous e_type_trap, 5, 140, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A41 10                    1    .db e_type_trap
   5A42 05                    2    .db 5
   5A43 8C                    3    .db 140
   5A44 00                    4    .db 0
   5A45 00                    5    .db 0
   5A46 05                    6    .db 5
   5A47 0A                    7    .db 10
   5A48 50 20                 8    .dw _tiles_sp_01
   5A4A 00                    9    .db 0
   5A4B 00 00                10    .dw 0x0000
   5A4D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A4E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A4F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A50                     418 DefineEntity tramp179, e_type_trap, 5, 120, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11B3                       1 tramp179::
   11B3                       2    DefineEntityAnnonimous e_type_trap, 5, 120, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A50 10                    1    .db e_type_trap
   5A51 05                    2    .db 5
   5A52 78                    3    .db 120
   5A53 00                    4    .db 0
   5A54 00                    5    .db 0
   5A55 05                    6    .db 5
   5A56 0A                    7    .db 10
   5A57 50 20                 8    .dw _tiles_sp_01
   5A59 00                    9    .db 0
   5A5A 00 00                10    .dw 0x0000
   5A5C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A5D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A5E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A5F                     419 DefineEntity tramp1710, e_type_trap, 5, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11C2                       1 tramp1710::
   11C2                       2    DefineEntityAnnonimous e_type_trap, 5, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A5F 10                    1    .db e_type_trap
   5A60 05                    2    .db 5
   5A61 6E                    3    .db 110
   5A62 00                    4    .db 0
   5A63 00                    5    .db 0
   5A64 05                    6    .db 5
   5A65 0A                    7    .db 10
   5A66 50 20                 8    .dw _tiles_sp_01
   5A68 00                    9    .db 0
   5A69 00 00                10    .dw 0x0000
   5A6B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A6C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 115.
Hexadecimal [16-Bits]



   5A6D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A6E                     420 DefineEntity tramp1711, e_type_trap, 5, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11D1                       1 tramp1711::
   11D1                       2    DefineEntityAnnonimous e_type_trap, 5, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A6E 10                    1    .db e_type_trap
   5A6F 05                    2    .db 5
   5A70 5A                    3    .db 90
   5A71 00                    4    .db 0
   5A72 00                    5    .db 0
   5A73 05                    6    .db 5
   5A74 0A                    7    .db 10
   5A75 50 20                 8    .dw _tiles_sp_01
   5A77 00                    9    .db 0
   5A78 00 00                10    .dw 0x0000
   5A7A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A7B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A7C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A7D                     421 DefineEntity tramp1712, e_type_trap, 5, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11E0                       1 tramp1712::
   11E0                       2    DefineEntityAnnonimous e_type_trap, 5, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A7D 10                    1    .db e_type_trap
   5A7E 05                    2    .db 5
   5A7F 50                    3    .db 80
   5A80 00                    4    .db 0
   5A81 00                    5    .db 0
   5A82 05                    6    .db 5
   5A83 0A                    7    .db 10
   5A84 50 20                 8    .dw _tiles_sp_01
   5A86 00                    9    .db 0
   5A87 00 00                10    .dw 0x0000
   5A89 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A8A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A8B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A8C                     422 DefineEntity tramp1713, e_type_trap, 5, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11EF                       1 tramp1713::
   11EF                       2    DefineEntityAnnonimous e_type_trap, 5, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A8C 10                    1    .db e_type_trap
   5A8D 05                    2    .db 5
   5A8E 3C                    3    .db 60
   5A8F 00                    4    .db 0
   5A90 00                    5    .db 0
   5A91 05                    6    .db 5
   5A92 0A                    7    .db 10
   5A93 50 20                 8    .dw _tiles_sp_01
   5A95 00                    9    .db 0
   5A96 00 00                10    .dw 0x0000
   5A98 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5A99 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5A9A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 116.
Hexadecimal [16-Bits]



                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5A9B                     423 DefineEntity tramp1714, e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   11FE                       1 tramp1714::
   11FE                       2    DefineEntityAnnonimous e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5A9B 10                    1    .db e_type_trap
   5A9C 28                    2    .db 40
   5A9D B4                    3    .db 180
   5A9E 00                    4    .db 0
   5A9F 00                    5    .db 0
   5AA0 05                    6    .db 5
   5AA1 0A                    7    .db 10
   5AA2 50 20                 8    .dw _tiles_sp_01
   5AA4 00                    9    .db 0
   5AA5 00 00                10    .dw 0x0000
   5AA7 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5AA8 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5AA9 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5AAA                     424 DefineEntity tramp1715, e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   120D                       1 tramp1715::
   120D                       2    DefineEntityAnnonimous e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5AAA 10                    1    .db e_type_trap
   5AAB 2D                    2    .db 45
   5AAC B4                    3    .db 180
   5AAD 00                    4    .db 0
   5AAE 00                    5    .db 0
   5AAF 05                    6    .db 5
   5AB0 0A                    7    .db 10
   5AB1 50 20                 8    .dw _tiles_sp_01
   5AB3 00                    9    .db 0
   5AB4 00 00                10    .dw 0x0000
   5AB6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5AB7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5AB8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5AB9                     425 DefineEntity tramp1716, e_type_trap, 50, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   121C                       1 tramp1716::
   121C                       2    DefineEntityAnnonimous e_type_trap, 50, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5AB9 10                    1    .db e_type_trap
   5ABA 32                    2    .db 50
   5ABB B4                    3    .db 180
   5ABC 00                    4    .db 0
   5ABD 00                    5    .db 0
   5ABE 05                    6    .db 5
   5ABF 0A                    7    .db 10
   5AC0 50 20                 8    .dw _tiles_sp_01
   5AC2 00                    9    .db 0
   5AC3 00 00                10    .dw 0x0000
   5AC5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5AC6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5AC7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 117.
Hexadecimal [16-Bits]



   5AC8                     426 DefineEntity tramp1717, e_type_trap, 70, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   122B                       1 tramp1717::
   122B                       2    DefineEntityAnnonimous e_type_trap, 70, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5AC8 10                    1    .db e_type_trap
   5AC9 46                    2    .db 70
   5ACA B4                    3    .db 180
   5ACB 00                    4    .db 0
   5ACC 00                    5    .db 0
   5ACD 05                    6    .db 5
   5ACE 0A                    7    .db 10
   5ACF 50 20                 8    .dw _tiles_sp_01
   5AD1 00                    9    .db 0
   5AD2 00 00                10    .dw 0x0000
   5AD4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5AD5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5AD6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5AD7                     427 DefineEntity tramp1718, e_type_trap, 75, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   123A                       1 tramp1718::
   123A                       2    DefineEntityAnnonimous e_type_trap, 75, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5AD7 10                    1    .db e_type_trap
   5AD8 4B                    2    .db 75
   5AD9 B4                    3    .db 180
   5ADA 00                    4    .db 0
   5ADB 00                    5    .db 0
   5ADC 05                    6    .db 5
   5ADD 0A                    7    .db 10
   5ADE 50 20                 8    .dw _tiles_sp_01
   5AE0 00                    9    .db 0
   5AE1 00 00                10    .dw 0x0000
   5AE3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5AE4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5AE5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            428 
   5AE6                     429 DefineEntity enemy171, e_type_enemy, 35, 170, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x16
   1249                       1 enemy171::
   1249                       2    DefineEntityAnnonimous e_type_enemy, 35, 170, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x16
   5AE6 B0                    1    .db e_type_enemy
   5AE7 23                    2    .db 35
   5AE8 AA                    3    .db 170
   5AE9 00                    4    .db 0
   5AEA 00                    5    .db 0
   5AEB 05                    6    .db 5
   5AEC 0A                    7    .db 10
   5AED E6 20                 8    .dw _tiles_sp_04
   5AEF 00                    9    .db 0
   5AF0 00 00                10    .dw 0x0000
   5AF2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5AF3 01                   13    .db #1      ; y para guardar el estado de la IA de los enemigos
   5AF4 16                   14    .db 0x16     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 118.
Hexadecimal [16-Bits]



                            430 
                            431 ;; NIVEL 20 (MULETILLA 18)
   5AF5                     432 DefineEntity player180, e_type_player, 0, 170, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
   1258                       1 player180::
   1258                       2    DefineEntityAnnonimous e_type_player, 0, 170, 0, 0, 5, 10, _protagonista_sp_0, 0, 0x0000, 0x01, 0x00, 0x00
   5AF5 78                    1    .db e_type_player
   5AF6 00                    2    .db 0
   5AF7 AA                    3    .db 170
   5AF8 00                    4    .db 0
   5AF9 00                    5    .db 0
   5AFA 05                    6    .db 5
   5AFB 0A                    7    .db 10
   5AFC 82 28                 8    .dw _protagonista_sp_0
   5AFE 00                    9    .db 0
   5AFF 00 00                10    .dw 0x0000
   5B01 01                   11    .db 0x01        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B02 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B03 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B04                     433 DefineEntity portal180, e_type_portal, 75, 50, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
   1267                       1 portal180::
   1267                       2    DefineEntityAnnonimous e_type_portal, 75, 50, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
   5B04 12                    1    .db e_type_portal
   5B05 4B                    2    .db 75
   5B06 32                    3    .db 50
   5B07 00                    4    .db 0
   5B08 00                    5    .db 0
   5B09 05                    6    .db 5
   5B0A 0A                    7    .db 10
   5B0B 82 20                 8    .dw _tiles_sp_02
   5B0D 00                    9    .db 0
   5B0E 00 00                10    .dw 0x0000
   5B10 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B11 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B12 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B13                     434 DefineEntity platah180, e_type_platform, 0, 180, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   1276                       1 platah180::
   1276                       2    DefineEntityAnnonimous e_type_platform, 0, 180, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5B13 18                    1    .db e_type_platform
   5B14 00                    2    .db 0
   5B15 B4                    3    .db 180
   5B16 00                    4    .db 0
   5B17 00                    5    .db 0
   5B18 05                    6    .db 5
   5B19 0A                    7    .db 10
   5B1A 1E 20                 8    .dw _tiles_sp_00
   5B1C 00                    9    .db 0
   5B1D 00 00                10    .dw 0x0000
   5B1F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B20 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B21 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 119.
Hexadecimal [16-Bits]



                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B22                     435 DefineEntity platah181, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   1285                       1 platah181::
   1285                       2    DefineEntityAnnonimous e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5B22 18                    1    .db e_type_platform
   5B23 0A                    2    .db 10
   5B24 A0                    3    .db 160
   5B25 00                    4    .db 0
   5B26 00                    5    .db 0
   5B27 0F                    6    .db 15
   5B28 0A                    7    .db 10
   5B29 B6 25                 8    .dw _floor_ceiling_sp_0
   5B2B 00                    9    .db 0
   5B2C 00 00                10    .dw 0x0000
   5B2E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B2F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B30 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B31                     436 DefineEntity platah182, e_type_platform, 0, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   1294                       1 platah182::
   1294                       2    DefineEntityAnnonimous e_type_platform, 0, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5B31 18                    1    .db e_type_platform
   5B32 00                    2    .db 0
   5B33 8C                    3    .db 140
   5B34 00                    4    .db 0
   5B35 00                    5    .db 0
   5B36 05                    6    .db 5
   5B37 0A                    7    .db 10
   5B38 1E 20                 8    .dw _tiles_sp_00
   5B3A 00                    9    .db 0
   5B3B 00 00                10    .dw 0x0000
   5B3D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B3E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B3F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B40                     437 DefineEntity platah183, e_type_platform, 5, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   12A3                       1 platah183::
   12A3                       2    DefineEntityAnnonimous e_type_platform, 5, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5B40 18                    1    .db e_type_platform
   5B41 05                    2    .db 5
   5B42 6E                    3    .db 110
   5B43 00                    4    .db 0
   5B44 00                    5    .db 0
   5B45 05                    6    .db 5
   5B46 0A                    7    .db 10
   5B47 1E 20                 8    .dw _tiles_sp_00
   5B49 00                    9    .db 0
   5B4A 00 00                10    .dw 0x0000
   5B4C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B4D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B4E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 120.
Hexadecimal [16-Bits]



   5B4F                     438 DefineEntity platah184, e_type_platform, 5, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   12B2                       1 platah184::
   12B2                       2    DefineEntityAnnonimous e_type_platform, 5, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5B4F 18                    1    .db e_type_platform
   5B50 05                    2    .db 5
   5B51 50                    3    .db 80
   5B52 00                    4    .db 0
   5B53 00                    5    .db 0
   5B54 05                    6    .db 5
   5B55 0A                    7    .db 10
   5B56 1E 20                 8    .dw _tiles_sp_00
   5B58 00                    9    .db 0
   5B59 00 00                10    .dw 0x0000
   5B5B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B5C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B5D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B5E                     439 DefineEntity platah185, e_type_platform, 20, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   12C1                       1 platah185::
   12C1                       2    DefineEntityAnnonimous e_type_platform, 20, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5B5E 18                    1    .db e_type_platform
   5B5F 14                    2    .db 20
   5B60 3C                    3    .db 60
   5B61 00                    4    .db 0
   5B62 00                    5    .db 0
   5B63 05                    6    .db 5
   5B64 0A                    7    .db 10
   5B65 1E 20                 8    .dw _tiles_sp_00
   5B67 00                    9    .db 0
   5B68 00 00                10    .dw 0x0000
   5B6A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B6B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B6C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B6D                     440 DefineEntity platah186, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   12D0                       1 platah186::
   12D0                       2    DefineEntityAnnonimous e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5B6D 18                    1    .db e_type_platform
   5B6E 0A                    2    .db 10
   5B6F A0                    3    .db 160
   5B70 00                    4    .db 0
   5B71 00                    5    .db 0
   5B72 0F                    6    .db 15
   5B73 0A                    7    .db 10
   5B74 B6 25                 8    .dw _floor_ceiling_sp_0
   5B76 00                    9    .db 0
   5B77 00 00                10    .dw 0x0000
   5B79 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B7A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B7B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B7C                     441 DefineEntity platah187, e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 121.
Hexadecimal [16-Bits]



   12DF                       1 platah187::
   12DF                       2    DefineEntityAnnonimous e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5B7C 18                    1    .db e_type_platform
   5B7D 23                    2    .db 35
   5B7E 8C                    3    .db 140
   5B7F 00                    4    .db 0
   5B80 00                    5    .db 0
   5B81 0F                    6    .db 15
   5B82 0A                    7    .db 10
   5B83 B6 25                 8    .dw _floor_ceiling_sp_0
   5B85 00                    9    .db 0
   5B86 00 00                10    .dw 0x0000
   5B88 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B89 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B8A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B8B                     442 DefineEntity platah188, e_type_platform, 50, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   12EE                       1 platah188::
   12EE                       2    DefineEntityAnnonimous e_type_platform, 50, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5B8B 18                    1    .db e_type_platform
   5B8C 32                    2    .db 50
   5B8D 8C                    3    .db 140
   5B8E 00                    4    .db 0
   5B8F 00                    5    .db 0
   5B90 0F                    6    .db 15
   5B91 0A                    7    .db 10
   5B92 B6 25                 8    .dw _floor_ceiling_sp_0
   5B94 00                    9    .db 0
   5B95 00 00                10    .dw 0x0000
   5B97 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5B98 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5B99 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5B9A                     443 DefineEntity platah189, e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   12FD                       1 platah189::
   12FD                       2    DefineEntityAnnonimous e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
   5B9A 18                    1    .db e_type_platform
   5B9B 41                    2    .db 65
   5B9C 8C                    3    .db 140
   5B9D 00                    4    .db 0
   5B9E 00                    5    .db 0
   5B9F 0F                    6    .db 15
   5BA0 0A                    7    .db 10
   5BA1 B6 25                 8    .dw _floor_ceiling_sp_0
   5BA3 00                    9    .db 0
   5BA4 00 00                10    .dw 0x0000
   5BA6 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5BA7 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5BA8 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5BA9                     444 DefineEntity platah1810, e_type_platform, 75, 118, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   130C                       1 platah1810::
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 122.
Hexadecimal [16-Bits]



   130C                       2    DefineEntityAnnonimous e_type_platform, 75, 118, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5BA9 18                    1    .db e_type_platform
   5BAA 4B                    2    .db 75
   5BAB 76                    3    .db 118
   5BAC 00                    4    .db 0
   5BAD 00                    5    .db 0
   5BAE 05                    6    .db 5
   5BAF 0A                    7    .db 10
   5BB0 1E 20                 8    .dw _tiles_sp_00
   5BB2 00                    9    .db 0
   5BB3 00 00                10    .dw 0x0000
   5BB5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5BB6 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5BB7 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5BB8                     445 DefineEntity platah1811, e_type_platform, 60, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   131B                       1 platah1811::
   131B                       2    DefineEntityAnnonimous e_type_platform, 60, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5BB8 18                    1    .db e_type_platform
   5BB9 3C                    2    .db 60
   5BBA 5A                    3    .db 90
   5BBB 00                    4    .db 0
   5BBC 00                    5    .db 0
   5BBD 05                    6    .db 5
   5BBE 0A                    7    .db 10
   5BBF 1E 20                 8    .dw _tiles_sp_00
   5BC1 00                    9    .db 0
   5BC2 00 00                10    .dw 0x0000
   5BC4 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5BC5 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5BC6 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5BC7                     446 DefineEntity platah1812, e_type_platform, 75, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   132A                       1 platah1812::
   132A                       2    DefineEntityAnnonimous e_type_platform, 75, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
   5BC7 18                    1    .db e_type_platform
   5BC8 4B                    2    .db 75
   5BC9 3C                    3    .db 60
   5BCA 00                    4    .db 0
   5BCB 00                    5    .db 0
   5BCC 05                    6    .db 5
   5BCD 0A                    7    .db 10
   5BCE 1E 20                 8    .dw _tiles_sp_00
   5BD0 00                    9    .db 0
   5BD1 00 00                10    .dw 0x0000
   5BD3 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5BD4 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5BD5 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            447 
                            448 
   5BD6                     449 DefineEntity tramp181, e_type_trap, 15, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 123.
Hexadecimal [16-Bits]



   1339                       1 tramp181::
   1339                       2    DefineEntityAnnonimous e_type_trap, 15, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5BD6 10                    1    .db e_type_trap
   5BD7 0F                    2    .db 15
   5BD8 96                    3    .db 150
   5BD9 00                    4    .db 0
   5BDA 00                    5    .db 0
   5BDB 05                    6    .db 5
   5BDC 0A                    7    .db 10
   5BDD 50 20                 8    .dw _tiles_sp_01
   5BDF 00                    9    .db 0
   5BE0 00 00                10    .dw 0x0000
   5BE2 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5BE3 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5BE4 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5BE5                     450 DefineEntity tramp182, e_type_trap, 0, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1348                       1 tramp182::
   1348                       2    DefineEntityAnnonimous e_type_trap, 0, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5BE5 10                    1    .db e_type_trap
   5BE6 00                    2    .db 0
   5BE7 50                    3    .db 80
   5BE8 00                    4    .db 0
   5BE9 00                    5    .db 0
   5BEA 05                    6    .db 5
   5BEB 0A                    7    .db 10
   5BEC 50 20                 8    .dw _tiles_sp_01
   5BEE 00                    9    .db 0
   5BEF 00 00                10    .dw 0x0000
   5BF1 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5BF2 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5BF3 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5BF4                     451 DefineEntity tramp183, e_type_trap, 10, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1357                       1 tramp183::
   1357                       2    DefineEntityAnnonimous e_type_trap, 10, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5BF4 10                    1    .db e_type_trap
   5BF5 0A                    2    .db 10
   5BF6 50                    3    .db 80
   5BF7 00                    4    .db 0
   5BF8 00                    5    .db 0
   5BF9 05                    6    .db 5
   5BFA 0A                    7    .db 10
   5BFB 50 20                 8    .dw _tiles_sp_01
   5BFD 00                    9    .db 0
   5BFE 00 00                10    .dw 0x0000
   5C00 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C01 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C02 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            452 ;DefineEntity tramp184, e_type_trap, 20, 30, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
                            453 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 124.
Hexadecimal [16-Bits]



   5C03                     454 DefineEntity tramp185, e_type_trap, 25, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1366                       1 tramp185::
   1366                       2    DefineEntityAnnonimous e_type_trap, 25, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C03 10                    1    .db e_type_trap
   5C04 19                    2    .db 25
   5C05 3C                    3    .db 60
   5C06 00                    4    .db 0
   5C07 00                    5    .db 0
   5C08 05                    6    .db 5
   5C09 0A                    7    .db 10
   5C0A 50 20                 8    .dw _tiles_sp_01
   5C0C 00                    9    .db 0
   5C0D 00 00                10    .dw 0x0000
   5C0F 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C10 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C11 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5C12                     455 DefineEntity tramp186, e_type_trap, 30, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1375                       1 tramp186::
   1375                       2    DefineEntityAnnonimous e_type_trap, 30, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C12 10                    1    .db e_type_trap
   5C13 1E                    2    .db 30
   5C14 3C                    3    .db 60
   5C15 00                    4    .db 0
   5C16 00                    5    .db 0
   5C17 05                    6    .db 5
   5C18 0A                    7    .db 10
   5C19 50 20                 8    .dw _tiles_sp_01
   5C1B 00                    9    .db 0
   5C1C 00 00                10    .dw 0x0000
   5C1E 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C1F 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C20 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            456 
   5C21                     457 DefineEntity tramp187, e_type_trap, 40, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1384                       1 tramp187::
   1384                       2    DefineEntityAnnonimous e_type_trap, 40, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C21 10                    1    .db e_type_trap
   5C22 28                    2    .db 40
   5C23 5A                    3    .db 90
   5C24 00                    4    .db 0
   5C25 00                    5    .db 0
   5C26 05                    6    .db 5
   5C27 0A                    7    .db 10
   5C28 50 20                 8    .dw _tiles_sp_01
   5C2A 00                    9    .db 0
   5C2B 00 00                10    .dw 0x0000
   5C2D 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C2E 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C2F 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 125.
Hexadecimal [16-Bits]



   5C30                     458 DefineEntity tramp188, e_type_trap, 45, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   1393                       1 tramp188::
   1393                       2    DefineEntityAnnonimous e_type_trap, 45, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C30 10                    1    .db e_type_trap
   5C31 2D                    2    .db 45
   5C32 5A                    3    .db 90
   5C33 00                    4    .db 0
   5C34 00                    5    .db 0
   5C35 05                    6    .db 5
   5C36 0A                    7    .db 10
   5C37 50 20                 8    .dw _tiles_sp_01
   5C39 00                    9    .db 0
   5C3A 00 00                10    .dw 0x0000
   5C3C 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C3D 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C3E 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            459 
   5C3F                     460 DefineEntity tramp189, e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   13A2                       1 tramp189::
   13A2                       2    DefineEntityAnnonimous e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C3F 10                    1    .db e_type_trap
   5C40 19                    2    .db 25
   5C41 82                    3    .db 130
   5C42 00                    4    .db 0
   5C43 00                    5    .db 0
   5C44 05                    6    .db 5
   5C45 0A                    7    .db 10
   5C46 50 20                 8    .dw _tiles_sp_01
   5C48 00                    9    .db 0
   5C49 00 00                10    .dw 0x0000
   5C4B 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C4C 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C4D 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5C4E                     461 DefineEntity tramp1810, e_type_trap, 30, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   13B1                       1 tramp1810::
   13B1                       2    DefineEntityAnnonimous e_type_trap, 30, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C4E 10                    1    .db e_type_trap
   5C4F 1E                    2    .db 30
   5C50 82                    3    .db 130
   5C51 00                    4    .db 0
   5C52 00                    5    .db 0
   5C53 05                    6    .db 5
   5C54 0A                    7    .db 10
   5C55 50 20                 8    .dw _tiles_sp_01
   5C57 00                    9    .db 0
   5C58 00 00                10    .dw 0x0000
   5C5A 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C5B 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C5C 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 126.
Hexadecimal [16-Bits]



                            462 
   5C5D                     463 DefineEntity tramp1811, e_type_trap, 5, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   13C0                       1 tramp1811::
   13C0                       2    DefineEntityAnnonimous e_type_trap, 5, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C5D 10                    1    .db e_type_trap
   5C5E 05                    2    .db 5
   5C5F B4                    3    .db 180
   5C60 00                    4    .db 0
   5C61 00                    5    .db 0
   5C62 05                    6    .db 5
   5C63 0A                    7    .db 10
   5C64 50 20                 8    .dw _tiles_sp_01
   5C66 00                    9    .db 0
   5C67 00 00                10    .dw 0x0000
   5C69 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C6A 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C6B 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5C6C                     464 DefineEntity tramp1812, e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   13CF                       1 tramp1812::
   13CF                       2    DefineEntityAnnonimous e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C6C 10                    1    .db e_type_trap
   5C6D 1E                    2    .db 30
   5C6E B4                    3    .db 180
   5C6F 00                    4    .db 0
   5C70 00                    5    .db 0
   5C71 05                    6    .db 5
   5C72 0A                    7    .db 10
   5C73 50 20                 8    .dw _tiles_sp_01
   5C75 00                    9    .db 0
   5C76 00 00                10    .dw 0x0000
   5C78 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C79 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C7A 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5C7B                     465 DefineEntity tramp1813, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   13DE                       1 tramp1813::
   13DE                       2    DefineEntityAnnonimous e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
   5C7B 10                    1    .db e_type_trap
   5C7C 19                    2    .db 25
   5C7D B4                    3    .db 180
   5C7E 00                    4    .db 0
   5C7F 00                    5    .db 0
   5C80 05                    6    .db 5
   5C81 0A                    7    .db 10
   5C82 50 20                 8    .dw _tiles_sp_01
   5C84 00                    9    .db 0
   5C85 00 00                10    .dw 0x0000
   5C87 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C88 00                   13    .db 0x00      ; y para guardar el estado de la IA de los enemigos
   5C89 00                   14    .db 0x00     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 127.
Hexadecimal [16-Bits]



                            466 
   5C8A                     467 DefineEntity enemy181, e_type_enemy, 38, 100, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x24
   13ED                       1 enemy181::
   13ED                       2    DefineEntityAnnonimous e_type_enemy, 38, 100, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x24
   5C8A B0                    1    .db e_type_enemy
   5C8B 26                    2    .db 38
   5C8C 64                    3    .db 100
   5C8D 00                    4    .db 0
   5C8E 00                    5    .db 0
   5C8F 05                    6    .db 5
   5C90 0A                    7    .db 10
   5C91 E6 20                 8    .dw _tiles_sp_04
   5C93 00                    9    .db 0
   5C94 00 00                10    .dw 0x0000
   5C96 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5C97 01                   13    .db #1      ; y para guardar el estado de la IA de los enemigos
   5C98 24                   14    .db 0x24     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
   5C99                     468 DefineEntity enemy182, e_type_enemy, 38, 70, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x24
   13FC                       1 enemy182::
   13FC                       2    DefineEntityAnnonimous e_type_enemy, 38, 70, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x24
   5C99 B0                    1    .db e_type_enemy
   5C9A 26                    2    .db 38
   5C9B 46                    3    .db 70
   5C9C 00                    4    .db 0
   5C9D 00                    5    .db 0
   5C9E 05                    6    .db 5
   5C9F 0A                    7    .db 10
   5CA0 E6 20                 8    .dw _tiles_sp_04
   5CA2 00                    9    .db 0
   5CA3 00 00                10    .dw 0x0000
   5CA5 00                   11    .db 0x00        ; Lo usamos para saber cuando una plataforma deja de renderizarse (Arreglamos el trozo que no se pintaba de la plataforma)
                             12                      ; y para guardar la ultima direccion pulsada por el player para moverse (Cambiar la animacion)
   5CA6 FF                   13    .db #-1      ; y para guardar el estado de la IA de los enemigos
   5CA7 24                   14    .db 0x24     ; Maxima distancia recorrida por los enemigos
                             15                      ; y booleano para comprobar si es una plataforma o una estrella
                            469 
                            470 
                            471 
                            472 ;; Inicializamos el manager de entidades junto a los sistemas y creamos entidades
                            473 ;; INPUT
                            474 ;;      0
                            475 ;; DESTROY
                            476 ;;      AF, HL, BC, DE, IX, IY
                            477 ;; RETURN
                            478 ;;      0
   5CA8                     479 man_game_init::
                            480 
                            481     ;; Iniciamos el juego con el nivel 1
   5CA8 00                  482     _current_level:: .db #0
                            483 
                            484     ;; Inicializamos los managers y sistemas
   5CA9 CD A8 45      [17]  485     call    man_entity_init
   5CAC CD 0C 45      [17]  486     call    sys_render_init
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 128.
Hexadecimal [16-Bits]



                            487 ;    call    sys_input_init
                            488 
                            489     ;; Cargamos el nivel 1
   5CAF CD 05 5D      [17]  490     call    man_game_load_next_level
                            491 
                            492     ;; Especificamos en que partida estamos, la primera
   5CB2 CD 21 5D      [17]  493     call    man_game_next_play
                            494 
   5CB5 C9            [10]  495     ret
                            496 
                            497 
                            498 
                            499 
                            500 
                            501 
                            502 ;; Reinciamos el juego comenzando apartir de una primera partida
                            503 ;; INPUT
                            504 ;;      0
                            505 ;; DESTROY
                            506 ;;      AF, HL, BC, DE, IX, IY
                            507 ;; RETURN
                            508 ;;      0
   5CB6                     509 man_game_restart::
                            510 
                            511     ;; Especificamos que estamos en el inicio
   5CB6 3E 00         [ 7]  512     ld      a, #0
   5CB8 32 A8 5C      [13]  513     ld      (_current_level), a
                            514 
                            515     ;; Cargamos el nivel 1
   5CBB CD 05 5D      [17]  516     call  man_game_load_next_level
                            517 
                            518     ;; Especificamos en que partida estamos
   5CBE CD 21 5D      [17]  519     call man_game_next_play
                            520 
   5CC1 C9            [10]  521     ret
                            522 
                            523 
                            524 
                            525 
                            526 
                            527 
                            528 
                            529 
                            530 ;; Actualizamos el juego
                            531 ;; INPUT
                            532 ;;      0
                            533 ;; DESTROY
                            534 ;;      AF, HL, BC, DE, IX, IY
                            535 ;; RETURN
                            536 ;;      0
   5CC2                     537 man_game_run::
                            538 
                            539     ;; Guardamos en IX la entidad del player
   5CC2 CD 04 48      [17]  540     call  man_entity_getPlayer_IX
                            541 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 129.
Hexadecimal [16-Bits]



                            542     ;; Actualizamos los sistemas de movimiento
   5CC5 CD 7E 45      [17]  543     call    sys_render_update
   5CC8 CD 22 44      [17]  544     call    sys_input_update
   5CCB CD 3D 43      [17]  545     call    sys_ai_control_update
   5CCE CD 03 45      [17]  546     call    sys_physics_update
                            547 
                            548     ;; Comprobamos si el jugador ha muerto
                            549     ;; Primero marcamos la entidad como muerta
                            550     ;; para visualizar la colision que provoca
                            551     ;; su muerte y luego reiniciamos el nivel
   5CD1 DD 7E 00      [19]  552     ld      a, e_type(ix)
   5CD4 EE 04         [ 7]  553     xor     #e_type_dead_mask
   5CD6 20 06         [12]  554     jr     nz, _update_game_systems
   5CD8 DD 36 00 00   [19]  555     ld      e_type(ix), #e_type_invalid                     ; Invalida al jugador
   5CDC 18 0E         [12]  556     jr      _check_game_state                               ; Terminamos comprobaciones
   5CDE                     557 _update_game_systems:    
                            558 
                            559     ;; Actualizamos las colisiones
   5CDE CD 19 44      [17]  560     call    sys_collision_update
                            561 
                            562     ;; Actualizamos la animacion del player
   5CE1 CD 46 43      [17]  563     call    sys_animation_update
                            564 
                            565     ;; Si el jugador ha muerto, marcamos como muertas todas las entidades enemigas
   5CE4 DD 7E 00      [19]  566     ld      a, e_type(ix)
   5CE7 EE 04         [ 7]  567     xor     #e_type_dead_mask
   5CE9 CC 03 67      [17]  568     call    z, man_game_destroy_all_enemies
   5CEC                     569 _check_game_state:
                            570 
                            571     ;; Comprobamos si el jugador ha muerto
   5CEC DD 7E 00      [19]  572     ld      a, e_type(ix)
   5CEF EE 00         [ 7]  573     xor     #e_type_invalid                                 ; XOR con mascara de entidad invalida
   5CF1 CC 13 5D      [17]  574     call    z, man_game_restart_level
                            575 
                            576     ;; Comprobamos si el jugador colisiona con el portal para pasar al siguiente nivel
   5CF4 3E 01         [ 7]  577     ld      a, #1                                           ; A = posicion de la puerta en el array
   5CF6 CD 09 48      [17]  578     call    man_entity_get_from_idx_IY                      ; IY = entidad portal
   5CF9 FD 7E 00      [19]  579     ld      a, e_type(iy)                                   ; A = e_type
   5CFC EE 04         [ 7]  580     xor     #e_type_dead_mask                               ; Comprobamos si la entidad esta muerta
   5CFE CC 05 5D      [17]  581     call    z, man_game_load_next_level                     ; Cambiamos de nivel
                            582 
                            583     ;; Guardamos el nivel actual para comprobar si nos hemos pasado el juego o no
   5D01 3A A8 5C      [13]  584     ld      a, (_current_level)
                            585 
   5D04 C9            [10]  586     ret
                            587 
                            588 
                            589 
                            590 
                            591 
                            592 
                            593 
                            594 
                            595 ;; Cargamos el siguiente nivel del juego
                            596 ;; INPUT
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 130.
Hexadecimal [16-Bits]



                            597 ;;      0
                            598 ;; DESTROY
                            599 ;;      ALL
                            600 ;; RETURN
                            601 ;;      0
   5D05                     602 man_game_load_next_level::
                            603 
   5D05 CD DE 66      [17]  604     call    man_game_clean_next_level               ; Limpiamos por pantalla
   5D08 3A A8 5C      [13]  605     ld      a, (_current_level)
   5D0B 3C            [ 4]  606     inc     a                                       ; Incrementamos el nivel
   5D0C 32 A8 5C      [13]  607     ld      (_current_level), a
   5D0F CD 29 5D      [17]  608     call    man_game_load_level                     ; Cargar nivel actual
   5D12 C9            [10]  609     ret
                            610 
                            611 
                            612 
                            613 
                            614 
                            615 
                            616 
                            617 
                            618 
                            619 ;; Funcion para reiniciar el nivel del juego
                            620 ;; INPUT
                            621 ;;      0
                            622 ;; DESTROY
                            623 ;;      ALL
                            624 ;; RETURN
                            625 ;;      0
   5D13                     626 man_game_restart_level::
                            627 
   5D13 CD E5 66      [17]  628     call    man_game_clean_restart          ; Destruimos todo el nivel para reconstruirlo
   5D16 CD 29 5D      [17]  629     call    man_game_load_level             ; Cargar nivel actual
   5D19 C9            [10]  630     ret
                            631 
                            632 
                            633 
                            634 
                            635 
                            636 
                            637 
                            638 
                            639 ;; Funcion para sibujar todos los elementos por pantalla y continuar el juego
                            640 ;; INPUT
                            641 ;;      0
                            642 ;; DESTROY
                            643 ;;      ALL
                            644 ;; RETURN
                            645 ;;      0
   5D1A                     646 man_game_continue_level::
                            647 
   5D1A CD 3A 42      [17]  648     call    cpct_limpiarPantalla_asm
   5D1D CD 77 45      [17]  649     call    sys_render_update_all
   5D20 C9            [10]  650     ret
                            651 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 131.
Hexadecimal [16-Bits]



                            652 
                            653 
                            654 
                            655 
                            656 
                            657 
                            658 
                            659 ;; Funcion para incrementar el contador de partidas
                            660 ;; INPUT
                            661 ;;      0
                            662 ;; DESTROY
                            663 ;;      ALL
                            664 ;; RETURN
                            665 ;;      0
   5D21                     666 man_game_next_play::
                            667 
   5D21 3A 9D 48      [13]  668     ld      a, (_num_games)
   5D24 3C            [ 4]  669     inc     a
   5D25 32 9D 48      [13]  670     ld      (_num_games), a
   5D28 C9            [10]  671     ret
                            672 
                            673 
                            674 
                            675 
                            676 
                            677 
                            678 
                            679 
                            680 
                            681 ;; Funcion para cargar el nivel actual del juego
                            682 ;; INPUT
                            683 ;;      0
                            684 ;; DESTROY
                            685 ;;      ALL
                            686 ;; RETURN
                            687 ;;      0
   5D29                     688 man_game_load_level::
   5D29 3A A8 5C      [13]  689      ld      a, (_current_level)             ; Cargamos el nivel actual
   5D2C 3D            [ 4]  690     dec     a
   5D2D CA 77 5D      [10]  691     jp      z, _check_level_zerozero
   5D30 3D            [ 4]  692     dec     a
   5D31 CA A4 5D      [10]  693     jp      z, _check_level_zero
   5D34 3D            [ 4]  694     dec     a
   5D35 CA DD 5D      [10]  695     jp      z, _check_level_one
   5D38 3D            [ 4]  696     dec     a
   5D39 CA 22 5E      [10]  697     jp      z, _check_level_two
   5D3C 3D            [ 4]  698     dec     a
   5D3D CA 61 5E      [10]  699     jp      z, _check_level_three
   5D40 3D            [ 4]  700     dec     a
   5D41 CA B8 5E      [10]  701     jp      z, _check_level_four
   5D44 3D            [ 4]  702     dec     a
   5D45 CA 27 5F      [10]  703     jp      z, _check_level_five
   5D48 3D            [ 4]  704     dec     a
   5D49 CA 96 5F      [10]  705     jp      z, _check_level_six
   5D4C 3D            [ 4]  706     dec     a
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 132.
Hexadecimal [16-Bits]



   5D4D CA 17 60      [10]  707     jp      z, _check_level_seven
   5D50 3D            [ 4]  708     dec     a
   5D51 CA 9E 60      [10]  709     jp      z, _check_level_eight
   5D54 3D            [ 4]  710     dec     a
   5D55 CA 1F 61      [10]  711     jp      z, _check_level_nine
   5D58 3D            [ 4]  712     dec     a
   5D59 CA A0 61      [10]  713     jp      z, _check_level_ten
   5D5C 3D            [ 4]  714     dec     a
   5D5D CA 09 62      [10]  715     jp      z, _check_level_eleven
   5D60 3D            [ 4]  716     dec     a
   5D61 CA 9C 62      [10]  717     jp      z, _check_level_twelve
   5D64 3D            [ 4]  718     dec     a
   5D65 CA 4D 63      [10]  719     jp      z, _check_level_thirteen
   5D68 3D            [ 4]  720     dec     a
   5D69 CA CE 63      [10]  721     jp      z, _check_level_fourteen
   5D6C 3D            [ 4]  722     dec     a
   5D6D CA 6D 64      [10]  723     jp      z, _check_level_sixteen
   5D70 3D            [ 4]  724     dec     a
   5D71 CA 30 65      [10]  725     jp      z, _check_level_seventeen
   5D74 C3 1D 66      [10]  726     jp      _check_level_eighteen
                            727 
                            728 
   5D77                     729 _check_level_zerozero:
   5D77 21 BC 48      [10]  730     ld      hl,#player
   5D7A CD 18 48      [17]  731     call man_entity_create
   5D7D 21 CB 48      [10]  732     ld      hl,#portal000
   5D80 CD 18 48      [17]  733     call man_entity_create
   5D83 21 DA 48      [10]  734     ld      hl,#platah001
   5D86 CD 18 48      [17]  735     call man_entity_create
   5D89 21 E9 48      [10]  736     ld      hl,#platah002
   5D8C CD 18 48      [17]  737     call man_entity_create
   5D8F 21 F8 48      [10]  738     ld      hl,#tierra
   5D92 CD 18 48      [17]  739     call man_entity_create
                            740 
   5D95 21 9E 48      [10]  741     ld    hl, #suelo1
   5D98 CD 18 48      [17]  742     call  man_entity_create
   5D9B 21 AD 48      [10]  743     ld    hl, #suelo2
   5D9E CD 18 48      [17]  744     call  man_entity_create
                            745 
   5DA1 C3 DA 66      [10]  746     jp    _no_load_level
                            747 
   5DA4                     748 _check_level_zero:
   5DA4 21 BC 48      [10]  749     ld      hl,#player
   5DA7 CD 18 48      [17]  750     call man_entity_create
   5DAA 21 07 49      [10]  751     ld      hl,#portal00
   5DAD CD 18 48      [17]  752     call man_entity_create
   5DB0 21 16 49      [10]  753     ld      hl,#platah01
   5DB3 CD 18 48      [17]  754     call man_entity_create
   5DB6 21 25 49      [10]  755     ld      hl,#platah02
   5DB9 CD 18 48      [17]  756     call man_entity_create
   5DBC 21 34 49      [10]  757     ld      hl,#platah03
   5DBF CD 18 48      [17]  758     call man_entity_create
   5DC2 21 43 49      [10]  759     ld      hl,#platah04
   5DC5 CD 18 48      [17]  760     call man_entity_create
   5DC8 21 52 49      [10]  761     ld      hl,#platah05
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 133.
Hexadecimal [16-Bits]



   5DCB CD 18 48      [17]  762     call man_entity_create
                            763 
   5DCE 21 9E 48      [10]  764     ld    hl, #suelo1
   5DD1 CD 18 48      [17]  765     call  man_entity_create
   5DD4 21 AD 48      [10]  766     ld    hl, #suelo2
   5DD7 CD 18 48      [17]  767     call  man_entity_create
                            768 
   5DDA C3 DA 66      [10]  769     jp    _no_load_level
                            770 
   5DDD                     771 _check_level_one:
                            772 
   5DDD 21 BC 48      [10]  773     ld      hl,#player
   5DE0 CD 18 48      [17]  774     call man_entity_create
   5DE3 21 61 49      [10]  775     ld      hl,#portal11
   5DE6 CD 18 48      [17]  776     call man_entity_create
   5DE9 21 70 49      [10]  777     ld      hl,#platah11
   5DEC CD 18 48      [17]  778     call man_entity_create
   5DEF 21 7F 49      [10]  779     ld      hl,#platah12
   5DF2 CD 18 48      [17]  780     call man_entity_create
   5DF5 21 8E 49      [10]  781     ld      hl,#platah13
   5DF8 CD 18 48      [17]  782     call man_entity_create
   5DFB 21 9D 49      [10]  783     ld      hl,#platah14
   5DFE CD 18 48      [17]  784     call man_entity_create
   5E01 21 AC 49      [10]  785     ld      hl,#platah15
   5E04 CD 18 48      [17]  786     call man_entity_create
   5E07 21 BB 49      [10]  787     ld      hl,#platah16
   5E0A CD 18 48      [17]  788     call man_entity_create
   5E0D 21 CA 49      [10]  789     ld      hl,#platah17
   5E10 CD 18 48      [17]  790     call man_entity_create
                            791 
   5E13 21 9E 48      [10]  792     ld    hl, #suelo1
   5E16 CD 18 48      [17]  793     call  man_entity_create
   5E19 21 AD 48      [10]  794     ld    hl, #suelo2
   5E1C CD 18 48      [17]  795     call  man_entity_create
                            796 
   5E1F C3 DA 66      [10]  797     jp    _no_load_level
                            798 
                            799 
   5E22                     800 _check_level_two:
                            801 
   5E22 21 BC 48      [10]  802     ld      hl,#player
   5E25 CD 18 48      [17]  803     call man_entity_create
   5E28 21 D9 49      [10]  804     ld      hl,#portal20
   5E2B CD 18 48      [17]  805     call man_entity_create
   5E2E 21 E8 49      [10]  806     ld      hl,#platah21
   5E31 CD 18 48      [17]  807     call man_entity_create
   5E34 21 F7 49      [10]  808     ld      hl,#platah22
   5E37 CD 18 48      [17]  809     call man_entity_create
   5E3A 21 06 4A      [10]  810     ld      hl,#platah23
   5E3D CD 18 48      [17]  811     call man_entity_create
   5E40 21 15 4A      [10]  812     ld      hl,#platah24
   5E43 CD 18 48      [17]  813     call man_entity_create
   5E46 21 24 4A      [10]  814     ld      hl,#platah25
   5E49 CD 18 48      [17]  815     call man_entity_create
   5E4C 21 33 4A      [10]  816     ld      hl,#platah26
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 134.
Hexadecimal [16-Bits]



   5E4F CD 18 48      [17]  817     call man_entity_create
                            818 
                            819 
   5E52 21 9E 48      [10]  820     ld    hl, #suelo1
   5E55 CD 18 48      [17]  821     call man_entity_create
   5E58 21 AD 48      [10]  822     ld    hl, #suelo2
   5E5B CD 18 48      [17]  823     call  man_entity_create
                            824 
   5E5E C3 DA 66      [10]  825     jp    _no_load_level
                            826 
                            827 
   5E61                     828 _check_level_three:
   5E61 21 BC 48      [10]  829     ld      hl,#player
   5E64 CD 18 48      [17]  830     call man_entity_create
   5E67 21 42 4A      [10]  831     ld      hl,#portal30
   5E6A CD 18 48      [17]  832     call man_entity_create
   5E6D 21 51 4A      [10]  833     ld      hl,#platah31
   5E70 CD 18 48      [17]  834     call man_entity_create
   5E73 21 60 4A      [10]  835     ld      hl,#platah32
   5E76 CD 18 48      [17]  836     call man_entity_create
   5E79 21 6F 4A      [10]  837     ld      hl,#platah33
   5E7C CD 18 48      [17]  838     call man_entity_create
   5E7F 21 7E 4A      [10]  839     ld      hl,#platah34
   5E82 CD 18 48      [17]  840     call man_entity_create
   5E85 21 8D 4A      [10]  841     ld      hl,#platah35
   5E88 CD 18 48      [17]  842     call man_entity_create
   5E8B 21 9C 4A      [10]  843     ld      hl,#platah36
   5E8E CD 18 48      [17]  844     call man_entity_create
   5E91 21 AB 4A      [10]  845     ld      hl,#platah37
   5E94 CD 18 48      [17]  846     call man_entity_create
   5E97 21 BA 4A      [10]  847     ld      hl,#platah38
   5E9A CD 18 48      [17]  848     call man_entity_create
   5E9D 21 C9 4A      [10]  849     ld      hl,#tramp31
   5EA0 CD 18 48      [17]  850     call man_entity_create
   5EA3 21 D8 4A      [10]  851     ld      hl,#tramp32
   5EA6 CD 18 48      [17]  852     call man_entity_create
                            853 
   5EA9 21 9E 48      [10]  854     ld    hl, #suelo1
   5EAC CD 18 48      [17]  855     call man_entity_create
   5EAF 21 AD 48      [10]  856     ld    hl, #suelo2
   5EB2 CD 18 48      [17]  857     call  man_entity_create
                            858 
   5EB5 C3 DA 66      [10]  859     jp  _no_load_level
                            860 
                            861 
   5EB8                     862 _check_level_four:
   5EB8 21 BC 48      [10]  863     ld      hl,#player
   5EBB CD 18 48      [17]  864     call man_entity_create
   5EBE 21 E7 4A      [10]  865     ld      hl,#portal40
   5EC1 CD 18 48      [17]  866     call man_entity_create
   5EC4 21 F6 4A      [10]  867     ld      hl,#platah41
   5EC7 CD 18 48      [17]  868     call man_entity_create
   5ECA 21 05 4B      [10]  869     ld      hl,#platah42
   5ECD CD 18 48      [17]  870     call man_entity_create
   5ED0 21 14 4B      [10]  871     ld      hl,#platah43
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 135.
Hexadecimal [16-Bits]



   5ED3 CD 18 48      [17]  872     call man_entity_create
   5ED6 21 23 4B      [10]  873     ld      hl,#platah44
   5ED9 CD 18 48      [17]  874     call man_entity_create
   5EDC 21 32 4B      [10]  875     ld      hl,#platah45
   5EDF CD 18 48      [17]  876     call man_entity_create
   5EE2 21 41 4B      [10]  877     ld      hl,#platah46
   5EE5 CD 18 48      [17]  878     call man_entity_create
   5EE8 21 50 4B      [10]  879     ld      hl,#platah47
   5EEB CD 18 48      [17]  880     call man_entity_create
   5EEE 21 5F 4B      [10]  881     ld      hl,#platah48
   5EF1 CD 18 48      [17]  882     call man_entity_create
   5EF4 21 6E 4B      [10]  883     ld      hl,#platah49
   5EF7 CD 18 48      [17]  884     call man_entity_create
   5EFA 21 7D 4B      [10]  885     ld      hl,#tramp41
   5EFD CD 18 48      [17]  886     call man_entity_create
   5F00 21 8C 4B      [10]  887     ld      hl,#tramp42
   5F03 CD 18 48      [17]  888     call man_entity_create
   5F06 21 9B 4B      [10]  889     ld      hl,#tramp43
   5F09 CD 18 48      [17]  890     call man_entity_create
   5F0C 21 AA 4B      [10]  891     ld      hl,#tramp44
   5F0F CD 18 48      [17]  892     call man_entity_create
   5F12 21 B9 4B      [10]  893     ld      hl,#tramp45
   5F15 CD 18 48      [17]  894     call man_entity_create
                            895     
   5F18 21 9E 48      [10]  896     ld    hl, #suelo1
   5F1B CD 18 48      [17]  897     call man_entity_create
   5F1E 21 AD 48      [10]  898     ld    hl, #suelo2
   5F21 CD 18 48      [17]  899     call  man_entity_create
                            900 
   5F24 C3 DA 66      [10]  901     jp  _no_load_level
                            902 
   5F27                     903 _check_level_five:
                            904 
   5F27 21 BC 48      [10]  905     ld      hl,#player
   5F2A CD 18 48      [17]  906     call man_entity_create
   5F2D 21 C8 4B      [10]  907     ld      hl,#portal50
   5F30 CD 18 48      [17]  908     call man_entity_create
   5F33 21 D7 4B      [10]  909     ld      hl,#platah51
   5F36 CD 18 48      [17]  910     call man_entity_create
   5F39 21 E6 4B      [10]  911     ld      hl,#platah52
   5F3C CD 18 48      [17]  912     call man_entity_create
   5F3F 21 F5 4B      [10]  913     ld      hl,#platah53
   5F42 CD 18 48      [17]  914     call man_entity_create
   5F45 21 04 4C      [10]  915     ld      hl,#platah54
   5F48 CD 18 48      [17]  916     call man_entity_create
   5F4B 21 13 4C      [10]  917     ld      hl,#platah55
   5F4E CD 18 48      [17]  918     call man_entity_create
   5F51 21 22 4C      [10]  919     ld      hl,#platah56
   5F54 CD 18 48      [17]  920     call man_entity_create
   5F57 21 31 4C      [10]  921     ld      hl,#platah57
   5F5A CD 18 48      [17]  922     call man_entity_create
   5F5D 21 40 4C      [10]  923     ld      hl,#platav58
   5F60 CD 18 48      [17]  924     call man_entity_create
   5F63 21 4F 4C      [10]  925     ld      hl,#platav59
   5F66 CD 18 48      [17]  926     call man_entity_create
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 136.
Hexadecimal [16-Bits]



   5F69 21 5E 4C      [10]  927     ld      hl,#tramp51
   5F6C CD 18 48      [17]  928     call man_entity_create    
   5F6F 21 6D 4C      [10]  929     ld      hl,#tramp52
   5F72 CD 18 48      [17]  930     call man_entity_create    
   5F75 21 7C 4C      [10]  931     ld      hl,#tramp53
   5F78 CD 18 48      [17]  932     call man_entity_create    
   5F7B 21 8B 4C      [10]  933     ld      hl,#tramp54
   5F7E CD 18 48      [17]  934     call man_entity_create    
   5F81 21 9A 4C      [10]  935     ld      hl,#tramp55
   5F84 CD 18 48      [17]  936     call man_entity_create
                            937 
   5F87 21 9E 48      [10]  938     ld    hl, #suelo1
   5F8A CD 18 48      [17]  939     call man_entity_create
   5F8D 21 AD 48      [10]  940     ld    hl, #suelo2
   5F90 CD 18 48      [17]  941     call  man_entity_create
                            942 
   5F93 C3 DA 66      [10]  943     jp  _no_load_level
                            944 
   5F96                     945 _check_level_six:
                            946 
   5F96 21 BC 48      [10]  947     ld      hl,#player
   5F99 CD 18 48      [17]  948     call man_entity_create
   5F9C 21 A9 4C      [10]  949     ld      hl,#portal60
   5F9F CD 18 48      [17]  950     call man_entity_create
   5FA2 21 B8 4C      [10]  951     ld      hl,#platah61
   5FA5 CD 18 48      [17]  952     call man_entity_create
   5FA8 21 C7 4C      [10]  953     ld      hl,#platah62
   5FAB CD 18 48      [17]  954     call man_entity_create
   5FAE 21 D6 4C      [10]  955     ld      hl,#platah63
   5FB1 CD 18 48      [17]  956     call man_entity_create
   5FB4 21 E5 4C      [10]  957     ld      hl,#platah64
   5FB7 CD 18 48      [17]  958     call man_entity_create
   5FBA 21 F4 4C      [10]  959     ld      hl,#platah65
   5FBD CD 18 48      [17]  960     call man_entity_create
   5FC0 21 03 4D      [10]  961     ld      hl,#platah66
   5FC3 CD 18 48      [17]  962     call man_entity_create
   5FC6 21 12 4D      [10]  963     ld      hl,#platah67
   5FC9 CD 18 48      [17]  964     call man_entity_create
   5FCC 21 21 4D      [10]  965     ld      hl,#platah68
   5FCF CD 18 48      [17]  966     call man_entity_create
   5FD2 21 30 4D      [10]  967     ld      hl,#tramp61
   5FD5 CD 18 48      [17]  968     call man_entity_create
   5FD8 21 3F 4D      [10]  969     ld      hl,#tramp62
   5FDB CD 18 48      [17]  970     call man_entity_create
   5FDE 21 4E 4D      [10]  971     ld      hl,#tramp63
   5FE1 CD 18 48      [17]  972     call man_entity_create
   5FE4 21 5D 4D      [10]  973     ld      hl,#tramp64
   5FE7 CD 18 48      [17]  974     call man_entity_create
   5FEA 21 6C 4D      [10]  975     ld      hl,#tramp65
   5FED CD 18 48      [17]  976     call man_entity_create
   5FF0 21 7B 4D      [10]  977     ld      hl,#tramp66
   5FF3 CD 18 48      [17]  978     call man_entity_create
   5FF6 21 8A 4D      [10]  979     ld      hl,#tramp67
   5FF9 CD 18 48      [17]  980     call man_entity_create
   5FFC 21 99 4D      [10]  981     ld      hl,#tramp68
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 137.
Hexadecimal [16-Bits]



   5FFF CD 18 48      [17]  982     call man_entity_create
   6002 21 A8 4D      [10]  983     ld      hl,#tramp69
   6005 CD 18 48      [17]  984     call man_entity_create
                            985 
   6008 21 9E 48      [10]  986     ld    hl, #suelo1
   600B CD 18 48      [17]  987     call man_entity_create
   600E 21 AD 48      [10]  988     ld    hl, #suelo2
   6011 CD 18 48      [17]  989     call  man_entity_create
   6014 C3 DA 66      [10]  990     jp  _no_load_level
                            991 
   6017                     992 _check_level_seven:
   6017 21 BC 48      [10]  993     ld      hl,#player
   601A CD 18 48      [17]  994     call man_entity_create
   601D 21 B7 4D      [10]  995     ld      hl,#portal70
   6020 CD 18 48      [17]  996     call man_entity_create
   6023 21 C6 4D      [10]  997     ld      hl,#platah71
   6026 CD 18 48      [17]  998     call man_entity_create
   6029 21 D5 4D      [10]  999     ld      hl,#platah72
   602C CD 18 48      [17] 1000     call man_entity_create
   602F 21 E4 4D      [10] 1001     ld      hl,#platah73
   6032 CD 18 48      [17] 1002     call man_entity_create
   6035 21 F3 4D      [10] 1003     ld      hl,#platah74
   6038 CD 18 48      [17] 1004     call man_entity_create
   603B 21 02 4E      [10] 1005     ld      hl,#platah75
   603E CD 18 48      [17] 1006     call man_entity_create
   6041 21 11 4E      [10] 1007     ld      hl,#platah76
   6044 CD 18 48      [17] 1008     call man_entity_create
   6047 21 20 4E      [10] 1009     ld      hl,#platah77
   604A CD 18 48      [17] 1010     call man_entity_create
   604D 21 2F 4E      [10] 1011     ld      hl,#platah78
   6050 CD 18 48      [17] 1012     call man_entity_create
   6053 21 3E 4E      [10] 1013     ld      hl,#platah79
   6056 CD 18 48      [17] 1014     call man_entity_create
   6059 21 4D 4E      [10] 1015     ld      hl,#platah710
   605C CD 18 48      [17] 1016     call man_entity_create
   605F 21 5C 4E      [10] 1017     ld      hl,#platah711
   6062 CD 18 48      [17] 1018     call man_entity_create
   6065 21 6B 4E      [10] 1019     ld      hl,#platah712
   6068 CD 18 48      [17] 1020     call man_entity_create
   606B 21 7A 4E      [10] 1021     ld      hl,#platah713
   606E CD 18 48      [17] 1022     call man_entity_create
   6071 21 89 4E      [10] 1023     ld      hl,#platah714
   6074 CD 18 48      [17] 1024     call man_entity_create
   6077 21 98 4E      [10] 1025     ld      hl,#tramp71
   607A CD 18 48      [17] 1026     call man_entity_create
   607D 21 A7 4E      [10] 1027     ld      hl,#tramp72
   6080 CD 18 48      [17] 1028     call man_entity_create
   6083 21 B6 4E      [10] 1029     ld      hl,#tramp73
   6086 CD 18 48      [17] 1030     call man_entity_create
   6089 21 C5 4E      [10] 1031     ld      hl,#enemyh71
   608C CD 18 48      [17] 1032     call man_entity_create
                           1033 
   608F 21 9E 48      [10] 1034     ld    hl, #suelo1
   6092 CD 18 48      [17] 1035     call man_entity_create
   6095 21 AD 48      [10] 1036     ld    hl, #suelo2
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 138.
Hexadecimal [16-Bits]



   6098 CD 18 48      [17] 1037     call  man_entity_create
                           1038 
   609B C3 DA 66      [10] 1039     jp  _no_load_level
                           1040 
   609E                    1041 _check_level_eight:
   609E 21 BC 48      [10] 1042     ld      hl,#player
   60A1 CD 18 48      [17] 1043     call man_entity_create
   60A4 21 D4 4E      [10] 1044     ld      hl,#portal80
   60A7 CD 18 48      [17] 1045     call man_entity_create
   60AA 21 E3 4E      [10] 1046     ld      hl,#platah81
   60AD CD 18 48      [17] 1047     call man_entity_create
   60B0 21 F2 4E      [10] 1048     ld      hl,#platah82
   60B3 CD 18 48      [17] 1049     call man_entity_create
   60B6 21 01 4F      [10] 1050     ld      hl,#platah83
   60B9 CD 18 48      [17] 1051     call man_entity_create
   60BC 21 10 4F      [10] 1052     ld      hl,#platah84
   60BF CD 18 48      [17] 1053     call man_entity_create
   60C2 21 1F 4F      [10] 1054     ld      hl,#platah85
   60C5 CD 18 48      [17] 1055     call man_entity_create
   60C8 21 2E 4F      [10] 1056     ld      hl,#platah86
   60CB CD 18 48      [17] 1057     call man_entity_create
                           1058 
   60CE 21 3D 4F      [10] 1059     ld      hl,#platah87
   60D1 CD 18 48      [17] 1060     call man_entity_create
   60D4 21 4C 4F      [10] 1061     ld      hl,#platah88
   60D7 CD 18 48      [17] 1062     call man_entity_create
   60DA 21 5B 4F      [10] 1063     ld      hl,#platah89
   60DD CD 18 48      [17] 1064     call man_entity_create
   60E0 21 6A 4F      [10] 1065     ld      hl,#platah810
   60E3 CD 18 48      [17] 1066     call man_entity_create
   60E6 21 79 4F      [10] 1067     ld      hl,#platah811
   60E9 CD 18 48      [17] 1068     call man_entity_create
   60EC 21 88 4F      [10] 1069     ld      hl,#platah812
   60EF CD 18 48      [17] 1070     call man_entity_create
                           1071 
   60F2 21 97 4F      [10] 1072     ld      hl,#platav81
   60F5 CD 18 48      [17] 1073     call man_entity_create
   60F8 21 A6 4F      [10] 1074     ld      hl,#platav82
   60FB CD 18 48      [17] 1075     call man_entity_create
   60FE 21 B5 4F      [10] 1076     ld      hl,#enemy81
   6101 CD 18 48      [17] 1077     call man_entity_create
   6104 21 C4 4F      [10] 1078     ld      hl,#tramp80
   6107 CD 18 48      [17] 1079     call man_entity_create
   610A 21 D3 4F      [10] 1080     ld      hl,#tramp81
   610D CD 18 48      [17] 1081     call man_entity_create
                           1082 
   6110 21 9E 48      [10] 1083     ld    hl, #suelo1
   6113 CD 18 48      [17] 1084     call man_entity_create
   6116 21 AD 48      [10] 1085     ld    hl, #suelo2
   6119 CD 18 48      [17] 1086     call  man_entity_create
                           1087 
   611C C3 DA 66      [10] 1088     jp  _no_load_level
                           1089 
   611F                    1090 _check_level_nine:
   611F 21 BC 48      [10] 1091     ld      hl,#player
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 139.
Hexadecimal [16-Bits]



   6122 CD 18 48      [17] 1092     call man_entity_create
   6125 21 E2 4F      [10] 1093     ld      hl,#portal90
   6128 CD 18 48      [17] 1094     call man_entity_create
   612B 21 F1 4F      [10] 1095     ld      hl,#platah91
   612E CD 18 48      [17] 1096     call man_entity_create
   6131 21 00 50      [10] 1097     ld      hl,#platah92
   6134 CD 18 48      [17] 1098     call man_entity_create
   6137 21 0F 50      [10] 1099     ld      hl,#platah93
   613A CD 18 48      [17] 1100     call man_entity_create
   613D 21 1E 50      [10] 1101     ld      hl,#platah94
   6140 CD 18 48      [17] 1102     call man_entity_create
   6143 21 2D 50      [10] 1103     ld      hl,#platah95
   6146 CD 18 48      [17] 1104     call man_entity_create
   6149 21 3C 50      [10] 1105     ld      hl,#platah96
   614C CD 18 48      [17] 1106     call man_entity_create
   614F 21 4B 50      [10] 1107     ld      hl,#platah97
   6152 CD 18 48      [17] 1108     call man_entity_create
   6155 21 5A 50      [10] 1109     ld      hl,#platah98
   6158 CD 18 48      [17] 1110     call man_entity_create
   615B 21 69 50      [10] 1111     ld      hl,#platah99
   615E CD 18 48      [17] 1112     call man_entity_create
   6161 21 78 50      [10] 1113     ld      hl,#platah910
   6164 CD 18 48      [17] 1114     call man_entity_create
   6167 21 87 50      [10] 1115     ld      hl,#platah911
   616A CD 18 48      [17] 1116     call man_entity_create
   616D 21 96 50      [10] 1117     ld      hl,#platah912
   6170 CD 18 48      [17] 1118     call man_entity_create
                           1119 
   6173 21 A5 50      [10] 1120     ld      hl,#tramp91
   6176 CD 18 48      [17] 1121     call man_entity_create
   6179 21 B4 50      [10] 1122     ld      hl,#tramp92
   617C CD 18 48      [17] 1123     call man_entity_create
   617F 21 C3 50      [10] 1124     ld      hl,#tramp93
   6182 CD 18 48      [17] 1125     call man_entity_create
                           1126 
   6185 21 D2 50      [10] 1127     ld      hl,#enemy91
   6188 CD 18 48      [17] 1128     call man_entity_create
   618B 21 E1 50      [10] 1129     ld      hl,#enemy92
   618E CD 18 48      [17] 1130     call man_entity_create
                           1131 
   6191 21 9E 48      [10] 1132     ld    hl, #suelo1
   6194 CD 18 48      [17] 1133     call man_entity_create
   6197 21 AD 48      [10] 1134     ld    hl, #suelo2
   619A CD 18 48      [17] 1135     call  man_entity_create
                           1136 
   619D C3 DA 66      [10] 1137     jp _no_load_level
                           1138 
   61A0                    1139 _check_level_ten:
   61A0 21 BC 48      [10] 1140     ld      hl,#player
   61A3 CD 18 48      [17] 1141     call man_entity_create
   61A6 21 F0 50      [10] 1142     ld      hl,#portal100
   61A9 CD 18 48      [17] 1143     call man_entity_create
   61AC 21 FF 50      [10] 1144     ld      hl,#platah101
   61AF CD 18 48      [17] 1145     call man_entity_create
   61B2 21 0E 51      [10] 1146     ld      hl,#platah102
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 140.
Hexadecimal [16-Bits]



   61B5 CD 18 48      [17] 1147     call man_entity_create
   61B8 21 1D 51      [10] 1148     ld      hl,#platah103
   61BB CD 18 48      [17] 1149     call man_entity_create
   61BE 21 2C 51      [10] 1150     ld      hl,#platah104
   61C1 CD 18 48      [17] 1151     call man_entity_create
   61C4 21 3B 51      [10] 1152     ld      hl,#platah105
   61C7 CD 18 48      [17] 1153     call man_entity_create
   61CA 21 4A 51      [10] 1154     ld      hl,#platah106
   61CD CD 18 48      [17] 1155     call man_entity_create
   61D0 21 59 51      [10] 1156     ld      hl,#platah107
   61D3 CD 18 48      [17] 1157     call man_entity_create
   61D6 21 68 51      [10] 1158     ld      hl,#platah108
   61D9 CD 18 48      [17] 1159     call man_entity_create
                           1160 
   61DC 21 77 51      [10] 1161     ld      hl,#enemy101
   61DF CD 18 48      [17] 1162     call man_entity_create
   61E2 21 86 51      [10] 1163     ld      hl,#enemy102
   61E5 CD 18 48      [17] 1164     call man_entity_create
                           1165 
   61E8 21 95 51      [10] 1166     ld      hl,#tramp101
   61EB CD 18 48      [17] 1167     call man_entity_create
   61EE 21 A4 51      [10] 1168     ld      hl,#tramp102
   61F1 CD 18 48      [17] 1169     call man_entity_create
   61F4 21 B3 51      [10] 1170     ld      hl,#tramp103
   61F7 CD 18 48      [17] 1171     call man_entity_create
                           1172 
   61FA 21 9E 48      [10] 1173     ld    hl, #suelo1
   61FD CD 18 48      [17] 1174     call man_entity_create
   6200 21 AD 48      [10] 1175     ld    hl, #suelo2
   6203 CD 18 48      [17] 1176     call  man_entity_create
                           1177 
   6206 C3 DA 66      [10] 1178     jp _no_load_level
                           1179 
   6209                    1180 _check_level_eleven:
                           1181 
   6209 21 BC 48      [10] 1182     ld      hl,#player
   620C CD 18 48      [17] 1183     call man_entity_create
   620F 21 C2 51      [10] 1184     ld      hl,#portal110
   6212 CD 18 48      [17] 1185     call man_entity_create
                           1186 
   6215 21 D1 51      [10] 1187     ld      hl,#platah111
   6218 CD 18 48      [17] 1188     call man_entity_create
   621B 21 E0 51      [10] 1189     ld      hl,#platah112
   621E CD 18 48      [17] 1190     call man_entity_create
   6221 21 EF 51      [10] 1191     ld      hl,#platah113
   6224 CD 18 48      [17] 1192     call man_entity_create
   6227 21 FE 51      [10] 1193     ld      hl,#platah114
   622A CD 18 48      [17] 1194     call man_entity_create
   622D 21 0D 52      [10] 1195     ld      hl,#platah115
   6230 CD 18 48      [17] 1196     call man_entity_create
   6233 21 1C 52      [10] 1197     ld      hl,#platah116
   6236 CD 18 48      [17] 1198     call man_entity_create
   6239 21 2B 52      [10] 1199     ld      hl,#platah117
   623C CD 18 48      [17] 1200     call man_entity_create
   623F 21 3A 52      [10] 1201     ld      hl,#platah118
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 141.
Hexadecimal [16-Bits]



   6242 CD 18 48      [17] 1202     call man_entity_create
   6245 21 49 52      [10] 1203     ld      hl,#platah119
   6248 CD 18 48      [17] 1204     call man_entity_create
   624B 21 58 52      [10] 1205     ld      hl,#platah1110
   624E CD 18 48      [17] 1206     call man_entity_create
   6251 21 67 52      [10] 1207     ld      hl,#platah1111
   6254 CD 18 48      [17] 1208     call man_entity_create
   6257 21 76 52      [10] 1209     ld      hl,#platah1112
   625A CD 18 48      [17] 1210     call man_entity_create
   625D 21 85 52      [10] 1211     ld      hl,#platah1113
   6260 CD 18 48      [17] 1212     call man_entity_create
   6263 21 94 52      [10] 1213     ld      hl,#platah1114
   6266 CD 18 48      [17] 1214     call man_entity_create
   6269 21 A3 52      [10] 1215     ld      hl,#platah1115
   626C CD 18 48      [17] 1216     call man_entity_create
   626F 21 B2 52      [10] 1217     ld      hl,#platah1116
   6272 CD 18 48      [17] 1218     call man_entity_create
                           1219 
   6275 21 C1 52      [10] 1220     ld      hl,#tramp111
   6278 CD 18 48      [17] 1221     call man_entity_create
   627B 21 D0 52      [10] 1222     ld      hl,#tramp112
   627E CD 18 48      [17] 1223     call man_entity_create
   6281 21 DF 52      [10] 1224     ld      hl,#tramp113
   6284 CD 18 48      [17] 1225     call man_entity_create
                           1226 
   6287 21 EE 52      [10] 1227     ld      hl,#enemy111
   628A CD 18 48      [17] 1228     call man_entity_create
                           1229 
   628D 21 9E 48      [10] 1230     ld    hl, #suelo1
   6290 CD 18 48      [17] 1231     call  man_entity_create
   6293 21 AD 48      [10] 1232     ld    hl, #suelo2
   6296 CD 18 48      [17] 1233     call  man_entity_create
                           1234 
   6299 C3 DA 66      [10] 1235     jp  _no_load_level
                           1236 
   629C                    1237 _check_level_twelve:
                           1238 
   629C 21 BC 48      [10] 1239     ld      hl,#player
   629F CD 18 48      [17] 1240     call man_entity_create
   62A2 21 FD 52      [10] 1241     ld      hl,#portal120
   62A5 CD 18 48      [17] 1242     call man_entity_create
                           1243 
   62A8 21 0C 53      [10] 1244     ld      hl,#platah121
   62AB CD 18 48      [17] 1245     call man_entity_create
   62AE 21 1B 53      [10] 1246     ld      hl,#platah122
   62B1 CD 18 48      [17] 1247     call man_entity_create
   62B4 21 2A 53      [10] 1248     ld      hl,#platah123
   62B7 CD 18 48      [17] 1249     call man_entity_create
   62BA 21 39 53      [10] 1250     ld      hl,#platah124
   62BD CD 18 48      [17] 1251     call man_entity_create
   62C0 21 48 53      [10] 1252     ld      hl,#platav125
   62C3 CD 18 48      [17] 1253     call man_entity_create
   62C6 21 57 53      [10] 1254     ld      hl,#platav126
   62C9 CD 18 48      [17] 1255     call man_entity_create
   62CC 21 66 53      [10] 1256     ld      hl,#platah127
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 142.
Hexadecimal [16-Bits]



   62CF CD 18 48      [17] 1257     call man_entity_create
   62D2 21 75 53      [10] 1258     ld      hl,#platah128
   62D5 CD 18 48      [17] 1259     call man_entity_create
   62D8 21 84 53      [10] 1260     ld      hl,#platah129
   62DB CD 18 48      [17] 1261     call man_entity_create
   62DE 21 93 53      [10] 1262     ld      hl,#platah1210
   62E1 CD 18 48      [17] 1263     call man_entity_create
   62E4 21 A2 53      [10] 1264     ld      hl,#platah1211
   62E7 CD 18 48      [17] 1265     call man_entity_create
   62EA 21 B1 53      [10] 1266     ld      hl,#platah1212
   62ED CD 18 48      [17] 1267     call man_entity_create
   62F0 21 C0 53      [10] 1268     ld      hl,#platah1213
   62F3 CD 18 48      [17] 1269     call man_entity_create
   62F6 21 CF 53      [10] 1270     ld      hl,#platah1214
   62F9 CD 18 48      [17] 1271     call man_entity_create
   62FC 21 DE 53      [10] 1272     ld      hl,#platah1215
   62FF CD 18 48      [17] 1273     call man_entity_create
   6302 21 ED 53      [10] 1274     ld      hl,#platah1216
   6305 CD 18 48      [17] 1275     call man_entity_create
   6308 21 FC 53      [10] 1276     ld      hl,#platah1217
   630B CD 18 48      [17] 1277     call man_entity_create
   630E 21 0B 54      [10] 1278     ld      hl,#platah1218
   6311 CD 18 48      [17] 1279     call man_entity_create
                           1280 
                           1281 
   6314 21 1A 54      [10] 1282     ld      hl,#tramp121
   6317 CD 18 48      [17] 1283     call man_entity_create
   631A 21 29 54      [10] 1284     ld      hl,#tramp122
   631D CD 18 48      [17] 1285     call man_entity_create
   6320 21 38 54      [10] 1286     ld      hl,#tramp123
   6323 CD 18 48      [17] 1287     call man_entity_create
   6326 21 47 54      [10] 1288     ld      hl,#tramp124
   6329 CD 18 48      [17] 1289     call man_entity_create
   632C 21 56 54      [10] 1290     ld      hl,#tramp125
   632F CD 18 48      [17] 1291     call man_entity_create
   6332 21 65 54      [10] 1292     ld      hl,#tramp126
   6335 CD 18 48      [17] 1293     call man_entity_create
                           1294 
   6338 21 74 54      [10] 1295     ld      hl,#enemy121
   633B CD 18 48      [17] 1296     call man_entity_create
                           1297 
   633E 21 9E 48      [10] 1298     ld    hl, #suelo1
   6341 CD 18 48      [17] 1299     call  man_entity_create
   6344 21 AD 48      [10] 1300     ld    hl, #suelo2
   6347 CD 18 48      [17] 1301     call  man_entity_create
                           1302 
   634A C3 DA 66      [10] 1303     jp      _no_load_level
                           1304 
   634D                    1305 _check_level_thirteen:
                           1306 
   634D 21 BC 48      [10] 1307     ld      hl,#player
   6350 CD 18 48      [17] 1308     call man_entity_create
   6353 21 83 54      [10] 1309     ld      hl,#portal130
   6356 CD 18 48      [17] 1310     call man_entity_create
                           1311 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 143.
Hexadecimal [16-Bits]



   6359 21 92 54      [10] 1312     ld      hl,#platah131
   635C CD 18 48      [17] 1313     call man_entity_create
   635F 21 A1 54      [10] 1314     ld      hl,#platah132
   6362 CD 18 48      [17] 1315     call man_entity_create
   6365 21 B0 54      [10] 1316     ld      hl,#platah133
   6368 CD 18 48      [17] 1317     call man_entity_create
   636B 21 BF 54      [10] 1318     ld      hl,#platah134
   636E CD 18 48      [17] 1319     call man_entity_create
   6371 21 CE 54      [10] 1320     ld      hl,#platah135
   6374 CD 18 48      [17] 1321     call man_entity_create
   6377 21 DD 54      [10] 1322     ld      hl,#platah136
   637A CD 18 48      [17] 1323     call man_entity_create
   637D 21 EC 54      [10] 1324     ld      hl,#platah137
   6380 CD 18 48      [17] 1325     call man_entity_create
   6383 21 FB 54      [10] 1326     ld      hl,#platah138
   6386 CD 18 48      [17] 1327     call man_entity_create
   6389 21 0A 55      [10] 1328     ld      hl,#platah139
   638C CD 18 48      [17] 1329     call man_entity_create
   638F 21 19 55      [10] 1330     ld      hl,#platah1310
   6392 CD 18 48      [17] 1331     call man_entity_create
   6395 21 28 55      [10] 1332     ld      hl,#platah1311
   6398 CD 18 48      [17] 1333     call man_entity_create
   639B 21 37 55      [10] 1334     ld      hl,#platah1312
   639E CD 18 48      [17] 1335     call man_entity_create
   63A1 21 46 55      [10] 1336     ld      hl,#platah1313
   63A4 CD 18 48      [17] 1337     call man_entity_create
   63A7 21 55 55      [10] 1338     ld      hl,#platah1314
   63AA CD 18 48      [17] 1339     call man_entity_create
                           1340 
                           1341 
   63AD 21 64 55      [10] 1342     ld      hl,#tramp131
   63B0 CD 18 48      [17] 1343     call man_entity_create
   63B3 21 73 55      [10] 1344     ld      hl,#tramp132
   63B6 CD 18 48      [17] 1345     call man_entity_create
                           1346 
   63B9 21 82 55      [10] 1347     ld      hl,#enemy131
   63BC CD 18 48      [17] 1348     call man_entity_create
                           1349 
   63BF 21 9E 48      [10] 1350     ld    hl, #suelo1
   63C2 CD 18 48      [17] 1351     call  man_entity_create
   63C5 21 AD 48      [10] 1352     ld    hl, #suelo2
   63C8 CD 18 48      [17] 1353     call  man_entity_create
                           1354 
   63CB C3 DA 66      [10] 1355     jp      _no_load_level
                           1356 
   63CE                    1357 _check_level_fourteen:
   63CE 21 91 55      [10] 1358     ld      hl, #player140
   63D1 CD 18 48      [17] 1359     call man_entity_create
   63D4 21 A0 55      [10] 1360     ld      hl, #portal140
   63D7 CD 18 48      [17] 1361     call man_entity_create
   63DA 21 AF 55      [10] 1362     ld      hl, #platah141
   63DD CD 18 48      [17] 1363     call man_entity_create
   63E0 21 BE 55      [10] 1364     ld      hl, #platah142
   63E3 CD 18 48      [17] 1365     call man_entity_create
   63E6 21 CD 55      [10] 1366     ld      hl, #platah143
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 144.
Hexadecimal [16-Bits]



   63E9 CD 18 48      [17] 1367     call man_entity_create
   63EC 21 DC 55      [10] 1368     ld      hl, #platah144
   63EF CD 18 48      [17] 1369     call man_entity_create
   63F2 21 EB 55      [10] 1370     ld      hl, #platah145
   63F5 CD 18 48      [17] 1371     call man_entity_create
   63F8 21 FA 55      [10] 1372     ld      hl, #platah146
   63FB CD 18 48      [17] 1373     call man_entity_create
   63FE 21 09 56      [10] 1374     ld      hl, #platah147
   6401 CD 18 48      [17] 1375     call man_entity_create
   6404 21 18 56      [10] 1376     ld      hl, #platah148
   6407 CD 18 48      [17] 1377     call man_entity_create
   640A 21 27 56      [10] 1378     ld      hl, #platah149
   640D CD 18 48      [17] 1379     call man_entity_create
   6410 21 36 56      [10] 1380     ld      hl, #platah1410
   6413 CD 18 48      [17] 1381     call man_entity_create
   6416 21 45 56      [10] 1382     ld      hl, #platah1411
   6419 CD 18 48      [17] 1383     call man_entity_create
   641C 21 54 56      [10] 1384     ld      hl, #platah1412
   641F CD 18 48      [17] 1385     call man_entity_create
   6422 21 63 56      [10] 1386     ld      hl, #platah1413
   6425 CD 18 48      [17] 1387     call man_entity_create
   6428 21 72 56      [10] 1388     ld      hl, #platah1414
   642B CD 18 48      [17] 1389     call man_entity_create
   642E 21 81 56      [10] 1390     ld      hl, #platah1415
   6431 CD 18 48      [17] 1391     call man_entity_create
                           1392 
   6434 21 90 56      [10] 1393     ld      hl, #tramp141
   6437 CD 18 48      [17] 1394     call man_entity_create
   643A 21 9F 56      [10] 1395     ld      hl, #tramp142
   643D CD 18 48      [17] 1396     call man_entity_create
   6440 21 AE 56      [10] 1397     ld      hl, #tramp143
   6443 CD 18 48      [17] 1398     call man_entity_create
   6446 21 BD 56      [10] 1399     ld      hl, #tramp144
   6449 CD 18 48      [17] 1400     call man_entity_create
   644C 21 CC 56      [10] 1401     ld      hl, #tramp145
   644F CD 18 48      [17] 1402     call man_entity_create
                           1403 
   6452 21 DB 56      [10] 1404     ld      hl, #enemy141
   6455 CD 18 48      [17] 1405     call man_entity_create
   6458 21 EA 56      [10] 1406     ld      hl, #enemy142
   645B CD 18 48      [17] 1407     call man_entity_create
                           1408 
   645E 21 9E 48      [10] 1409     ld    hl, #suelo1
   6461 CD 18 48      [17] 1410     call  man_entity_create
   6464 21 AD 48      [10] 1411     ld    hl, #suelo2
   6467 CD 18 48      [17] 1412     call  man_entity_create
                           1413 
   646A C3 DA 66      [10] 1414     jp      _no_load_level
                           1415 
   646D                    1416 _check_level_sixteen:
                           1417 
   646D 21 F9 56      [10] 1418     ld      hl,#player16
   6470 CD 18 48      [17] 1419     call man_entity_create
   6473 21 08 57      [10] 1420     ld      hl,#portal160
   6476 CD 18 48      [17] 1421     call man_entity_create
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 145.
Hexadecimal [16-Bits]



   6479 21 17 57      [10] 1422     ld      hl,#tierra16
   647C CD 18 48      [17] 1423     call man_entity_create
                           1424 
   647F 21 26 57      [10] 1425     ld      hl,#platah161
   6482 CD 18 48      [17] 1426     call man_entity_create
   6485 21 35 57      [10] 1427     ld      hl,#platah162
   6488 CD 18 48      [17] 1428     call man_entity_create
   648B 21 44 57      [10] 1429     ld      hl,#platah163
   648E CD 18 48      [17] 1430     call man_entity_create
   6491 21 53 57      [10] 1431     ld      hl,#platah164
   6494 CD 18 48      [17] 1432     call man_entity_create
   6497 21 62 57      [10] 1433     ld      hl,#platah165
   649A CD 18 48      [17] 1434     call man_entity_create
   649D 21 71 57      [10] 1435     ld      hl,#platah166
   64A0 CD 18 48      [17] 1436     call man_entity_create
   64A3 21 80 57      [10] 1437     ld      hl,#platah167
   64A6 CD 18 48      [17] 1438     call man_entity_create
   64A9 21 8F 57      [10] 1439     ld      hl,#platah168
   64AC CD 18 48      [17] 1440     call man_entity_create
   64AF 21 9E 57      [10] 1441     ld      hl,#platah169
   64B2 CD 18 48      [17] 1442     call man_entity_create
   64B5 21 AD 57      [10] 1443     ld      hl,#platah1610
   64B8 CD 18 48      [17] 1444     call man_entity_create
   64BB 21 BC 57      [10] 1445     ld      hl,#platah1611
   64BE CD 18 48      [17] 1446     call man_entity_create
   64C1 21 CB 57      [10] 1447     ld      hl,#platah1612
   64C4 CD 18 48      [17] 1448     call man_entity_create
   64C7 21 DA 57      [10] 1449     ld      hl,#platah1613
   64CA CD 18 48      [17] 1450     call man_entity_create
   64CD 21 E9 57      [10] 1451     ld      hl,#platah1614
   64D0 CD 18 48      [17] 1452     call man_entity_create
                           1453 
   64D3 21 F8 57      [10] 1454     ld      hl,#tramp161
   64D6 CD 18 48      [17] 1455     call man_entity_create
   64D9 21 07 58      [10] 1456     ld      hl,#tramp162
   64DC CD 18 48      [17] 1457     call man_entity_create
   64DF 21 16 58      [10] 1458     ld      hl,#tramp163
   64E2 CD 18 48      [17] 1459     call man_entity_create
   64E5 21 25 58      [10] 1460     ld      hl,#tramp165
   64E8 CD 18 48      [17] 1461     call man_entity_create
   64EB 21 34 58      [10] 1462     ld      hl,#tramp166
   64EE CD 18 48      [17] 1463     call man_entity_create
   64F1 21 43 58      [10] 1464     ld      hl,#tramp167
   64F4 CD 18 48      [17] 1465     call man_entity_create
   64F7 21 52 58      [10] 1466     ld      hl,#tramp168
   64FA CD 18 48      [17] 1467     call man_entity_create
   64FD 21 61 58      [10] 1468     ld      hl,#tramp169
   6500 CD 18 48      [17] 1469     call man_entity_create
   6503 21 70 58      [10] 1470     ld      hl,#tramp1610
   6506 CD 18 48      [17] 1471     call man_entity_create
   6509 21 7F 58      [10] 1472     ld      hl,#tramp1611
   650C CD 18 48      [17] 1473     call man_entity_create
   650F 21 8E 58      [10] 1474     ld      hl,#tramp1612
   6512 CD 18 48      [17] 1475     call man_entity_create
                           1476 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 146.
Hexadecimal [16-Bits]



                           1477 
   6515 21 9D 58      [10] 1478     ld      hl,#enemy161
   6518 CD 18 48      [17] 1479     call man_entity_create
   651B 21 AC 58      [10] 1480     ld      hl,#enemy162
   651E CD 18 48      [17] 1481     call man_entity_create
                           1482 
   6521 21 9E 48      [10] 1483     ld    hl, #suelo1
   6524 CD 18 48      [17] 1484     call  man_entity_create
   6527 21 AD 48      [10] 1485     ld    hl, #suelo2
   652A CD 18 48      [17] 1486     call  man_entity_create
                           1487 
   652D C3 DA 66      [10] 1488     jp      _no_load_level
                           1489 
   6530                    1490 _check_level_seventeen:
                           1491 
   6530 21 BB 58      [10] 1492     ld      hl,#player17
   6533 CD 18 48      [17] 1493     call man_entity_create
   6536 21 CA 58      [10] 1494     ld      hl,#portal170
   6539 CD 18 48      [17] 1495     call man_entity_create
                           1496 
   653C 21 D9 58      [10] 1497     ld      hl,#platav171
   653F CD 18 48      [17] 1498     call man_entity_create
   6542 21 E8 58      [10] 1499     ld      hl,#platah172
   6545 CD 18 48      [17] 1500     call man_entity_create
   6548 21 F7 58      [10] 1501     ld      hl,#platah173
   654B CD 18 48      [17] 1502     call man_entity_create
   654E 21 06 59      [10] 1503     ld      hl,#platah174
   6551 CD 18 48      [17] 1504     call man_entity_create
   6554 21 15 59      [10] 1505     ld      hl,#platah175
   6557 CD 18 48      [17] 1506     call man_entity_create
   655A 21 24 59      [10] 1507     ld      hl,#platah176
   655D CD 18 48      [17] 1508     call man_entity_create
   6560 21 33 59      [10] 1509     ld      hl,#platah177
   6563 CD 18 48      [17] 1510     call man_entity_create
   6566 21 42 59      [10] 1511     ld      hl,#platah178
   6569 CD 18 48      [17] 1512     call man_entity_create
   656C 21 51 59      [10] 1513     ld      hl,#platah179
   656F CD 18 48      [17] 1514     call man_entity_create
   6572 21 6F 59      [10] 1515     ld      hl,#platah1710
   6575 CD 18 48      [17] 1516     call man_entity_create
   6578 21 7E 59      [10] 1517     ld      hl,#platah1711
   657B CD 18 48      [17] 1518     call man_entity_create
   657E 21 8D 59      [10] 1519     ld      hl,#platah1712
   6581 CD 18 48      [17] 1520     call man_entity_create
   6584 21 9C 59      [10] 1521     ld      hl,#platah1713
   6587 CD 18 48      [17] 1522     call man_entity_create
   658A 21 AB 59      [10] 1523     ld      hl,#platah1714
   658D CD 18 48      [17] 1524     call man_entity_create
   6590 21 BA 59      [10] 1525     ld      hl,#platah1715
   6593 CD 18 48      [17] 1526     call man_entity_create
   6596 21 60 59      [10] 1527     ld      hl,#platah1716
   6599 CD 18 48      [17] 1528     call man_entity_create
                           1529 
   659C 21 C9 59      [10] 1530     ld      hl,#tramp171
   659F CD 18 48      [17] 1531     call man_entity_create
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 147.
Hexadecimal [16-Bits]



   65A2 21 D8 59      [10] 1532     ld      hl,#tramp172
   65A5 CD 18 48      [17] 1533     call man_entity_create
   65A8 21 E7 59      [10] 1534     ld      hl,#tramp173
   65AB CD 18 48      [17] 1535     call man_entity_create
   65AE 21 F6 59      [10] 1536     ld      hl,#tramp174
   65B1 CD 18 48      [17] 1537     call man_entity_create
                           1538     ;ld      hl,#tramp175
                           1539     ;call man_entity_create
   65B4 21 23 5A      [10] 1540     ld      hl,#tramp176
   65B7 CD 18 48      [17] 1541     call man_entity_create
   65BA 21 32 5A      [10] 1542     ld      hl,#tramp177
   65BD CD 18 48      [17] 1543     call man_entity_create
   65C0 21 41 5A      [10] 1544     ld      hl,#tramp178
   65C3 CD 18 48      [17] 1545     call man_entity_create
   65C6 21 50 5A      [10] 1546     ld      hl,#tramp179
   65C9 CD 18 48      [17] 1547     call man_entity_create
   65CC 21 5F 5A      [10] 1548     ld      hl,#tramp1710
   65CF CD 18 48      [17] 1549     call man_entity_create
   65D2 21 6E 5A      [10] 1550     ld      hl,#tramp1711
   65D5 CD 18 48      [17] 1551     call man_entity_create
   65D8 21 7D 5A      [10] 1552     ld      hl,#tramp1712
   65DB CD 18 48      [17] 1553     call man_entity_create
   65DE 21 8C 5A      [10] 1554     ld      hl,#tramp1713
   65E1 CD 18 48      [17] 1555     call man_entity_create
   65E4 21 9B 5A      [10] 1556     ld      hl,#tramp1714
   65E7 CD 18 48      [17] 1557     call man_entity_create
   65EA 21 AA 5A      [10] 1558     ld      hl,#tramp1715
   65ED CD 18 48      [17] 1559     call man_entity_create
   65F0 21 B9 5A      [10] 1560     ld      hl,#tramp1716
   65F3 CD 18 48      [17] 1561     call man_entity_create
   65F6 21 C8 5A      [10] 1562     ld      hl,#tramp1717
   65F9 CD 18 48      [17] 1563     call man_entity_create
   65FC 21 D7 5A      [10] 1564     ld      hl,#tramp1718
   65FF CD 18 48      [17] 1565     call man_entity_create
   6602 21 05 5A      [10] 1566     ld      hl,#tramp1719
   6605 CD 18 48      [17] 1567     call man_entity_create
                           1568 
   6608 21 E6 5A      [10] 1569     ld      hl,#enemy171
   660B CD 18 48      [17] 1570     call man_entity_create
                           1571 
   660E 21 9E 48      [10] 1572     ld    hl, #suelo1
   6611 CD 18 48      [17] 1573     call  man_entity_create
   6614 21 AD 48      [10] 1574     ld    hl, #suelo2
   6617 CD 18 48      [17] 1575     call  man_entity_create
                           1576 
   661A C3 DA 66      [10] 1577     jp      _no_load_level
                           1578 
   661D                    1579 _check_level_eighteen:
   661D 21 F5 5A      [10] 1580     ld      hl,#player180
   6620 CD 18 48      [17] 1581     call man_entity_create
   6623 21 04 5B      [10] 1582     ld      hl,#portal180
   6626 CD 18 48      [17] 1583     call man_entity_create
   6629 21 13 5B      [10] 1584     ld      hl,#platah180
   662C CD 18 48      [17] 1585     call man_entity_create
   662F 21 22 5B      [10] 1586     ld      hl,#platah181
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 148.
Hexadecimal [16-Bits]



   6632 CD 18 48      [17] 1587     call man_entity_create
   6635 21 31 5B      [10] 1588     ld      hl,#platah182
   6638 CD 18 48      [17] 1589     call man_entity_create
   663B 21 40 5B      [10] 1590     ld      hl,#platah183
   663E CD 18 48      [17] 1591     call man_entity_create
   6641 21 4F 5B      [10] 1592     ld      hl,#platah184
   6644 CD 18 48      [17] 1593     call man_entity_create
   6647 21 5E 5B      [10] 1594     ld      hl,#platah185
   664A CD 18 48      [17] 1595     call man_entity_create
   664D 21 6D 5B      [10] 1596     ld      hl,#platah186
   6650 CD 18 48      [17] 1597     call man_entity_create
   6653 21 7C 5B      [10] 1598     ld      hl,#platah187
   6656 CD 18 48      [17] 1599     call man_entity_create
   6659 21 8B 5B      [10] 1600     ld      hl,#platah188
   665C CD 18 48      [17] 1601     call man_entity_create
   665F 21 9A 5B      [10] 1602     ld      hl,#platah189
   6662 CD 18 48      [17] 1603     call man_entity_create
   6665 21 A9 5B      [10] 1604     ld      hl,#platah1810
   6668 CD 18 48      [17] 1605     call man_entity_create
   666B 21 B8 5B      [10] 1606     ld      hl,#platah1811
   666E CD 18 48      [17] 1607     call man_entity_create
   6671 21 C7 5B      [10] 1608     ld      hl,#platah1812
   6674 CD 18 48      [17] 1609     call man_entity_create
                           1610 
   6677 21 D6 5B      [10] 1611     ld      hl,#tramp181
   667A CD 18 48      [17] 1612     call man_entity_create
   667D 21 E5 5B      [10] 1613     ld      hl,#tramp182
   6680 CD 18 48      [17] 1614     call man_entity_create
   6683 21 F4 5B      [10] 1615     ld      hl,#tramp183
   6686 CD 18 48      [17] 1616     call man_entity_create
                           1617     ;ld      hl,#tramp184
                           1618     ;call man_entity_create
   6689 21 03 5C      [10] 1619     ld      hl,#tramp185
   668C CD 18 48      [17] 1620     call man_entity_create
   668F 21 12 5C      [10] 1621     ld      hl,#tramp186
   6692 CD 18 48      [17] 1622     call man_entity_create
   6695 21 21 5C      [10] 1623     ld      hl,#tramp187
   6698 CD 18 48      [17] 1624     call man_entity_create
   669B 21 30 5C      [10] 1625     ld      hl,#tramp188
   669E CD 18 48      [17] 1626     call man_entity_create
   66A1 21 3F 5C      [10] 1627     ld      hl,#tramp189
   66A4 CD 18 48      [17] 1628     call man_entity_create
   66A7 21 4E 5C      [10] 1629     ld      hl,#tramp1810
   66AA CD 18 48      [17] 1630     call man_entity_create
   66AD 21 5D 5C      [10] 1631     ld      hl,#tramp1811
   66B0 CD 18 48      [17] 1632     call man_entity_create
   66B3 21 6C 5C      [10] 1633     ld      hl,#tramp1812
   66B6 CD 18 48      [17] 1634     call man_entity_create
   66B9 21 7B 5C      [10] 1635     ld      hl,#tramp1813
   66BC CD 18 48      [17] 1636     call man_entity_create
                           1637 
   66BF 21 8A 5C      [10] 1638     ld      hl,#enemy181
   66C2 CD 18 48      [17] 1639     call man_entity_create
   66C5 21 99 5C      [10] 1640     ld      hl,#enemy182
   66C8 CD 18 48      [17] 1641     call man_entity_create
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 149.
Hexadecimal [16-Bits]



                           1642 
   66CB 21 9E 48      [10] 1643     ld    hl, #suelo1
   66CE CD 18 48      [17] 1644     call  man_entity_create
   66D1 21 AD 48      [10] 1645     ld    hl, #suelo2
   66D4 CD 18 48      [17] 1646     call  man_entity_create
   66D7 C3 DA 66      [10] 1647     jp      _no_load_level
                           1648 
   66DA                    1649 _no_load_level:
   66DA CD 77 45      [17] 1650     call    sys_render_update_all           ; Renderizamos todo el nivel
   66DD                    1651 _game_no_load:
   66DD C9            [10] 1652     ret
                           1653 
                           1654     
                           1655 
                           1656 
                           1657 
                           1658 
                           1659 
                           1660 
                           1661 
                           1662 ;; Funcion limpiar el nivel actual del juego
                           1663 ;; INPUT
                           1664 ;;      0
                           1665 ;; DESTROY
                           1666 ;;      ALL
                           1667 ;; RETURN
                           1668 ;;      0
   66DE                    1669 man_game_clean_next_level::
                           1670 
                           1671     ; Limpiamos la pantalla
   66DE CD 3A 42      [17] 1672     call    cpct_limpiarPantalla_asm 
                           1673 
                           1674     ;; Vaciamos el registro de entidades
   66E1 CD F9 66      [17] 1675     call    man_game_empty_array
                           1676 
   66E4 C9            [10] 1677     ret
                           1678 
                           1679 
                           1680 
                           1681 
                           1682 
                           1683 
                           1684 
                           1685 ;; Funcion para reiniciar en nivel actual del juego. Tenemos al player y las trampas con las que colisiona, marcadas como e_type_dead_mask
                           1686 ;; INPUT
                           1687 ;;      0
                           1688 ;; DESTROY
                           1689 ;;      ALL
                           1690 ;; RETURN
                           1691 ;;      0
   66E5                    1692 man_game_clean_restart::
                           1693 
                           1694     ;; Interrumpe el juego para visualizar al jugador muriendo
   66E5 3E B4         [ 7] 1695     ld      a, #180
   66E7 CD 48 42      [17] 1696     call    cpct_interrupt_flow
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 150.
Hexadecimal [16-Bits]



                           1697 
                           1698     ;; EL OBJETIVO ES HACER UN CLEAR SUAVE PARA REINICIAR EL NIVEL
                           1699     ;; Actualizamos la posicion de los enemigos para borrarlos del render correctamente
   66EA 21 3A 48      [10] 1700     ld     hl, #man_entity_calculate_screen_position
   66ED 3E 04         [ 7] 1701     ld      a, #e_type_dead_mask
   66EF CD 63 48      [17] 1702     call    man_entity_update_forall_matching
                           1703 
                           1704     ;; Borramos al jugador de la zona
   66F2 CD 97 45      [17] 1705     call    sys_render_update_clear
                           1706 
                           1707     ;; Vaciamos el registro de entidades
   66F5 CD F9 66      [17] 1708     call    man_game_empty_array
   66F8 C9            [10] 1709     ret
                           1710 
                           1711 
                           1712 
                           1713 
                           1714 
                           1715 
                           1716 ;; Funcion para reestablecer el array de entidades a sus estado inicial
                           1717 ;; INPUT
                           1718 ;;      0
                           1719 ;; DESTROY
                           1720 ;;      ALL
                           1721 ;; RETURN
                           1722 ;;      0
   66F9                    1723 man_game_empty_array::
                           1724 
                           1725     ;; Destruimos todas las entidades
   66F9 21 8C 48      [10] 1726     ld      hl, #man_entity_destroy_one
   66FC CD 4D 48      [17] 1727     call    man_entity_update_forall
                           1728 
                           1729     ;; Reestablecemos los valores del manager de entidades
   66FF CD 91 48      [17] 1730     call    man_entity_empty_array
   6702 C9            [10] 1731     ret
                           1732 
                           1733 
                           1734 
                           1735 
                           1736 
                           1737 
                           1738 
                           1739 
                           1740 
                           1741 
                           1742 ;; Funcion para marcar como muertas todos los enemigos del juego
                           1743 ;; INPUT
                           1744 ;;      A: Cantidad de interrupciones a ejecutar
                           1745 ;; DESTROY
                           1746 ;;      ALL
                           1747 ;; RETURN
                           1748 ;;      0
   6703                    1749 man_game_destroy_all_enemies::
   6703 21 87 48      [10] 1750     ld     hl, #man_entity_set4destruction
   6706 3E 80         [ 7] 1751     ld      a, #e_type_alive_mask
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 151.
Hexadecimal [16-Bits]



   6708 CD 63 48      [17] 1752     call    man_entity_update_forall_matching
   670B C9            [10] 1753     ret
                           1754 
                           1755 
                           1756 
                           1757 
                           1758 
                           1759 
                           1760 
                           1761 
                           1762 ;; Funcion para devolver el numero de partidas jugadas
                           1763 ;; INPUT
                           1764 ;;      0
                           1765 ;; DESTROY
                           1766 ;;      A
                           1767 ;; RETURN
                           1768 ;;      A: Numero de partidas jugadas
   670C                    1769 man_game_getNumGames_A::
   670C 3A 9D 48      [13] 1770     ld      a, (_num_games)
   670F C9            [10] 1771     ret
