defmodule Main do
  defp parse_data(input_data) do
    input_data |> String.split("\n") |> Enum.at(0)
  end

  defp calculate_hash(salt, index) do
    full_salt = salt <> Integer.to_string(index)
    :crypto.hash(:md5, full_salt) |> Base.encode16()
  end

  defp check_triplet(input) do
    char_list = input |> String.to_charlist()
    check_triplet(char_list, nil, nil)
  end

  defp check_triplet([], _, _) do
    :error
  end

  defp check_triplet([head | _], head, head) do
    {:ok, head}
  end

  defp check_triplet([head | tail], previous1, _) do
    check_triplet(tail, head, previous1)
  end

  defp build_search_string(in_char) do
    1..5 |> Enum.map(fn _ -> in_char end) |> Kernel.to_string()
  end

  defp search_codes(_, _, found_keys, _) when length(found_keys) >= 64 do
    {:ok, Enum.max(found_keys)}
  end

  defp search_codes(salt, index, found_keys, potential_keys) do
    new_hash = calculate_hash(salt, index)

    confirmed_keys =
      potential_keys
      |> Enum.filter(fn {_, search_elem} ->
        String.contains?(new_hash, search_elem)
      end)
      |> Enum.map(fn {key_index, _} -> key_index end)

    confirmed_set = MapSet.new(confirmed_keys)

    removed_potential =
      potential_keys
      |> Enum.filter(fn {key_index, _} -> !MapSet.member?(confirmed_set, key_index) end)

    new_found_keys = confirmed_keys ++ found_keys

    kept_potential_keys =
      removed_potential |> Enum.filter(fn {key_index, _} -> key_index + 1000 > index end)

    new_potential_keys =
      case check_triplet(new_hash) do
        {:ok, elem} ->
          [{index, build_search_string(elem)} | kept_potential_keys]

        :error ->
          kept_potential_keys
      end

    search_codes(salt, index + 1, new_found_keys, new_potential_keys)
  end

  def part1(input_data) do
    salt = parse_data(input_data)
    search_codes(salt, 0, [], [])
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
