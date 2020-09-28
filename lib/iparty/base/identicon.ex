defmodule Iparty.Base.Identicon do
  @moduledoc false
  defstruct hash: nil, color: nil, grid: nil, pixelmap: nil
  alias __MODULE__, as: Identicon

  def create(input, :svg), do: input |> process()
  def create(input, :file), do: input |> process() |> save(input)

  def process(input) do
    input
    |> hash()
    |> color()
    |> make_grid()
    |> filter_odd()
    |> make_pixelmap()
    |> draw()
  end

  defp hash(data) do
    hash = :crypto.hash(:sha3_512, data) |> :binary.bin_to_list()
    %Identicon{hash: hash}
  end

  defp color(%Identicon{hash: [r, g, b | _]} = image),
    do: %Identicon{image | color: {r, g, b}}

  defp make_grid(%Identicon{hash: hash} = image) do
    grid =
      hash
      |> Enum.chunk_every(2)
      |> Enum.map(&mirror/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon{image | grid: grid}
  end

  defp mirror([one, two | _] = data),
    do: data ++ [two, one]

  defp filter_odd(%Identicon{grid: grid} = image) do
    grid = Enum.filter(grid, fn {code, _} -> rem(code, 2) == 0 end)
    %Identicon{image | grid: grid}
  end

  defp make_pixelmap(%Identicon{grid: grid} = image) do
    pixelmap =
      Enum.map(grid, fn {_, index} ->
        h = rem(index, 5) * 50
        v = div(index, 5) * 50
        # Top left | Bottom right
        {{h, v}, {h + 50, v + 50}}
      end)

    %Identicon{image | pixelmap: pixelmap}
  end

  defp draw(%Identicon{color: color, pixelmap: pixelmap}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixelmap, fn {begin, stop} ->
      :egd.filledRectangle(image, begin, stop, fill)
    end)

    :egd.render(image)
  end

  def save(image, input) do
    File.write("#{input}.png", image)
  end
end
