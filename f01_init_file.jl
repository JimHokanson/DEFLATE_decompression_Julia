
#Let's read the file
data = read("gunzip.c.gz")

#This is specific to this file. Often the value is actually 11
in_next_I = 20
#This is the length of the file - 8 + 1
in_end_I = 4696+1

"""
Before getting any further almost all processing of the input stream is done
using bits rather than bytes. We need to introduce functionality that will
allow us to work with bits rather than just bytes.

To do that we introduce the following functions:
1. read_bits(n_bits) - read bits but don't remove them
2. drop_bits(n_bits) - remove bits
3. pop_bits(n_bits) - read bits and remove them

This code is introduced below. We also introduce state variables.
"""

# The # of bits in our buffer
n_bits_left = UInt64(0)

# Our buffer consists of one number which we fill!
bit_buffer = UInt64(0)

"""
read_bits(n)
The specifics of this function aren't critical, the basic idea is that we
get bytes from "data" and add them to the bit buffer.
"""
function read_bits(n)
    global bit_buffer
    global in_end_I
    global in_next_I
    global n_bits_left
    if n > n_bits_left
        #This approach only adds 1 byte at a time
        #
        #We could alternatively add multiple bytes if we have the room
        if in_next_I == in_end_I
            n_bits_left += 64
        else
            while n > n_bits_left
                bit_buffer |= UInt64(data[in_next_I]) << n_bits_left
                in_next_I += 1
                n_bits_left += 8
            end
        end
    end
    #To set all bits up to n we subtract 1 from 2^n
    return bit_buffer & UInt64((UInt64(1) << n) - 1)
end

function drop_bits(n)
    global bit_buffer
    global n_bits_left
    n_bits_left = n_bits_left - n
    bit_buffer = bit_buffer >> n
end

function pop_bits(n)
    x = read_bits(n)
    drop_bits(n)
    return x
end
