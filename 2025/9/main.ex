defmodule Main do
  defp load_input(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn elem -> String.length(elem) > 0 end)
    |> Enum.map(fn elem ->
      elem |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  defp largest_square(_start_point, [], largest_area) do
    {:ok, largest_area}
  end

  defp largest_square({x1, y1} = start_point, [{x2, y2} | tail], largest_area) do
    area = (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
    largest_square(start_point, tail, max(largest_area, area))
  end

  defp largest_square([_], largest_area) do
    {:ok, largest_area}
  end

  defp largest_square([point | tail], largest_area) do
    {:ok, new_large} = largest_square(point, tail, largest_area)
    largest_square(tail, new_large)
  end

  def part1(input_data) do
    data = load_input(input_data)
    largest_square(data, 0)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
