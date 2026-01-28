defmodule Main do
  defp potential_register(str_value) do
    case Integer.parse(str_value) do
      {value, _} -> {:value, value}
      :error -> {:register, str_value}
    end
  end

  defp parse_instruction("cpy " <> rest) do
    [value, reg] = rest |> String.split(" ")
    {:cpy, potential_register(value), reg}
  end

  defp parse_instruction("inc " <> rest) do
    {:inc, rest}
  end

  defp parse_instruction("dec " <> rest) do
    {:dec, rest}
  end

  defp parse_instruction("jnz " <> rest) do
    [value, offset] = rest |> String.split(" ")
    {:jnz, potential_register(value), String.to_integer(offset)}
  end

  defp process_data(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn line -> String.length(line) > 0 end)
    |> Enum.map(&parse_instruction/1)
    |> Enum.with_index()
    |> Enum.map(fn {instruction, index} -> {index, instruction} end)
    |> Map.new()
  end

  defp run_instruction(registers, {:cpy, {:value, value}, register}, index) do
    new_registers = Map.replace(registers, register, value)
    {index + 1, new_registers}
  end

  defp run_instruction(registers, {:cpy, {:register, source_name}, register}, index) do
    value = Map.get(registers, source_name)
    run_instruction(registers, {:cpy, {:value, value}, register}, index)
  end

  defp run_instruction(registers, {:mod, register, mod_value}, index) do
    value = Map.get(registers, register)
    new_registers = Map.replace(registers, register, value + mod_value)
    {index + 1, new_registers}
  end

  defp run_instruction(registers, {:inc, register}, index) do
    run_instruction(registers, {:mod, register, 1}, index)
  end

  defp run_instruction(registers, {:dec, register}, index) do
    run_instruction(registers, {:mod, register, -1}, index)
  end

  defp run_instruction(registers, {:jnz, {:value, value}, jump}, index) do
    case value do
      0 -> {index + 1, registers}
      _ -> {index + jump, registers}
    end
  end

  defp run_instruction(registers, {:jnz, {:register, register}, jump}, index) do
    value = Map.get(registers, register)
    run_instruction(registers, {:jnz, {:value, value}, jump}, index)
  end

  defp apply_instruction(registers, instructions, instruction_index) do
    case Map.get(instructions, instruction_index) do
      nil ->
        {:ok, registers}

      instruction ->
        {new_index, new_registers} = run_instruction(registers, instruction, instruction_index)
        apply_instruction(new_registers, instructions, new_index)
    end
  end

  defp apply_instructions(instructions) do
    registers = %{"a" => 0, "b" => 0, "c" => 0, "d" => 0}
    apply_instruction(registers, instructions, 0)
  end

  def part1(input_data) do
    instructions = process_data(input_data)
    {:ok, registers} = apply_instructions(instructions)
    {:ok, Map.get(registers, "a")}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
