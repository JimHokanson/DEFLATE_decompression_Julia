#Read d00_intro.jl

#Define bit manipulation functions
include("f01_init_file.jl")

"""
So now we have the relevant functions to work with bits. Now onto the format.

From 3.2.3
1. Bit 1 - BFINAL - is this the last block?
2. Bits 2,3 - BTYPE - specifies how the data are compressed, as follows:

    00 - no compression
    01 - compressed with fixed Huffman codes
    10 - compressed with dynamic Huffman codes
    11 - reserved (error)

So, let's read our file.
"""

BFINAL = pop_bits(1) #BFINAL = 1 - this is the final block
BTYPE  = pop_bits(2) #BTYPE  = 3 - Dynamic Huffman Coding

"""
Since BTYPE = 3 we will be using dynamic Huffman coding

we need to look at 3.2.7 of the RFC which states:
    5 Bits: HLIT, # of Literal/Length codes - 257 (257 - 286)
    5 Bits: HDIST, # of Distance codes - 1        (1 - 32)
    4 Bits: HCLEN, # of Code Length codes - 4     (4 - 19)
"""

HLIT = pop_bits(5)
HDIST = pop_bits(5)
HCLEN = pop_bits(4)

n_literal_codes = HLIT + 257
n_distance_codes = HDIST + 1
n_code_length_codes = HCLEN + 4

MAX_NUMBER_CODE_LENGTH_CODES = 19

code_lengths = zeros(UInt8, MAX_NUMBER_CODE_LENGTH_CODES)

code_lengths_order = UInt8[16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]
#Convert from 1 based to zero based
code_lengths_order += 1

length_counts = zeros(UInt8, 8)

for i = 1:n_code_length_codes
    index = code_lengths_order[i]
    length_value = pop_bits(3)
    code_lengths[index] = length_value

    #We'll use this later
    length_counts[length_value+1] += 1
end

for i = 1:MAX_NUMBER_CODE_LENGTH_CODES
    @printf("%d: %d\n",i-1,code_lengths[i])
end

#d03_code_length_results.jl
#-------------------------------------

#This is not the best approach but it works

code_values = zeros(UInt8, MAX_NUMBER_CODE_LENGTH_CODES)

last_value = -1
last_length = -1
#Must loop over lengths on outer, not inner
for current_length = 1:7
    for i = 1:MAX_NUMBER_CODE_LENGTH_CODES
    #We skip 0, it doesn't take any value
    #7 is the max because we used 3 bytes (encoding 0-7)
        if code_lengths[i] == current_length
            #Then we will assign the code some value
            if last_value == -1
                code_values[i] = 0
                last_value = 0
            elseif last_length != current_length
                last_length = current_length
                code_values[i] = 2*(last_value+1)
                last_value = code_values[i]
            else
                code_values[i] = last_value+1
                last_value += 1
            end
        end
    end
end

#summary
for i = 1:MAX_NUMBER_CODE_LENGTH_CODES
    if code_lengths[i] != 0
        len = Int64(code_lengths[i])
        bin_value = bin(code_values[i],len)
        pad_string = lpad(bin_value,7)
        #Subtract 1 due to IDs typically being 0 based
        index = lpad(i-1,2)
        #@printf("bin %s\n",bin_value)
        #@printf("len %d\n",7-len)
        #@printf("lpad %s\n",lpad(bin_value,7-len))
        @printf("%s, %s\n",index,pad_string)
    end
end

#=
This yields:
 0,     010
 4,    1100
 5,    1101
 6,     011
 7,      00
 8,     100
 9,     101
10,    1110
11,   11110
16,  111110
17, 1111110
18, 1111111

Note that I've right aligned the bit strings.

Normally when lookings at bits, we consider the first bit
to be the bit on the right. Then we move to the left.

Now consider the bit string "101"
If we see that, which ID does it represent?

You might say #9, but what about #5?
=#


#The same code as above, but now right padded
for i = 1:MAX_NUMBER_CODE_LENGTH_CODES
    if code_lengths[i] != 0
        len = Int64(code_lengths[i])
        bin_value = bin(code_values[i],len)
        pad_string = rpad(bin_value,7)
        #Subtract 1 due to IDs typically being 0 based
        index = lpad(i-1,2)
        #@printf("bin %s\n",bin_value)
        #@printf("len %d\n",7-len)
        #@printf("lpad %s\n",lpad(bin_value,7-len))
        @printf("%s, %s\n",index,pad_string)
    end
end

#d04_I1_lengths_part1.jl

#Sort index by length
indices_to_process = zeros(UInt8,n_code_length_codes)

MAX_LENGTH = 8
current_start_indices = zeros(UInt8, MAX_LENGTH)
current_start_indices[1] = 1
for i = 1:MAX_LENGTH-1
    current_start_indices[i+1] = current_start_indices[i] + length_counts[i]
end

for i = 1:MAX_NUMBER_CODE_LENGTH_CODES
    if code_lengths[i] != 0
        len_b1 = code_lengths[i]+1
        current_index = current_start_indices[len_b1]
        @printf("%d of len %d to %d\n",i,code_lengths[i],current_index)
        indices_to_process[current_index] = i
        current_start_indices[len_b1] += 1
    end
end

#indices_to_process
#
#Now we know the order in which to process the values

code_values2 = zeros(UInt8,MAX_NUMBER_CODE_LENGTH_CODES)

current_value = UInt16(0)
last_length = -1
for i = 2:n_code_length_codes
    current_index = indices_to_process[i]
    current_length = code_lengths[current_index]

    #x2 - does nothing since we are going in reverse
    #add 1
    #   - find first zero
    #   - everything beyond needs to be zerod
    #   - add 1

    #001 => 1 << 0
    #010 => 1 << 1 (length = 2)
    #100 => 1 << 2 (length = 3)

    if current_length == last_length
        #Add 1 at current length
        bit = UInt16(1) << (current_length-1)
    else
        #add 1 at old length then multiply by 2
        #
        # when reversed increasing multiplying
        # by 2 has no effect
        #
        # =>  01
        # => 001 #Now "3" bits but still same value
        bit = UInt16(1) << (current_length-2)
    end

    #Adding 1
    #---------------------------------
    while (current_value & bit != 0)
        bit >>= 1
    end
    #Keep all lower bits
    current_value &= bit-1
    #Add in current bit
    current_value |= bit

    last_length = current_length
    code_values2[current_index] = current_value
end

#Building lookup table
i1_table = zeros(UInt16,256)
for i = 1:MAX_NUMBER_CODE_LENGTH_CODES
#code_values2
    current_value = UInt16(code_values2[i])
    current_length = code_lengths[i]
    if current_length != 0
        #5
        @printf("%d\n",i)
        increment = UInt16(1) << current_length
        while current_value < 256
            #TODO: problem if bit string is 0
            #Unfortunately we'll have to test if zero
            #and if not, then do our indexing
            if current_value != 0
            i1_table[current_value] = current_value
            end
            current_value += increment
        end
    end
end
