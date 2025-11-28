defmodule Main do
  @operands %{
    "AND" => :and,
    "OR" => :or,
    "XOR" => :xor
  }

  def and_op("1", "1") do
    "1"
  end

  def and_op(_, _) do
    "0"
  end

  def or_op("0", "0") do
    "0"
  end

  def or_op(_, _) do
    "1"
  end

  def xor_op(value, value) do
    "0"
  end

  def xor_op(_, _) do
    "1"
  end

  def parse_data(input_list) do
    {:ok, full_state, operations_list} = parse_state(input_list, %{})
    {:ok, operations} = parse_operations(operations_list, [])
    {:ok, full_state, operations}
  end

  def parse_state(["" | tail], state) do
    {:ok, state, tail}
  end

  def parse_state([head | tail], state) do
    [name, value] = String.split(head, ": ")
    new_state = Map.put(state, name, value)
    parse_state(tail, new_state)
  end

  def parse_operations(["" | _tail], operations) do
    {:ok, operations}
  end

  def parse_operations([head | tail], operations) do
    [input1, operand, input2, "->", result] = String.split(head, " ")
    operation = {input1, @operands[operand], input2, result}
    parse_operations(tail, [operation | operations])
  end

  def apply_operations(state, []) do
    {:ok, state}
  end

  def apply_operations(state, operations) do
    {:ok, new_state, missing} = apply_operations(state, operations, [])
    apply_operations(new_state, missing)
  end

  def apply_operations(state, [], missing) do
    {:ok, state, missing}
  end

  def apply_operations(state, [head | tail], missing) do
    case apply_operation(state, head) do
      {:ok, new_state} -> apply_operations(new_state, tail, missing)
      :error -> apply_operations(state, tail, [head | missing])
    end
  end

  def apply_operation(state, {input1, :and, input2, result}) do
    apply_generic_operation(state, input1, input2, result, &and_op/2)
  end

  def apply_operation(state, {input1, :or, input2, result}) do
    apply_generic_operation(state, input1, input2, result, &or_op/2)
  end

  def apply_operation(state, {input1, :xor, input2, result}) do
    apply_generic_operation(state, input1, input2, result, &xor_op/2)
  end

  def apply_generic_operation(state, input1, input2, result_name, function) do
    with {:ok, value1} <- Map.fetch(state, input1), {:ok, value2} <- Map.fetch(state, input2) do
      value = function.(value1, value2)
      new_state = Map.put(state, result_name, value)
      {:ok, new_state}
    end
  end

  def build_result(state) do
    z_keys =
      Map.filter(state, fn {key, _value} -> String.starts_with?(key, "z") end)
      |> Map.keys()
      |> Enum.sort(:desc)

    z_values = for(key <- z_keys, do: state[key]) |> Enum.join("")
    {:ok, String.to_integer(z_values, 2)}
  end

  def part1(input_data) do
    {:ok, state, operations} = parse_data(String.split(input_data, "\n"))
    {:ok, end_state} = apply_operations(state, operations)
    build_result(end_state)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
