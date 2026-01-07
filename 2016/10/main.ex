defmodule Main do
  defp parse_input([], initial_state, operations) do
    {:ok, initial_state, operations}
  end

  defp parse_input(["value " <> params | tail], initial_state, operations) do
    # value 61 goes to bot 209
    [value, bot_name] = String.split(params, " goes to ", parts: 2)

    old_values_list = Map.get(initial_state, bot_name, [])
    new_state = Map.put(initial_state, bot_name, [String.to_integer(value) | old_values_list])

    parse_input(tail, new_state, operations)
  end

  defp parse_input(["bot " <> params | tail], initial_state, operations) do
    # bot 189 gives low to bot 62 and high to bot 168
    # or
    # bot 194 gives low to output 9 and high to bot 74
    [bot_id, low_id, high_id] =
      String.split(params, [" gives low to ", " and high to "], parts: 3)

    bot_name = "bot #{bot_id}"

    operation = {:low, low_id, :high, high_id}

    if Map.has_key?(operations, bot_name) do
      {:error, :duplicated_operation, bot_name}
    else
      new_operations = Map.put(operations, bot_name, operation)
      parse_input(tail, initial_state, new_operations)
    end
  end

  defp parse_input(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    parse_input(lines, %{}, %{})
  end

  defp find_active_bots([], result) do
    {:ok, result}
  end

  defp find_active_bots([{"bot " <> _ = bot_name, [_, _] = values} | tail], result) do
    new_bot = {bot_name, values |> Enum.min_max()}
    find_active_bots(tail, [new_bot | result])
  end

  defp find_active_bots([_ | tail], result) do
    find_active_bots(tail, result)
  end

  defp find_active_bots(state) do
    find_active_bots(Map.to_list(state), [])
  end

  defp bump_bots([], state, _operations) do
    {:ok, state}
  end

  defp bump_bots([{active_bot, {low_value, high_value}} | tail], state, operations) do
    {:low, low_target, :high, high_target} = Map.get(operations, active_bot)

    low_target_values = state |> Map.get(low_target, [])
    high_target_values = state |> Map.get(high_target, [])

    new_state =
      state
      |> Map.put(active_bot, [])
      |> Map.put(low_target, [low_value | low_target_values])
      |> Map.put(high_target, [high_value | high_target_values])

    bump_bots(tail, new_state, operations)
  end

  defp bump_until(state, operations, expected_state, last_matching) do
    {:ok, active_bots} = find_active_bots(state)

    if length(active_bots) == 0 do
      {:ok, last_matching}
    else
      {bot_name, bot_state} = acting_bot = active_bots |> Enum.at(0)

      new_matching =
        if bot_state == expected_state do
          bot_name
        else
          last_matching
        end

      {:ok, new_state} = bump_bots([acting_bot], state, operations)
      bump_until(new_state, operations, expected_state, new_matching)
    end
  end

  def part1(input_data) do
    {:ok, state, operations} = parse_input(input_data)
    # Test params:
    # {:ok, "bot " <> bot_id_str} = bump_until(state, operations, {2, 5}, nil)
    # Run params:
    {:ok, "bot " <> bot_id_str} = bump_until(state, operations, {17, 61}, nil)
    {:ok, String.to_integer(bot_id_str)}
  end

  defp bump_until2(state, operations) do
    {:ok, active_bots} = find_active_bots(state)

    if length(active_bots) == 0 do
      {:ok, state}
    else
      acting_bot = active_bots |> Enum.at(0)
      {:ok, new_state} = bump_bots([acting_bot], state, operations)
      bump_until2(new_state, operations)
    end
  end

  def part2(input_data) do
    {:ok, state, operations} = parse_input(input_data)
    {:ok, new_state} = bump_until2(state, operations)
    output0_value = Map.get(new_state, "output 0") |> Enum.at(0)
    output1_value = Map.get(new_state, "output 1") |> Enum.at(0)
    output2_value = Map.get(new_state, "output 2") |> Enum.at(0)
    {:ok, output0_value * output1_value * output2_value}
  end
end
