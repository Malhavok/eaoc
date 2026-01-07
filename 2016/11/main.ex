defmodule Main.Input do
  defstruct floor_idx: -1, elements: []

  @floor_mapping %{"first" => 1, "second" => 2, "third" => 3, "fourth" => 4}

  defp handle_conversion(intro_string) do
    [_, source_str, type_str] = intro_string |> String.split(" ", parts: 3)

    type =
      case type_str do
        "microchip" -> :microchip
        "generator" -> :generator
      end

    source =
      case type do
        :microchip ->
          [out, _] = source_str |> String.split("-", parts: 2)
          out

        :generator ->
          source_str
      end

    {type, source}
  end

  defp parse_entries(entries_str) do
    entries_str
    |> String.split(["and", ", "])
    |> Enum.map(fn entry -> String.trim(entry) end)
    |> Enum.filter(fn entry -> String.length(entry) > 0 end)
    |> Enum.map(fn entry -> String.replace(entry, ".", "") end)
    |> Enum.map(fn entry -> handle_conversion(entry) end)
  end

  def parse_line(line) do
    # The first floor contains a polonium generator, a thulium generator, a thulium-compatible microchip, a promethium generator, a ruthenium generator, a ruthenium-compatible microchip, a cobalt generator, and a cobalt-compatible microchip.
    [floor_marker, entries_marker] = String.split(line, " contains ", parts: 2)
    [_, floor_str, _] = String.split(floor_marker, " ", parts: 3)
    floor_idx = Map.get(@floor_mapping, floor_str)

    elements =
      if entries_marker == "nothing relevant." do
        []
      else
        parse_entries(entries_marker)
      end

    %__MODULE__{floor_idx: floor_idx, elements: elements}
  end
end

defmodule Main do
  defp parse_input(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    {:ok, lines |> Enum.map(fn line -> Main.Input.parse_line(line) end)}
  end

  defp is_floor_safe?(all_elements) do
    microchips =
      all_elements
      |> Enum.filter(fn {key, _} -> key == :microchip end)
      |> Enum.map(fn {_, value} -> value end)
      |> MapSet.new()

    generators =
      all_elements
      |> Enum.filter(fn {key, _} -> key == :generator end)
      |> Enum.map(fn {_, value} -> value end)
      |> MapSet.new()

    unpaired_microchips = MapSet.difference(microchips, generators)

    # If there are unpaired microchips, the floor isn't safe.
    MapSet.size(unpaired_microchips) == 0
  end

  defp what_can_be_safely_taken(all_elements) do
    # First, lets list all the single items that are "safe to move".
  end

  defp is_part1_finished?(floor_states, all_elements) do
    %Main.Input{floor_idx: 4} =
      last_floor = floor_states |> Enum.find(nil, fn elem -> elem.floor_idx == 4 end)

    sorted_elements = last_floor.elements |> Enum.sort()
    expected_elements = all_elements |> Enum.sort()

    sorted_elements == expected_elements
  end

  def part1(input_data) do
    {:ok, state} = parse_input(input_data)
    state |> inspect() |> IO.puts()
    {:ok, :test}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
