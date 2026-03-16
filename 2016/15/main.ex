# Part 1 is using Chinese Reminder Theorem.
# I could shoot it with SCIP or GLPSOL, but decided to ask GPT about ways of solving these kind of problems.
#
# Assumption: all moduli are prime / co-prime
#
# Algo is as follows:
#
# 1.
# we take (x + Ki) % Ni = 0
# and convert it into x = Ji (mod Ni)
# this is x = -Ki % Ni = ai
#
# 2.
# calculate P = N1 * N2 * ... * Nn
#
# 3.
# calculate Mi = P / Ki
#
# 4.
# calculate yi such as Mi yi = 1 (mod Ni)
# this can be calculated by searching linearly y from range 1 to (Ni - 1)
#
# 5.
# calculate Ti = ai * Mi * yi
#
# 6.
# calculate final solution x = (T1 + T2 + ... + Tn) % P

defmodule Main do
  defp parse_line(line) do
    # Disc #1 has 13 positions; at time=0, it is at position 1.
    [_, counter_raw, _, num_pos, _, _, _, _, _, _, _, start_pos_raw] = String.split(line, " ")
    {_, counter} = String.split_at(counter_raw, 1)
    {start_pos, _} = String.split_at(start_pos_raw, -1)

    {
      String.to_integer(counter),
      String.to_integer(num_pos),
      String.to_integer(start_pos)
    }
  end

  defp parse_input(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(fn line -> parse_line(line) end)
  end

  defp convert_inputs([], result) do
    {:ok, result |> Enum.reverse()}
  end

  defp convert_inputs([{index, modulo, offset} | tail], result) do
    # Our input is:
    # index – 1-based disc index, which also is the delay before capsule reaches this disk
    # modulo – modulo value for the disc
    # offset – start offset of the disc
    # So, what we're looking for is: (t + index + offset) % modulo == 0
    zero_index = -(offset + index)
    final_index = iterate_for_modulo(zero_index, modulo)
    convert_inputs(tail, [{final_index, modulo} | result])
  end

  defp iterate_for_modulo(value, modulo) when value < 0 do
    iterate_for_modulo(value + modulo, modulo)
  end

  defp iterate_for_modulo(value, modulo) do
    rem(value, modulo)
  end

  defp algo_part_2(part_1_list) do
    part_1_list
    |> Enum.map(fn {_, modulo} -> modulo end)
    |> Enum.reduce(1, fn value, acc -> acc * value end)
  end

  defp algo_search_y(capital_M, modulo) do
    result =
      1..(modulo - 1)
      |> Enum.find(fn potential_y -> rem(capital_M * potential_y, modulo) == 1 end)

    {:ok, result}
  end

  defp algo_part_3_4_5([], _, result) do
    {:ok, result |> Enum.reverse()}
  end

  defp algo_part_3_4_5([{a_n, modulo} | tail], capital_P, result) do
    capital_M = div(capital_P, modulo)
    {:ok, y} = algo_search_y(capital_M, modulo)
    capital_T = a_n * capital_M * y
    algo_part_3_4_5(tail, capital_P, [capital_T | result])
  end

  defp run_algo(input) do
    {:ok, a_n_input} = convert_inputs(input, [])
    capital_P = algo_part_2(a_n_input)
    {:ok, capital_Ts} = algo_part_3_4_5(a_n_input, capital_P, [])
    final_T = capital_Ts |> Enum.sum()
    {:ok, rem(final_T, capital_P)}
  end

  def part1(input_data) do
    input = parse_input(input_data)
    run_algo(input)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
