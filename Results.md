# Resluts

## Time benching

### Compression time for all pictures in the test set

Reduction|Huffman|LZW
---|---|---
000|40s|69s
111|41s|127s
222|45s|220s
333|46s|305s
444|46s|378s
555|46s|484s
666|46s|554s
777|46s|629s
888|46s|733s
999|46s|805s

### Decompression time for all pictures in the test set

In both compression models and in any reduction rate the decompression of all images takes about 22s


## Compression

### Compression size

The total size of the uncompressed files is 19'241'478 B or ~18.35 MB

Reduction|Huffman|LZW
---|---|---
000|15.24 MB|12.14 MB
111|13.42 MB|9.23 MB
222|12.07 MB|7.69 MB
333|11.12 MB|6.67 MB
444|10.43 MB|5.98 MB
555|9.87 MB|5.40 MB
666|9.34 MB|4.97 MB
777|9.04 MB|4.61 MB
888|8.71 MB|4.30 MB
999|8.33 MB|4.07 MB


### Compression rate

Calculated by dividing non-compressed size by compressed size

Reduction|Huffman|LZW
---|---|---
000|1.20|1.51
111|1.37|1.99
222|1.52|2.39
333|1.65|2.75
444|1.76|3.07
555|1.86|3.40
666|1.96|3.69
777|2.03|3.98
888|2.11|4.27
999|2.20|4.51

### Compression rate per time spend

Calculated by divided compression rate by compression time in minutes

Reduction|Huffman|LZW
---|---|---
000|1.80|1.31
111|2.00|0.94
222|2.03|0.65
333|2.15|0.54
444|2.30|0.49
555|2.43|0.42
666|2.56|0.40
777|2.65|0.38
888|2.75|0.34
999|2.87|0.37

## Quality

### PSNR

Calculated using __*Peak signal-to-noise ratio(PSNR)*__

Reduction|Huffman|LZW
---|---|---
000|Inf|Inf
111|43.86 dB|52.72 dB
222|40.94 dB|47.79 dB
333|38.26 dB|44.70 dB
444|36.17 dB|42.66 dB
555|34.54 db|40.70 dB
666|33.31 dB|39.34 dB
777|32.65 dB|38.12 dB
888|31.82 dB|37.00 dB
999|30.78 dB|36.13 dB

### Quality with compression rate

Calculated by multiplying PSNR and compression rate

Reduction|Huffman|LZW
---|---|---
000|Inf|Inf
111|60.09|104.91
222|62.23|114.22
333|63.13|122.93
444|63.66|130.97
555|64.24|138.38
666|65.29|145.16
777|66.28|151.72
888|67.14|158.00
999|67.72|162.95

### Quality with compression per time spend

Calculated by multiplying PSNR and compression rate and dividing the result to the time spend encoding in minutes

Reduction|Huffman|LZW
---|---|---
000|Inf|Inf
111|87.94|49.56
222|82.97|31.15
333|82.34|24.18
444|83.03|20.79
555|83.79|17.15
666|85.16|15.72
777|86.45|14.47
888|87.57|12.93
999|88.33|12.15

## Non mesurable qualities

At least in my opinion LZW seems to produce images that look much more like the original and produce less visual artifact.
