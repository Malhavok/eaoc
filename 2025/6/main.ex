defmodule Main do
  defp read_lines(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn elem -> String.length(elem) > 0 end)
    |> Enum.map(fn elem -> String.split(elem, " ", trim: true) end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)

    # <3
  end

  defp perform_summation([], result) do
    result
  end

  defp perform_summation([head | tail], result) do
    perform_summation(tail, result + String.to_integer(head))
  end

  defp perform_multiplication([], result) do
    result
  end

  defp perform_multiplication([head | tail], result) do
    perform_multiplication(tail, result * String.to_integer(head))
  end

  defp apply_operation(["+" | tail]) do
    result = perform_summation(tail, 0)
    result
  end

  defp apply_operation(["*" | tail]) do
    result = perform_multiplication(tail, 1)
    result
  end

  def part1(input_data) do
    lines = read_lines(input_data)
    result = lines |> Enum.map(&apply_operation/1) |> Enum.sum()
    {:ok, result}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
