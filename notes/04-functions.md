# Stack and Functions

## Topics of this Section

* the `sp` register
* stack instructions
* functions: `call` and `ret` instructions
* preserving values
* `[hl]` as operand

## The `sp` register

* another 16-bit register, dedicated to memory addressing
* `sp` stands for "stack pointer"
* it is used as a way to store and read values in memory
  at a particular location
* when the Game Boy boots up, initialized at `$FFFE`

## The stack, as an Abstract Datatype

The stack is implemented with a pointer to memory and two operations:

  * push(x): move pointer to one direction, stores value x in memory.
  * pop(): returns value from pointer, move pointer to the other direction.

These operations mean that we can only get the latest value pushed on the
stack. A stack is a first-in-last-out data structure (or last-in-first-out).

## Stack instructions

    Mnemonic     Description
    ------------ -----------------------------------------
    push rr      SP--, (SP)=MSB(rr), SP--, (SP)=LSB(rr)
    pop rr       LSB(rr)=(SP), SP++, MSB(rr)=(SP), SP++

  * MSB: most significant byte
  * LSB: least significant byte
  * `rr` can be `BC`,`DE`,`HL`, `AF`

## Good use of the stack

* always push before pop
* use as many pop's as push's
* do not access stack memory manually, use push/pop

## Exercise 1

~~~gnuassembler
  ld hl,10
  ld bc,20
  ld de,30
  push hl
  push bc
  push de
  pop  hl
  pop  bc
  pop  de
~~~

What are the final values of `hl`, `bc`, `de`?

## Exercise 2

Write a code snippet `concat:` that takes three memory addresses `HL`, `DE`
and `BC` and a non-zero integer `A`. `HL` and `DE` are zero-terminated strings
that must be copied one after another to the location `BC`.
`A` is the maximum size of the `BC` buffer.
A final zero must be written at the end of the `BC` string, only if the size
of the buffer allows it.


## `call` and `ret` instructions

    Mnemonic     Description
    ------------ -------------------------------------------------------------------------
    call nn      equivalent to PUSH PC, PC=nn
    call f,nn    conditional call if nz,z,nc,c
    ret          return: equivalent to POP PC
    ret f        conditional return if nz,z,nc,c

  * *calling a function* involves saving the return address of the calling
    environment on the stack
  * *returning* from a function means getting back that return address from
    the stack and jumping back to it
  * since the stack is FILO (first-in, last-out), nested calls work

## Function example 

~~~gnuassembler
; input: HL: base address
;         B: index
; output: A: = [HL+B]
; modifies: HL
getArrayIdx:
  ld a,l
  add a,b
  jp nc, getValue
  inc h
getValue:
  ld l,a
  ld a,[hl]
  ret
~~~

## Same with HL preservation

~~~gnuassembler
; input: HL: base address
;         B: index
; output: A: = [HL+B]
getArrayIdx:
  push hl
  ld a,l
  add a,b
  jp nc, getValue
  inc h
getValue:
  ld l,a
  ld a,[hl]
  pop hl
  ret
~~~

## Exercise 3

Write a function `sameSum` that expects a memory
address in `DE`, a positive integer value in `B`, and performs
the sum of the first `B` bytes in memory starting from address `DE`,
then the sum of the next `B` bytes in memory; if both sum are equal,
it sets `A` to `1` and returns, otherwise it sets `A` to `0` and returns.
The function should preserve registers `DE` and `HL`.

## `[hl]` as operand

`[hl]` can be used as an operand in all arithmetic and logic
instructions that accept an 8-bit register operand.

Hence, these instructions exist:

* `add/sub [hl]`
* `or/and/xor [hl]`
* `cp [hl]`

With these instructions, the value stored at memory address `hl`
is taken as second operand, and the result is stored in `a` as usual
(except `cp` that only updates flags). The following instructions
also exist:

* `inc/dec [hl]`

And set the zero flag whether the new value of `[hl]` is zero.

### Exercise 4

Write a function `duplicates:` that checks if the
array stored in memory at address `HL` and of
size `B` contains duplicated values; it should
set `A` to 1 if it does, `A` to 0 if it does not,
then return.

The function must use two nested loops, it must use
the `cp [HL]` instruction, and it must not use the stack.

