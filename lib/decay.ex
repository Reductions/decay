defmodule Decay do
  def main(args)do
    args
    |> parse_args
  end

  defp parse_args(args) do
    {switches, _} = args
    |> OptionParser.parse!(
      strict: [in: :string,
               out: :string,
               rgb: :boolean,
               ycc: :boolean,
               reduction: :integer,
               compress: :boolean,
               decompress: :boolean],
      aliases: [c: :compress,
                d: :decompress,
                r: :rgb,
                y: :ycc])
    switches
  end
end
