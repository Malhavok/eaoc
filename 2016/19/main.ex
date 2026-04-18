defmodule Main do
  require Integer

  defp parse_input(input_data) do
    input_data |> String.split("\n", trim: true) |> Enum.at(0) |> String.to_integer()
  end

  defp reduce_count(count) do
    reduce_count(1, count, 1)
  end

  defp reduce_count(first_index, 1, _order) do
    {:ok, first_index}
  end

  defp reduce_count(first_index, count, order) when Integer.is_even(count) do
    reduce_count(first_index, div(count, 2), order * 2)
  end

  defp reduce_count(first_index, count, order) do
    reduce_count(first_index + order * 2, div(count, 2), order * 2)
  end

  def part1(input_data) do
    count = parse_input(input_data)

    # Ok, simple reduction won't work in this case.
    # We can think of it this way tho:
    # First step removes each even element, then redefines what "even" mean.
    # There are two cases – we have even elements at start – which means we
    # won't eat the first element, or we have odd elements and the "first"
    # element will be eaten.

    {:ok, _result} = reduce_count(count)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
