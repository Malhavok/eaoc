defmodule Main do
  defp read_lines(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn elem -> String.length(elem) > 0 end)
    |> Enum.map(fn elem -> String.split(elem, " ", trim: true) end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)

    # <3
  end

  defp perform_summation([], result) do
    result
  end

  defp perform_summation([head | tail], result) do
    perform_summation(tail, result + String.to_integer(head))
  end

  defp perform_multiplication([], result) do
    result
  end

  defp perform_multiplication([head | tail], result) do
    perform_multiplication(tail, result * String.to_integer(head))
  end

  defp apply_operation(["+" | tail]) do
    perform_summation(tail, 0)
  end

  defp apply_operation(["*" | tail]) do
    perform_multiplication(tail, 1)
  end

  def part1(input_data) do
    lines = read_lines(input_data)
    result = lines |> Enum.map(&apply_operation/1) |> Enum.sum()
    {:ok, result}
  end

  defp gather_offsets([], _offset, offsets) do
    # head here will always be 0, and we're not splitting explicitly at zero.
    [_head | tail] = offsets |> Enum.reverse()
    {:ok, tail |> Enum.reverse()}
  end

  defp gather_offsets([?\s | tail], offset, offsets) do
    gather_offsets(tail, offset + 1, offsets)
  end

  defp gather_offsets([_ | tail], offset, offsets) do
    gather_offsets(tail, offset + 1, [offset | offsets])
  end

  defp read_split_offsets([last_line | _]) do
    last_line |> String.to_charlist() |> gather_offsets(0, [])
  end

  defp split_on_offset(line, [], parts) do
    [line | parts]
  end

  defp split_on_offset(line, [offset | rest], parts) do
    {prefix, new_part} = line |> String.split_at(offset)
    split_on_offset(prefix, rest, [new_part | parts])
  end

  defp split_on_offsets(line, offsets) do
    split_on_offset(line, offsets, [])
  end

  defp convert_tail(tail) do
    tail
    |> Enum.reverse()
    |> Enum.map(&String.to_charlist/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&List.to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn elem -> elem |> String.length() > 0 end)
  end

  defp apply_operation_2(["+" <> _ | tail]) do
    new_tail = convert_tail(tail)
    perform_summation(new_tail, 0)
  end

  defp apply_operation_2(["*" <> _ | tail]) do
    new_tail = convert_tail(tail)
    perform_multiplication(new_tail, 1)
  end

  defp apply_operation_2(arg) do
    arg |> inspect() |> IO.puts()
  end

  def part2(input_data) do
    data_lines =
      input_data
      |> String.split("\n")
      |> Enum.filter(fn elem -> String.length(elem) > 0 end)

    {:ok, split_offsets} = data_lines |> Enum.reverse() |> read_split_offsets()

    result =
      data_lines
      |> Enum.map(fn line -> split_on_offsets(line, split_offsets) end)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.reverse/1)
      |> Enum.map(&apply_operation_2/1)
      |> Enum.sum()

    {:ok, result}
  end
end
