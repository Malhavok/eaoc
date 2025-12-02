defmodule Main do
  require Integer

  def find_duplicated_numbers(range_str, fun) do
    [range_start_str, range_end_str] = range_str |> String.split("-")

    find_duplicated_numbers(
      String.to_integer(range_start_str),
      String.to_integer(range_end_str),
      fun
    )
  end

  def find_duplicated_numbers(range_start, range_end, fun) do
    {:ok, range_start..range_end |> Enum.filter(fn elem -> fun.(elem) end)}
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

  def search_for_duplicates([], duplicates, _fun) do
    {:ok, duplicates}
  end

  def search_for_duplicates([head | tail], duplicates, fun) do
    {:ok, new_duplicates} = find_duplicated_numbers(head, fun)
    search_for_duplicates(tail, new_duplicates ++ duplicates, fun)
  end

  def part1(input_data) do
    ranges = input_data |> String.trim() |> String.split(",")
    {:ok, duplicates} = search_for_duplicates(ranges, [], &is_duplicate?/1)
    {:ok, duplicates |> Enum.sum()}
  end

  def is_invalid?(number) do
    digits = number |> Integer.digits()
    digits_count = digits |> length()

    if digits_count == 1 do
      false
    else
      1..div(digits_count, 2)
      |> Enum.filter(fn entry -> rem(digits_count, entry) == 0 end)
      |> Enum.map(fn entry -> is_invalid?(digits, entry) end)
      |> Enum.any?()
    end
  end

  def is_invalid?(digits, count) do
    [first | rest] = digits |> Enum.chunk_every(count)
    rest |> Enum.all?(fn entry -> entry == first end)
  end

  def part2(input_data) do
    ranges = input_data |> String.trim() |> String.split(",")
    {:ok, duplicates} = search_for_duplicates(ranges, [], &is_invalid?/1)
    {:ok, duplicates |> Enum.sum()}
  end
end
