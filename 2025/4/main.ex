defmodule Main do
  @neighbours [{1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, 0}, {-1, -1}]
  @max_around 4

  defp count_from_position(_point, ?., _grid) do
    {:ok, 0}
  end

  defp count_from_position(point, ?@, grid) do
    {:ok, neighbours} = Grid.get_neighbours(grid, point, @neighbours)

    counter =
      neighbours
      |> Enum.map(fn {_point, entry} -> entry end)
      |> Enum.filter(fn entry -> entry == ?@ end)
      |> length()

    bump =
      if counter < @max_around do
        1
      else
        0
      end

    {:ok, bump}
  end

  defp count_neighbours([], _grid, result) do
    {:ok, result}
  end

  defp count_neighbours([point | tail], grid, result) do
    grid_entry = Map.get(grid, point)
    {:ok, addition} = count_from_position(point, grid_entry, grid)
    count_neighbours(tail, grid, result + addition)
  end

  def part1(input_data) do
    {:ok, grid} = Grid.init(input_data)
    {:ok, _counter} = count_neighbours(Map.keys(grid), grid, 0)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
