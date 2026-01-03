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
    with {:ok, value1} <- Map.fetch(state, input1),
         {:ok, value2} <- Map.fetch(state, input2) do
      value = function.(value1, value2)
      new_state = Map.put(state, result_name, value)
      {:ok, new_state}
    end
  end

  def build_result(state, prefix \\ "z") do
    z_keys =
      Map.filter(state, fn {key, _value} -> String.starts_with?(key, prefix) end)
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

  defp list_operations(operations, wanted_nodes, end_at, result) do
    new_ops =
      operations
      |> Enum.filter(fn {input1, _op, input2, _result} ->
        (MapSet.member?(wanted_nodes, input1) or MapSet.member?(wanted_nodes, input2)) and
          input1 != end_at and input2 != end_at
      end)

    if length(new_ops) == 0 do
      {:ok, result}
    else
      new_result = (result ++ new_ops) |> Enum.uniq()
      new_wanted = new_ops |> Enum.map(fn {_, _, _, result} -> result end) |> MapSet.new()
      list_operations(operations, new_wanted, end_at, new_result)
    end
  end

  defp list_operations_starting_from(start_node, operations, end_at) do
    wanted_nodes = MapSet.new([start_node])
    list_operations(operations, wanted_nodes, end_at, [])
  end

  defp find_operation([], _, _) do
    :error
  end

  defp find_operation(
         [{input1, operation_type, input2, _result} = head | tail],
         input_starts_with,
         operation_type
       ) do
    if String.starts_with?(input1, input_starts_with) or
         String.starts_with?(input2, input_starts_with) do
      {:ok, head}
    else
      find_operation(tail, input_starts_with, operation_type)
    end
  end

  defp find_operation([_head | tail], input_starts_with, operation_type) do
    find_operation(tail, input_starts_with, operation_type)
  end

  defp get_carry_from_ops(operations) do
    # This goes in two stages:
    # First we find :xor operation starting with one of the input being "xXX"
    # We check the output node there
    # Then we find another :xor operation where one of the inputs is the previous output
    # (this has been confirmed to work in our case)
    # We then return the other input to that function.
    {:ok, {_, :xor, _, xor_output}} = find_operation(operations, "x", :xor)
    {:ok, {input1, :xor, input2, _}} = find_operation(operations, xor_output, :xor)

    if input1 == xor_output do
      {:ok, input2}
    else
      {:ok, input1}
    end
  end

  def part2(input_data) do
    {:ok, _state, operations} = parse_data(String.split(input_data, "\n"))

    {:ok, result} = list_operations_starting_from("x44", operations, nil)
    get_carry_from_ops(result) |> inspect() |> IO.puts()

    # Top level (5 operations):
    # {"y44", :and, "x44", "vdn"}
    # {"x44", :xor, "y44", "nnt"}
    # {"nnt", :and, "jnj", "qtn"}  – jnj has to be carry from the level below.
    # {"nnt", :xor, "jnj", "z44"}
    # {"vdn", :or, "qtn", "z45"}
    #
    # Lower level (always 5 operations):
    # {"x43", :xor, "y43", "gnj"}
    # {"y43", :and, "x43", "hsd"}
    # {"gnj", :and, "dpg", "nsf"} – :and from input  has to go to :and from carry into :or for next carry
    # {"dpg", :xor, "gnj", "z43"} – :xor from inputs has to go to :xor from previous carry and into current output bit
    # {"hsd", :or, "nsf", "jnj"} – new carry is :and from inputs :or :xor inputs with :and previous carry
    #
    # So:
    # inputs :xor has to go to some :and and :xor with the same input, being previous carry
    # :xor :xor –> has to go to the given level output
    # :xor :and + :and –> goes to this level carry
    #
    # After manual analysis:
    # - carry is always provided as :xor :xor on each level properly, that is none of the input xor outputs are misplaced.
    # - this allows us to simply partition whole operations into groups of 5 (except for the first one, which is a group of 2).

    {:ok, :test}
  end
end
