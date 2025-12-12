defmodule Main do
  defp parse_lights(lights) do
    len = String.length(lights)
    base_data = String.slice(lights, 1, len - 2)
    base_data |> String.to_charlist() |> Enum.map(fn elem -> elem == ?# end)
  end

  defp parse_joltage(joltage) do
    len = String.length(joltage)
    base_data = String.slice(joltage, 1, len - 2)
    base_data |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  defp parse_button(button) do
    len = String.length(button)
    base_data = String.slice(button, 1, len - 2)
    base_data |> String.split(",") |> Enum.map(&String.to_integer/1)
  end

  defp parse_line(line) do
    [lights | parts] = line |> String.split(" ")
    [joltage | buttons] = parts |> Enum.reverse()
    {{parse_lights(lights), parse_joltage(joltage)}, buttons |> Enum.map(&parse_button/1)}
  end

  defp parse_input(input_data) do
    result =
      input_data
      |> String.split("\n")
      |> Enum.filter(fn elem -> String.length(elem) > 0 end)
      |> Enum.map(&parse_line/1)

    {:ok, result}
  end

  defp apply_button(full_state, []) do
    {:ok, full_state}
  end

  defp apply_button({state, counter}, [index | tail]) do
    state_value = Enum.at(state, index)
    new_state = List.replace_at(state, index, !state_value)

    counter_value = Enum.at(counter, index)
    new_counter = List.replace_at(counter, index, counter_value + 1)

    apply_button({new_state, new_counter}, tail)
  end

  defp make_initial_state({state, counter}) do
    initial_state = state |> Enum.map(fn _ -> false end)
    initial_counter = counter |> Enum.map(fn _ -> 0 end)
    {:ok, {initial_state, initial_counter}}
  end

  defp check_state({state, _}, {state, _}, depth, _buttons) do
    {:ok, depth}
  end

  defp check_state(_current_state, _wanted_state, _depth, []) do
    {:ok, 999_999}
  end

  defp check_state(current_state, wanted_state, depth, [button | tail]) do
    {:ok, new_state} = apply_button(current_state, button)

    {:ok, with_press} = check_state(new_state, wanted_state, depth + 1, tail)
    {:ok, without_press} = check_state(current_state, wanted_state, depth, tail)

    {:ok, min(with_press, without_press)}
  end

  defp handle_part1({full_state, buttons}) do
    {:ok, initial_state} = make_initial_state(full_state)

    {:ok, result} = check_state(initial_state, full_state, 0, buttons)
    result
  end

  def part1(input_data) do
    {:ok, result} = parse_input(input_data)
    final_data = result |> Enum.map(&handle_part1/1) |> Enum.sum()
    {:ok, final_data}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
