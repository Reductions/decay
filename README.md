# Decay

This is command line tool for compressing and decompressing images.

## Installation

```
mix deps.get
mix escript.build
```

This shoud create executable named __decay__ in the root directroy of the project

## Usage

There are 2 main ways to use this tool.

### Compression

#### Mandatory switches
- **--compress** or **-c**

   Initiates compression
- **--in**=**FILE_NAME**

   **FILE_NAME** should be the name of the file to be encoded. It should be PNG image with extension .png

   The file create after the compression will start with the same root as FILE_NAME but it will have some info at the end and will be with extension .dcy
- one of **--huffman** or **--lzw**

   Encoding schema.
- one of **--rgb** or **--ycc**

   Color space to be used for compression(--ycc is not recommended).
- **--reduction**=**C<sub>1</sub>**__C<sub>2</sub>__**C<sub>3</sub>**

   **C<sub>1</sub>**, __C<sub>2</sub>__ and **C<sub>3</sub>** are the reductions in each channel R, G and B or Y, C<sub>r</sub> and C<sub>b</sub>. Those could be any single digit numbers.

   In case of Huffman encoding the reduction in a channel show how man samples will be used to represent the that channel calculated as follows 255/(R*2+1) where R is the reduction.

   In case of LZW the reduction shows how big of a difference could a encoded value differ from the real one.


### Decompression

#### Mandatory switches
- **--decompress** or **-d**

   Initiates compression
- **--in**=**FILE_NAME**

   **FILE_NAME** should be the name of the file to be decoded. It should end with extension .png
