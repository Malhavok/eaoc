defmodule Main do
  defp parse_input(input_data) do
    result =
      input_data
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.split("-")
        |> Enum.map(fn entry -> String.to_integer(entry) end)
        |> Enum.sort()
        |> List.to_tuple()
      end)

    {:ok, result}
  end

  defp merge_ranges([], current_min, current_max, slices) do
    {:ok, [{current_min, current_max} | slices] |> Enum.reverse()}
  end

  defp merge_ranges([{min_value, max_value} | tail], current_min, current_max, slices)
       when current_max >= min_value - 1 do
    merge_ranges(tail, current_min, Enum.max([max_value, current_max]), slices)
  end

  defp merge_ranges([{min_value, max_value} | tail], current_min, current_max, slices) do
    new_slices = [{current_min, current_max} | slices]
    merge_ranges(tail, min_value, max_value, new_slices)
  end

  defp merge_ranges(ranges_list) do
    sorted_ranges = ranges_list |> Enum.sort()
    [{first_min, first_max} | tail] = sorted_ranges
    merge_ranges(tail, first_min, first_max, [])
  end

  def part1(input_data) do
    {:ok, ranges} = parse_input(input_data)
    {:ok, merged_ranges} = merge_ranges(ranges)
    [head | _tail] = merged_ranges
    {_min_value, max_value} = head
    {:ok, max_value + 1}
  end

  defp sum_ranges([], _last_max, sum) do
    {:ok, sum}
  end

  defp sum_ranges([{min_value, max_value} | tail], last_max, sum) do
    spacing = min_value - last_max
    sum_ranges(tail, max_value + 1, sum + spacing)
  end

  def part2(input_data) do
    {:ok, ranges} = parse_input(input_data)
    {:ok, merged_ranges} = merge_ranges(ranges)
    [{_start, first_max} | tail] = merged_ranges
    {:ok, _result_between} = sum_ranges(tail, first_max + 1, 0)
  end
end
