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

.globl _floor_ceiling_sp_0
.globl _walls_sp_0
.globl _protagonista_sp_0                 ;; Derecha
.globl _protagonista_sp_1                 ;; Izquierda
.globl _protagonista_sp_2                 ;; Muerte
.globl _protagonista_sp_3                 ;; Salto
.globl _delimitador_sp_0 ;;Suelo de la pantalla
.globl _tiles_sp_00 ;;Sprite de bloque normal
.globl _tiles_sp_01 ;;Sprite de trampa
.globl _tiles_sp_02 ;;Sprite de reloj/portal
.globl _tiles_sp_03 ;;Sprite de bloque delimitador
.globl _tiles_sp_04 ;;Sprite de alien naranja izquierda
.globl _tiles_sp_05 ;;Sprite de alien naranja derecha
.globl _tiles_sp_06 ;;Sprite de alien azul izquierda
.globl _tiles_sp_07 ;;Sprite de alien azul derecha
.globl _tiles_sp_08 ;;Sprite de alien rojo izquierda
.globl _tiles_sp_09 ;;Sprite de alien rojo derecha
.globl _linea_pin_sp
.globl _tierra_sp_0
.globl _song_menu
.globl _song_ingame
.globl _screenmenu_z_end
.globl _screenhistory_z_end
.globl _screencredits_z_end
.globl _screencontrols_z_end
.globl _screenwin_z_end


;;
;; PALETAS
;;

.globl _protagonista_pal