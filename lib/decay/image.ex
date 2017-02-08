defmodule Decay.Image do
  alias Decay.Huffman

  def encode_image(pixels, {r1, r2, r3}, :huf, space) do
    {c1, c2, c3} =
      pixels
      |> List.flatten
      |> transform(space)
      |> split_channels
    e1 = Huffman.encode(c1, r1)
    e2 = Huffman.encode(c2, r2)
    e3 = Huffman.encode(c3, r3)

    <<byte_size(e1)::size(32),
      byte_size(e2)::size(32),
      byte_size(e3)::size(32),
      e1::binary,
      e2::binary,
      e3::binary>>
  end

  def write_image(bin, file_name) do
    {:ok, file} = File.open(file_name, [:write])
    IO.binwrite(file, bin)
    File.close(file)
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
end
