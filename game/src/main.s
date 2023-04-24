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

;; Include all CPCtelera constant definitions, macros and variables
.include "cpctelera.h.s"
.include "cpctelera_functions.h.s"
.include "man/menu.h.s"
.include "man/game.h.s"
.include "man/interrupcion.h.s"





.area _DATA
.area _CODE



_main::
   ;; Ahora utilizamos esto en vez de disble firmware porque ese trozo de line de codigo
   ;; autoactualizable llama a una funcion personalizada del manager de interrupciones
   call set_int_handler
   
   
_reset:
   ;; Pintamos del color de fondo toda la pantalla
   call cpct_limpiarPantalla_asm

   ;; Llamamos a load menu song del manager de interrupciones
   call man_int_load_menu_song

   ;; Ejecutamos el menu del juego
   call man_menu_init   
   call man_menu_run

   ;; Paramos la ejecucion de la musica del menu
   call cpct_akp_stop_asm

   ;; Llamamos a load ingame song del manager de interrupciones   
   call man_int_load_ingame_song
   
   ;; Comproabamos en que partida vamos a comenzar el juego desde el principio
   call man_game_getNumGames_A
   or    a
   jr   nz, _main_restart_game
   call man_game_init                        ; Iniciamos el juego desde el inicio
   jr    loop                                ; Comenzamos bucle

_main_restart_game:
   call man_game_restart                     ; Iniciamos el juego desde el inicio



loop:



   ;; Actualizamos el juego
   call man_game_run



   ;; Comprobamos si nos hemos pasado todos los niveles
   ld       b, a
   ld       a, #_total_levels
   sub      b
   jr      nc, _continue_all_game1
   call     man_menu_win_run                  ; Ejecutamos el menu de fin de juego
   jr       _reset
_continue_all_game1:



   ;; Le posibilitamos al jugador salir del juego
   call     cpct_scanKeyboard_f_asm
   ld      hl, #Key_Esc
   call     cpct_isKeyPressed_asm
   jr       z, _continue_all_game2           ; Menu de pause
   call     man_menu_pause_run               ; Return input option
   or       a
   jr       z, _continue_pause_menu
   call     man_game_next_play               ; Pasamos a la siguiente partida
   jr       _reset                           ; Reseteamos el juego
_continue_pause_menu:
   call     man_game_continue_level          ; Continuamos por el nivel donde estabamos
_continue_all_game2:



   ;; Controlamos la activacion y desactivacion de la señal vsync
   .rept 2
      halt
      halt
      call cpct_waitVSYNC_asm
   .endm

   jr loop








;; Funcion para limpiar toda la pantalla
;; INPUT
;;      0
;; DESTROY
;;      ALL
;; RETURN
;;      0
cpct_limpiarPantalla_asm::
   ld    hl, #0xC000    ;; [3] HL Points to Start of Video Memory
   ld    de, #0xC001    ;; [3] DE Points to the next byte
   ld    bc, #0x4000    ;; [3] BC = 16384 bytes to be copied
   ld   (hl), #0      ;; [3] First Byte = given Colour
   ldir 
ret









;; Funcion para pausar el juego mediante interrupciones
;; INPUT
;;      A: Cantidad de interrupciones a ejecutar
;; DESTROY
;;      ALL
;; RETURN
;;      0
cpct_interrupt_flow::

_pause_game:
   halt
   dec     a
   jr     nz, _pause_game
   ret
