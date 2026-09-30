# Integer Representation

## Positional Number Systems

Computers represent information as sequences of bits.
Before working with assembly language, we need to be comfortable
interpreting these bits as numbers.

A positional number system represents a number as a sequence of digits,
where each position has a weight determined by the base.

- Decimal is base 10.
- Binary is base 2.
- Hexadecimal is base 16.

An $N$-bit binary value has $2^N$ possible bit patterns, representing the
values from $0$ to $2^N-1$ when interpreted as unsigned.

For example,

\[
10110_2 = 1\times2^4 + 0\times2^3 + 1\times2^2 + 1\times2^1 + 0\times2^0 = 22_{10}.
\]

## Hexadecimal

Hexadecimal uses sixteen digits:

~~~
0 1 2 3 4 5 6 7 8 9 A B C D E F
~~~

The digits `A` through `F` represent decimal values 10 through 15.

Four binary bits correspond exactly to one hexadecimal digit.
Thus hexadecimal is a convenient compact notation for binary values.

| Binary | Hex | Decimal |
|---|---:|---:|
| `0000` | `0` | 0 |
| `0001` | `1` | 1 |
| `0010` | `2` | 2 |
| `0011` | `3` | 3 |
| `0100` | `4` | 4 |
| `0101` | `5` | 5 |
| `0110` | `6` | 6 |
| `0111` | `7` | 7 |
| `1000` | `8` | 8 |
| `1001` | `9` | 9 |
| `1010` | `A` | 10 |
| `1011` | `B` | 11 |
| `1100` | `C` | 12 |
| `1101` | `D` | 13 |
| `1110` | `E` | 14 |
| `1111` | `F` | 15 |

For example,

\[
2ED_{16} = 2\times16^2 + E\times16 + D = 749_{10}.
\]

In assembly code, hexadecimal constants are commonly written with a `$` prefix:

```asm
ld a, $3F
```

## Bits, Bytes, and Nibbles

- A **bit** has value `0` or `1`.
- A **nibble** is 4 bits.
- A **byte** is 8 bits.
- A **word** is a group of bits processed as a unit by a processor; its size depends on the architecture.

The rightmost bit is the **least significant bit (LSB)** and the leftmost bit is the **most significant bit (MSB)**.

```text
10110100
^      ^
MSB    LSB
```

Hexadecimal dump tools such as `hexdump` and `xxd` display files as sequences
of bytes, usually showing the byte offset, hexadecimal values, and an ASCII
interpretation.

## Unsigned Integer Representation

A bit vector can be interpreted as an **unsigned** integer, meaning it
represents a nonnegative value.

For a word of $w$ bits:

\[
0 \leq x \leq 2^w-1.
\]

The smallest value is all zeroes; the largest is all ones.

| Bits | Maximum unsigned value |
|---:|---:|
| 8 | 255 |
| 16 | 65,535 |
| 32 | 4,294,967,295 |

## Two's Complement Representation

The same bit vector can instead be interpreted as a **signed** integer.
The standard representation used for signed integers is **two's complement**.

The most significant bit has negative weight. For a $w$-bit value:

\[
-2^{w-1} \leq x \leq 2^{w-1}-1.
\]

For example, with 4 bits, the bit weights are:

~~~
bit:       3 2 1 0
weight:   -8 4 2 1
~~~

Thus:

~~~
1011 = -8 + 2 + 1 = -5
~~~

The range is asymmetric: there is one more negative value than positive values.

For 8 bits:

| Value | Representation |
|---:|---:|
| -128 | `$80` |
| -1 | `$FF` |
| 0 | `$00` |
| 127 | `$7F` |

In general:

- minimum signed value: $-2^{w-1}$
- maximum signed value: $2^{w-1}-1$

## Addition and Overflow

Computers operate on fixed-size words, so an exact mathematical result may
require more bits than are available.

For example, with 4-bit unsigned values, operands range from 0 to 15,
but their sum can reach 30.

When the result does not fit in the available word size, **overflow** occurs.

## Unsigned addition

For $w$-bit unsigned values, the result is truncated to $w$ bits.
This is equivalent to arithmetic modulo $2^w$:

\[
x +_u y = (x+y) \bmod 2^w.
\]

For example, using 8 bits:

~~~
  250
+  10
-----
  260
~~~

The stored result is `4`, because 260 modulo 256 is 4.

## Two's complement addition

At the bit level, two's complement addition uses the same binary addition
operation as unsigned addition. The difference is how the resulting bit
pattern is interpreted.

Signed overflow occurs when the mathematical result falls outside the
two's-complement range. In particular:

- two positive operands producing a negative result indicates positive overflow;
- two negative operands producing a positive result indicates negative overflow.

## Negating a Two's Complement Number

To negate a two's-complement value:

1. invert every bit;
2. add 1.

For example:

~~~
  00000101    +5
  11111010    invert bits
+        1
-----------
  11111011    -5
~~~

The minimum signed value is a special case. In an 8-bit representation,
`$80` represents `-128`, and `+128` cannot be represented. Negating `$80`
therefore produces the same bit pattern and involves overflow.

## Integer Sizes and C

The number of bits used to represent an integer determines its possible range.
In C, the exact size of some integer types is implementation-dependent,
so portable programs should not assume that `int` always has a particular size.

On a common modern system where `int` is 32 bits:

~~~
int          -2,147,483,648 ... 2,147,483,647
unsigned int          0 ... 4,294,967,295
~~~

C integer arithmetic also uses fixed-size representations: the mathematical
integers are not unbounded when stored in machine types.

## Summary

- Binary is a direct representation of bits.
- One hexadecimal digit corresponds to four bits.
- An unsigned $w$-bit value ranges from $0$ to $2^w-1$.
- A signed two's-complement $w$-bit value ranges from $-2^{w-1}$ to $2^{w-1}-1$.
- Fixed word sizes mean that arithmetic can overflow.
- Signed and unsigned addition use the same underlying bit-level operation.
- To negate a two's-complement value, invert the bits and add one.
