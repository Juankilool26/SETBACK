;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.8 #9946 (Linux)
;--------------------------------------------------------
	.module tiles
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _tiles_sp_09
	.globl _tiles_sp_08
	.globl _tiles_sp_07
	.globl _tiles_sp_06
	.globl _tiles_sp_05
	.globl _tiles_sp_04
	.globl _tiles_sp_03
	.globl _tiles_sp_02
	.globl _tiles_sp_01
	.globl _tiles_sp_00
	.globl _tiles_pal
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
_tiles_pal:
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
_tiles_sp_00:
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xcf	; 207
	.db #0xcf	; 207
	.db #0xcf	; 207
	.db #0xda	; 218
	.db #0xf0	; 240
	.db #0xe5	; 229
	.db #0xe5	; 229
	.db #0xf0	; 240
	.db #0xda	; 218
	.db #0xe5	; 229
	.db #0xf0	; 240
	.db #0xcf	; 207
	.db #0xda	; 218
	.db #0xda	; 218
	.db #0xe5	; 229
	.db #0xda	; 218
	.db #0xe5	; 229
	.db #0xcf	; 207
	.db #0xda	; 218
	.db #0xe5	; 229
	.db #0xcf	; 207
	.db #0xf0	; 240
	.db #0xe5	; 229
	.db #0xda	; 218
	.db #0xe5	; 229
	.db #0xe5	; 229
	.db #0xcf	; 207
	.db #0xf0	; 240
	.db #0xda	; 218
	.db #0xe5	; 229
	.db #0xf0	; 240
	.db #0xda	; 218
	.db #0xda	; 218
	.db #0xf0	; 240
	.db #0xe5	; 229
	.db #0xcf	; 207
	.db #0xcf	; 207
	.db #0xcf	; 207
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
	.db #0xf0	; 240
_tiles_sp_01:
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x05	; 5
	.db #0x05	; 5
	.db #0x5b	; 91
	.db #0x0a	; 10
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x05	; 5
	.db #0xf3	; 243
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x5b	; 91
	.db #0xf3	; 243
	.db #0xa7	; 167
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x5b	; 91
	.db #0xf3	; 243
	.db #0xa7	; 167
	.db #0x0a	; 10
	.db #0x0f	; 15
	.db #0x5b	; 91
	.db #0xb2	; 178
	.db #0xf3	; 243
	.db #0x0a	; 10
	.db #0x5b	; 91
	.db #0xf3	; 243
	.db #0xb2	; 178
	.db #0xf3	; 243
	.db #0x0f	; 15
	.db #0x5b	; 91
	.db #0xf3	; 243
	.db #0x30	; 48	'0'
	.db #0x71	; 113	'q'
	.db #0xa7	; 167
	.db #0x05	; 5
	.db #0xb2	; 178
	.db #0x30	; 48	'0'
	.db #0x71	; 113	'q'
	.db #0x0a	; 10
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
_tiles_sp_02:
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x10	; 16
	.db #0x28	; 40
	.db #0x00	; 0
	.db #0x14	; 20
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x3d	; 61
	.db #0x3f	; 63
	.db #0x3e	; 62
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x14	; 20
	.db #0x3f	; 63
	.db #0x28	; 40
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x14	; 20
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x28	; 40
	.db #0x15	; 21
	.db #0x14	; 20
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x3d	; 61
	.db #0x3f	; 63
	.db #0x3e	; 62
	.db #0x20	; 32
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
_tiles_sp_03:
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
	.db #0xc3	; 195
	.db #0x43	; 67	'C'
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
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
	.db #0x03	; 3
_tiles_sp_04:
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x2f	; 47
	.db #0x1f	; 31
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x2f	; 47
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x1f	; 31
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x5f	; 95
	.db #0xff	; 255
	.db #0x0f	; 15
	.db #0x0a	; 10
	.db #0x00	; 0
	.db #0x2a	; 42
	.db #0x55	; 85	'U'
	.db #0xaf	; 175
	.db #0x00	; 0
	.db #0x0a	; 10
	.db #0x0a	; 10
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0x5f	; 95
	.db #0xff	; 255
	.db #0xaf	; 175
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0f	; 15
_tiles_sp_05:
	.db #0x2f	; 47
	.db #0x1f	; 31
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x1f	; 31
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0x2f	; 47
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0xff	; 255
	.db #0xaf	; 175
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x5f	; 95
	.db #0xaa	; 170
	.db #0x15	; 21
	.db #0x00	; 0
	.db #0x0a	; 10
	.db #0x7f	; 127
	.db #0xaa	; 170
	.db #0x05	; 5
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0x5f	; 95
	.db #0xff	; 255
	.db #0xaf	; 175
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x00	; 0
	.db #0x0a	; 10
	.db #0x05	; 5
	.db #0x0f	; 15
	.db #0x0f	; 15
	.db #0x00	; 0
	.db #0x0f	; 15
	.db #0x0f	; 15
_tiles_sp_06:
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x3e	; 62
	.db #0x3d	; 61
	.db #0x28	; 40
	.db #0x14	; 20
	.db #0x3e	; 62
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3d	; 61
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x7d	; 125
	.db #0xff	; 255
	.db #0x3c	; 60
	.db #0x28	; 40
	.db #0x00	; 0
	.db #0x2a	; 42
	.db #0x55	; 85	'U'
	.db #0xbe	; 190
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x28	; 40
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x14	; 20
	.db #0x3c	; 60
	.db #0x7d	; 125
	.db #0xff	; 255
	.db #0xbe	; 190
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x14	; 20
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x14	; 20
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x3c	; 60
_tiles_sp_07:
	.db #0x3e	; 62
	.db #0x3d	; 61
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3d	; 61
	.db #0x28	; 40
	.db #0x14	; 20
	.db #0x3c	; 60
	.db #0x3e	; 62
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x14	; 20
	.db #0x3c	; 60
	.db #0xff	; 255
	.db #0xbe	; 190
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x7d	; 125
	.db #0xaa	; 170
	.db #0x15	; 21
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x7f	; 127
	.db #0xaa	; 170
	.db #0x14	; 20
	.db #0x14	; 20
	.db #0x3c	; 60
	.db #0x7d	; 125
	.db #0xff	; 255
	.db #0xbe	; 190
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x14	; 20
	.db #0x00	; 0
	.db #0x28	; 40
	.db #0x14	; 20
	.db #0x3c	; 60
	.db #0x3c	; 60
	.db #0x00	; 0
	.db #0x3c	; 60
	.db #0x3c	; 60
_tiles_sp_08:
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x3a	; 58
	.db #0x35	; 53	'5'
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x3a	; 58
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x35	; 53	'5'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x75	; 117	'u'
	.db #0xff	; 255
	.db #0x30	; 48	'0'
	.db #0x20	; 32
	.db #0x00	; 0
	.db #0x2a	; 42
	.db #0x55	; 85	'U'
	.db #0xba	; 186
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x20	; 32
	.db #0x55	; 85	'U'
	.db #0xbf	; 191
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0x75	; 117	'u'
	.db #0xff	; 255
	.db #0xba	; 186
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
_tiles_sp_09:
	.db #0x3a	; 58
	.db #0x35	; 53	'5'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x35	; 53	'5'
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0x3a	; 58
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0xff	; 255
	.db #0xba	; 186
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x75	; 117	'u'
	.db #0xaa	; 170
	.db #0x15	; 21
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x7f	; 127
	.db #0xaa	; 170
	.db #0x10	; 16
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0x75	; 117	'u'
	.db #0xff	; 255
	.db #0xba	; 186
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x00	; 0
	.db #0x20	; 32
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.area _INITIALIZER
	.area _CABS (ABS)
