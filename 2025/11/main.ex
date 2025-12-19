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

  defp handle2(_operations, target, target) do
    1
  end

  defp handle2(_operations, "out", _target) do
    0
  end

  defp handle2(operations, current_node, target) do
    [{^current_node, list_of_outputs}] =
      operations |> Enum.filter(fn {elem, _} -> elem == current_node end)

    list_of_outputs
    |> Enum.map(fn output -> handle2(operations, output, target) end)
    |> Enum.sum()
  end

  def part2(input_data) do
    data = parse_input(input_data)

    path1 = [
      handle2(data, "svr", "dac"),
      handle2(data, "dac", "fft"),
      handle2(data, "fft", "out")
    ]

    path1_result =
      if Enum.any?(path1, fn elem -> elem == 0 end) do
        0
      else
        List.last(path1)
      end

    path2 = [
      handle2(data, "svr", "fft"),
      handle2(data, "fft", "dac"),
      handle2(data, "dac", "out")
    ]

    path2_result =
      if Enum.any?(path2, fn elem -> elem == 0 end) do
        0
      else
        List.last(path2)
      end

    {:ok, path1_result + path2_result}
  end
end
