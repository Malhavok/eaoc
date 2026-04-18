defmodule Main do
  @trap_tile ?^
  @safe_tile ?.

  @trap_cases MapSet.new([~c"^..", ~c"..^", ~c"^^.", ~c".^^"])

  defp parse_input(input_data) do
    input_data |> String.split("\n", trim: true) |> Enum.at(0) |> String.to_charlist()
  end

  defp is_trap?(left, center, right) do
    trap_key = [left, center, right]
    MapSet.member?(@trap_cases, trap_key)
  end

  defp get_next_symbol(left, center, right) do
    if is_trap?(left, center, right) do
      @trap_tile
    else
      @safe_tile
    end
  end

  defp get_next(state) do
    safe_state = [@safe_tile] ++ state ++ [@safe_tile]
    get_next(safe_state, [])
  end

  defp get_next([_, _], output) do
    {:ok, Enum.reverse(output)}
  end

  defp get_next([left | tail], output) do
    [center, right | _] = tail
    new_tile = get_next_symbol(left, center, right)
    get_next(tail, [new_tile | output])
  end

  defp count_safe(state) do
    result = Enum.count(state, fn elem -> elem == @safe_tile end)
    {:ok, result}
  end

  defp iterate(initial_state, count) do
    iterate(initial_state, count, 0)
  end

  defp iterate(_state, 0, sum_so_far) do
    {:ok, sum_so_far}
  end

  defp iterate(state, count, sum_so_far) do
    {:ok, safe_in_state} = count_safe(state)
    {:ok, new_state} = get_next(state)
    iterate(new_state, count - 1, sum_so_far + safe_in_state)
  end

  def part1(input_data) do
    initial_state = parse_input(input_data)
    iterate(initial_state, 40)
  end

  def part2(input_data) do
    initial_state = parse_input(input_data)
    iterate(initial_state, 400_000)
  end
end
