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

  defp handle2(_operations, "out", []) do
    1
  end

  defp handle2(_operations, "out", [_target | _tail]) do
    0
  end

  defp handle2(operations, current_node, [target | tail] = targets) do
    [{^current_node, list_of_outputs}] =
      operations |> Enum.filter(fn {elem, _} -> elem == current_node end)

    if Enum.find(list_of_outputs, fn elem -> elem == target end) do
      handle2(operations, target, tail)
    else
      results =
        list_of_outputs
        |> Enum.map(fn output -> handle2(operations, output, targets) end)
        |> Enum.sum()

      results
    end
  end

  def part2(input_data) do
    data = parse_input(input_data)

    {:ok,
     handle2(data, "svr", ["fft", "dac", "out"]) + handle2(data, "svr", ["dac", "fft", "out"])}
  end
end
