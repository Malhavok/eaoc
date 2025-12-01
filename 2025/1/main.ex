defmodule Main do
  @start_position 50
  @total_numbers 100

  def parse_lines([], state) do
    {:ok, state}
  end

  def parse_lines(["L" <> digits_str | tail], state) do
    parse_lines(tail, [-String.to_integer(digits_str) | state])
  end

  def parse_lines(["R" <> digits_str | tail], state) do
    parse_lines(tail, [String.to_integer(digits_str) | state])
  end

  def parse_lines(["" | tail], state) do
    parse_lines(tail, state)
  end

  def apply_operations_1([], _state, zero_count) do
    {:ok, zero_count}
  end

  def apply_operations_1([count | tail], state, zero_count) do
    new_state = rem(state + count, @total_numbers)

    zero_boost =
      if new_state == 0 do
        1
      else
        0
      end

    apply_operations_1(tail, new_state, zero_count + zero_boost)
  end

  def part1(input_data) do
    {:ok, reverse_operations} = String.split(input_data, "\n") |> parse_lines([])
    operations = Enum.reverse(reverse_operations)
    apply_operations_1(operations, @start_position, 0)
  end

  def apply_operations_2([], _state, zero_count) do
    {:ok, zero_count}
  end

  def apply_operations_2([count | tail], state, zero_count) do
    new_state = state + count
    # Calculate how many times total_numbers fits into a number before and after counter.
    zero_boost = abs(div(new_state, @total_numbers) - div(state, @total_numbers))
    apply_operations_2(tail, new_state, zero_count + zero_boost)
  end

  def part2(input_data) do
    {:ok, reverse_operations} = String.split(input_data, "\n") |> parse_lines([])
    operations = Enum.reverse(reverse_operations)
    # Picking some big number so we never can go below zero.
    abs_sum_of_ops = operations |> Enum.map(fn elem -> abs(elem) end) |> Enum.sum()
    rounded_to_full = abs_sum_of_ops + @total_numbers - rem(abs_sum_of_ops, @total_numbers)
    apply_operations_2(operations, @start_position + rounded_to_full, 0)
  end
end
