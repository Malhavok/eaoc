defmodule Main do
  require Integer

  def find_duplicated_numbers(range_str) do
    [range_start_str, range_end_str] = range_str |> String.split("-")
    find_duplicated_numbers(String.to_integer(range_start_str), String.to_integer(range_end_str))
  end

  def find_duplicated_numbers(range_start, range_end) do
    {:ok, range_start..range_end |> Enum.filter(fn elem -> is_duplicate?(elem) end)}
  end

  def is_duplicate?(number) do
    digits_count = number |> Integer.digits() |> length()
    is_duplicate?(number, digits_count)
  end

  def is_duplicate?(_number, digits_count) when Integer.is_odd(digits_count) do
    false
  end

  def is_duplicate?(number, digits_count) do
    divider = Integer.pow(10, div(digits_count, 2))
    div(number, divider) == rem(number, divider)
  end

  def search_for_duplicates([], duplicates) do
    {:ok, duplicates}
  end

  def search_for_duplicates([head | tail], duplicates) do
    {:ok, new_duplicates} = find_duplicated_numbers(head)
    search_for_duplicates(tail, new_duplicates ++ duplicates)
  end

  def part1(input_data) do
    ranges = input_data |> String.trim() |> String.split(",")
    {:ok, duplicates} = search_for_duplicates(ranges, [])
    {:ok, duplicates |> Enum.sum()}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
