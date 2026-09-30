# SM83 Instruction Sequencing

## Why Look Inside the CPU?

Most of the lab is concerned with the programmer's view of the Game Boy CPU:
registers, memory, instructions, flags, and timing.
This chapter looks at what happens inside the processor when an instruction is executed.

This is advanced material. You do not need it to write Game Boy programs,
but it explains several things that otherwise look arbitrary in the instruction set and timing tables.

## ISA and Microarchitecture

The **instruction set architecture (ISA)** is the programmer-visible interface of a processor.
It includes the registers that programs can access, the memory model, the instruction set,
and the binary encoding of instructions.

The **microarchitecture** is the internal hardware organization used to implement that ISA.
It can contain registers and other state that are not visible to an assembly programmer.

For example, the programmer knows about the Program Counter (`PC`) register,
but the CPU also needs an **instruction register (IR)**
to hold the instruction being decoded. It can also need temporary registers for intermediate values.

Different microarchitectures can implement the same ISA. The programmer-visible behavior remains the same.

## Fetch, Decode, Execute

At a high level, executing an instruction can be described as:

1. **Fetch**: obtain the instruction bytes from memory.
2. **Decode**: determine what operation the bytes represent.
3. **Execute**: perform the operation and update registers or memory.

The `PC` points to the next instruction byte. Conceptually:

~~~
IR := [PC]
PC := PC + 1
~~~

The fetched byte is stored in the **instruction register (IR)**.
Its bits then determine which internal operations must take place.

## Instruction Size and Execution Time

Instruction **size** and **execution time** are different properties.

For example:

~~~
ld a, b
~~~

requires the instruction byte and an internal register transfer.

By contrast:

~~~
ld a, [hl]
~~~

also requires a memory access.

Likewise, `CALL` has to fetch its operand, save the return address,
update the stack pointer, and load the target into the `PC`.

The encoding tells us **what instruction was requested**; the microarchitecture
determines **how that instruction is carried out**.

## Hidden Registers

Consider:

~~~
inc [hl]
~~~

The CPU has to:

1. read the byte from memory;
2. increment it;
3. write it back.

Conceptually:

~~~
temporary := [HL]
temporary := temporary + 1
[HL] := temporary
~~~

Using a programmer-visible register as the temporary would unexpectedly change the program state.

Hence, the microarchitecture provides an internal temporary register,
traditionally called **W**.

The model also uses **Z** for temporary values; `W` and `Z` can together hold a 16-bit value.

These are not programmer-visible SM83 registers. They are part of the internals of the CPU.

## Example: `JP`

Consider:

~~~
jp $2468
~~~

A conceptual sequence is:

~~~
FETCH:
    IR := [PC]
    PC := PC + 1

OP1:
    Z := [PC]
    PC := PC + 1

OP2:
    W := [PC]
    PC := PC + 1

JUMP:
    PC := WZ
~~~

The two operand bytes are collected in `Z` and `W`, then used to form the target address.

This also illustrates why the `PC` has already advanced beyond the instruction before the jump is performed.

Note that in the "FETCH" stage, fetching a byte from the RAM is done in parallel with incrementing PC.
This is thanks to a fast 16-bit incrementer circuit in the CPU and does not rely on the ALU.

## Example: `SUB A, [HL]`

Consider:

~~~
sub a, [hl]
~~~

A conceptual sequence is:

~~~
FETCH:
    IR := [PC]
    PC := PC + 1

MEM0:
    Z := [HL]

ALU:
    A := A - Z
~~~

There is a dependency:

~~~
memory read --> ALU operation
~~~

The subtraction cannot happen before the memory value has been obtained.

## Example: `PUSH BC`

A push requires stack-pointer updates and memory writes:

~~~
FETCH:
    IR := [PC]
    PC := PC + 1

ALU:
    SP := SP - 1

MEM0:
    [SP] := B

ALU2:
    SP := SP - 1

MEM2:
    [SP] := C
~~~

An apparently simple assembly instruction can therefore correspond to several internal operations.

## Example: `CALL`

Consider:

~~~
call $1357
~~~

A conceptual sequence is:

~~~
FETCH:
    IR := [PC]
    PC := PC + 1

OP1:
    Z := [PC]
    PC := PC + 1

OP2:
    W := [PC]
    PC := PC + 1

ALU:
    SP := SP - 1

MEM1:
    [SP] := PC(high byte)

ALU2:
    SP := SP - 1

MEM2:
    [SP] := PC(low byte)

JUMP:
    PC := WZ
~~~

`CALL` is therefore much more expensive than a simple register-to-register operation:
it involves instruction bytes, stack operations, and a change to the program counter.

## Example: `RET`

A return reconstructs the saved address:

~~~
FETCH:
    IR := [PC]
    PC := PC + 1

MEM0:
    Z := [SP]

ALU:
    SP := SP + 1

MEM1:
    W := [SP]

ALU2:
    SP := SP + 1

JUMP:
    PC := WZ
~~~

## Why Timing Depends on the Instruction

Instruction timing reflects the work that the implementation has to perform.

Factors include:

- the number of instruction bytes fetched;
- the number of data-memory accesses;
- internal operations;
- dependencies between operations;
- whether a conditional branch is taken.

For example:

~~~
ld a, b
~~~

requires a fetch and an internal transfer.

~~~
call label
~~~

requires several memory accesses and stack operations.

This helps explain why the timing table assigns different cycle counts to different instructions.

## Prefetching (or: Fetch/Execute Overlap)

If fetching a byte from memory takes 4 cycles, and if an internal CPU operation
(e.g. an 8-bit ALU operation) takes another 4 cycles, then how come the fastest
instructions are said to take 4 cycles instead of 8?

The answer is that the CPU uses **prefetching**: it fetches the next instruction
while the current instruction is being executed.

The two operations occur concurrently. When instruction N finishes, instruction
N+1 has already been fetched and can begin execution.

For a sequence of instructions, this means that the 4-cycle instruction fetch
does not have to be added to the execution time of every instruction.
There is an initial 4-cycle cost when the CPU starts executing its very first
instruction, that we can safely ignore.

Prefetching cannot always be maintained seamlessly. In particular, a jump
changes the `PC`, so an instruction fetched from the sequential address
may no longer be the instruction that should execute. The processor must then
fetch the instruction from the new address.

It is not necessary to understand prefetching to program, or even to compute
the execution time of a code snippet: using the cycle counts from the
instruction table is enough.

## Sources

* University of Manchester, School of Computer Science, COMP22111.
* <https://gbdev.io/gb-opcodes/optables/>
* [Game Boy: Complete Technical Reference](https://github.com/Gekkio/gb-ctr)
