defmodule Decay.Huffman do
  def encode(pixels, %{c1: 0, c2: 0, c3: 0}) do
    tree =
    count_single(pixels, counter_init)
    |> Map.to_list
    |> Enum.sort(&(elem(&1,1) < elem(&2,1)))
    |> create_tree

    serialized_tree = serialize_tree(tree)
    encoding_map = map_from_tree(tree)
  end

  def encode(pixels, %{c1: c1, c2: c2, c3: c3}) do
    # TODO
  end

  # private functions

  defp count_single([], counter), do: counter
  defp count_single([[] | tail], counter), do: count_single(tail, counter)
  defp count_single([[to_count | rest] | tail], counter) do
    count_single([rest | tail], %{counter | to_count => counter[to_count]+1})
  end

  defp count_multi() do
  end

  defp counter_init() do
    Enum.into((for i <- (0..255), do: {i, 0}), Map.new)
  end

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
  defp place_in(tree, [front | rest]) when tree_size(tree) > tree_size(front) do
    [front | place_in(tree, rest)]
  end
  defp place_in(tree, forest), do: [tree | forest]

  defp tree_size({_, size}), do: size

  defp serialize_tree({left, right}) do
     <<0::size(1)>> <> do_serialize_tree(left) <> do_serialize_tree(right)
  end
  defp serialize_tree(leaf) do
    <<1::size(1)>> <> <<leaf::size(8)>>
  end

  defp map_from_tree(tree), do: do_map_from_tree(tree, <<>>)

  defp do_map_from_tree({left, right}, binary) do
    Map.merge(do_map_from_tree(left, binary <> <<0::size(1)>>),
      do_map_from_tree(right, binary <> <<0::size(1)>>))
  end
  defp do_map_from_tree(leaf, binary), do: %{leaf => binary}
end
