# The Game Boy Memory Map

## Simplified Memory Map

Range          Size    Description   Access
-------------  -----   -----------   -----------    
\$0000-\$7FFF  32 KB   Game ROM      Read-only
\$C000-\$DFFF  8 KB    Work RAM      Read-write

* The ROM contains both code and data from your program; the remaining space
  is usually filled with `$00` or `$FF`.
* Larger games use bank switching to go beyond 32 KB.
* Work RAM is where your variables live during execution.

## Sections

  * An assembly file can have multiple sections.
  * A section is a chunk of code and data that should be kept together in the
    final ROM (`.gb`) file.
  * A section can specify a start address (eg, `ROM0[$1000]`)
  * If it does not specify a start address, the linker chooses where to place it
    in the final ROM file.

~~~asm
SECTION name, type
SECTION name, type[addr]
~~~

  * Common section types:
    * `ROM0`: ROM area (`$0000`-`$7FFF`)
    * `WRAM0`: Work RAM (`$C000`-`$DFFF`)
  * A section in `WRAM` can just define labels, not code or data.

## Exercise 3

3.1

~~~gnuassembler
SECTION "Main", ROM0[$1000]
main: dec a
      dec b
      add b
      jp main
~~~

What bytes are generated?

3.2

~~~gnuassembler
SECTION "Main", ROM0[$2000]
main:
  ld a,50
  ld [health], a
  ld hl,counter
  ld [hl],30
loop:
  dec [hl]
  push hl
  ld hl,counter
  dec [hl]
  pop hl
  jp loop

SECTION "Variables", WRAM0[$C000]
health:  DS 1  ; reserve 1 byte for health
counter: DS 1  ; reserve 1 byte for counter
~~~ 

What bytes are generated?

## Local Labels

* Labels let the assembler handle addresses for you.
* Global labels end with `:` or `::`, they must be unique.
* Local labels start with `.`
* Internally, local labels are automatically prefixed with the last global label before it
* Thus you can reuse local labels (example: `.loop`, `.skip`, etc.)

## Exercise 4

Get the program [`checksum.asm`](asm/checksum.asm) and follow the instructions
of the two questions.

If you don't have the RGBDS toolchain installed on your computer yet,
use RGBDS-live: <https://gbdev.io/rgbds-live/>.

Paste the contents of `checksum.asm` into the text editor of
RGBDS-live (the file must be `main.asm`), then click on "Run"
to assemble, link and run the program.
Any modification to the program source code will re-start the assembling,
linking and running process. Select the `WRAM` tab to see the
contents of the Work RAM.
