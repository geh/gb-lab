# Stored Programs, Control Flow

## In this section

* Stored programs.
* Labels and jump instructions.
* Flags.
* Conditional jumps.
* Control flow in assembly: if, if-else, do-while, while.

## Addressable Memory

  * The addressable memory is storage than can be accessed
    by means of an address.
  * Think of the addressable memory as a big array, and you can do:
    * `register = memory[address]` to read
    * `memory[address] = register` to write
  * On the SM83 CPU:
    * `address` is a value from `$0000` to `$FFFF`
    * `register` is a value from `$00` to `$FF`

## Stored programs

* Not only data is stored in memory, programs too.
* Each instruction of a stored program has an address, eg:

~~~gnuassembler
$0000 | XOR A
$0001 | LD B,A
$0002 | LD C,A
$0003 | INC C
$0004 | INC C
$0005 | ADD A,C
. . .
~~~

* Instructions can be 1, 2 or 3 bytes big.
* Instructions are normally executed in increasing order of memory address.
* Conditions and loops are implemented with special instructions called
  "jumps".

## `jp` and labels

    Mnemonic     Description
    ------------ -------------------------
    jp nn        jump to memory address nn

An infinite loop:

~~~gnuassembler
mylabel:
  instruction1
  instruction2
  instruction3
  jp mylabel
~~~

* The value of `mylabel:` is the memory address of the next instruction.
* We do not need to know the actual value because the assembler takes care
  of calculating the memory address of all labels in a program.
* A label is not an instruction. Machine code does not contain labels
  (unless it includes debug information).

## Introducing flags

~~~
                        CPU
                 +--------------+
                 |   8-bit      |
instructions ->  |  registers   |
                 |              | 
                 | a,b,c,d,e,h,l|
                 |   zero flag  |
                 |   carry flag |
                 +--------------+
~~~

  * zero flag: a single bit
    * meaning: "last instruction result is zero"
  * carry flag: a single bit
    * meaning: "last instruction produced a carry bit"

Vocabulary:

* to set a bit: set its value to 1
* to reset a bit: set its value to 0

## Conditional jumps

    Mnemonic     Description
    ------------ ------------------------------------------
    jp f,nn      conditional jump if nz,z,nc,c

Conditions (f):

* nz: jump if not zero
* z: jump if zero
* nc: jump if not carry
* c: jump if carry

## How instructions affect zero and carry flags

  * load instructions do not affect flags
  * inc/dec
    * zero flag set iff result is zero
    * does not affect carry flag
  * and/or/xor:
    * zero flag set iff result is zero
    * always reset carry flag
  * add/sub instructions affect zero and carry flags
    * zero flag set iff result is zero
    * carry flag set iff operation creates a carry/borrow bit

## A loop example

~~~gnuassembler
  ld b,10
loop:
  ...
  [instructions that do not affect b]
  ...
  dec b
  jp nz,loop
~~~

<!--
~~~gnuassembler
  ld a, 2
loop2:
  ld b,10
loop1:
  [do something]
  dec b
  jp nz,loop1
  dec a
  jp nz,loop2
~~~
-->

## Comparing values

    Mnemonic     Description
    ------------ ------------------
    cp r         compare A-r
    cp n         compare A-n

* cp performs a `sub` but does not save the result, only zero and carry flags are affected
* to jump to `label` if `a == b`: `cp b` then `jp z, label`
* to jump to `label` if `a >= b` (`a` and `b` considered unsigned): `cp b` then `jp nc, label`
* to jump to `label` if `a < b` (`a` and `b` considered unsigned): `cp b` then `jp c, label`

## Another loop example

~~~gnuassembler
  ld b,0
loop:
  ...
  [instructions that do not affect b]
  ...
  inc b
  ld a,b
  cp 10
  jp nz,loop
~~~

## Program Counter

How does the CPU store the address of the current instruction?

It has an extra register called `PC` "program counter":

~~~
                        CPU
                 +--------------+
                 |   8-bit      |
instructions ->  |  registers   |
                 |a,b,c,d,e,h,l | 
                 |              |
                 |   zero flag  |
                 |   carry flag |
                 |              |
                 |  pc register | 
                 +--------------+
~~~

This explains the following description of `jp`:

    Mnemonic     Description
    ------------ ------------------------------------------
    jp nn        jump to nn, PC=nn

There are no instructions that let you use `pc` as a normal
register (to store data, do arithmetic).

## Exercise 1

Convert the following high-level code to assembly.

~~~C
if (d == e)
  [CODE1]
[CODE2]
~~~

~~~C
if (d == e)
  [CODE1]
else
  [CODE2]
[CODE3]
~~~

## Exercise 2

Convert the following high-level code to assembly.

~~~C
c=0;
do {
  [CODE1]
} while (++c != 10);
[CODE2]
~~~

## Exercise 3

Convert the following high-level code to assembly.
Explain which registers correspond to variables `pow` and `x`.
You are allowed to destroy other registers.

~~~C
int pow = 1;
int x = 0;

while (pow != 64){
  pow = pow * 2;
  x = x + 1;
}
~~~

## Exercise 4

Same exercise.

~~~C
int sum = 0, i;

for (i = 0; i != 10; i = i + 1) {
  sum = sum + i ;
}
~~~

## Exercise 5

Write a code snippet that multiplies the values of registers
B and C (interpreted as unsigned) and store the result in A
(do not handle overflow). Make sure the code works even when
one of the parameters is equal to 0.


