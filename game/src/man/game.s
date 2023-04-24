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
;; GAME MANAGER
;;

.include "entity.h.s"
.include "sys/animation.h.s"
.include "sys/render.h.s"
.include "sys/physics.h.s"
.include "sys/input.h.s"
.include "sys/collision.h.s"
.include "sys/ai_control.h.s"
.include "game.h.s"
.include "assets/assets.h.s"
.include "cpctelera_functions.h.s"




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_num_games:: .db    0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; TEMPLATES ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Para asociar una entidad como enemigo, es necesario tener en cuenta que:
    ; 1. El ultimo parametro es el rango en el que se puede mover la patrulla del enemigo (Ej: 7   -7------0------+7)
    ; 2. El penultimo parametro define la direccion y sentido en el que se mueve (1: Derecha, -1: Izquierda, 2 y 3: Abajo, -2 y -3: Arriba)
    ; 3. La diferencia entre el parametro 2 y 3, es la velocidad a la que se mueve y la distancia que recorre (3 > 2 obv)
    ; 4. Se puede modificar desde donde se empieza dentro del recorrido, modificando los parametros de _vx y _vy, siempre y cuando este dentro del rango.
    ; 5. Hay un limite sobre la cantidad de enemigos que se puede poner que puede afectar al render. No rebasar el limite.
;; Para asociar una entidad como estrella, es necesario tener en cuenta que:
    ; 1. Hay que asignarle el type e_type_star
    ; 2. El ultimo parametro llamado _distance tiene que tener el valor 0
    
 ;;SUELO
DefineEntity suelo1, e_type_platform, 0, 190, 0, 0, 40, 10, _delimitador_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity suelo2, e_type_platform, 40, 190, 0, 0, 40, 10, _delimitador_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
;;FIN DE SUELO

DefineEntity player, e_type_player, 0, 180, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00

;; NIVEL INICIAL
DefineEntity portal000, e_type_portal,   50, 130, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah001, e_type_platform, 20, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah002, e_type_platform, 40, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tierra, e_type_platform, 60, 30, 0, 0, 15, 30, _tierra_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

;; NIVEL 0
DefineEntity portal00, e_type_portal,   10, 50, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah01, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah02, e_type_platform, 30, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah03, e_type_platform, 50, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah04, e_type_platform, 30, 87, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah05, e_type_platform, 10, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

; NIVEL 1
DefineEntity portal11, e_type_portal, 0, 30, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah11, e_type_platform, 10, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah12, e_type_platform, 37, 136, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah13, e_type_platform, 65,  135, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah14, e_type_platform, 75, 103, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah15, e_type_platform, 50, 73, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, #-1, #9                                      ; ENEMIGO
DefineEntity platah16, e_type_platform, 20, 73, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah17, e_type_platform, 0,  40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

;NIVEL 2
DefineEntity portal20, e_type_portal, 75, 110, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah21, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah22, e_type_platform, 25, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah23, e_type_platform, 10, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah24, e_type_platform, 20, 80, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah25, e_type_platform, 50, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah26, e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

; NIVEL 3
DefineEntity portal30, e_type_portal, 30, 20, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah31, e_type_platform, 20, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah32, e_type_platform, 45, 148, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah33, e_type_platform, 60, 158, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah34, e_type_platform, 75, 126, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah35, e_type_platform, 50, 94, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah36, e_type_platform, 32, 94, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah37, e_type_platform, 10, 62, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah38, e_type_platform, 30, 30, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp31, e_type_trap, 20, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp32, e_type_trap, 39, 94, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

;; NIVEL 4
DefineEntity portal40, e_type_portal, 65, 60, 0, 0, 5, 10, _tiles_sp_02, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah41, e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah42, e_type_platform, 45, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah43, e_type_platform, 30, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah44, e_type_platform, 12, 125, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah45, e_type_platform, 0, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah46, e_type_platform, 10, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah47, e_type_platform, 25, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah48, e_type_platform, 40, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah49, e_type_platform, 55, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp41, e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp42, e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp43, e_type_trap, 40, 120, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp44, e_type_trap, 45, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp45, e_type_trap, 25, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

; NIVEL 5
DefineEntity portal50, e_type_portal, 40, 40, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah51, e_type_platform, 47, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah52, e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah53, e_type_platform, 70, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah54, e_type_platform, 20, 105, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah55, e_type_platform, 50, 105, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah56, e_type_platform, 15, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah57, e_type_platform, 30, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platav58, e_type_platform, 20, 180, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platav59, e_type_platform, 30, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp51, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp52, e_type_trap, 35, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp53, e_type_trap, 47, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp54, e_type_trap, 70, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp55, e_type_trap, 20, 95, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x002

;;NIVEL 6
DefineEntity portal60, e_type_portal, 30, 70, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah61, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah62, e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah63, e_type_platform, 60, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah64, e_type_platform, 75, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah65, e_type_platform, 70, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah66, e_type_platform, 65, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah67, e_type_platform, 40, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah68, e_type_platform, 15, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp61, e_type_trap, 10, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp62, e_type_trap, 15, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp63, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp64, e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp65, e_type_trap, 40, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp66, e_type_trap, 60, 125, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp67, e_type_trap, 50, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp68, e_type_trap, 40, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp69, e_type_trap, 25, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

;;NIVEL 7
DefineEntity portal70, e_type_portal, 75, 30, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah71, e_type_platform, 30, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah72, e_type_platform, 5, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah73, e_type_platform, 45, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah74, e_type_platform, 60, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah75, e_type_platform, 75, 150, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah76, e_type_platform, 60, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah77, e_type_platform, 40, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah78, e_type_platform, 25, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah79, e_type_platform, 0, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah710, e_type_platform, 15, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah711, e_type_platform, 35, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah712, e_type_platform, 50, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah713, e_type_platform, 65, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah714, e_type_platform, 20, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp71, e_type_trap, 25, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp72, e_type_trap, 15, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp73, e_type_trap, 30, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity enemyh71, e_type_enemy, 52, 140, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x17

;;NIVEL 8

DefineEntity portal80, e_type_portal, 5, 100, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah81, e_type_platform, 40, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah82, e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah83, e_type_platform, 70, 135, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah84, e_type_platform, 65, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah85, e_type_platform, 35, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah86, e_type_platform, 5, 110, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platah87, e_type_platform, 10, 30, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah88, e_type_platform, 10, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah89, e_type_platform, 10, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platah810, e_type_platform, 55, 30, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah811, e_type_platform, 55, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah812, e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platav81, e_type_platform, 25, 140, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platav82, e_type_platform, 55, 140, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity enemy81, e_type_enemy, 40, 180, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x18
DefineEntity tramp80, e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp81, e_type_trap, 55, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

;;NIVEL 9
DefineEntity portal90, e_type_portal, 5, 80, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah91, e_type_platform, 10, 168, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah92, e_type_platform, 20, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah93, e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah94, e_type_platform, 50, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah95, e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah96, e_type_platform, 75, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah97, e_type_platform, 55, 75, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah98, e_type_platform, 40, 75, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah99, e_type_platform, 15, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah910, e_type_platform, 10, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah911, e_type_platform, 5, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah912, e_type_platform, 5, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp91, e_type_trap, 60, 65, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp92, e_type_trap, 45, 65, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp93, e_type_trap, 15, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity enemy91, e_type_enemy, 35, 130, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x7
DefineEntity enemy92, e_type_enemy, 65, 130, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, 0x00, 0x7

;;NIVEL 10
DefineEntity portal100, e_type_portal, 15, 50, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah101, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah102, e_type_platform, 10, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah103, e_type_platform, 25, 130, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah104, e_type_platform, 50, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah105, e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah106, e_type_platform, 55, 84, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah107, e_type_platform, 30, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah108, e_type_platform, 15, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity enemy101, e_type_enemy, 20, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x10
DefineEntity enemy102, e_type_enemy, 30, 120, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x10

DefineEntity tramp101, e_type_trap, 70, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp102, e_type_trap, 20, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp103, e_type_trap, 35, 50, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00


;;NIVEL 11
DefineEntity portal110, e_type_portal, 75, 40, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah111, e_type_platform, 65, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah112, e_type_platform, 45, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah113, e_type_platform, 30, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah114, e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah115, e_type_platform, 5, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah116, e_type_platform, 5, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah117, e_type_platform, 15, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah118, e_type_platform, 5, 60, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah119, e_type_platform, 25, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1110, e_type_platform, 40, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1111, e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platah1112, e_type_platform, 70, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1113, e_type_platform, 75, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1114, e_type_platform, 60, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1115, e_type_platform, 60, 80, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1116, e_type_platform, 60, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp111, e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp112, e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp113, e_type_trap, 10, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity enemy111, e_type_enemy, 40, 100, 0, 0, 5, 10, _tiles_sp_06, 0, 0x0000, 0x00, #2, 0x1E

;;NIVEL 12
DefineEntity portal120, e_type_portal, 75, 30, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah121, e_type_platform, 20, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah122, e_type_platform, 35, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah123, e_type_platform, 50, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah124, e_type_platform, 65, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platav125, e_type_platform, 70, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platav126, e_type_platform, 75, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah127, e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah128, e_type_platform, 75, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah129, e_type_platform, 70, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1210, e_type_platform, 50, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1211, e_type_platform, 40, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1212, e_type_platform, 30, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1213, e_type_platform, 5, 100, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1214, e_type_platform, 0, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1215, e_type_platform, 5, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platah1216, e_type_platform, 15, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1217, e_type_platform, 40, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1218, e_type_platform, 65, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp121, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp122, e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp123, e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp124, e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp125, e_type_trap, 55, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp126, e_type_trap, 60, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity enemy121, e_type_enemy, 35, 90, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x1E

;;NIVEL 13
DefineEntity portal130, e_type_portal, 45, 10, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah131, e_type_platform, 0, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah132, e_type_platform, 20, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah133, e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah134, e_type_platform, 35, 120, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah135, e_type_platform, 55, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah136, e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah137, e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah138, e_type_platform, 75, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah139, e_type_platform, 75, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1310, e_type_platform, 50, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1311, e_type_platform, 20, 70, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1312, e_type_platform, 0, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1313, e_type_platform, 15, 20, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1314, e_type_platform, 35, 20, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp131, e_type_trap, 30, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp132, e_type_trap, 30, 20, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity enemy131, e_type_enemy, 40, 70, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x10

;;NIVEL 14
DefineEntity player140, e_type_player, 0, 160, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
DefineEntity portal140, e_type_portal, 75, 40, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah141, e_type_platform, 25, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah142, e_type_platform, 40, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah143, e_type_platform, 55, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah144, e_type_platform, 70, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah145, e_type_platform, 75, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah146, e_type_platform, 60, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah147, e_type_platform, 30, 100, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah148, e_type_platform, 12, 75, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah149, e_type_platform, 22, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1410, e_type_platform, 35, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1411, e_type_platform, 55, 50, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1412, e_type_platform, 75, 50, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1413, e_type_platform, 0, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1414, e_type_platform, 5, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1415, e_type_platform, 10, 170, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp141, e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp142, e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp143, e_type_trap, 30, 180, 0, 0, 50, 10, _linea_pin_sp, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp144, e_type_trap, 35, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp145, e_type_trap, 40, 40, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity enemy141, e_type_enemy, 55, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x10
DefineEntity enemy142, e_type_enemy, 17, 50, 0, 0, 5, 10, _tiles_sp_08, 0, 0x0000, 0x00, #3, 0x8

;; NIVEL 18 (MULETILLA 16)
DefineEntity player16, e_type_player, 0, 150, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
DefineEntity portal160, e_type_portal, 5, 18, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tierra16, e_type_platform, 60, 0, 0, 0, 15, 30, _tierra_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platah161, e_type_platform, 0, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah162, e_type_platform, 5, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah163, e_type_platform, 20, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah164, e_type_platform, 35, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah165, e_type_platform, 50, 160, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah166, e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah167, e_type_platform, 70, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah168, e_type_platform, 50, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah169, e_type_platform, 0, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1610, e_type_platform, 15, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1611, e_type_platform, 30, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1612, e_type_platform, 25, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1613, e_type_platform, 0, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1614, e_type_platform, 0, 30, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp161, e_type_trap, 10, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp162, e_type_trap, 15, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp163, e_type_trap, 20, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp165, e_type_trap, 75, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp166, e_type_trap, 65, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp167, e_type_trap, 5, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp168, e_type_trap, 5, 30, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp169, e_type_trap, 55, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1610, e_type_trap, 60, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1611, e_type_trap, 65, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1612, e_type_trap, 70, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity enemy161, e_type_enemy, 35, 150, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x0F
DefineEntity enemy162, e_type_enemy, 15, 80, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x0F

;; NIVEL 17 (MULETILLA 19)
DefineEntity player17, e_type_player, 0, 150, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
DefineEntity portal170, e_type_portal, 55, 80, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00

DefineEntity platav171, e_type_platform, 0, 160, 0, 0, 5, 30, _walls_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah172, e_type_platform, 0, 130, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah173, e_type_platform, 0, 100, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah174, e_type_platform, 0, 70, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah175, e_type_platform, 0, 40, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah176, e_type_platform, 15, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah177, e_type_platform, 20, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah178, e_type_platform, 25, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah179, e_type_platform, 30, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1716, e_type_platform, 35, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1710, e_type_platform, 65, 150, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1711, e_type_platform, 10, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1712, e_type_platform, 25, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1713, e_type_platform, 55, 180, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1714, e_type_platform, 65, 120, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1715, e_type_platform, 55, 90, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp171, e_type_trap, 15, 70, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp172, e_type_trap, 20, 70, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp173, e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp174, e_type_trap, 30, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1719, e_type_trap, 35, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp175, e_type_trap, 5, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp176, e_type_trap, 5, 170, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp177, e_type_trap, 5, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp178, e_type_trap, 5, 140, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp179, e_type_trap, 5, 120, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1710, e_type_trap, 5, 110, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1711, e_type_trap, 5, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1712, e_type_trap, 5, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1713, e_type_trap, 5, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1714, e_type_trap, 40, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1715, e_type_trap, 45, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1716, e_type_trap, 50, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1717, e_type_trap, 70, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1718, e_type_trap, 75, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity enemy171, e_type_enemy, 35, 170, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x16

;; NIVEL 20 (MULETILLA 18)
DefineEntity player180, e_type_player, 0, 170, 0, 0, 5, 10, _protagonista_sp_0,  0, 0x0000, 0x01, 0x00, 0x00
DefineEntity portal180, e_type_portal, 75, 50, 0, 0, 5, 10, _tiles_sp_02,  0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah180, e_type_platform, 0, 180, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah181, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah182, e_type_platform, 0, 140, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah183, e_type_platform, 5, 110, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah184, e_type_platform, 5, 80, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah185, e_type_platform, 20, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah186, e_type_platform, 10, 160, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah187, e_type_platform, 35, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah188, e_type_platform, 50, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah189, e_type_platform, 65, 140, 0, 0, 15, 10, _floor_ceiling_sp_0, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1810, e_type_platform, 75, 118, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1811, e_type_platform, 60, 90, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity platah1812, e_type_platform, 75, 60, 0, 0, 5, 10, _tiles_sp_00, 0, 0x0000, 0x00, 0x00, 0x00


DefineEntity tramp181, e_type_trap, 15, 150, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp182, e_type_trap, 0, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp183, e_type_trap, 10, 80, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
;DefineEntity tramp184, e_type_trap, 20, 30, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp185, e_type_trap, 25, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp186, e_type_trap, 30, 60, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp187, e_type_trap, 40, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp188, e_type_trap, 45, 90, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp189, e_type_trap, 25, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1810, e_type_trap, 30, 130, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity tramp1811, e_type_trap, 5, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1812, e_type_trap, 30, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00
DefineEntity tramp1813, e_type_trap, 25, 180, 0, 0, 5, 10, _tiles_sp_01, 0, 0x0000, 0x00, 0x00, 0x00

DefineEntity enemy181, e_type_enemy, 38, 100, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #1, 0x24
DefineEntity enemy182, e_type_enemy, 38, 70, 0, 0, 5, 10, _tiles_sp_04, 0, 0x0000, 0x00, #-1, 0x24



;; Inicializamos el manager de entidades junto a los sistemas y creamos entidades
;; INPUT
;;      0
;; DESTROY
;;      AF, HL, BC, DE, IX, IY
;; RETURN
;;      0
man_game_init::

    ;; Iniciamos el juego con el nivel 1
    _current_level:: .db #0

    ;; Inicializamos los managers y sistemas
    call    man_entity_init
    call    sys_render_init
;    call    sys_input_init

    ;; Cargamos el nivel 1
    call    man_game_load_next_level

    ;; Especificamos en que partida estamos, la primera
    call    man_game_next_play

    ret






;; Reinciamos el juego comenzando apartir de una primera partida
;; INPUT
;;      0
;; DESTROY
;;      AF, HL, BC, DE, IX, IY
;; RETURN
;;      0
man_game_restart::

    ;; Especificamos que estamos en el inicio
    ld      a, #0
    ld      (_current_level), a

    ;; Cargamos el nivel 1
    call  man_game_load_next_level

    ;; Especificamos en que partida estamos
    call man_game_next_play

    ret








;; Actualizamos el juego
;; INPUT
;;      0
;; DESTROY
;;      AF, HL, BC, DE, IX, IY
;; RETURN
;;      0
man_game_run::

    ;; Guardamos en IX la entidad del player
    call  man_entity_getPlayer_IX

    ;; Actualizamos los sistemas de movimiento
    call    sys_render_update
    call    sys_input_update
    call    sys_ai_control_update
    call    sys_physics_update

    ;; Comprobamos si el jugador ha muerto
    ;; Primero marcamos la entidad como muerta
    ;; para visualizar la colision que provoca
    ;; su muerte y luego reiniciamos el nivel
    ld      a, e_type(ix)
    xor     #e_type_dead_mask
    jr     nz, _update_game_systems
    ld      e_type(ix), #e_type_invalid                     ; Invalida al jugador
    jr      _check_game_state                               ; Terminamos comprobaciones
_update_game_systems:    

    ;; Actualizamos las colisiones
    call    sys_collision_update

    ;; Actualizamos la animacion del player
    call    sys_animation_update

    ;; Si el jugador ha muerto, marcamos como muertas todas las entidades enemigas
    ld      a, e_type(ix)
    xor     #e_type_dead_mask
    call    z, man_game_destroy_all_enemies
_check_game_state:

    ;; Comprobamos si el jugador ha muerto
    ld      a, e_type(ix)
    xor     #e_type_invalid                                 ; XOR con mascara de entidad invalida
    call    z, man_game_restart_level

    ;; Comprobamos si el jugador colisiona con el portal para pasar al siguiente nivel
    ld      a, #1                                           ; A = posicion de la puerta en el array
    call    man_entity_get_from_idx_IY                      ; IY = entidad portal
    ld      a, e_type(iy)                                   ; A = e_type
    xor     #e_type_dead_mask                               ; Comprobamos si la entidad esta muerta
    call    z, man_game_load_next_level                     ; Cambiamos de nivel

    ;; Guardamos el nivel actual para comprobar si nos hemos pasado el juego o no
    ld      a, (_current_level)

    ret








;; Cargamos el siguiente nivel del juego
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_load_next_level::

    call    man_game_clean_next_level               ; Limpiamos por pantalla
    ld      a, (_current_level)
    inc     a                                       ; Incrementamos el nivel
    ld      (_current_level), a
    call    man_game_load_level                     ; Cargar nivel actual
    ret









;; Funcion para reiniciar el nivel del juego
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_restart_level::

    call    man_game_clean_restart          ; Destruimos todo el nivel para reconstruirlo
    call    man_game_load_level             ; Cargar nivel actual
    ret








;; Funcion para sibujar todos los elementos por pantalla y continuar el juego
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_continue_level::

    call    cpct_limpiarPantalla_asm
    call    sys_render_update_all
    ret








;; Funcion para incrementar el contador de partidas
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_next_play::

    ld      a, (_num_games)
    inc     a
    ld      (_num_games), a
    ret









;; Funcion para cargar el nivel actual del juego
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_load_level::
     ld      a, (_current_level)             ; Cargamos el nivel actual
    dec     a
    jp      z, _check_level_zerozero
    dec     a
    jp      z, _check_level_zero
    dec     a
    jp      z, _check_level_one
    dec     a
    jp      z, _check_level_two
    dec     a
    jp      z, _check_level_three
    dec     a
    jp      z, _check_level_four
    dec     a
    jp      z, _check_level_five
    dec     a
    jp      z, _check_level_six
    dec     a
    jp      z, _check_level_seven
    dec     a
    jp      z, _check_level_eight
    dec     a
    jp      z, _check_level_nine
    dec     a
    jp      z, _check_level_ten
    dec     a
    jp      z, _check_level_eleven
    dec     a
    jp      z, _check_level_twelve
    dec     a
    jp      z, _check_level_thirteen
    dec     a
    jp      z, _check_level_fourteen
    dec     a
    jp      z, _check_level_sixteen
    dec     a
    jp      z, _check_level_seventeen
    jp      _check_level_eighteen


_check_level_zerozero:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal000
    call man_entity_create
    ld      hl,#platah001
    call man_entity_create
    ld      hl,#platah002
    call man_entity_create
    ld      hl,#tierra
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp    _no_load_level

_check_level_zero:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal00
    call man_entity_create
    ld      hl,#platah01
    call man_entity_create
    ld      hl,#platah02
    call man_entity_create
    ld      hl,#platah03
    call man_entity_create
    ld      hl,#platah04
    call man_entity_create
    ld      hl,#platah05
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp    _no_load_level

_check_level_one:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal11
    call man_entity_create
    ld      hl,#platah11
    call man_entity_create
    ld      hl,#platah12
    call man_entity_create
    ld      hl,#platah13
    call man_entity_create
    ld      hl,#platah14
    call man_entity_create
    ld      hl,#platah15
    call man_entity_create
    ld      hl,#platah16
    call man_entity_create
    ld      hl,#platah17
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp    _no_load_level


_check_level_two:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal20
    call man_entity_create
    ld      hl,#platah21
    call man_entity_create
    ld      hl,#platah22
    call man_entity_create
    ld      hl,#platah23
    call man_entity_create
    ld      hl,#platah24
    call man_entity_create
    ld      hl,#platah25
    call man_entity_create
    ld      hl,#platah26
    call man_entity_create


    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp    _no_load_level


_check_level_three:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal30
    call man_entity_create
    ld      hl,#platah31
    call man_entity_create
    ld      hl,#platah32
    call man_entity_create
    ld      hl,#platah33
    call man_entity_create
    ld      hl,#platah34
    call man_entity_create
    ld      hl,#platah35
    call man_entity_create
    ld      hl,#platah36
    call man_entity_create
    ld      hl,#platah37
    call man_entity_create
    ld      hl,#platah38
    call man_entity_create
    ld      hl,#tramp31
    call man_entity_create
    ld      hl,#tramp32
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp  _no_load_level


_check_level_four:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal40
    call man_entity_create
    ld      hl,#platah41
    call man_entity_create
    ld      hl,#platah42
    call man_entity_create
    ld      hl,#platah43
    call man_entity_create
    ld      hl,#platah44
    call man_entity_create
    ld      hl,#platah45
    call man_entity_create
    ld      hl,#platah46
    call man_entity_create
    ld      hl,#platah47
    call man_entity_create
    ld      hl,#platah48
    call man_entity_create
    ld      hl,#platah49
    call man_entity_create
    ld      hl,#tramp41
    call man_entity_create
    ld      hl,#tramp42
    call man_entity_create
    ld      hl,#tramp43
    call man_entity_create
    ld      hl,#tramp44
    call man_entity_create
    ld      hl,#tramp45
    call man_entity_create
    
    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp  _no_load_level

_check_level_five:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal50
    call man_entity_create
    ld      hl,#platah51
    call man_entity_create
    ld      hl,#platah52
    call man_entity_create
    ld      hl,#platah53
    call man_entity_create
    ld      hl,#platah54
    call man_entity_create
    ld      hl,#platah55
    call man_entity_create
    ld      hl,#platah56
    call man_entity_create
    ld      hl,#platah57
    call man_entity_create
    ld      hl,#platav58
    call man_entity_create
    ld      hl,#platav59
    call man_entity_create
    ld      hl,#tramp51
    call man_entity_create    
    ld      hl,#tramp52
    call man_entity_create    
    ld      hl,#tramp53
    call man_entity_create    
    ld      hl,#tramp54
    call man_entity_create    
    ld      hl,#tramp55
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp  _no_load_level

_check_level_six:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal60
    call man_entity_create
    ld      hl,#platah61
    call man_entity_create
    ld      hl,#platah62
    call man_entity_create
    ld      hl,#platah63
    call man_entity_create
    ld      hl,#platah64
    call man_entity_create
    ld      hl,#platah65
    call man_entity_create
    ld      hl,#platah66
    call man_entity_create
    ld      hl,#platah67
    call man_entity_create
    ld      hl,#platah68
    call man_entity_create
    ld      hl,#tramp61
    call man_entity_create
    ld      hl,#tramp62
    call man_entity_create
    ld      hl,#tramp63
    call man_entity_create
    ld      hl,#tramp64
    call man_entity_create
    ld      hl,#tramp65
    call man_entity_create
    ld      hl,#tramp66
    call man_entity_create
    ld      hl,#tramp67
    call man_entity_create
    ld      hl,#tramp68
    call man_entity_create
    ld      hl,#tramp69
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create
    jp  _no_load_level

_check_level_seven:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal70
    call man_entity_create
    ld      hl,#platah71
    call man_entity_create
    ld      hl,#platah72
    call man_entity_create
    ld      hl,#platah73
    call man_entity_create
    ld      hl,#platah74
    call man_entity_create
    ld      hl,#platah75
    call man_entity_create
    ld      hl,#platah76
    call man_entity_create
    ld      hl,#platah77
    call man_entity_create
    ld      hl,#platah78
    call man_entity_create
    ld      hl,#platah79
    call man_entity_create
    ld      hl,#platah710
    call man_entity_create
    ld      hl,#platah711
    call man_entity_create
    ld      hl,#platah712
    call man_entity_create
    ld      hl,#platah713
    call man_entity_create
    ld      hl,#platah714
    call man_entity_create
    ld      hl,#tramp71
    call man_entity_create
    ld      hl,#tramp72
    call man_entity_create
    ld      hl,#tramp73
    call man_entity_create
    ld      hl,#enemyh71
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp  _no_load_level

_check_level_eight:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal80
    call man_entity_create
    ld      hl,#platah81
    call man_entity_create
    ld      hl,#platah82
    call man_entity_create
    ld      hl,#platah83
    call man_entity_create
    ld      hl,#platah84
    call man_entity_create
    ld      hl,#platah85
    call man_entity_create
    ld      hl,#platah86
    call man_entity_create

    ld      hl,#platah87
    call man_entity_create
    ld      hl,#platah88
    call man_entity_create
    ld      hl,#platah89
    call man_entity_create
    ld      hl,#platah810
    call man_entity_create
    ld      hl,#platah811
    call man_entity_create
    ld      hl,#platah812
    call man_entity_create

    ld      hl,#platav81
    call man_entity_create
    ld      hl,#platav82
    call man_entity_create
    ld      hl,#enemy81
    call man_entity_create
    ld      hl,#tramp80
    call man_entity_create
    ld      hl,#tramp81
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp  _no_load_level

_check_level_nine:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal90
    call man_entity_create
    ld      hl,#platah91
    call man_entity_create
    ld      hl,#platah92
    call man_entity_create
    ld      hl,#platah93
    call man_entity_create
    ld      hl,#platah94
    call man_entity_create
    ld      hl,#platah95
    call man_entity_create
    ld      hl,#platah96
    call man_entity_create
    ld      hl,#platah97
    call man_entity_create
    ld      hl,#platah98
    call man_entity_create
    ld      hl,#platah99
    call man_entity_create
    ld      hl,#platah910
    call man_entity_create
    ld      hl,#platah911
    call man_entity_create
    ld      hl,#platah912
    call man_entity_create

    ld      hl,#tramp91
    call man_entity_create
    ld      hl,#tramp92
    call man_entity_create
    ld      hl,#tramp93
    call man_entity_create

    ld      hl,#enemy91
    call man_entity_create
    ld      hl,#enemy92
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp _no_load_level

_check_level_ten:
    ld      hl,#player
    call man_entity_create
    ld      hl,#portal100
    call man_entity_create
    ld      hl,#platah101
    call man_entity_create
    ld      hl,#platah102
    call man_entity_create
    ld      hl,#platah103
    call man_entity_create
    ld      hl,#platah104
    call man_entity_create
    ld      hl,#platah105
    call man_entity_create
    ld      hl,#platah106
    call man_entity_create
    ld      hl,#platah107
    call man_entity_create
    ld      hl,#platah108
    call man_entity_create

    ld      hl,#enemy101
    call man_entity_create
    ld      hl,#enemy102
    call man_entity_create

    ld      hl,#tramp101
    call man_entity_create
    ld      hl,#tramp102
    call man_entity_create
    ld      hl,#tramp103
    call man_entity_create

    ld    hl, #suelo1
    call man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp _no_load_level

_check_level_eleven:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal110
    call man_entity_create

    ld      hl,#platah111
    call man_entity_create
    ld      hl,#platah112
    call man_entity_create
    ld      hl,#platah113
    call man_entity_create
    ld      hl,#platah114
    call man_entity_create
    ld      hl,#platah115
    call man_entity_create
    ld      hl,#platah116
    call man_entity_create
    ld      hl,#platah117
    call man_entity_create
    ld      hl,#platah118
    call man_entity_create
    ld      hl,#platah119
    call man_entity_create
    ld      hl,#platah1110
    call man_entity_create
    ld      hl,#platah1111
    call man_entity_create
    ld      hl,#platah1112
    call man_entity_create
    ld      hl,#platah1113
    call man_entity_create
    ld      hl,#platah1114
    call man_entity_create
    ld      hl,#platah1115
    call man_entity_create
    ld      hl,#platah1116
    call man_entity_create

    ld      hl,#tramp111
    call man_entity_create
    ld      hl,#tramp112
    call man_entity_create
    ld      hl,#tramp113
    call man_entity_create

    ld      hl,#enemy111
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp  _no_load_level

_check_level_twelve:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal120
    call man_entity_create

    ld      hl,#platah121
    call man_entity_create
    ld      hl,#platah122
    call man_entity_create
    ld      hl,#platah123
    call man_entity_create
    ld      hl,#platah124
    call man_entity_create
    ld      hl,#platav125
    call man_entity_create
    ld      hl,#platav126
    call man_entity_create
    ld      hl,#platah127
    call man_entity_create
    ld      hl,#platah128
    call man_entity_create
    ld      hl,#platah129
    call man_entity_create
    ld      hl,#platah1210
    call man_entity_create
    ld      hl,#platah1211
    call man_entity_create
    ld      hl,#platah1212
    call man_entity_create
    ld      hl,#platah1213
    call man_entity_create
    ld      hl,#platah1214
    call man_entity_create
    ld      hl,#platah1215
    call man_entity_create
    ld      hl,#platah1216
    call man_entity_create
    ld      hl,#platah1217
    call man_entity_create
    ld      hl,#platah1218
    call man_entity_create


    ld      hl,#tramp121
    call man_entity_create
    ld      hl,#tramp122
    call man_entity_create
    ld      hl,#tramp123
    call man_entity_create
    ld      hl,#tramp124
    call man_entity_create
    ld      hl,#tramp125
    call man_entity_create
    ld      hl,#tramp126
    call man_entity_create

    ld      hl,#enemy121
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp      _no_load_level

_check_level_thirteen:

    ld      hl,#player
    call man_entity_create
    ld      hl,#portal130
    call man_entity_create

    ld      hl,#platah131
    call man_entity_create
    ld      hl,#platah132
    call man_entity_create
    ld      hl,#platah133
    call man_entity_create
    ld      hl,#platah134
    call man_entity_create
    ld      hl,#platah135
    call man_entity_create
    ld      hl,#platah136
    call man_entity_create
    ld      hl,#platah137
    call man_entity_create
    ld      hl,#platah138
    call man_entity_create
    ld      hl,#platah139
    call man_entity_create
    ld      hl,#platah1310
    call man_entity_create
    ld      hl,#platah1311
    call man_entity_create
    ld      hl,#platah1312
    call man_entity_create
    ld      hl,#platah1313
    call man_entity_create
    ld      hl,#platah1314
    call man_entity_create


    ld      hl,#tramp131
    call man_entity_create
    ld      hl,#tramp132
    call man_entity_create

    ld      hl,#enemy131
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp      _no_load_level

_check_level_fourteen:
    ld      hl, #player140
    call man_entity_create
    ld      hl, #portal140
    call man_entity_create
    ld      hl, #platah141
    call man_entity_create
    ld      hl, #platah142
    call man_entity_create
    ld      hl, #platah143
    call man_entity_create
    ld      hl, #platah144
    call man_entity_create
    ld      hl, #platah145
    call man_entity_create
    ld      hl, #platah146
    call man_entity_create
    ld      hl, #platah147
    call man_entity_create
    ld      hl, #platah148
    call man_entity_create
    ld      hl, #platah149
    call man_entity_create
    ld      hl, #platah1410
    call man_entity_create
    ld      hl, #platah1411
    call man_entity_create
    ld      hl, #platah1412
    call man_entity_create
    ld      hl, #platah1413
    call man_entity_create
    ld      hl, #platah1414
    call man_entity_create
    ld      hl, #platah1415
    call man_entity_create

    ld      hl, #tramp141
    call man_entity_create
    ld      hl, #tramp142
    call man_entity_create
    ld      hl, #tramp143
    call man_entity_create
    ld      hl, #tramp144
    call man_entity_create
    ld      hl, #tramp145
    call man_entity_create

    ld      hl, #enemy141
    call man_entity_create
    ld      hl, #enemy142
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp      _no_load_level

_check_level_sixteen:

    ld      hl,#player16
    call man_entity_create
    ld      hl,#portal160
    call man_entity_create
    ld      hl,#tierra16
    call man_entity_create

    ld      hl,#platah161
    call man_entity_create
    ld      hl,#platah162
    call man_entity_create
    ld      hl,#platah163
    call man_entity_create
    ld      hl,#platah164
    call man_entity_create
    ld      hl,#platah165
    call man_entity_create
    ld      hl,#platah166
    call man_entity_create
    ld      hl,#platah167
    call man_entity_create
    ld      hl,#platah168
    call man_entity_create
    ld      hl,#platah169
    call man_entity_create
    ld      hl,#platah1610
    call man_entity_create
    ld      hl,#platah1611
    call man_entity_create
    ld      hl,#platah1612
    call man_entity_create
    ld      hl,#platah1613
    call man_entity_create
    ld      hl,#platah1614
    call man_entity_create

    ld      hl,#tramp161
    call man_entity_create
    ld      hl,#tramp162
    call man_entity_create
    ld      hl,#tramp163
    call man_entity_create
    ld      hl,#tramp165
    call man_entity_create
    ld      hl,#tramp166
    call man_entity_create
    ld      hl,#tramp167
    call man_entity_create
    ld      hl,#tramp168
    call man_entity_create
    ld      hl,#tramp169
    call man_entity_create
    ld      hl,#tramp1610
    call man_entity_create
    ld      hl,#tramp1611
    call man_entity_create
    ld      hl,#tramp1612
    call man_entity_create


    ld      hl,#enemy161
    call man_entity_create
    ld      hl,#enemy162
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp      _no_load_level

_check_level_seventeen:

    ld      hl,#player17
    call man_entity_create
    ld      hl,#portal170
    call man_entity_create

    ld      hl,#platav171
    call man_entity_create
    ld      hl,#platah172
    call man_entity_create
    ld      hl,#platah173
    call man_entity_create
    ld      hl,#platah174
    call man_entity_create
    ld      hl,#platah175
    call man_entity_create
    ld      hl,#platah176
    call man_entity_create
    ld      hl,#platah177
    call man_entity_create
    ld      hl,#platah178
    call man_entity_create
    ld      hl,#platah179
    call man_entity_create
    ld      hl,#platah1710
    call man_entity_create
    ld      hl,#platah1711
    call man_entity_create
    ld      hl,#platah1712
    call man_entity_create
    ld      hl,#platah1713
    call man_entity_create
    ld      hl,#platah1714
    call man_entity_create
    ld      hl,#platah1715
    call man_entity_create
    ld      hl,#platah1716
    call man_entity_create

    ld      hl,#tramp171
    call man_entity_create
    ld      hl,#tramp172
    call man_entity_create
    ld      hl,#tramp173
    call man_entity_create
    ld      hl,#tramp174
    call man_entity_create
    ;ld      hl,#tramp175
    ;call man_entity_create
    ld      hl,#tramp176
    call man_entity_create
    ld      hl,#tramp177
    call man_entity_create
    ld      hl,#tramp178
    call man_entity_create
    ld      hl,#tramp179
    call man_entity_create
    ld      hl,#tramp1710
    call man_entity_create
    ld      hl,#tramp1711
    call man_entity_create
    ld      hl,#tramp1712
    call man_entity_create
    ld      hl,#tramp1713
    call man_entity_create
    ld      hl,#tramp1714
    call man_entity_create
    ld      hl,#tramp1715
    call man_entity_create
    ld      hl,#tramp1716
    call man_entity_create
    ld      hl,#tramp1717
    call man_entity_create
    ld      hl,#tramp1718
    call man_entity_create
    ld      hl,#tramp1719
    call man_entity_create

    ld      hl,#enemy171
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create

    jp      _no_load_level

_check_level_eighteen:
    ld      hl,#player180
    call man_entity_create
    ld      hl,#portal180
    call man_entity_create
    ld      hl,#platah180
    call man_entity_create
    ld      hl,#platah181
    call man_entity_create
    ld      hl,#platah182
    call man_entity_create
    ld      hl,#platah183
    call man_entity_create
    ld      hl,#platah184
    call man_entity_create
    ld      hl,#platah185
    call man_entity_create
    ld      hl,#platah186
    call man_entity_create
    ld      hl,#platah187
    call man_entity_create
    ld      hl,#platah188
    call man_entity_create
    ld      hl,#platah189
    call man_entity_create
    ld      hl,#platah1810
    call man_entity_create
    ld      hl,#platah1811
    call man_entity_create
    ld      hl,#platah1812
    call man_entity_create

    ld      hl,#tramp181
    call man_entity_create
    ld      hl,#tramp182
    call man_entity_create
    ld      hl,#tramp183
    call man_entity_create
    ;ld      hl,#tramp184
    ;call man_entity_create
    ld      hl,#tramp185
    call man_entity_create
    ld      hl,#tramp186
    call man_entity_create
    ld      hl,#tramp187
    call man_entity_create
    ld      hl,#tramp188
    call man_entity_create
    ld      hl,#tramp189
    call man_entity_create
    ld      hl,#tramp1810
    call man_entity_create
    ld      hl,#tramp1811
    call man_entity_create
    ld      hl,#tramp1812
    call man_entity_create
    ld      hl,#tramp1813
    call man_entity_create

    ld      hl,#enemy181
    call man_entity_create
    ld      hl,#enemy182
    call man_entity_create

    ld    hl, #suelo1
    call  man_entity_create
    ld    hl, #suelo2
    call  man_entity_create
    jp      _no_load_level

_no_load_level:
    call    sys_render_update_all           ; Renderizamos todo el nivel
_game_no_load:
    ret

    







;; Funcion limpiar el nivel actual del juego
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_clean_next_level::

    ; Limpiamos la pantalla
    call    cpct_limpiarPantalla_asm 

    ;; Vaciamos el registro de entidades
    call    man_game_empty_array

    ret







;; Funcion para reiniciar en nivel actual del juego. Tenemos al player y las trampas con las que colisiona, marcadas como e_type_dead_mask
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_clean_restart::

    ;; Interrumpe el juego para visualizar al jugador muriendo
    ld      a, #180
    call    cpct_interrupt_flow

    ;; EL OBJETIVO ES HACER UN CLEAR SUAVE PARA REINICIAR EL NIVEL
    ;; Actualizamos la posicion de los enemigos para borrarlos del render correctamente
    ld     hl, #man_entity_calculate_screen_position
    ld      a, #e_type_dead_mask
    call    man_entity_update_forall_matching

    ;; Borramos al jugador de la zona
    call    sys_render_update_clear

    ;; Vaciamos el registro de entidades
    call    man_game_empty_array
    ret






;; Funcion para reestablecer el array de entidades a sus estado inicial
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_empty_array::

    ;; Destruimos todas las entidades
    ld      hl, #man_entity_destroy_one
    call    man_entity_update_forall

    ;; Reestablecemos los valores del manager de entidades
    call    man_entity_empty_array
    ret










;; Funcion para marcar como muertas todos los enemigos del juego
;; INPUT
;;      A: Cantidad de interrupciones a ejecutar
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_game_destroy_all_enemies::
    ld     hl, #man_entity_set4destruction
    ld      a, #e_type_alive_mask
    call    man_entity_update_forall_matching
    ret








;; Funcion para devolver el numero de partidas jugadas
;; INPUT
;;      0
;; DESTROY
;;      A
;; RETURN
;;      A: Numero de partidas jugadas
man_game_getNumGames_A::
    ld      a, (_num_games)
    ret