defmodule Main do
  @solver_path "/opt/homebrew/Cellar/glpk/5.0/bin/glpsol"
  @input_path "./solve.lp"
  @output_path "./output.txt"

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

  defp apply_button(full_state, indices, mod \\ 1)

  defp apply_button(full_state, [], _mod) do
    {:ok, full_state}
  end

  defp apply_button({state, counter}, [index | tail], mod) do
    state_value = Enum.at(state, index)
    new_state = List.replace_at(state, index, !state_value)

    counter_value = Enum.at(counter, index)
    new_counter = List.replace_at(counter, index, counter_value + mod)

    apply_button({new_state, new_counter}, tail, mod)
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

  defp add_button_to_equation(equations_state, [], _button_index) do
    {:ok, equations_state}
  end

  defp add_button_to_equation(equations_state, [index | tail], button_index) do
    {result, indices_list} = equations_state |> Enum.at(index)
    new_indices_list = [button_index | indices_list]
    new_state = List.replace_at(equations_state, index, {result, new_indices_list})
    add_button_to_equation(new_state, tail, button_index)
  end

  defp build_equation_from_buttons(equations_state, [], _index) do
    {:ok, equations_state}
  end

  defp build_equation_from_buttons(equations_state, [button | tail], button_index) do
    {:ok, new_state} = add_button_to_equation(equations_state, button, button_index)
    build_equation_from_buttons(new_state, tail, button_index + 1)
  end

  defp build_equations(state, buttons) do
    equations_state = state |> Enum.map(fn value -> {value, []} end)
    build_equation_from_buttons(equations_state, buttons, 0)
  end

  defp prepare_solver_input_file(equations_list, num_variables) do
    generals = 0..(num_variables - 1) |> Enum.map(fn elem -> "x#{elem}" end)

    output =
      [
        "Minimize",
        "  obj: #{generals |> Enum.join(" + ")}",
        "Subject To"
      ] ++
        (equations_list
         |> Enum.with_index()
         |> Enum.map(fn {{result, eq_indices}, index} ->
           index_strings =
             eq_indices |> Enum.reverse() |> Enum.map(fn x -> "x#{x}" end) |> Enum.join(" + ")

           "  index#{index}: #{index_strings} = #{result}"
         end)) ++
        [
          "Bounds"
        ] ++
        (generals |> Enum.map(fn entry -> "  #{entry} >= 0" end)) ++
        [
          "Generals",
          "  #{generals |> Enum.join(" ")}",
          "End"
        ]

    {:ok, output |> Enum.join("\n")}
  end

  defp read_result() do
    {:ok, content} = File.read(@output_path)

    [objectives_line] =
      content
      |> String.split("\n")
      |> Enum.filter(fn line -> String.starts_with?(line, "Objective:") end)

    objectives_line |> String.split() |> Enum.at(3) |> String.to_integer()
  end

  defp handle_part2({{_, state}, buttons}) do
    {:ok, equations} = build_equations(state, buttons)
    {:ok, input_file} = prepare_solver_input_file(equations, length(buttons))
    :ok = File.write(@input_path, input_file)
    {_, 0} = System.cmd(@solver_path, ["--lp", @input_path, "-o", @output_path])
    result = read_result()
    File.rm(@input_path)
    File.rm(@output_path)
    result
  end

  def part2(input_data) do
    {:ok, result} = parse_input(input_data)
    final_data = result |> Enum.map(&handle_part2/1) |> Enum.sum()
    {:ok, final_data}
  end
end
