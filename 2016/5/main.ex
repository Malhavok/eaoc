defmodule Main do
  defp calc_hash(_input_str, _index, result) when length(result) == 8 do
    {:ok, result |> Enum.reverse() |> Enum.join("")}
  end

  defp calc_hash(input_str, index, result) do
    hash_input = "#{input_str}#{index}"
    hash_output = :crypto.hash(:md5, hash_input) |> Base.encode16() |> String.downcase()

    if hash_output |> String.byte_slice(0, 5) == "00000" do
      next_letter = hash_output |> String.at(5)
      calc_hash(input_str, index + 1, [next_letter | result])
    else
      calc_hash(input_str, index + 1, result)
    end
  end

  def part1(input_data) do
    input_str = input_data |> String.split("\n") |> Enum.at(0)
    calc_hash(input_str, 0, [])
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
