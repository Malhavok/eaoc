defmodule Main do
  defp parse_unpacker([?) | tail], char_count, multi_count, _) do
    {:ok, tail, char_count, multi_count}
  end

  defp parse_unpacker([?x | tail], char_count, multi_count, _) do
    parse_unpacker(tail, char_count, multi_count, true)
  end

  defp parse_unpacker([digit | tail], char_count, multi_count, false) do
    new_count = char_count * 10 + (digit - ?0)
    parse_unpacker(tail, new_count, multi_count, false)
  end

  defp parse_unpacker([digit | tail], char_count, multi_count, true) do
    new_count = multi_count * 10 + (digit - ?0)
    parse_unpacker(tail, char_count, new_count, true)
  end

  defp calculate_length1([], _skip_count, length) do
    length
  end

  defp calculate_length1([?( | tail], 0, length) do
    {:ok, new_tail, char_count, multi_count} = parse_unpacker(tail, 0, 0, false)
    calculate_length1(new_tail, char_count, length + char_count * multi_count)
  end

  defp calculate_length1([_ | tail], 0, length) do
    calculate_length1(tail, 0, length + 1)
  end

  defp calculate_length1([_ | tail], skip_count, length) do
    calculate_length1(tail, skip_count - 1, length)
  end

  defp calculate_length1(line) do
    calculate_length1(String.to_charlist(line), 0, 0)
  end

  def part1(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    result = lines |> Enum.map(fn line -> calculate_length1(line) end)
    {:ok, result |> List.last()}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
