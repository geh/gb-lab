# Why the Game Boy

## The Game Boy CPU (SM83)

* small instruction set (less than 30 mnemonics in the subset we cover)
* small set of registers
* similar to Intel 8080 and Zilog 80, precursor of Intel x86 (classic CISC)

## The Game Boy Platform

* no loading (ROM is part of the memory map)
* limited ROM space (32 KBytes)
* PPU provides graphics rendering easily
  (at the cost of learning VBlank synchronization)
* VBlank synchronization provides a reason to focus on
  instructions timing
* no cache, timing is predictable

## Other nice features

* there is only one Game Boy model (as opposed to TV-pluggable
  retro videogame platform that have different PAL/NTSC versions)
* the subset of the Game Boy we cover is a fine notional machine
  for learning the fundamentals of machine language
  and computer architecture
  * sound, DMA, interrupts and several instructions are excluded
  * sprites (tiles) are stored in 1bpp (bit per pixel) instead of 2bpp
* up-to-date tools for programming on the Game Boy
  are available for free
* it can even be programmed with an on-line interface
* emulators and real hardware can run programs developed
  in this lab
