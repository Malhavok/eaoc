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
  @cache_name :cache_table

  defp parse_input(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    {:ok,
     lines
     |> Enum.map(fn line -> Main.Input.parse_line(line) end)
     |> Enum.map(fn %Main.Input{floor_idx: floor_idx, elements: elements} ->
       {floor_idx, elements}
     end)
     |> Map.new()}
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
    (MapSet.size(unpaired_microchips) == 0 and MapSet.size(generators) > 0) or
      MapSet.size(generators) == 0
  end

  defp single_items_safely_taken(list_of_elements) do
    list_of_elements
    |> Enum.with_index()
    |> Enum.map(fn {entry, index} -> {[entry], List.delete_at(list_of_elements, index)} end)
    |> Enum.filter(fn {_, sublist} -> is_floor_safe?(sublist) end)
  end

  defp what_can_be_safely_taken(all_elements) do
    first_level = single_items_safely_taken(all_elements)

    second_level =
      first_level
      |> Enum.map(fn {entries, sublist} ->
        sublevel = single_items_safely_taken(sublist)
        sublevel |> Enum.map(fn {elem, remaining} -> {entries ++ elem, remaining} end)
      end)
      |> List.flatten()

    {:ok,
     (first_level ++ second_level)
     |> Enum.map(fn {elems, remaining} -> {elems |> Enum.sort(), remaining |> Enum.sort()} end)
     |> Enum.uniq()}
  end

  defp is_part1_finished?(floor_states) do
    [1, 2, 3] |> Enum.all?(fn floor_idx -> length(Map.get(floor_states, floor_idx)) == 0 end)
  end

  defp next_floors(1) do
    {:ok, [2]}
  end

  defp next_floors(4) do
    {:ok, [3]}
  end

  defp next_floors(floor) do
    {:ok, [floor - 1, floor + 1]}
  end

  defp list_options(floor, floor_elements) do
    {:ok, new_floors} = next_floors(floor)
    {:ok, elements_remaining} = what_can_be_safely_taken(floor_elements)

    new_floors
    |> Enum.map(fn floor_idx ->
      elements_remaining
      |> Enum.map(fn {to_move, remaining} ->
        {floor_idx, to_move, remaining}
      end)
    end)
    |> List.flatten()
  end

  defp hash_floor_state(floor, state) do
    floors_group =
      state
      |> Map.to_list()
      |> Enum.map(fn {index, list_of_elements} ->
        list_of_elements
        |> Enum.map(fn {type, value} ->
          {value, type, index}
        end)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, fn {key, type, index}, acc ->
        current = Map.get(acc, key, %{:microchip => -1, :generator => -1})
        updated = Map.put(current, type, index)
        Map.put(acc, key, updated)
      end)
      |> Map.to_list()
      |> Enum.map(fn {_, mapping} ->
        microchip_floor = Map.get(mapping, :microchip)
        generator_floor = Map.get(mapping, :generator)
        {microchip_floor, generator_floor}
      end)
      |> Enum.sort()

    {floor, floors_group}
  end

  defp update_states([], out_states) do
    {:ok, out_states, false}
  end

  defp update_states([{floor, state} | tail], out_states) do
    if is_part1_finished?(state) do
      {:ok, [], true}
    else
      elements_options = Map.get(state, floor)
      # List of {new floor, elements moving to new floor, elements remaining on the current floor}
      options = list_options(floor, elements_options)

      # We need to convert it to {floor, state}, but we also need to filter out all "impossible" states.
      # So, we can build new state, where old floor has only remaining elements and new floor have old + new elements.
      # And we need to verify whether is_floor_safe? for the new floor is "valid".
      new_states =
        options
        |> Enum.map(fn {new_floor, moved_to_new_floor, left_on_this_floor} ->
          new_state =
            state
            |> Map.put(floor, left_on_this_floor)
            |> Map.put(new_floor, Map.get(state, new_floor) ++ moved_to_new_floor)

          {new_floor, new_state}
        end)
        |> Enum.filter(fn {new_floor, new_state} ->
          is_floor_safe?(Map.get(new_state, new_floor))
        end)
        |> Enum.filter(fn {new_floor, new_state} ->
          :ets.insert_new(@cache_name, {hash_floor_state(new_floor, new_state), true})
        end)

      update_states(tail, out_states ++ new_states)
    end
  end

  defp iterate_states(states, steps_count) do
    {:ok, new_states, is_done} = update_states(states, [])

    if is_done do
      {:ok, steps_count}
    else
      iterate_states(new_states, steps_count + 1)
    end
  end

  def part1(input_data) do
    {:ok, state} = parse_input(input_data)
    :ets.new(@cache_name, [:named_table, :set, :private])
    :ets.insert(@cache_name, {hash_floor_state(1, state), true})

    {:ok, _steps_count} = iterate_states([{1, state}], 0)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
