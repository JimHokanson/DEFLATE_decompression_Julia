"""
This yields:
0: 3
1: 0
2: 0
3: 0
4: 4
5: 4
6: 3
7: 2
8: 3
9: 3
10: 4
11: 5
12: 0
13: 0
14: 0
15: 0
16: 6
17: 7
18: 7

At this point we need to understand how to go from these values to
bit strings. This is done with Huffman coding.
https://en.wikipedia.org/wiki/Huffman_coding

I won't go into too much detail but the important idea is that we can git a
bunch of bit strings whereby each string can be uniquely identified.

For example the following, when read left to right are unique:
010
001
000

The following however would not be ok:
01
01011

Since if we saw 01 we wouldn't know if it was its own code or if it was a
subset of 01011

The algorithm is as follows:

- Start with 0 at the minimum length.
- Increment by 1 for every code at that length
- Once done go back to the next length and start at 2*last_value + 1
"""
