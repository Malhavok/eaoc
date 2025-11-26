defmodule Main do
  def part1(input_data) do
    as_charlist = input_data |> String.trim() |> String.to_charlist()
    {:ok, part1_counter(as_charlist, 0)}
  end

  defp part1_counter([], acc) do
    acc
  end

  defp part1_counter([?( | tail], acc) do
    part1_counter(tail, acc + 1)
  end

  defp part1_counter([?) | tail], acc) do
    part1_counter(tail, acc - 1)
  end

  def part2(input_data) do
    as_charlist = input_data |> String.trim() |> String.to_charlist()
    part2_counter(as_charlist, 0, 0)
  end

  defp part2_counter(_, index, -1) do
    {:ok, index}
  end

  defp part2_counter([?( | tail], index, acc) do
    part2_counter(tail, index + 1, acc + 1)
  end

  defp part2_counter([?) | tail], index, acc) do
    part2_counter(tail, index + 1, acc - 1)
  end
end
