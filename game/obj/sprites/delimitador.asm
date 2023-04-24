;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module delimitador
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _delimitador_sp_1
	.globl _delimitador_sp_0
	.globl _demitador_pal
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
_demitador_pal:
	.db #0x54	; 84	'T'
	.db #0x44	; 68	'D'
	.db #0x55	; 85	'U'
	.db #0x5c	; 92
	.db #0x4c	; 76	'L'
	.db #0x56	; 86	'V'
	.db #0x57	; 87	'W'
	.db #0x5e	; 94
	.db #0x40	; 64
	.db #0x5f	; 95
	.db #0x4e	; 78	'N'
	.db #0x52	; 82	'R'
	.db #0x53	; 83	'S'
	.db #0x4a	; 74	'J'
	.db #0x43	; 67	'C'
	.db #0x4b	; 75	'K'
_delimitador_sp_0:
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
_delimitador_sp_1:
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x03	; 3
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0x83	; 131
	.db #0x83	; 131
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x43	; 67	'C'
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0xc3	; 195
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.area _INITIALIZER
	.area _CABS (ABS)
