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
;; MANAGER DE INTERRUPCIONES
;;
.include "cpctelera.h.s"
.include "cpctelera_functions.h.s"
.include "assets/assets.h.s"


velocidad_min_musica: .db 06

;; Funcion que controla paralela al bucle de game que se reproduzca la musica con una tasa 
;; de 50Hz
int_handler::

   ;; Conservamos todos los registros ya que la funcion cpct_akp_musicPlay_asm se carga literalmente
   ;; todos ademas de los primos de cada registro
   push af
   push bc
   push de
   push hl

   ld   a, (velocidad_min_musica)
   dec  a
   jr  nz, _cont
_zero:
   call cpct_akp_musicPlay_asm
   ld   a, #6
_cont:
   ld    (velocidad_min_musica), a

   pop hl
   pop de
   pop bc
   pop af

   ei
   reti

;; Interrupcion personalizada que se mete en la direccion de memoria a continuacion del #0x0038
set_int_handler::
   ld     hl, #0x38
   ld   (hl), #0xC3
   inc    hl
   ld   (hl), #<int_handler
   inc    hl
   ld   (hl), #>int_handler
   inc    hl
   ld   (hl), #0xC9
   ret

;; Cargamos en DE la etiqueta correspondiente a la cancion de menu y la inicializamos
man_int_load_menu_song::

   ;; INPUT: DE to the start of songdata array
   ld de, #_song_menu
   call cpct_akp_musicInit_asm

   ret
;; Cargamos en DE la etiqueta correspondiente a la cancion de ingame y la inicializamos
man_int_load_ingame_song::

   ;; INPUT: DE to the start of songdata array
   ld de, #_song_ingame
   call cpct_akp_musicInit_asm

   ret