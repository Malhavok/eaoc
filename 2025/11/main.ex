defmodule Main do
  @cache :cache_table

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

  defp handle2(_operations, "out", ["out"]) do
    1
  end

  defp handle2(_operations, "out", _target) do
    0
  end

  defp handle2(operations, target, [target | tail]) do
    handle2(operations, target, tail)
  end

  defp handle2(operations, current_node, targets) do
    cache_key = {current_node, targets}

    case :ets.lookup(@cache, cache_key) do
      [{^cache_key, value}] ->
        value

      [] ->
        [{^current_node, list_of_outputs}] =
          operations |> Enum.filter(fn {elem, _} -> elem == current_node end)

        result =
          list_of_outputs
          |> Enum.map(fn output -> handle2(operations, output, targets) end)
          |> Enum.sum()

        :ets.insert(@cache, {cache_key, result})
        result
    end
  end

  def part2(input_data) do
    data = parse_input(input_data)

    :ets.new(@cache, [:named_table, :set])

    path1_result = handle2(data, "svr", ["dac", "fft", "out"])
    path2_result = handle2(data, "svr", ["fft", "dac", "out"])

    {:ok, path1_result + path2_result}
  end
end
