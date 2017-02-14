defmodule Decay.Image do
  alias Decay.Huffman
  alias Decay.LZW

  def encode_image(pixels, reduction, format, space) do
    {e1, e2, e3} =
      pixels
      |> List.flatten
      |> transform(space)
      |> split_channels
      |> encode_format(format, reduction)

    <<byte_size(e1)::size(32),
      byte_size(e2)::size(32),
      byte_size(e3)::size(32),
      e1::binary,
      e2::binary,
      e3::binary>>
  end

  def decode_image(file_name) do
    {:ok, file} = File.open(file_name, [:read])

    {enc, space, wight, height, bin} =
      IO.binread(file, :all)
      |> extract_header

    File.close(file)
    pixels =
      bin
      |> split_bins
      |> decode_format(enc)
      |> Enum.zip
      |> detransform(space)
      |> Enum.map(fn({r, g, b}) -> <<r::size(8), g::size(8), b::size(8)>> end)
      |> Enum.chunk(wight)
    {wight, height, pixels}
  end

  def write_image(bin, file_name) do
    {:ok, file} = File.open(file_name, [:write])
    IO.binwrite(file, bin)
    File.close(file)
  end

  defp encode_format({c1, c2, c3}, :huf, {r1, r2, r3}) do
    {Huffman.encode(c1, r1),
     Huffman.encode(c2, r2),
     Huffman.encode(c3, r3)}
  end
  defp encode_format({c1, c2, c3}, :lzw, {r1, r2, r3}) do
    {LZW.encode(c1, r1),
     LZW.encode(c2, r2),
     LZW.encode(c3, r3)}
  end

  defp split_bins(bin) do
    <<size1::size(32),
      size2::size(32),
      size3::size(32),
      rest::binary>> = bin
    {binary_part(rest, 0, size1),
     binary_part(rest, size1, size2),
     binary_part(rest, size1 + size2, size3)}
  end

  defp decode_format({bin1, bin2, bin3}, 'H') do
    [Huffman.decode(bin1),
     Huffman.decode(bin2),
     Huffman.decode(bin3)]
  end

  defp decode_format({bin1, bin2, bin3}, 'L') do
    [LZW.decode(bin1),
     LZW.decode(bin2),
     LZW.decode(bin3)]
  end

  defp split_channels(pixels) do
    List.foldr(
      pixels,
      {[],[],[]},
      fn({c1, c2, c3}, {l1, l2, l3}) -> {[c1|l1], [c2|l2], [c3|l3]} end
    )
  end

  defp transform(pixels, :rgb), do: pixels
  defp transform(pixels, :ycc) do
    Enum.map(pixels, fn({r, g, b}) ->
      { trunc(0.299*r + 0.587*g + 0.114*b),
        trunc(128 - 0.168736*r - 0.331264*g + 0.5*b),
        trunc(128 + 0.5*r - 0.418688*g - 0.081312*b)
      } end)
  end

  defp detransform(pixels, 'R'), do: pixels
  defp detransform(pixels, 'Y') do
    Enum.map(pixels, fn({y, cb, cr}) ->
      { trunc(y + 1.402*(cr - 128)),
        trunc(y - 0.344136*(cb - 128) - 0.714136*(cr - 128)),
        trunc(y + 1.772*(cb - 128))
      } end)
  end

  defp extract_header(
    <<"xxDCYxx",
    encoding::size(8), _::size(8), _::size(8), "xx",
    color_space::size(8), _::size(8), _::size(8), "xx",
    wight::size(16), height::size(16), rest::binary>>
  ) do
    {[encoding], [color_space], wight, height, rest}
  end
end
