"""
The following is based on RFC 1951 at:
https://www.ietf.org/rfc/rfc1951.txt

I found the RFC to very confusing until I read:
http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art001

Even this was confusing, so I'm including more information in this tutorial.
"""

"""
As an example we'll be working with the file gunzip.c.gz

gz stands for gzip, which is a file format that uses the DEFLATE compression algorithm
https://en.wikipedia.org/wiki/Gzip

Some key lingo:
1. GZIP - file format that uses DEFLATE
2. ZIP - different file format that often uses DEFLATE
3. DEFLATE - compression format which we'll be learning about below

When I first got started I was under the impression that the actual data for
GZIP files (.gz extension) always started at byte 11 (1 based). This is not true and for this particular file the actual compressed data starts at byte 20.

** For this file all byte numberings will be 1 based **

Important Numbers:
1. 20 - first byte in the compressed stream
2. 8 - # of bytes at the end of a gzip file
3. 4704 - # of bytes in this file
4. 4696 - last byte in the stream
"""
