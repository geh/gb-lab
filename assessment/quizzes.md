# GB Lab: In-class Quizzes and Clickers

## Lecture 1: Integer Representation

1. What is the hexadecimal representation of the binary number `10101111` ?

a. AF
b. A9
c. B1

2. What is the decimal equivalent of the hexadecimal number `1E`?

a. 30
b. 28
c. 16

3. What is the largest value that can be represented with an 8-bit
   binary number in the unsigned interpretation?

a. 255
b. 256
c. 127
d. 128

4. What is the binary representation of `-1` in a 8-bit system?

a. 11111111
b. 10000000
c. 00000001

5. What is the result of adding `1100` and `1010` as 4-bit two's complement numbers?

a. Overflow occurs
b. No overflow occurs

## Lab Quiz 1

1. Here is a C language statement `"d = (a + b + c)"`. Its closest assembly equivalent is:

a. add b ; add c ; ld d,a
b. add a; add b; ld d,c
c. ld d,a ; add a ; add b ; add c

2. The previous sequence of instructions is not completely equivalent to the C statement, this is because it destroys the value of:

a. A
b. B
c. C

3. After executing `XOR A` what is the value stored in register A?

a. 0
b. -1
c. 1

## Lab Quiz 3

1. What is the result of the instruction INC HL when HL = $FFFF?

a. HL = $0000
b. HL = $00FF
c. HL = $FF00

2. What will the instruction LD A, ($1234) do?

a. Load the contents of memory address $1234 into register A
b. Load the immediate value $1234 into register A
c. Store the contents of A at memory address $1234


3. In which case the instructions `DEC BC` and `DEC C` have the same effect on registers B and C?

a. When C != 0
b. When C == 0
c. When B != 0
d. When B == 0


## Lab Quiz 4

1. In the following code:

~~~
  ld a,2
loop2:
  ld b,10
loop1:
  [do something]
  dec b
  jp nz, loop1
  dec a
  jp nz, loop2
~~~

How many times is the `[do something]` part repeated?

a. 20
b. 12
c. 10

2. In the following code:

~~~
LD HL, $1234
PUSH HL
LD HL, $5678
POP HL
~~~

What is the value of HL after execution?

a. $1234
b. $5678

3. What is in registers BC and DE after the following code executes?

~~~
LD BC, $1234
PUSH BC
LD DE, $5678
PUSH DE
POP BC
POP DE
~~~

a. `BC = $5678, DE = $1234`
b. `BC = $1234, DE = $5678`
c. `BC = $0000, DE = $0000`

## Lab Quiz 5

~~~
; inputs:
;     HL: array
;     B: size of array
;     C: value to find
; output:
;     A = index of value if found
;     A = -1 otherwise

find:
    ld d,0
.loop:
    ld a,[hl]
    cp c
    jp z, ??    ; [1]
    inc hl
    inc ??      ; [2]
    dec b
    ??          ; [3]
.not_found:
    ld a,-1
    ret
.found:
    ld a,d
    ret
~~~

1. What label should be at `[1]`?

a. `.found`
b. `.not_found`
c. `.loop`

2. At `[2]`?

a. `inc d`
b. `inc c`
c. `inc a`
d. `inc b`

3. At `[3]`?

a. `jp nz, .loop`
b. `jp nz, .found`
c. `jp z, .found`
d. `jp z, .loop`

## Functions Quiz

1. Execution starts at main: and arrives at the NOP instruction, what is the value of register A?

~~~
main:
  ld a,50
  ld b,100
  call fun
  nop
  ...

fun:
  add 10
  ret
~~~

a. A==60
b. A==50
c. A==100

2. Same question:

~~~
main:
  ld a,30
  ld b,50
  call fun
  nop
  ...

function:
  ld b,30
  cp b
  ret z
  ld a,40
  ret
~~~

a. A==30
b. A==40
c. A==50

3. The function maxbc must return the max of registers b and c in register a:

~~~
maxbc:
  ld a,b
  cp c
  [........]
  ld a,c
  ret
~~~

Select the correct missing instruction:

a. `ret nc`
b. `ret c`



## OAM Quiz

1. How many objects can the OAM hold?

a. 40
b. 160

2. What does the first byte written to OAM (`_OAMRAM`) control?

a. The object's Y coordinate
b. The object's X coordinate 
c. The objects's tile number.

3. In the program, what do we achieve by writing zeros in ResetOAM?

a. We hide all objects by moving them off-screen
b. We move all objects to the top left corner of the screen.

4. To be used by the PPU, tile data must be in:

a. VRAM
b. RAM
c. ROM

## Random Walk Quiz

1. The `RandomByte` function contains the following sequence of instructions.

~~~
ld a,[rDIV]
xor b
xor l
xor [hl]
~~~

In which register or memory location is that "random byte" returned to the caller?

a. `A`
b. `B`
c. `L`
d. `[HL]`

2. In the "random walk" program, why did we use ShadowOAM?

a. To update objects coordinates without using VBlank time
b. To improve the quality of random bytes generation

3. How many rows does the Game Boy screen have

a. 144
b. 160
c. 154

4. What is the range of values of [rLY]?

a. 0 to 153
b. 0 to 143
c. 0 to 159

5. For which values of [rLY] are we in VBlank?

a. 144 to 153
b. 0 to 10
c. 0 to 143

## Background Lab

1. How many tiles are needed to implement the random walk + coordinates program?

Answer: 17 (1 for the random walk tile, 16 for the hexadecimal digits).

2. In the "Fog of War" exercise, during which phase of the frame should the background tilemap be updated to reveal tiles?

a. In the main loop, during VBlank only
b. During the initialization before the main loop
c. In the main loop, outside VBlank

3. If an object has screen coordinates `(Y=50, X=70)`, what is the formula to calculate the
   corresponding background tilemap address in `TILEMAP0`?

a. `TILEMAP0 + ((Y-16)/8)*32 + ((X-8)/8)`
b. `TILEMAP0 + Y*32 + X`
c. `TILEMAP0 + (Y/8)*32 + (X/8)`

## Lab Quiz 10

1. What does the instruction `JP HL` do?

a. jump to the address stored in HL
b. jump to the address stored in [HL]
c. push HL onto the stack and continues

2. How many bytes does each entry in a jumptable occupy?

a. 2
b. 1


