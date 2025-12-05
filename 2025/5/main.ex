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

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
