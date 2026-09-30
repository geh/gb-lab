# 16-bit Registers and Memory Addressing

## 16-bit registers 

  * 3 pairs of registers from existing registers
    * `BC`, `DE`, `HL`
    * treated as a single 16-bit register by a few instructions
  * any instruction that modifies `BC` may modify `B` or `C`,
    even both

## 16-bit Load instructions

    Mnemonic     Description
    ------------ -----------------------------------------
    ld rr,nn     rr=nn

  * `nn` is a constant
  * `rr` can only be `BC`, `DE` or `HL`
  * To load from other 16-bit registers, use 2 `LD` 8-bit instructions:
    * `ld h,b`
    * `ld l,c`


## 16-bit arithmetic instructions

    Mnemonic      Description
    ------------- --------------------------------------------
    inc rr        rr = rr+1
    dec rr        rr = rr-1
    add HL,rr     HL = HL+rr

  * `rr` can only be `BC`, `DE` or `HL` 
  * 16-bit inc/dec do not update any flag
  * 16-bit add updates the carry flag, but not the zero flag
  * there are no 16-bit logic instructions

## Exercise 1

Write a code snippet in which a loop is controlled by `BC`
and repeated 1000 times.

## Memory addressing

  * let us see instructions to load and store data from/to
    memory to register CPUs
  * this means we can use the memory to read and store data
  * notation:
    * `(nn)` or `[nn]`: the value stored at memory address `nn`
    * similar to the `*` operator of the C language
  * same for `(rr)` or `[rr]` when `rr` is a 16-bit register

## Load from/to memory instructions with the HL register

    Mnemonic        Description
    --------------- -------------------------------------
    ld r,[HL]       r=[HL]
    ld [HL],r       [HL]=r
    ld [HL],n       [HL]=n

* memory is written/read one byte at a time
* `HL` as a memory address can be used in combination with any
  8-bit register

## More load from/to memory instructions

    Mnemonic        Description
    --------------- -------------------------------------
    ld A,[BC]       A=[BC]
    ld A,[DE]       A=[DE]
    ld [BC],A       [BC]=A
    ld [DE],A       [DE]=A
    ld A,[nn]       A=[nn]
    ld [nn],A       [nn]=A

* `A` can be used in combination with any
  16-bit register address or 16-bit constant address
* the other combinations are not possible:
  * ~~`ld [nn],n`~~, ~~`ld E,[BC]`~~, etc.

## Exercise 2

Write a code snippet that sets `B` bytes of memory to 0, starting
from address `HL`. You may assume that `B` is not equal to 0.

## Exercise 3

Write a code snippet that copies `B` bytes from address `DE` to address `HL`.
You may assume that `B` is not equal to 0.

## Exercise 4

Write a code snippet that copies `BC` bytes from address `DE` to address `HL`.
The code snippet should do nothing if it detects that `BC` is equal to 0.

## Exercise 5

Write a code snippet `sumArray:` that expects a memory
address in `DE`, a non-null integer value in `B`, and performs
the sum of the first `B` bytes in memory starting from address `DE`,
and saves the sum in register `HL`. 
