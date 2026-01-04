defmodule Main.Input do
  defstruct original: "", sectorID: 0, checksum: "", frequencies: %{}

  def parse_line(in_line) do
    [suffix_reversed, prefix_reversed] =
      in_line |> String.reverse() |> String.split("-", parts: 2)

    frequencies = prefix_reversed |> String.to_charlist() |> Enum.frequencies()

    [sector_str, checksum_str] =
      suffix_reversed |> String.reverse() |> String.split("[", parts: 2)

    %__MODULE__{
      original: in_line,
      sectorID: String.to_integer(sector_str),
      checksum: String.byte_slice(checksum_str, 0, String.length(checksum_str) - 1),
      frequencies: frequencies
    }
  end
end

defmodule Main do
  defp parse_input(input_data) do
    output =
      input_data
      |> String.split()
      |> Enum.filter(fn line -> String.length(line) != 0 end)
      |> Enum.map(fn line -> Main.Input.parse_line(line) end)

    {:ok, output}
  end

  defp is_input_valid?(input_struct) do
    expected_checksum = input_struct.checksum |> String.to_charlist()

    got_checksum =
      input_struct.frequencies
      |> Map.to_list()
      |> Enum.filter(fn {elem, _} -> elem != ?- end)
      |> Enum.sort(fn {char1, freq1}, {char2, freq2} ->
        if freq1 == freq2 do
          char1 < char2
        else
          freq1 > freq2
        end
      end)
      |> Enum.chunk_every(5)
      |> Enum.at(0)
      |> Enum.map(fn {char, _} -> char end)

    expected_checksum == got_checksum
  end

  defp calculate_valid([], result) do
    {:ok, result}
  end

  defp calculate_valid([head | tail], result) do
    if is_input_valid?(head) do
      calculate_valid(tail, result + head.sectorID)
    else
      calculate_valid(tail, result)
    end
  end

  def part1(input_data) do
    {:ok, lines} = parse_input(input_data)
    calculate_valid(lines, 0)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
