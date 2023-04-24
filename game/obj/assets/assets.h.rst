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
