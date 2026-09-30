// genLut.c
//
// This file must be compiled with the -lm flag to link
// with the math.h library, eg:
//   gcc genLut.c -lm
//   tcc -run genLut.c -lm
//
// This program generates two angle-to-coordinate lookup tables,
// yLUT and xLUT, by using the standard sin() and cos() functions of math.h.
// Both lookup tables have 256 entries of 1 byte each.
//
// Functions sin() and cos() of `math.h` are documented in
// their  manpage (`man sin`, `man cos`)
// and online here:
// https://en.cppreference.com/w/c/numeric/math/cos
// https://en.cppreference.com/w/c/numeric/math/cos

#include <stdio.h>
#include <math.h>

#define PI 3.14159265

int main(){
  printf("SECTION \"Lookup Tables\", ROM0\n");

  printf("yLUT:\n");

  for (int angle=0; angle < 256; angle++)
    printf("  db %d\n", 85 + (int)(65 * sin( (angle * 2 * PI)/256 ))); 
   // Generated values must belong to range [20,150].

  printf("xLUT:\n");

  for (int angle=0; angle < 256; angle++)
   printf("  db %d\n", 85 + (int)(65 * cos ( (angle * 2 * PI)/256 )));
   // Generated values must belong to range [20,150].
 return 0;
}
