defmodule Main do
  defp parse_input(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn line_list ->
      [in_data | out_data] = line_list
      {String.replace(in_data, ":", ""), out_data}
    end)
  end

  defp handle1(operations, current_node) do
    [{^current_node, list_of_outputs}] =
      operations |> Enum.filter(fn {elem, _} -> elem == current_node end)

    if list_of_outputs == ["out"] do
      1
    else
      results =
        list_of_outputs |> Enum.map(fn output -> handle1(operations, output) end) |> Enum.sum()

      results
    end
  end

  def part1(input_data) do
    data = parse_input(input_data)
    {:ok, handle1(data, "you")}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
