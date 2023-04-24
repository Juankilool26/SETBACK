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
;; MENU MANAGER
;;

.include "cpctelera_functions.h.s"
.include "sys/render.h.s"
.include "assets/assets.h.s"
.include "cpctelera.h.s"






;; String del manu de pausa
linea_men_ini_0:: .asciz "PAUSE"
linea_men_ini_1:: .asciz "SPACE to continue"
linea_men_ini_2:: .asciz "  E   to exit"





;; Nada de input
;; Funcion que llama al render init para setear el modo de video a 
;; y crear la paleta de colores que se utilizaran en el juego
man_menu_init::
    call sys_render_init                ;; Inicializamos el render
    ret







;; Funcion para mostrar los menus y navegar por los mismos
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_menu_run::

    ;; MENU INICIAL
    ;; Pintamos el menu inicial por pantalla
    ld      hl, #_screenmenu_z_end
    call    man_menu_draw_menu_change

_initial_menu:
    call cpct_scanKeyboard_f_asm        ;; Escaneamos el teclado y lo guardamos en el buffer

    ;; Pulsamos SPACE para saltar al menu de historia
    ld      hl, #Key_Space
    call    cpct_isKeyPressed_asm
    jr     nz, _draw_history

    ;; Pulsamos C para visualizar los creditos
    ld      hl, #Key_C
    call    cpct_isKeyPressed_asm
    jr      z, _initial_menu


    ;; MENU DE CREDITOS
    ;; Pintamos por pantalla los creditos
    ld      hl, #_screencredits_z_end
    call    man_menu_draw_menu_change
_credits_menu:

    call cpct_scanKeyboard_f_asm        ;; Escaneamos el teclado y lo guardamos en el buffer
    ;; Si se pulsa SPACE volvemos al menu inicial
    ld      hl, #Key_Space
    call    cpct_isKeyPressed_asm
    jr      z, _credits_menu
    jp      man_menu_run


    ;; MENU DE HISTORIA
_draw_history:
    ;; Pintamos por pantalla la historia
    ld      hl, #_screenhistory_z_end
    call    man_menu_draw_menu_change
_history_menu:
    
    call cpct_scanKeyboard_f_asm        ;; Escaneamos el teclado y lo guardamos en el buffer
    ;; Si se pulsa SPACE dibujamos el menu de controles
    ld      hl, #Key_Space
    call    cpct_isKeyPressed_asm
    jr      z, _history_menu


    ;; MENU DE CONTROLES
    ;; Pintamos por pantalla los controles
    ld      hl, #_screencontrols_z_end
    call    man_menu_draw_menu_change
_controls_menu:

    call cpct_scanKeyboard_f_asm        ;; Escaneamos el teclado y lo guardamos en el buffer
    ld      hl, #Key_Space
    call    cpct_isKeyPressed_asm
    jr      z, _controls_menu

    ret







;; Funcion para renderizar una seccion del menu (imagenes comprimidas)
;; INPUT
;;      HL: Array con los bytes de la imagen comprimida
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_menu_draw_menu_change::
    ld      de, #0xFFFF
    call    cpct_zx7b_decrunch_s_asm
    ret








;; Funcion para mostrar el menu de pause y darle dos opciones al usuario
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      A: Opcion pulsada por el usuario (0: Space, 1: E)
man_menu_pause_run::

    call cpct_limpiarPantalla_asm                    ;; Limpiamos la pantalla del nivel primero

    ;; MOSTRAMOS LAS OPCIONES DE MENU
    ;; Mostramos el titulo del menu
    ld hl, #0x000F                              ;; Cargamos en hl el color de las letras
    call cpct_setDrawCharM0_asm                 ;; Llamamos setDraw para asignar el color que hay en hl
    ld iy, #linea_men_ini_0                     ;; Cargamos en IY el valor en asci de la etiqueta linea men_ini_1               
    X = 30
    Y = 40
    ld hl, #0xC000 + 64 * (Y/8)+2048*(Y&7)+X    ;; Calculos necesarios para decir en que parte de la pantalla
    call cpct_drawStringM0_asm                  ;; se van a pintar la lineas de texto que queremos
                             
    ;; Mostramos la opcion de reiniciar nivel
    ld hl, #0x0004
    call cpct_setDrawCharM0_asm
    ld iy, #linea_men_ini_1
    X = 5
    Y = 120
    ld hl, #0xC000 + 64 * (Y/8)+2048*(Y&7)+X
    call cpct_drawStringM0_asm

    ;; Mostramos la opcion de salir
    ld hl, #0x0004
    call cpct_setDrawCharM0_asm
    ld iy, #linea_men_ini_2
    X = 5
    Y = 160
    ld hl, #0xC000 + 64 * (Y/8)+2048*(Y&7)+X
    call cpct_drawStringM0_asm


    ;; HABILITAMOS LOS INPUTS DEL USUARIO
_pause_menu:
    call cpct_scanKeyboard_f_asm                ;; Escaneamos el teclado y lo guardamos en el buffer

    ;; Opcion para continuar el nivel
    ld      hl, #Key_Space
    call    cpct_isKeyPressed_asm
    jr     nz, _pause_option_Space

    ;; Opcion para salir y volver al menu inicial
    ld      hl, #Key_E
    call    cpct_isKeyPressed_asm
    jr      z, _pause_menu
    ld      a, #1                               ;; Devolvemos la opcion Exit
    ret

_pause_option_Space:
    ld      a, #0                               ;; Devolvemos la opcion Continue
    ret







;; Funcion para mostrar el menu de partida ganada
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
man_menu_win_run::

    ;; MENU FIN DE PARTIDA
    ;; Pintamos por pantalla final
    ld      hl, #_screenwin_z_end
    call    man_menu_draw_menu_change
_win_menu:

    call cpct_scanKeyboard_f_asm        ;; Escaneamos el teclado y lo guardamos en el buffer
    ld      hl, #Key_Space
    call    cpct_isKeyPressed_asm
    jr      z, _win_menu
    ret