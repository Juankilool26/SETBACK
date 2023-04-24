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
                             18 ;; AI CONTROL SYSTEM
                             19 ;;
                             20 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                             21 .include "man/entity.h.s"
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



                             22 .include "physics.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             23 .include "ai_control.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                             24 .include "assets/assets.h.s"
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
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                             25 
                             26 
                             27 
                             28 
                             29 ;; CONSTANTES
                             30 ;_add_op = 0xC6                  ; Operacion de suma al registro A
                             31 ;_sub_op = 0xD6                  ; Operacion de resta al registro A
                             32 
                             33 
                             34 
                             35 
                             36 ;; Actualiza la posicion de un enemigo
                             37 ;; INPUTS
                             38 ;;      IY: puntero a la entidad actualizar
                             39 ;; DESTROYS
                             40 ;;      AF, DE
                             41 ;; RETURN
                             42 ;;      0
   424D                      43 sys_ai_control_update_one_entity::
                             44 
   424D CD 86 44      [17]   45     call    sys_physics_calculate_previous_position     ; Calculamos la instancia previa
                             46 
                             47     ;; COMPRUEBA EL SENTIDO DEL RECORRIDO
                             48 
                             49     ;;; IZQUIERDA
                             50     ;;_operation = _add_op                                ; Especificamos la operacion de movimiento
                             51     ;;e_eje = e_x                                         ; Especificamos el eje en el que nos movemos
                             52     ;ld      a, e_x(iy)
                             53     ;ld      (_axis_movement), a
                             54     ;ld      d, #-1                                       ; D = Desplazamiento dentro del rango permitido
                             55     ;ld      e, #-1                                       ; E = Desplazamiento en su posicion real
                             56     ;ld      e_sp_l(iy), #_tiles_sp_4                    ; Asociamos el sprite para la direccion y sentido del npc
                             57     ;ld      a, e_walking(iy)                            ; A = Velocidad del enemigo
                             58     ;inc     a
                             59     ;jr      z, _ai_check_side
                             60     ;
                             61     ;;; DERECHA
                             62    ;; _operation = _sub_op
                             63     ;ld      d, #1
                             64     ;ld      e, #1
                             65     ;ld      e_sp_l(iy), #_tiles_sp_5
                             66     ;ld      a, e_walking(iy)
                             67     ;dec     a
                             68     ;jr      z, _ai_check_side2
                             69 ;
                             70     ;;; ARRIBA
                             71     ;;_operation = _sub_op
                             72     ;;e_eje = e_y
                             73     ;ld      h, #e_y
                             74     ;ld      d, #-1
                             75     ;ld      e, #-1
                             76     ;ld      e_sp_l(iy), #_tiles_sp_4
                             77     ;ld      a, e_walking(iy)
                             78     ;inc     a
                             79     ;inc     a
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



                             80     ;jr      z, _ai_check_side
                             81     ;
                             82     ;;; ARRIBA RAPIDO
                             83     ;ld      e, #-2
                             84     ;inc     a
                             85     ;jr      z, _ai_check_side
                             86 ;
                             87     ;;; ABAJO
                             88     ;;_operation = _add_op
                             89     ;ld      d, #1
                             90     ;ld      e, #1
                             91     ;ld      e_sp_l(iy), #_tiles_sp_5
                             92     ;ld      a, e_walking(iy)
                             93     ;dec     a
                             94     ;dec     a
                             95     ;jr      z, _ai_check_side2
                             96 ;
                             97     ;;; ABAJO RAPIDO
                             98     ;ld      e, #2
                             99     ;jr      z, _ai_check_side2
                            100     ;
                            101 
                            102 
                            103 
                            104 ;_ai_check_side:
                            105 ;
                            106 ;    ;ld      a, (_operation)
                            107 ;    ;ld      (_operation_code), a                   ; Registramos la operacion a realizar
                            108 ;    ld      a, e_vx(iy)                             ; A = Posicion dentro del rango de movimiento
                            109 ;
                            110 ;    ;; Modificamos la posicion de los enemigos los enemigos
                            111 ;;_operation_code = .
                            112 ;    add     e_distance(iy)                          ; Comprobamos si hemos alcanzado el limite del rango de movimiento
                            113 ;    jr      z, _ai_change_side                      ; y cambiamos el sentido
                            114 ;
                            115 ;    ;; Rango de movimiento de patrulla
                            116 ;    ld      a, e_vx(iy)                             ; A = Posicion dentro del rango de movimiento
                            117 ;    add     a, d                                    ; Modificamos la posicion dentro del rango de movimiento
                            118 ;    ld      e_vx(iy), a
                            119 ;
                            120 ;    ;; Posicion real del npc
                            121 ;_axis_movement = . + 1
                            122 ;    ld      a, #00                                  ; Hacemos lo propio con la posicion real del personaje
                            123 ;    add     a, e
                            124 ;    ld     (_axis_movement), a
                            125 ;
                            126 ;    jr      _ai_finish_check
                            127 ;_ai_change_side:
                            128 ;
                            129 ;    ;; Cambiamos el sentido del movimiento
                            130 ;    ld      a, e_walking(iy)
                            131 ;    neg                                             ; Cambiar el sentido es el mismo pero negado (cambiado de signo)
                            132 ;    ld      e_walking(iy), a
                            133 ;    jr      _ai_finish_check
                            134 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



                            135 
                            136     ;; Comprueba el sentido del recorrido
   4250 FD 7E 0D      [19]  137     ld      a, e_walking(iy)                            ; A = Velocidad del enemigo
   4253 C6 FF         [ 7]  138     add     #-1
   4255 CA 99 42      [10]  139     jp      z, _ai_check_right
                            140 
   4258 FD 7E 0D      [19]  141     ld      a, e_walking(iy)
   425B C6 01         [ 7]  142     add     #1
   425D CA 78 42      [10]  143     jp      z, _ai_check_left
                            144 
   4260 FD 7E 0D      [19]  145     ld      a, e_walking(iy)
   4263 C6 FE         [ 7]  146     add     #-2
   4265 CA DA 42      [10]  147     jp      z, _ai_check_bot
                            148 
   4268 3D            [ 4]  149     dec     a
   4269 CA 1C 43      [10]  150     jp      z, _ai_check_bot_fast
                            151 
   426C FD 7E 0D      [19]  152     ld      a, e_walking(iy)
   426F C6 02         [ 7]  153     add     #2
   4271 CA BA 42      [10]  154     jp      z, _ai_check_top
                            155 
   4274 3C            [ 4]  156     inc     a
   4275 CA FA 42      [10]  157     jp      z, _ai_check_top_fast
                            158 
                            159 
                            160     ;; Modificamos los enemigos
                            161     ;; IZQUIERDA
   4278                     162 _ai_check_left:
   4278 FD 7E 03      [19]  163     ld      a, e_vx(iy)
   427B FD 86 0E      [19]  164     add     e_distance(iy)
   427E 28 09         [12]  165     jr      z, _ai_change_right
   4280 FD 35 03      [23]  166     dec     e_vx(iy)
   4283 FD 35 01      [23]  167     dec     e_x(iy)
   4286 C3 3C 43      [10]  168     jp      _ai_finish_check
   4289                     169 _ai_change_right:
   4289 21 18 21      [10]  170     ld      hl, #_tiles_sp_05
   428C FD 75 07      [19]  171     ld      e_sp_l(iy), l
   428F FD 74 08      [19]  172     ld      e_sp_h(iy), h
   4292 FD 36 0D 01   [19]  173     ld      e_walking(iy), #1
   4296 C3 3C 43      [10]  174     jp      _ai_finish_check
                            175 
                            176     ;; DERECHA
   4299                     177 _ai_check_right:
   4299 FD 7E 03      [19]  178     ld      a, e_vx(iy)
   429C FD BE 0E      [19]  179     cp      e_distance(iy)
   429F 28 09         [12]  180     jr      z, _ai_change_left
   42A1 FD 34 03      [23]  181     inc     e_vx(iy)
   42A4 FD 34 01      [23]  182     inc     e_x(iy)
   42A7 C3 3C 43      [10]  183     jp      _ai_finish_check
   42AA                     184 _ai_change_left:
   42AA 21 E6 20      [10]  185     ld      hl, #_tiles_sp_04
   42AD FD 75 07      [19]  186     ld      e_sp_l(iy), l
   42B0 FD 74 08      [19]  187     ld      e_sp_h(iy), h
   42B3 FD 36 0D FF   [19]  188     ld      e_walking(iy), #-1
   42B7 C3 3C 43      [10]  189     jp      _ai_finish_check
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



                            190 
                            191     ;; ARRIBA
   42BA                     192 _ai_check_top:
   42BA FD 7E 04      [19]  193     ld      a, e_vy(iy)
   42BD FD 86 0E      [19]  194     add     e_distance(iy)
   42C0 28 09         [12]  195     jr      z, _ai_change_bot
   42C2 FD 35 04      [23]  196     dec     e_vy(iy)
   42C5 FD 35 02      [23]  197     dec     e_y(iy)
   42C8 C3 3C 43      [10]  198     jp      _ai_finish_check
   42CB                     199 _ai_change_bot:
   42CB 21 7C 21      [10]  200     ld      hl, #_tiles_sp_07
   42CE FD 75 07      [19]  201     ld      e_sp_l(iy), l
   42D1 FD 74 08      [19]  202     ld      e_sp_h(iy), h
   42D4 FD 36 0D 02   [19]  203     ld      e_walking(iy), #2
   42D8 18 62         [12]  204     jr      _ai_finish_check
                            205 
                            206     ;; ABAJO
   42DA                     207 _ai_check_bot:
   42DA FD 7E 04      [19]  208     ld      a, e_vy(iy)
   42DD FD BE 0E      [19]  209     cp      e_distance(iy)
   42E0 28 08         [12]  210     jr      z, _ai_change_top
   42E2 FD 34 04      [23]  211     inc     e_vy(iy)
   42E5 FD 34 02      [23]  212     inc     e_y(iy)
   42E8 18 52         [12]  213     jr      _ai_finish_check
   42EA                     214 _ai_change_top:
   42EA 21 4A 21      [10]  215     ld      hl, #_tiles_sp_06
   42ED FD 75 07      [19]  216     ld      e_sp_l(iy), l
   42F0 FD 74 08      [19]  217     ld      e_sp_h(iy), h
   42F3 FD 36 0D FE   [19]  218     ld      e_walking(iy), #-2
   42F7 C3 3C 43      [10]  219     jp      _ai_finish_check
                            220 
                            221 
                            222     ;; ARRIBA RAPIDO
   42FA                     223 _ai_check_top_fast:
   42FA FD 7E 04      [19]  224     ld      a, e_vy(iy)
   42FD FD 86 0E      [19]  225     add     e_distance(iy)
   4300 28 0B         [12]  226     jr      z, _ai_change_bot_fast
   4302 FD 35 04      [23]  227     dec     e_vy(iy)
   4305 FD 35 02      [23]  228     dec     e_y(iy)
   4308 FD 35 02      [23]  229     dec     e_y(iy)
   430B 18 2F         [12]  230     jr      _ai_finish_check
   430D                     231 _ai_change_bot_fast:
   430D 21 AE 21      [10]  232     ld      hl, #_tiles_sp_08
   4310 FD 75 07      [19]  233     ld      e_sp_l(iy), l
   4313 FD 74 08      [19]  234     ld      e_sp_h(iy), h
   4316 FD 36 0D 03   [19]  235     ld      e_walking(iy), #3
   431A 18 20         [12]  236     jr      _ai_finish_check
                            237 
                            238     ;; ABAJO LENTO
   431C                     239 _ai_check_bot_fast:
   431C FD 7E 04      [19]  240     ld      a, e_vy(iy)
   431F FD BE 0E      [19]  241     cp      e_distance(iy)
   4322 28 0B         [12]  242     jr      z, _ai_change_top_fast
   4324 FD 34 04      [23]  243     inc     e_vy(iy)
   4327 FD 34 02      [23]  244     inc     e_y(iy)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 12.
Hexadecimal [16-Bits]



   432A FD 34 02      [23]  245     inc     e_y(iy)
   432D 18 0D         [12]  246     jr      _ai_finish_check
   432F                     247 _ai_change_top_fast:
   432F 21 E0 21      [10]  248     ld      hl, #_tiles_sp_09
   4332 FD 75 07      [19]  249     ld      e_sp_l(iy), l
   4335 FD 74 08      [19]  250     ld      e_sp_h(iy), h
   4338 FD 36 0D FD   [19]  251     ld      e_walking(iy), #-3
                            252 
                            253 
                            254 
   433C                     255 _ai_finish_check:
   433C C9            [10]  256     ret
                            257 
                            258 
                            259 
                            260 
                            261 
                            262 
                            263 
                            264 
                            265 
                            266 ;; Actualiza la posicion de todos los enemigos que poseen IA
                            267 ;; INPUTS
                            268 ;;      0
                            269 ;; DESTROYS
                            270 ;;      AF, BC, HL, IX, IY
                            271 ;; RETURN
                            272 ;;      HL: Posicion anterior
   433D                     273 sys_ai_control_update::
                            274 
   433D 21 4D 42      [10]  275     ld     hl, #sys_ai_control_update_one_entity
   4340 3E 80         [ 7]  276     ld      a, #e_type_alive_mask                       ; Todos los enemigos que se mueven estan vivos
   4342 CD 63 48      [17]  277     call    man_entity_update_forall_matching
   4345 C9            [10]  278     ret
                            279 
