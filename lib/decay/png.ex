defmodule Decay.Png do
  import Imagineer, only: [load: 1]

  def get_image_info(image) do
    {:ok, png} = load(image)
    {png.width, png.height, png.pixels}
  end

  def write_image({wight, height, pixels}, image) do
    {:ok, file} = File.open(image, [:write])
    config = %{size: {wight, height},
               mode: {:rgb, 8},
               file: file}
    png = :png.create(config)
    pixels = Enum.map(pixels, &(conc_row(&1)))
    png = :png.append(png, {:rows, pixels})
    :png.close(png)
    File.close(file)
  end

  defp conc_row([]), do: <<>>
  defp conc_row([pix|rest]) do
    pix <> conc_row(rest)
  end
end
