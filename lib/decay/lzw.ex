defmodule Decay.LZW do
  def encode(pixels, reduction) do
    pixels
    |> do_encode(div((reduction - 1), 2))
    |> norm
  end

  def decode(bin) do
    bin
    |> do_decode
  end

  #private functios

  defp norm(x) when is_binary(x), do: x
  defp norm(x), do: norm(<<x::bitstring, 0::size(1)>>)

  defp mod(n) when n < 0, do: -n
  defp mod(n), do: n

  defp branch(pixel, margin) do
    ( for i <- ((pixel - margin)..(pixel + margin)), do: i )
    |> Enum.sort(&(mod(&1 - pixel) < mod(&2 - pixel)))
  end

  defp init_tree(n \\ 0) do
    { n, %{}}
  end

  defp init_map() do
    %{0 => []}
  end

  defp do_encode(pixels, margin, tree \\ init_tree, n \\ 1, bin \\ <<>>)
  defp do_encode([], _, _, _, bin), do: bin
  defp do_encode(pixels, margin, tree, n, bin) do
    {_, enc, rest, tree} =
      encode_single(pixels, margin, n, -1, -1, tree, 0)
    do_encode(rest, margin, tree, n + 1, <<bin::bitstring, enc::bitstring>>)
  end

  defp encode_single([], _, num, enc, inc,  _, length) do
    sz = bits(num-1)
    {length, <<enc::size(sz), inc::size(8)>>, [], nil}
  end
  defp encode_single(rest, _, num, enc, inc, nil, length) do
    sz = bits(num-1)
    {length, <<enc::size(sz), inc::size(8)>>, rest, init_tree(num)}
  end
  defp encode_single([pixel|rest], margin, num, enc, inc, {next_enc, map}, length) do
    {{length, enc, rest, tree}, subst} =
      pixel
      |> branch(margin)
      |> Enum.map(&{encode_single(rest, margin, num, next_enc, &1, map[&1], length + 1), &1})
      |> Enum.max_by(&elem(elem(&1,0),0))
    {length, enc, rest, {next_enc, Map.put(map, subst, tree)}}
  end

  defp do_decode(bin, num \\ 0, map \\ init_map, list \\ [])
  defp do_decode(bin, _, _, list) when bit_size(bin) < 8 do
    list
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.reverse
    |> List.flatten
  end
  defp do_decode(bin, num, map, list) do
    sz = bits(num)
    <<enc::size(sz), pixel::size(8), rest::bitstring>> = bin
    word = [pixel | map[enc]]
    do_decode(rest, num + 1, Map.put(map, num + 1, word), [ word | list ])
  end

  defp bits(x, n \\ 0)
  defp bits(0, n), do: n
  defp bits(x, n), do: bits(div(x,2), n+1)
end
