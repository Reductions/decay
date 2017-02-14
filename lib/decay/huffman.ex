defmodule Decay.Huffman do
  def encode(pixels, reduction) do
    { list, remapping } =
      count(pixels, counter_init())
      |> Map.to_list
      |> Enum.sort(&(elem(&1,1) < elem(&2,1)))
      |> reduce(reduction)
    tree = create_tree(list)
    <<serialize_tree(tree)::bitstring,
      serialize_content(pixels, map_from_tree(tree), remapping)::bitstring>>
    |> norm
  end

  def decode(binary) do
    {tree, rest} = decode_tree(binary)
    decode_pixels(rest, tree)
  end

  # private functions

  defp norm(x) when is_binary(x), do: x
  defp norm(x), do: norm(<<x::bitstring, 0::size(1)>>)

  defp mod(x) when x < 0, do: -x
  defp mod(x), do: x

  defp counter_init() do
    Enum.into((for i <- (0..255), do: {i, 0}), Map.new)
  end

  defp mappint_init() do
    Enum.into((for i <- (0..255), do: {i, i}), Map.new)
  end

  defp count([], counter), do: counter
  defp count([pixel | tail], counter) do
    if pixel < 0 or pixel  > 255, do: IO.puts pixel
    count(tail, %{counter | pixel => counter[pixel]+1})
  end

  defp reduce(list, reduction) do
    do_reduce(list, mappint_init(), div((256* (reduction - 1)),reduction))
  end

  defp do_reduce([{_,0}|tail], mapping, 0), do: do_reduce(tail, mapping, 0)
  defp do_reduce([{_,0}|tail], mapping, n), do: do_reduce(tail, mapping, n-1)
  defp do_reduce(list, mapping, 0), do: {list, mapping}
  defp do_reduce([{value, count}|tail], mapping, n) do
    {new_value, list} = squash({value, count}, tail)
    do_reduce(list, %{mapping | value => new_value}, n - 1)
  end

  defp squash({value, count}, list) do
    new_value = find(value, list)
    {new_value, insert_in(count, new_value, list)}
  end

  defp find(value, list, diff \\257, new_value \\ -1)
  defp find(_, [], _, new_value), do: new_value
  defp find(value, [{test_value, _} | tail], diff, new_value) do
    test_diff = mod(value - test_value)
    if test_diff > diff do
      find(value, tail, diff, new_value)
    else
      find(value, tail, test_diff, test_value)
    end
  end

  defp insert_in(add_count, value, [{value, count}|tail]) do
    bubble_up({value, count + add_count}, tail)
  end
  defp insert_in(add_count, value, [head | tail]) do
    [head | insert_in(add_count, value, tail)]
  end

  defp bubble_up(head, []), do: [head]
  defp bubble_up({value, count}, [{head_v, head_c} | tail]) when count > head_c do
    [{head_v, head_c} | bubble_up({value, count}, tail)]
  end
  defp bubble_up(head, list), do: [head | list]

  defp create_tree([{tree, _}]), do: tree
  defp create_tree([first, second | rest]) do
    connect(first, second)
    |> place_in(rest)
    |> create_tree
  end

  defp connect({left_sub_tree, left_count}, {right_sub_tree, right_count}) do
    {{left_sub_tree, right_sub_tree}, left_count + right_count}
  end

  defp place_in(tree, []), do: [tree]
  defp place_in(tree, [front | rest]) do
    if tree_size(tree) > tree_size(front) do
      [front | place_in(tree, rest)]
    else
      [tree , front | rest]
    end
  end

  defp tree_size({_, size}), do: size

  defp serialize_tree({left, right}) do
    <<0::size(1), serialize_tree(left)::bitstring,
      serialize_tree(right)::bitstring>>
  end
  defp serialize_tree(leaf) do
    <<1::size(1), leaf::size(8)>>
  end

  defp map_from_tree(tree, binary \\ <<>>)
  defp map_from_tree({left, right}, binary) do
    Map.merge(map_from_tree(left, <<binary::bitstring, 0::size(1)>>),
      map_from_tree(right, <<binary::bitstring, 1::size(1)>>))
  end
  defp map_from_tree(leaf, binary), do: %{leaf => binary}

  defp serialize_content(pixels, encode_map, pixel_remaping, encoding \\ <<>>)
  defp serialize_content([], _, _, encoding), do: encoding
  defp serialize_content([pixel | rest], encode_map, pixel_remaping, encoding) do
    serialize_content(rest, encode_map, pixel_remaping,
      <<encoding::bitstring, encode_map[find_remaping(pixel, pixel_remaping)]::bitstring>>)
  end

  defp find_remaping(pixel, pixel_remaping) do
    if pixel_remaping[pixel] == pixel do
      pixel
    else
      find_remaping(pixel_remaping[pixel], pixel_remaping)
    end
  end

  defp decode_tree(code)
  defp decode_tree(<<1::size(1), pixel::size(8), rest::bitstring>>), do: {pixel, rest}
  defp decode_tree(<<0::size(1), rest::bitstring>>) do
    {left, rest} = decode_tree(rest)
    {right, rest} = decode_tree(rest)
    {{left, right}, rest}
  end

  defp decode_pixels(code, tree, pixels \\ [])
  defp decode_pixels(<<>>, _, pixels), do: pixels |> trim |> Enum.reverse
  defp decode_pixels(code, tree, pixels) do
    {pixel, rest} = find_pixel(code, tree)
    decode_pixels(rest, tree, [pixel | pixels])
  end

  defp find_pixel(<<>>, _), do: {nil, <<>>}
  defp find_pixel(<<0::size(1), rest::bitstring>>, {left, _}), do: find_pixel(rest, left)
  defp find_pixel(<<1::size(1), rest::bitstring>>, {_, right}), do: find_pixel(rest, right)
  defp find_pixel(code, pixel), do: {pixel, code}

  defp trim([nil|rest]), do: trim(rest)
  defp trim(x), do: x
end
