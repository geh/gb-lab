# Exam MCQs

## Number Representation

1. What is the 8-bit two's complement representation of `-18`?

    a. `11101110`
    b. `10010010`
    c. `11101100`

2. Which of the following operations causes overflow in 4-bit two's complement addition?

    a. `0110 + 0101`
    b. `1001 + 0110`
    c. `0010 + 0011`


3. A 4-bit unsigned value `1001` is extended to 8 bits. Choose the result that preserves its value.

    a. `00001001`
    b. `10010000`
    c. `11111001`
    d. `00011001`

4. Consider the following 16-bit word: `$7FFF`. It is:

a. The maximum 16-bit two's complement value.
b. The maximum 16-bit unsigned value.
c. The minimum 16-bit two's complement value.
d. The minimum 16-bit unsigned value

5. A program stores the decimal value `-128` in an 8-bit signed two's complement variable.
   When this value is later interpreted as an unsigned 8-bit integer by a different part
   of the program, what decimal value will it be read as?

a. 128
b. 255
c. 0


6. Consider the following C snippet:

~~~C
for (unsigned char i = 99; i >= 0; --i) {
  /* some code without break */
}
~~~

How many times does the loop repeat?

a. Infinitely many
b. 99
d. 256


7. A programmer writes the following C code:

~~~C
signed char x = 100;
signed char y = 50;
signed char z = x + y;
~~~

What is the value of z after execution? Does overflow occur?

a. z = -106, overflow occurred
b. z = -106, no overflow
c. z = 150, overflow occurred
d. z = 150, no overflow

8. What is the vector of 16 bits who has the smallest value in
   the two's complement interpretation? In hexadecimal.

a. `$8000`
b. `$7FFF`
c. `$FFFF`

9. Consider the following 32-bit word: `$FFFFFFFF`. It is:

a. The maximum 32-bit unsigned value.
b. The maximum 32-bit two's complement value.
c. The minimum 32-bit two's complement value.
d. The minimum 32-bit unsigned value


## SM83 Assembly Programming

10. The following snippet is executed, with an unknown
initial value of register A:

~~~asm
and %00000001
dec a
~~~

What are the possible final values of register A
(in hexadecimal)?

a. 00 or FF
b. 00 or 01
c. 01 or FF

11. Consider the following sequencing of a GBz80 instruction:

~~~
; FETCH: IR := [PC]; PC = PC + 1
; MEM0:  Z :=[SP]
; ALU:   SP := SP + 1
; MEM1:  W :=[SP]
; ALU2:  SP := SP + 1
; JUMP:  PC := WZ
~~~

The instruction is:

a. RET
b. CALL
c. JP

12. A student attempts to compute the XOR of the two nibbles
    in the A register (i.e., `A[3:0] XOR A[7:4]`) and store
    the result back in A. They wrote this snippet:

~~~
swap a
xor a
~~~

What is the actual result of this code?

a. A is always 0
b. Both nibbles of A become `A[3:0] XOR A[7:4]`
c. The lower nibble of A becomes `A[3:0] XOR A[7:4]` and the upper nibble is set to 0

13. The following snippet is executed:

~~~
SECTION "Function", ROM0[$3000]
.snippet:
  ld hl, .snippet
  ld a, [hl]
~~~

What is the final value of A in hexadecimal?
   
a. 21
b. 30
c. 00
d. 7E


14. Consider these two functions in RGBASM syntax:

~~~
copy_loop:
  LD B, 100
.loop:
  LD A,[HL+]
  LD [DE],A
  INC DE
  DEC B
  JR NZ, .loop
  RET

copy_rept:
REPT 100
  LD A,[HL+]
  LD [DE],A
  INC DE
ENDR
  RET
~~~

What is the effect of replacing `copy_loop` with `copy_rept`?

a. Execution time decreases and ROM usage increases.
b. Execution time decreases and ROM usage decreases.
c. Execution time increases and ROM usage increases.
d. Execution time increases and ROM usage decreases.

15. What is the final value of `HL` in the following snippet?
All numbers are given in decimal.

~~~
LD  HL,1000
LD  B,2
LD  C,2
ADD HL,BC
~~~

    a. 1514
    b. 1022
    c. 1202
    d. 514

16. Consider the following code snippet:

~~~
.loop:
  LD   A, [DE]
  LD   [HL+], A
  INC  DE
  DEC  B
  JR   NZ, .loop
  RET
~~~

If the initial value of B is 0, what is the total number of clock cycles of this snippet?

    a. 10252
    b. 10256
    c. 52
    d. 56

17. Consider the following snippet:

~~~
SECTION "Main", ROM0[$1000]
main: DEC A
      ADD B
      jp main
~~~

What is the sequence of bytes produced by the assembler from this section?

    a. 3D 80 C3 00 10
    b. 3D 80 C3 10 00
    c. 3D 80 C3 01 10
    d. 3D 80 C3 10 01

18. The following snippet's control flow can be simplified:

~~~
  [some code]
  JR Z, .label
  RET
.label:
  [more code]
~~~

It is correct to replace the `JR Z,.label` and `RET` instructions by:

    a. RET NZ
    b. RET Z
    c. CALL Z, .label
    d. CALL NZ, .label

19. We have a problem in the following snippet:

~~~
Foo:
  LD A, [variable]
  CP 6
  CALL z, doThis
  CP 7
  CALL z, doThat
  [more code]
~~~

The problem is, if `doThis` is called, it may modify *something*
so then `doThat` may be called too in the same call to `Foo`.
What is this *something*?

a. the register A
b. the flags
c. the value at memory location `variable`

20. Consider this function is called:

~~~
Function:
  CALL .label
.label:
  POP HL
  JP HL
~~~

What will happen?

a. Return to the calling environment of `Function`.
b. Jump to some unknown location.
c. Enter an infinite loop.

21. In the following snippet, what are the values of registers A and B after its execution?

~~~
LD   A,1
LD   B,2
LD   C,A
ADD  B
ADD  C
INC  BC
~~~

a. A==4, B==2
b. A==4, B==3
c. A==1, B==2
d. A==1, B==3

22. Convert the following sequence of bytes into a sequence of instructions.

~~~
AF 47 4F 2A 81 30 01 04 4F 15 20 F7 C9
~~~

This code contains a loop. The number of repeats of the loop depends on the value of
register:

a. D
b. B
c. C
d. A

23. 20. Consider the following code snippet:

~~~
.loop:
  LD   A, [DE]
  LD   [HL+], A
  INC  DE
  DEC  BC
  LD   A, B
  OR   C
  JR   NZ, .loop
  RET
~~~

Assuming BC > 0, what is the total number of cycles of this code, expressed as a function of BC ?

    a. 52 * BC + 12
    b. 52 * BC + 16
    c. 48 * BC + 16
    d. 48 * BC + 12
    e. 44 * BC + 16
    f. 44 * BC + 12

24. Variables should be declared as labels in:

    a. Work RAM
    b. Video RAM
    c. ROM

25. Which of the following instructions takes the most cycles to execute?

    a. CALL label
    b. LD A, B
    c. NOP

26. A label "variable" is defined to some memory address.
    The smallest sequence of instructions (in total size of instructions in bytes) to test if
    that value is zero, jump to label ".zero" is:

    a. `LD A,[variable] :: OR A :: JP Z, .zero`
    b. `LD HL,variable  :: OR [HL] :: JP Z, .zero`
    c. `LD A,[variable] :: OR 0 :: JP Z, .zero`

## Completing a Checksum Function

27. Consider this function that computes the XOR checksum of an array:

Calling environment:

~~~asm
EntryPoint:
  ld hl, Array             ; beginning of the array
  ld bc, Array.end - Array ; size of the array

  call XorArray

  ld [checksum],a
~~~

The incomplete function code is:

~~~
XorArray:
  ld d,0
.loop:
  ; [missing #1]
  inc hl
  ; [missing #2]
  ld a,b
  ; [missing #3]
  jr nz, .loop
  ; [missing #4]
  ret
~~~

Choose the correct missing instruction(s) `#1`.
(The `::` syntax allows to write several instructions in a single line.)

a. `ld a,d :: xor [hl] :: ld d,a`
b. `xor [hl]`
c. `ld a,[hl+] :: xor d :: ld d,a`

28. Choose the correct missing instruction(s) `#2`.

a. `dec bc`
b. `dec b`
c. `dec c`
d. `dec b :: dec c`

29. Choose the correct missing instruction `#3`.

a. `or c`
b. `or b`
c. `or a`
d. `or d`

30.  Choose the correct missing instruction `#4`.

a. `ld a,d`
b. `xor d`
c. `xor [hl]`
d. `ld a,[hl]`

## More Questions

31. The following snippet is executed:

~~~
  LD A, 10
  CALL .label
  CALL .label
.label:
  ADD A,A
  RET
~~~

   What is the final value of A?

   a. 80
   b. 20
   c. 40
   d. 10

32. Consider the following sequence of bytes in hexadecimal,
    generated by RGBASM from a function's source code.

~~~
C5 06 FA B7 05 20 FC C1 C9
~~~

How many cycles does that function last when executed? Do not
take the `call` to the function into account, but do take the `ret`
of the function into account.

a. 5048 cycles
b. 4052 cycles
c. Infinitely many cycles


33. The following function computes the division of register A
    by 10. What is the missing instruction `XXXX`?

~~~asm
DivBy10:
  ld b,0
.loop:
  XXXX
  jr c, .done
  sub 10
  inc b
  jr .loop
.done:
  ret
~~~

a. cp 10
b. add 10
c. cp b
d. add b

34. Consider the snippet:

~~~asm
Start:
  ld a, [hl]
  cp SOME_CONSTANT
  call z, .X
  call nz, .Y
.Z:
  [some code]
  ret
.X:
  [code without jump or call]
  ret
.Y:
  [code without jump or call]
  ret
~~~

Execution starts at label `Start`.
In which case will the code at label `.Z` be executed?

a. always
b. only if `.X` is called
c. only if `.Z` is called
d. never

35. Consider the following snippet.

~~~
ClearHL:
        ld b, 100
        ld a, 0
.loop:
        ld [hl+], a
        dec b
        jr nz,.loop
~~~

What is the total number of cycles of this code?

a. 2412
b. 2416
c. 2016
d. 2012
e. 2408
f. 2008

36. Assume register `A` contains value `$00`. After a `DEC A` instruction, A contains value:

a. $FF
b. $F0
c. $7F
d. $0F
e. $70

37. The following sequence of bytes encodes a function whose parameters are stored
    in registers A and B. What operation does it implement?

~~~
26 00 6F 29 05 20 FC C9
~~~

a. a * (2^b)
b. a * b
c. a ^ b
d. a + b^2
e. (2 * a) + b

(Note: function is: LD H,0; LD L,A ; ADD HL,HL; DEC B; JR NZ, -4; RET)

38. The following sequence of bytes encodes a function whose parameters are stored
    in registers A and B. What operation does it implement?

~~~
48 80 0D 20 FC 06 00 C9
~~~

a. a + b^2
b. a * (2^b)
c. a * b
d. a ^ b
e. (2 * a) + b

(Note: function is:  LD C,B ; ADD A,B; DEC C; JR NZ, -4; LD B,0 ; RET)

39. Which instruction loads a byte from memory address `$FF00` into register `A`?

a. LD A, [$FF00]
b. LD A, $FF00
c. LD [$FF00], A

40. Which part of an instruction typically specifies the operation to be performed?

a. The first byte
b. The second byte
c. The last byte

41. How are registers encoded within GBz80 instructions?

a. Using 3-bit codes in the opcode
b. Using separate bytes following the opcode
c. Instructions implicitely use specific registers without encoding them

42. Which register in the Game Boy's SM83 CPU holds the address of the next instruction to be executed?

a. PC
b. SP
c. HL

43. If the Zero flag is not set, what is the effect of the "JR Z, offset"?

a. Execution continues with the next instruction.
b. Execution jumps to the address specified by the offset.
c. Pop the stack and jump to the popped address.


44. Select the instruction whose result is influenced by some flag.

a. adc b
b. push de
c. inc [hl]

45. The immediate value of a JR instruction is considered:

a. signed
b. unsigned
c. it depends on the value of the zero flag


46. When a function is called, where is the return address stored?

a. In the RAM.
b. In the SP register.
c. In the HL register.

47. To repeat a section of code 10 times, which approach is the most
    efficient in terms of execution speed?

a. Unrolling (repeating) the code 10 times.
b. Using a conditional relative jump instruction (JR) and a loop counter.
c. Calling a function 10 times recursively.


48. What is the relation between code size and execution speed?

    a. There is no relationship between code size and execution speed
    b. Smaller code is always faster
    c. Smaller code is always slower


49. How are instructions and data typically organized in the final .gb file?

a. They are interleaved throughout the file.
b. Instructions are stored first, followed by data.
c. Data is stored first, followed by instructions.


50. Consider the following code.

~~~
snippet:
    ld      hl, address1
    ld      a, [hl]
    ld      d, 0
    ret     nz
    ld      de, address2
    ld      [de], a
    ret
~~~

In the provided routine, what determines whether the byte is copied?

a. The state of the Z flag
b. The value of register A
c. The value of register D

51. Consider the following code:

~~~
; Sorts two unsigned 8-bit numbers in memory locations pointed to by HL and DE
    ld      a, [hl]
    ld      b, [de]
    cp      b
    jr      c, swap_numbers
    ret
swap_numbers:
    ld      [hl], b
    ld      [de], a
    ret
~~~

It looks reasonable. However, the instruction "LD B, [DE]" does not exist.
What sequence of instructions can replace it, without introducing an error in the function?

    a. `PUSH AF ; LD A,[DE] ; LD B,A ; POP AF`
    b. `PUSH DE ; POP HL ; LD B,[HL]`
    c. `PUSH DE ; LD B,[HL] ; POP HL`

52. In the previous code, how can the JR followed by RET be optimized?

    a. Replace them by RET NC
    b. Replace them by RET C
    c. Remove the RET instruction
    d. Remove both instructions

## Search function

53. Consider the following GBz80 function:

~~~
search:
    cp      [hl]
    ret     z
    inc     hl
    dec     b
    jr      nz, search
    ld      hl, -1
    ret
~~~


Which register holds the value being searched for?

a. A
b. B
c. HL

54. How does the code indicate whether the value was found or not?

a. By returning a specific value in HL
b. By setting the zero flag
c. By jumping to a different section of code

55. Which register pair is used to keep track of the current position within the list?

a. HL
b. BC
c. CP

## Copymem function

56. Consider the function:

~~~
copyMem:
  ld a, [de]
  ld [hl+], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, copyMem
  ret
~~~

Which register pair holds the source memory address for the copyMem function?

a. DE
b. BC
c. HL

57. How does the copyMem function ensure that it copies the correct number of bytes?

a. By decrementing the value in the BC register pair until it reaches zero
b. By checking for a specific value in the accumulator
c. By comparing the current memory address to an end address

58.  What does the copyMem function expect the `bc` register to contain?

a. The amount of memory bytes to copy from `de` to `hl`.
b. The starting memory address of the source.
c. The starting memory address of the destination.

## Another function

59. Consider the function:

~~~
function1:
  ld a, 0
.loop:
  ld [hli], a
  dec b
  jp nz,.loop
  ret
~~~

What is the primary purpose of function1?

a. To fill a specified region of memory with zeros
b. To copy a block of memory from one location to another
c. To calculate the sum of values stored in a memory region

60. Which register pair holds the starting memory address to be processed by function1?

a. HL
b. BC
c. AF

61. How does funcion1 determine when to stop repeating?

a. By decrementing the value in the B register until it reaches zero
b. By checking for a specific value in the accumulator
c. By comparing the current memory address to an end address

## More questions...

62. In the instruction table provided in this exam, what do the instruction of rows 8x to Bx
   (in the first sheet) have in common?

a. They all involve some ALU operation.
b. They all involve the stack.
c. They all involve some immediate value.

63. Consider the following function. It takes `A` and `B` as parameters
    and saves the result into `A` before returning.
    
~~~gnuassembler
function:
  CP B
  LD A,1
  RET Z
  DEC A
  RET
~~~

What would be an description for it?
   
a. Tests if A == B
b. Returns the max of A and B
c. If B is greater than A, return A-1.

64. Consider this snippet:

~~~asm
    ld e, a
    ld d, 0
    add hl, de
    add hl, de
~~~

What does this snippet calculate?

a. `HL := HL + 2*A`
b. `HL := 2*(HL+A)`
c. `HL := 2*(HL + 2*A)`

65. Consider this snippet:

~~~asm
    ld e, a
    ld d, 0
    add hl, de
    add hl, hl
~~~

What does this snippet calculate?

a. `HL := 2*(HL+A)`
b. `HL := HL + 2*A`
c. `HL := 2*(HL + 2*A)`

66. What is the main difference between RAM (Random Access Memory) and ROM (Read-Only Memory)?
   
a. RAM requires constant power while ROM retains data even without power.
b. RAM is slower than ROM.
c. ROM can be written to while RAM is read-only.
 
