"""
Now if we pad to the start on the left hand side
and read to the right we see that the bit strings are all uniquely
identifiable. For example if I see 101, I know that represents
#9 and isn't just a subset for something else.

 0, 010
 4, 1100
 5, 1101
 6, 011
 7, 00
 8, 100
 9, 101
10, 1110
11, 11110
16, 111110
17, 1111110
18, 1111111

Note however that bits are never processed left to right, they are
processed right to left. So for processing of our data we need to reverse
the bits. Also note that this does not mean swapping the first and last bit
in a byte since the bit strings are of a given length.

So here is a side by side of the original values and what we need.

    Orig         New   Level & Index    New as # and hex
 0,     010 -     010   L3 - 1          2
 4,    1100 -    0011       L4 - 1      3
 5,    1101 -    1011       L4 - 2      11 b
 6,     011 -     110   L3 - 2          6
 7,      00 -      00 L2 - 1            0
 8,     100 -     001   L3 - 3          1
 9,     101 -     101   L3 - 4          5
10,    1110 -    0111       L4 - 3      7
11,   11110 -   01111 L5 - 1
16,  111110 -  011111 L6 - 1
17, 1111110 - 0111111 L7 - 1
18, 1111111 - 1111111 L7 - 2


"""
