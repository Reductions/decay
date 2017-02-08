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
               reduction: :string,
               compress: :boolean,
               decompress: :boolean],
      aliases: [c: :compress,
                d: :decompress,
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

  defp process(%{compress: true, rgb: true, reduction: <<c1, c2, c3>>, in: file_name}) do
    {width, height, pixels} = Png.get_image_info(file_name)
    pixels
    |> Image.encode_image({c1 - 47, c2 - 47, c3 - 47}, :huf, :rgb)
    |> add_header(<<"xxDCYxxRGBxx", c1, c2, c3, "xx", width::size(16), height::size(16)>>)
    |> Image.write_image(String.replace_suffix(file_name, ".png", "-RGB-#{<<c1,c2,c3>>}.dcy"))
  end

  defp process(%{compress: true, ycc: true, reduction: <<c1, c2, c3>>, in: file_name}) do
    {width, height, pixels} = Png.get_image_info(file_name)
    pixels
    |> Image.encode_image({c1 - 47, c2 - 47, c3 - 47}, :huf, :ycc)
    |> add_header(<<"xxDCYxxYCCxx", c1, c2, c3, "xx", width::size(16), height::size(16)>>)
    |> Image.write_image(String.replace_suffix(file_name, ".png", "-YCC-#{<<c1,c2,c3>>}.dcy"))
  end

  def add_header(bin, header), do: header <> bin
end
