defmodule Main do
  def part1(input_data) do
    result =
      input_data
      |> String.split("\n")
      |> Enum.filter(fn line -> String.length(line) != 0 end)
      |> Enum.map(fn line -> String.to_charlist(line) end)
      |> Enum.zip()
      |> Enum.map(fn in_tuple -> Tuple.to_list(in_tuple) end)
      |> Enum.map(fn line ->
        line
        |> Enum.frequencies()
        |> Map.to_list()
        |> Enum.sort(fn {_, count1}, {_, count2} -> count1 >= count2 end)
        |> Enum.map(fn {value, _} -> value end)
        |> Enum.at(0)
      end)

    {:ok, result}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
