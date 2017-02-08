defmodule Decay.Png do
  import Imagineer, only: [load: 1]

  def get_image_info(image) do
    {:ok, png} = load(image)
    {png.width, png.height, png.pixels}
  end
end
