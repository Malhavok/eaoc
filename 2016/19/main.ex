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

  defp build_list(0, output) do
    {:ok, output}
  end

  defp build_list(counter, output) do
    build_list(counter - 1, [counter | output])
  end

  defp reduce([elem]) do
    {:ok, elem}
  end

  defp reduce(elf_list) do
    remove_idx = div(length(elf_list), 2)
    [head | tail] = elf_list |> List.delete_at(remove_idx)
    reduce(tail ++ [head])
  end

  defp closest_power_of_3(number, power) when power * 3 > number do
    {:ok, power}
  end

  defp closest_power_of_3(number, power) do
    closest_power_of_3(number, power * 3)
  end

  def part2(input_data) do
    count = parse_input(input_data)

    # This helped me analyse the behaviour of this structure.
    2..730
    |> Enum.map(fn in_count ->
      {:ok, elf_list} = build_list(in_count, [])
      {:ok, _result} = reduce(elf_list)
      # {in_count, result} |> inspect() |> IO.puts()
    end)

    # Wow, this one is much more difficult. In the previous one I saw the half-cut
    # almost instantly, here – not so much. I thought about adding elements to some
    # "sorted" structure that would balance them on both sides somehow, but I don't
    # yet see any that would significantly help.
    # I can obviously brute-force solution – build list, cut in half, remove middle
    # element and append head to the end of the list. Repeat until a single element
    # remains. But with 3m elements this becomes at least difficult. O(log n)
    # or better solution is a must.
    #
    # Ok, observation.
    # 3 –> 3 => 4 -> 1
    # 3^2 –> 9 => 10 -> 1
    # 3^3 –> 27 => 28 –> 1
    # 3^4 –> 81 => 82 –> 1
    # 3^5 –> 243 => 244 –> 1
    #
    # Another one:
    # 2 * 3^x = 3^x, so
    # 486 –> 243
    # 162 –> 81
    #
    # It goes deeper.
    # 243 + 81 –> 324 => 81
    # So... 3^m + 3^k = 3^min(m, k) ?
    # 243 + 9 –> 252 => 9, matches
    # 81 + 3 –> 84 => 3, matches, plausible
    #
    # Testing, 243 + 9 + 3 –> 255 => 12, interesting
    #
    # However, this means we can "reduce" the number by finding power of 3 that we could subtract from it.
    #
    # Let's consider `325`. We know the result is 82.
    # Closest power of 3 is 243, subtract and we get 82 already.
    # But it's below "half" of the next power of 3.
    # Up to 2/3 of the given "value", everything matches this simple subtraction.
    # Above it "weird things happen".

    {:ok, close_power} = closest_power_of_3(count, 1)
    remainder = count - close_power

    if remainder / (close_power * 3) < 0.66 do
      {:ok, remainder}
    else
      {:error, :unknown}
    end
  end
end
