; checksum.asm
;
;  Exercises:
;  1. What are the value of the two bytes of the sum (in hexa)?
;  2. After summing the range of bytes into a 16-bit variable and
;     before the MainLoop, implement and call the function XorBytes8
;     to XOR the range of bytes into an 8-bit variable in WRAM.
;     Follow a similar format for the inputs and outputs of the
;     function. What is the value of the result (in hexa)?
;  3. What happens if you comment out (or delete) the line
;     "SECTION "Functions", ROM0"? Look at the ROM tab.

INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0

EntryPoint:
  ld de, Array
  ld b, Array.end - Array

  call SumBytes16 ; returns sum in DE

  ; store 16-bit sum in WRAM
  ld a, l
  ld [sum_lo],a
  ld a, h
  ld [sum_hi],a

MainLoop:
  jp MainLoop

SECTION "Functions", ROM0
SumBytes16:
;  input:  DE = array, B = length
;  output: HL = sum of [DE..(DE+B-1)]
    ld   hl, 0
.loop:
    push bc
    ld   a, [de]
    inc  de
    ld   b, 0
    ld   c, a
    add  hl,bc
    pop  bc
    dec  b
    jp   nz, .loop
    ret

XorBytes8:
    ; TODO
    ret

SECTION "Data", ROM0
Array:
  db  $DE, $CA, $FB, $AD, $F0, $CA, $CC, $1A
.end:

SECTION "Variables", WRAM0
sum_lo: ds 1
sum_hi: ds 1
