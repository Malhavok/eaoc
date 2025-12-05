defmodule Main do
  defp parse_input_ingredients([""], ranges, ingredients) do
    {:ok, ranges, ingredients}
  end

  defp parse_input_ingredients([head | tail], ranges, ingredients) do
    parse_input_ingredients(tail, ranges, [String.to_integer(head) | ingredients])
  end

  defp parse_input_ranges(["" | tail], ranges, ingredients) do
    parse_input_ingredients(tail, ranges, ingredients)
  end

  defp parse_input_ranges([head | tail], ranges, ingredients) do
    [start_value, end_value] = String.split(head, "-", parts: 2)
    new_range = {String.to_integer(start_value), String.to_integer(end_value)}
    parse_input_ranges(tail, [new_range | ranges], ingredients)
  end

  defp does_belong_to_range?(ranges, ingredient) do
    Enum.any?(ranges, fn {start_value, end_value} ->
      start_value <= ingredient && ingredient <= end_value
    end)
  end

  def part1(input_data) do
    lines = input_data |> String.split("\n")
    {:ok, ranges, ingredients} = parse_input_ranges(lines, [], [])
    belonging = Enum.filter(ingredients, fn item -> does_belong_to_range?(ranges, item) end)
    {:ok, length(belonging)}
  end

  defp sum_ranges([], result) do
    {:ok, result}
  end

  defp sum_ranges([{start_value, end_value} | tail], result) do
    sum_ranges(tail, result + end_value - start_value + 1)
  end

  defp merge_ranges([], merged, range) do
    {:ok, [range | merged]}
  end

  defp merge_ranges([{start_value, end_value} | tail], merged, nil) do
    merge_ranges(tail, merged, {start_value, end_value})
  end

  defp merge_ranges([{start_value, end_value} | tail], merged, {range_start, range_end})
       when range_end < start_value do
    merge_ranges(tail, [{range_start, range_end} | merged], {start_value, end_value})
  end

  defp merge_ranges([{_start_value, end_value} | tail], merged, {range_start, range_end}) do
    merge_ranges(tail, merged, {range_start, max(end_value, range_end)})
  end

  def part2(input_data) do
    lines = input_data |> String.split("\n")
    {:ok, ranges, _ingredients} = parse_input_ranges(lines, [], [])

    # Sort ranges by their start. This way, if the next start is smaller than the previous end – we can merge them.
    sorted_ranges = ranges |> Enum.sort(fn {s1, _e1}, {s2, _e2} -> s1 <= s2 end)
    # Merge ranges prepared in this way.
    {:ok, merged} = merge_ranges(sorted_ranges, [], nil)

    sum_ranges(merged, 0)
  end
end
