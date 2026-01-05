defmodule Main.Input do
  defstruct base: [], brackets: []

  def parse_line(line) do
    parts_list = line |> String.split(["[", "]"])
    base = parts_list |> Enum.take_every(2)
    brackets = parts_list |> Enum.drop(1) |> Enum.take_every(2)

    %__MODULE__{base: base, brackets: brackets}
  end
end

defmodule Main do
  defp parse_input(input_data) do
    result =
      input_data
      |> String.split("\n")
      |> Enum.filter(fn line -> String.length(line) > 0 end)
      |> Enum.map(fn line -> Main.Input.parse_line(line) end)

    {:ok, result}
  end

  defp contains_abba?([]) do
    false
  end

  defp contains_abba?([a | [b, b, a | _]]) when b != a do
    true
  end

  defp contains_abba?([_ | tail]) do
    contains_abba?(tail)
  end

  defp is_input_valid?(entry) do
    base_matches =
      entry.base
      |> Enum.map(fn elem -> contains_abba?(String.to_charlist(elem)) end)
      |> Enum.any?()

    bracket_matches =
      entry.brackets
      |> Enum.map(fn elem -> contains_abba?(String.to_charlist(elem)) end)
      |> Enum.any?()

    !bracket_matches and base_matches
  end

  def part1(input_data) do
    {:ok, data} = parse_input(input_data)
    result = data |> Enum.filter(fn entry -> is_input_valid?(entry) end) |> Enum.count()
    {:ok, result}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
