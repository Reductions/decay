defmodule Decay do
  alias Decay.Png
  alias Decay.Huffman
  alias Decay.Image
  #import Decay.Image

  def main(args)do
    args
    |> parse_args
    |> process
  end

  defp parse_args(args) do
    {switches, _} = args
    |> OptionParser.parse!(
      strict: [in: :string,
               rgb: :boolean,
               ycc: :boolean,
               huffman: :boolean,
               lzw: :boolean,
               reduction: :string,
               compress: :boolean,
               decompress: :boolean],
      aliases: [c: :compress,
                d: :decompress,
                h: :huffman,
                l: :lzw,
                r: :rgb,
                y: :ycc])
    Enum.into(switches, Map.new)
  end

  defp process(%{compress: true, decompress: true}) do
    raise "Can not both compress and decompress"
  end

  defp process(%{compress: true, rgb: true, ycc: true}) do
    raise "Can not both encode in RGB and YCrCb"
  end

  defp process(%{compress: true, huffman: true, lzw: true}) do
    raise "Can not both encode with huffman and LZW"
  end

  defp process(%{decompress: true, in: file_name}) do
    # {wight, height, pixels} =
    file_name
    |> Image.decode_image
    |> Png.write_image(String.replace_suffix(file_name, "dcy", "png"))

  end

  defp process(%{compress: true, huffman: true, rgb: true, reduction: <<c1, c2, c3>>, in: file_name}) do
    {width, height, pixels} = Png.get_image_info(file_name)
    pixels
    |> Image.encode_image({( c1 - 48 )*2 + 1, ( c2 - 48 )*2 + 1, ( c3 - 48 )*2 + 1}, :huf, :rgb)
    |> add_header(<<"xxDCYxxHUFxxRGBxx", width::size(16), height::size(16)>>)
    |> Image.write_image(String.replace_suffix(file_name, ".png", "-HUF-RGB-#{<<c1,c2,c3>>}.dcy"))
  end

  defp process(%{compress: true, huffman: true, ycc: true, reduction: <<c1, c2, c3>>, in: file_name}) do
    {width, height, pixels} = Png.get_image_info(file_name)
    pixels
    |> Image.encode_image({( c1 - 48 )*2 + 1, ( c2 - 48 )*2 + 1, ( c3 - 48 )*2 + 1}, :huf, :ycc)
    |> add_header(<<"xxDCYxxHUFxxYCCxx", width::size(16), height::size(16)>>)
    |> Image.write_image(String.replace_suffix(file_name, ".png", "-HUF-YCC-#{<<c1,c2,c3>>}.dcy"))
  end

  defp process(%{compress: true, lzw: true, rgb: true, reduction: <<c1, c2, c3>>, in: file_name}) do
    {width, height, pixels} = Png.get_image_info(file_name)
    pixels
    |> Image.encode_image({( c1 - 48 )*2 + 1, ( c2 - 48 )*2 + 1, ( c3 - 48 )*2 + 1}, :lzw, :rgb)
    |> add_header(<<"xxDCYxxLZWxxRGBxx", width::size(16), height::size(16)>>)
    |> Image.write_image(String.replace_suffix(file_name, ".png", "-LZW-RGB-#{<<c1,c2,c3>>}.dcy"))
  end

  defp process(%{compress: true, lzw: true, ycc: true, reduction: <<c1, c2, c3>>, in: file_name}) do
    {width, height, pixels} = Png.get_image_info(file_name)
    pixels
    |> Image.encode_image({( c1 - 48 )*2 + 1, ( c2 - 48 )*2 + 1, ( c3 - 48 )*2 + 1}, :lzw, :ycc)
    |> add_header(<<"xxDCYxxLZWxxYCCxx", width::size(16), height::size(16)>>)
    |> Image.write_image(String.replace_suffix(file_name, ".png", "-LZW-YCC-#{<<c1,c2,c3>>}.dcy"))
  end

  def add_header(bin, header), do: header <> bin
end
