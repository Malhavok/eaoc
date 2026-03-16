defmodule Main do
  defp parse_input(input_data) do
    [raw_count, raw_input] =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    {:ok, String.to_integer(raw_count), String.to_charlist(raw_input)}
  end

  defp build_data(data, data_len, wanted_len) when data_len >= wanted_len do
    {:ok, data |> Enum.slice(0, wanted_len)}
  end

  defp build_data(data, data_len, wanted_len) do
    second_part =
      data
      |> Enum.reverse()
      |> Enum.map(fn entry ->
        if entry == ?1 do
          ?0
        else
          ?1
        end
      end)

    new_len = data_len * 2 + 1
    build_data(data ++ [?0] ++ second_part, new_len, wanted_len)
  end

  defp calculate_hash(data, data_len) when rem(data_len, 2) == 1 do
    {:ok, data}
  end

  defp calculate_hash(data, data_len) do
    new_data =
      data
      |> Enum.chunk_every(2)
      |> Enum.map(fn [elem1, elem2] ->
        if elem1 == elem2 do
          ?1
        else
          ?0
        end
      end)

    calculate_hash(new_data, div(data_len, 2))
  end

  def part1(input_data) do
    {:ok, count, input} = parse_input(input_data)
    {:ok, data} = build_data(input, length(input), count)
    {:ok, _hashed_data} = calculate_hash(data, count)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
