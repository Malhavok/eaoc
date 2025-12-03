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

  def get_largest_number(number_string) do
    digits = number_string |> String.to_integer() |> Integer.digits()
    {largest_digit, tail} = get_largest_digit(digits, 1, {-1, []})
    {next_digit, _tail} = get_largest_digit(tail, 0, {-1, []})
    [largest_digit, next_digit] |> Integer.undigits()
  end

  def part1(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn elem -> String.length(elem) > 0 end)

    {:ok, for(elem <- lines, do: get_largest_number(elem)) |> Enum.sum()}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
