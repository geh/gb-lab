# Assembly Optimizations

## Optimizations of assembly code

* From <https://github.com/pret/pokecrystal/wiki/Optimizing-assembly-code>
* Interesting because they involve:
  * knowing the Game Boy instructions
  * bit-level logic operations
  * use of the carry bit
  * (signed) integer representation
  * understanding control flow

## What does "Optimization" mean?

* Optimization for **speed**
  * Doing the same operation in fewer cycles
* Optimization for **space**
  * Doing the same operation in fewer bytes
* Should you always optimize?
  * No! In the project, prefer clarity over optimizations.
  * The only place where optimizing is crucial for speed is VBlank.

Categories:

* 8-bit optimizations
* 16-bit optimizations
* Control Flow optimizations

## Increment/decrement `a` when the carry flag is set

Naively:

~~~asm
; 3/12
  jr nc, .ok
  inc a
.ok
~~~

or:

~~~asm
; 3/12
  jr nc, .ok
  dec a
.ok
~~~

Optimized:

~~~asm
adc 0 ; 2/8
~~~

~~~asm
sbc 0 ; 2/8
~~~


## Increment/decrement `a` when the carry flag is *not* set

Naively

~~~asm
; 3/12
  jr c, .ok
  inc a
.ok
~~~

or

~~~asm
; 3/12
  jr c, .ok
  dec a
.ok
~~~

Optimized:


~~~asm
sbc -1 ; 2/8
~~~

~~~asm
adc -1 ; 2/8
~~~

## Divide `a` by 16 (shift `a` right 4 bits)

Naively:

~~~asm
; 8/32
srl a
srl a
srl a
srl a
~~~

Optimized:

~~~asm
; 4/16
swap a
and %00001111
~~~

## Load constant to `[hl]`

Naively:

~~~asm
; 3/16
ld a, CONSTANT
ld [hl],a
~~~

Optimized:

~~~asm
; 2/12
ld [hl], CONSTANT
~~~

## Increment or decrement `[hl]`

Naively:

~~~asm
; 3/20
ld a,[hl]
inc a   /  dec a
ld [hl],a
~~~

Optimized:

~~~asm
; 1/12
inc [hl]  /  dec [hl]
~~~

## Sign-Extend `a` into a 16-bit Register

Naively:

~~~asm
; 10/(36 or 40)
  ld l, a
  cp $80    ; nor bit 7, a
  ld a, $00
  jr c, .ok ; nor jr z, .ok
  ld a, $ff
.ok
  ld h, a
~~~

Also naively:

~~~asm
; 9/(32 or 36)
  ld l, a
  cp $80    ; or bit 7, a
  ld a, $00
  jr c, .ok ; or jr z, .ok
  dec a
.ok
  ld h, a
~~~

Also naively:

~~~asm
; 6/24
ld l, a
cp $80
ccf
sbc a
ld h, a
~~~

Optimized:

~~~asm
; 4/16
ld l, a
add a
sbc a
ld h, a
~~~

Now, we turn to 16-bit optimizations.

## Load from a memory address to `hl`

Naively:

~~~asm
; 8/40
ld a, [Address] ; LSB first
ld l, a
ld a, [Address+1]
ld h, a
~~~

Optimized:

~~~asm
; 6/32
ld hl, Address
ld a, [hl+]
ld h, [hl]
ld l, a
~~~

## Multiply `hl` by 2

Naively:

~~~asm
; 4/16
sla l
rl h
~~~

Optimized:

~~~asm
; 1/8
add hl,hl
~~~

Now, let us see **control flow optimizations**.

## Tail call optimization

Naively:

~~~asm
; 4/40
call Function
ret
~~~

Optimized:

~~~asm
jp Function ; 3/12
~~~

## Fallthrough

Naively:

~~~asm
	(some code)
	call Function
	ret

Function:
	(function code)
	ret
~~~

Also naively:

~~~asm
	(some code)
	jp Function

Function:
	(function code)
	ret
~~~

Optimized:

~~~asm
	(some code)
	; fallthrough
Function:
	(function code)
	ret
~~~

You can still call `Function` elsewhere, but one tail call can be optimized
into a fallthrough.

## Conditional Fallthrough

Naively:

~~~asm
	(some code)
	jr z, .foo
	jr .bar

.foo
	(foo code)

.bar
	(bar code)
~~~

Optimized:

~~~asm
	(some code)
	jr nz, .bar
	; fallthrough
.foo
	(foo code)

.bar
	(bar code)
~~~


## Conditional return

Naively:

~~~asm
	; 3/(12 or 24)
	jr z, .skip
	ret
.skip
	...
~~~

Also naively:

~~~asm
	; 3/(28 or 8)
	jr nz, .return
	...

.return
	ret
~~~

Optimized:

~~~asm
	; 1/(20 or 8)
	ret nz
	...
~~~

## Conditional call

Naively:

~~~asm
	; 5/(12 or 36)
	jr nz, .skip
	call Foo
.skip
~~~

Optimized:

~~~asm
	; 3/(24 or 12)
	call z, Foo
~~~

## Conditional jump

Naively:

~~~asm
	jr nz, .skip
	jp Foo
.skip
~~~

Optimized:

~~~asm
	jp z, Foo
~~~

## Chain compare and jump

Naively:

~~~asm
	cp 1
	jr z, .equals1
	cp 2
	jr z, .equals2
	cp 3
	jr z, .equals3
	...
~~~

Optimized:

~~~asm
	dec a
	jr z, .equals1
	dec a
	jr z, .equals2
	dec a
	jr z, .equals3
	...
~~~

Optimized:

~~~asm
	dec a
	ld hl, .jumptable
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.jumptable:
	dw .equals1
	dw .equals2
	dw .equals3
	...
~~~

**Important reminder** when performance is not needed, clarity must be your priority!
