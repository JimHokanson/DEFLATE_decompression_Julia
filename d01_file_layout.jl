"""
At this point we need to briefly discuss the overall layout of the file. The
main portion of the file consists of the compressed data which is compressed
in two ways.

1. Using bit encoding rather than byte encoding. Frequently used ... TODO
2. By allowing pointers to previously used sequences of bytes. For example
we can say go back 100 bytes and copy 50 bytes. This is known as run-length
encoding.

In order to save space with bit encoding which values get the shorter bit
phrases can vary from file to file.

For example, we might want to reserve the bit sequence 00 for a common letter
like 'e' rather than 0101010111. Somehow though we need to specify that
e = '00'

In order to save space there is no location that explicitly says e = '00'.
Obviously this can be encoded in the file somehow, but it is not as a literal
byte of 'e'

Thus the file layout becomes (in reverse order of what is in the file)

3. The compressed data
2. Instructions on how to read the compressed data (e = '00', f = '00101').
We'll call these I2.
1. Instructions on how to read the Instructions - otherwise we'd waste
  400 - 600ish bytes of precious memory on I2. We'll call this first set I1.

I2 consists of:
1. Literals and their bit values, i.e. e = '00'
2. Distance and length instructions, i.e. go back 100 spaces and copy 50 bytes

We'll get into more specifics on that in a second, but first we need to
understand the instructions (I1) on how to read the instructions (I2).
"""
