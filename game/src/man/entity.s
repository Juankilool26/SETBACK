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

.include "cpctelera_functions.h.s"
.include "entity.h.s"
.include "sys/render.h.s"
.include "cpctelera.h.s"




;; CONSTANTES
max_entities == 40         ; Maximo de entidades a crear







;; Inicializa el array de entidades, el puntero al mismo y su contador
;; INPUT
;;      0
;; DESTROY
;;      0
;; RETURN
;;      0
man_entity_init::

    _num_entities:: .db 0                               ; Declaramos el numero de entidades

    DefineEntityArray _entity_array, max_entities       ; Creamos el array de entidades
    _last_elem_ptr:: .dw _entity_array                  ; Puntero a la ultima entidad libre
    ret








;; Devuelve el jugador que por defecto sera la primera entidad del array
;; INPUT
;;      0
;; DESTROY
;;      IX
;; RETURN
;;      IX: Puntero a la entidad del jugador
man_entity_getPlayer_IX::
    ld      ix, #_entity_array
    ret






;; Devuelve la entidad especificada mediante un indice que indica su posicion en el array
;; INPUT
;;      A: Indice del array
;; DESTROY
;;      A, BC, IY
;; RETURN
;;      IY: Puntero a la entidad asociada al indice
man_entity_get_from_idx_IY::
    inc     a
    ld      iy, #_entity_array                      ; Cargamos en A el puntero al inicio del array
    ld      bc, #sizeof_e
_getter_loop:
    dec      a                                      ; Siguiente iteración del bucle
    ret      z
    add     iy, bc                                  ; Pasamos a la siguiente entidad
    jr      _getter_loop

  ret







;; Crea una nueva entidad y la introduce en el array de entidades
;; INPUT
;;      HL: Puntero a los bytes de inicializacion
;; DESTROY
;;      A, HL, BC, DE, IX
;; RETURN
;;      A:  Numero de entidades totales
;;      HL: Puntero a la primera entidad libre del array 
man_entity_create::
    
    ld     de, (_last_elem_ptr)
    ld     bc, #sizeof_e
    ldir    ;; Copia lo que hay en HL en la posicion
            ;; DE y copia tantos bytes como diga BC

    ;; El puntero anterior apunta a la misma posicion (e_lastPtr != 0xC000)
    ;; Las fisicas actualizan el puntero a la posicion anterior, pero no es necesario para entidades estaticas
    ld     iy, (_last_elem_ptr) ;; Movemos la entidad creada al registro desplazable IX
    call    man_entity_calculate_screen_position
    
    ;; Aumentamos el numero de entidades
    ld      a, (_num_entities)
    inc     a
    ld      (_num_entities), a

    ;; Actualizamos el puntero a la siguiente entidad
    ld     hl, (_last_elem_ptr)
    ld     bc, #sizeof_e
    add    hl, bc
    ld     (_last_elem_ptr), hl

    ret









;; Calcula el puntero en memoria de video de la posicion actual de la entidad
;; INPUT
;;      IX: Puntero a la entidad deseada
;; DESTROY
;;      HL, BC, DE, IX
;; RETURN
;;      HL: Puntero a la posicion en memoria de video calculada 
man_entity_calculate_screen_position::
    ld     de, #0xC000            ;; DE = Pointer to start of the screen
    ld      c, e_x(iy)            ;; x
    ld      b, e_y(iy)            ;; y
    call   cpct_getScreenPtr_asm
    ld     e_lastPtr+1(iy), h
    ld     e_lastPtr  (iy), l
    ret










;; Destruye la entidad pasada por parametro y libera su memoria
;; INPUT
;;      IY: Puntero a la entidad a eliminar
;; DESTROY
;;      A, BC, IX, HL
;; RETURN
;;      0
;man_entity_destroy::
;
;    ;; Actualiza la primera entidad libre a la anterior viva
;    ld      hl, (_last_elem_ptr)                ; HL = Ultima entidad libre
;    ld      bc, #-sizeof_e                      ;
;    add     hl, bc                              ;
;    ld      (_last_elem_ptr), hl                ; HL = Ultima entidad viva
;
;    ;; Comprueba si las dos entidades son iguales (e1 = e2 -> No copiar)
;    ld__a_iyl                                   ; Instrucciones no documentadas
;    sub     l
;    jr     nz, _copy
;    ld__a_iyh
;    sub     h
;    jr      z, _nocopy
;_copy:
;    
;    ;; Copia la ultima entidad en el array para borrar la entidad muerta
;    ld__e_iyl                                   ; DE = IX
;    ld__d_iyh
;    ld      bc, #sizeof_e                       ; BC = sizeof_e
;    ldir                                        ; Copia la ultima entidad a la invalida
;    ld      hl, (_last_elem_ptr)
;_nocopy:
;    ld      (hl), #e_type_invalid
;
;    ret







;; Recorre el array de entidades para actualizar cada una de ellas
;; INPUT
;;      HL: Rutina update a ejecutar de un sistema
;; DESTROY
;;      A, BC, IX, HL
;; RETURN
;;      IY: Puntero a la primera entidad libre
man_entity_update_forall::
    ld      (_to_call), hl                  ; Guardamos en memoria automodificable la funcion
    ld      iy, #_entity_array              ; Primera entidad del array

_next_entity:
    ld      a, (iy)                         ; Solo para entidades vivas
    or      a                               ; OR para comprobar si la entidad esta muerta
    ret     z                               ; Si no es 0, comprobamos si es invalida

_to_call = . + 1                            ; Codigo automodificable
    call    _to_call                        ; Llamamos a la funcion pasada por parametro

    ld     bc, #sizeof_e                    ; Guardamos en BC el tamano de una entidad
    add    iy, bc
    jr      _next_entity

;man_entity_update_forall::
;
;    ld      a, (_num_entities)              ; Cargamos en A el numero de entidades
;    ld     ix, #_entity_array               ; Guardamos en IX el puntero a la primera entidad
;
;_updloop:
;
;    push    af                              ; Guardamos en la pila el contador de entidades
;
;    ld     bc, #_next_it_loop               ; Guardamos en BC la siguiente iteracion del bucle
;    push   bc                               ; y lo ponemos en la primera posicion de la pila
;    jp    (iy)                              ; Saltamos a la rutina a la que apunta HL (WARNING: Destruye A y HL)
;
;_next_it_loop:
;    pop     af                              ; Recuperamos de la pila el contador de entidades
;    dec     a                               ; Decrementamos el contador de entidades
;    ret     z                               ; Terminamos el bucle si el contador llega a 0
;
;_next_it:
;    ld     bc, #sizeof_e                    ; Guardamos en BC el tamano de una entidad
;    add    ix, bc                           ; IX apunta a la siguiente entidad
;    jr      _updloop                        ; Siguiente iteracion






;; Recorre el array de entidades para actualizar cada una de ellas que tengan unos componentes en especifico
;; INPUT
;;      HL: Rutina update a ejecutar de un sistema
;;       A: Tipo de signatura para ejecutar la funcion
;;       D: Indicador para entidades de fondo
;; DESTROY
;;      A, BC, IX, HL
;; RETURN
;;      IY: Puntero a la primera entidad libre
man_entity_update_forall_matching::
    ld      (_fam_to_call),   hl            ; Guardamos en memoria automodificable la funcion
    ld      (_fam_type_sign),  a            ; Guardamos en memoria automodificable los signos de los tipos a funcionar
    ld      iy, #_entity_array              ; Primera entidad del array, el player
    jr      _fam_not_matching               ; Actualizamos todas las entidades menos la del jugador que se realiza aparte

_fam_next_entity:
    ld      a, (iy)                         ; Solo para entidades vivas
    or      a
    ret     z
    
_fam_type_sign = . + 1                      ; Referencia lo que se ha pasado en A en la siguiente instruccion
    ;; Solo se ejecuta el update para aquellas entidades que coincidan al menos con alguna mascara
    ld      b, #00                          ; El valor pasado A queda guardado en B (en la instruccion se refiere a "#00")
    ld      c, (iy)                         ; B = copia del tipo de la entidad
    or      b                               ; OR para comprobar si la mascara produce un cambio en el tipo
    sub     c                               ; Le restamos el valor inicial del tipo de la entidad (e_new_type - e_type)
    jr     nz, _fam_not_matching

; Esto funciona para actualizar unicamente las que coinciden exactamente con la mascara
;    ld      b, #00                          ; El valor pasado A queda guardado en B (en la instruccion se refiere a "#00")
;    and     b                               ; Operacion AND entre A y B (tipo y mascara)
;    sub     b                               ; Le restamos de nuevo B
;    jr     nz, _fam_not_matching            ; if = 0 -> type = mask

    ;; Si la entidad es valida
_fam_to_call = . + 1                        ; Codigo automodificable
    call    _fam_to_call                    ; Llamamos a la funcion pasada por parametro

_fam_not_matching:
    ld     bc, #sizeof_e                    ; Guardamos en BC el tamano de una entidad
    add    iy, bc
    jr     _fam_next_entity








;; Invalida una entidad para dejarla lista para borrarla
;; INPUT
;;      IY: Puntera a la entidad a invalidar
;; DESTROY
;;      0
;; RETURN
;;      0
man_entity_set4destruction::
    ld      e_type(iy), #(e_type_dead_mask | e_type_render_mask)
    ret









;; Invalida una entidad para dejarla lista para borrarla
;; INPUT
;;      IY: Puntera a la entidad a invalidar
;; DESTROY
;;      0
;; RETURN
;;      0
man_entity_destroy_one::
    ld      e_type(iy), #e_type_invalid
    ret







;; Reinicia los valores del manager de entidades, puntero a ultima posicion libre y contador de entidades
;; INPUT
;;      0
;; DESTROY
;;      0
;; RETURN
;;      0
man_entity_empty_array::
    ld      a, #0
    ld      (_num_entities), a              ; Contador de entidades a 0
    ld      hl, #_entity_array              ; Puntero a la primera posicion del array
    ld      (_last_elem_ptr), hl
    ret