"""

## Code length codes, I1 ##

In the first section, we read a series of 3 bit codes.

The meaning of these codes is follows, as specified in 3.2.7:

The alphabet for code lengths is as follows. This will make
more sense once we go through the actual values.

From 3.2.7:
0 - 15: Represent code lengths of 0 - 15
16: Copy the previous code length 3 - 6 times.
   The next 2 bits indicate repeat length
         (0 = 3, ... , 3 = 6)
      Example:  Codes 8, 16 (+2 bits 11),
                16 (+2 bits 10) will expand to
                12 code lengths of 8 (1 + 6 + 5)
17: Repeat a code length of 0 for 3 - 10 times.
   (3 bits of length)
18: Repeat a code length of 0 for 11 - 138 times
   (7 bits of length)

Finally, the 3 bit values are not in order but rather
are in the following order, allowing you to potentially save a few extra
bytes if they are not used.

"(HCLEN + 4) x 3 bits: code lengths for the code length
alphabet given just above, in the order: 16, 17, 18,
0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15"

So in brief summary, the next 3 bits to process correspond to code 16, which
when seen later indicates to copy a previous code 3 - 6 times. This made
absolutely no sense to me until I worked through an example.

"""
