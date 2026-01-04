defmodule Main.Input do
  defstruct original: "", sectorID: 0, checksum: "", frequencies: %{}, prefix: []

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
      frequencies: frequencies,
      prefix: prefix_reversed |> String.to_charlist() |> Enum.reverse()
    }
  end
end

defmodule Main do
  @wanted_name ~c"northpole object storage"

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

  defp rotate_letters([], _rotator, result) do
    {:ok, result |> Enum.reverse()}
  end

  defp rotate_letters([?- | tail], rotator, result) do
    rotate_letters(tail, rotator, [?\s | result])
  end

  defp rotate_letters([letter | tail], rotator, result) do
    base_letter = letter - ?a
    modifier = ?z - ?a + 1
    new_letter = rem(base_letter + rotator, modifier) + ?a
    rotate_letters(tail, rotator, [new_letter | result])
  end

  defp calculate_rotated_name(input_struct) do
    rotate_letters(input_struct.prefix, input_struct.sectorID, [])
  end

  defp search_for_valid_name([]) do
    {:error, :missing}
  end

  defp search_for_valid_name([head | tail]) do
    with true <- is_input_valid?(head), {:ok, @wanted_name} <- calculate_rotated_name(head) do
      {:ok, head.sectorID}
    else
      _ -> search_for_valid_name(tail)
    end
  end

  def part2(input_data) do
    {:ok, lines} = parse_input(input_data)
    search_for_valid_name(lines)
  end
end
