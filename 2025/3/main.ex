defmodule Main do
  def get_largest_digit(digits_list, stop_at_tail_length, largest_info)
      when length(digits_list) == stop_at_tail_length do
    largest_info
  end

  def get_largest_digit([head | tail], stop_at_tail_length, {largest_value, _old_tail})
      when head > largest_value do
    get_largest_digit(tail, stop_at_tail_length, {head, tail})
  end

  def get_largest_digit([_head | tail], stop_at_tail_length, largest_info) do
    get_largest_digit(tail, stop_at_tail_length, largest_info)
  end

  def get_largest_number(_digits, gathered, expected_length)
      when length(gathered) == expected_length do
    gathered |> Enum.reverse() |> Integer.undigits()
  end

  def get_largest_number(digits, gathered, expected_length) do
    {largest_digit, tail} =
      get_largest_digit(digits, expected_length - length(gathered) - 1, {-1, []})

    get_largest_number(tail, [largest_digit | gathered], expected_length)
  end

  def get_largest_number(number_string, iterations) do
    digits = number_string |> String.to_integer() |> Integer.digits()
    largest_number = get_largest_number(digits, [], iterations)
    largest_number
  end

  def part1(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn elem -> String.length(elem) > 0 end)

    {:ok, for(elem <- lines, do: get_largest_number(elem, 2)) |> Enum.sum()}
  end

  def part2(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn elem -> String.length(elem) > 0 end)

    {:ok, for(elem <- lines, do: get_largest_number(elem, 12)) |> Enum.sum()}
  end
end
