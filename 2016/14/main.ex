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

  defp search_codes(_, index, wanted_index, found_keys, found_keys_count, _, _)
       when found_keys_count >= 64 and wanted_index != nil and index >= wanted_index do
    {:ok, found_keys |> Enum.sort() |> Enum.at(63)}
  end

  defp search_codes(
         salt,
         index,
         forced_index,
         found_keys,
         found_keys_count,
         potential_keys,
         hash_fun
       ) do
    new_hash = hash_fun.(salt, index)

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
    new_found_keys_count = found_keys_count + length(confirmed_keys)

    kept_potential_keys =
      removed_potential |> Enum.filter(fn {key_index, _} -> key_index + 1000 >= index end)

    {new_potential_keys, new_forced_index} =
      case check_triplet(new_hash) do
        {:ok, elem} ->
          new_forced_index =
            if new_found_keys_count >= 64 do
              forced_index
            else
              # We need to search further, because earlier key could be found later.
              index + 1000
            end

          {
            [{index, build_search_string(elem)} | kept_potential_keys],
            new_forced_index
          }

        :error ->
          {
            kept_potential_keys,
            forced_index
          }
      end

    search_codes(
      salt,
      index + 1,
      new_forced_index,
      new_found_keys,
      new_found_keys_count,
      new_potential_keys,
      hash_fun
    )
  end

  def part1(input_data) do
    salt = parse_data(input_data)
    search_codes(salt, 0, nil, [], 0, [], &calculate_hash/2)
  end

  defp calculate_hash2(salt, index) do
    full_salt = salt <> Integer.to_string(index)
    cycle_hash(full_salt, 0)
  end

  defp cycle_hash(in_hash, offset) when offset >= 2017 do
    in_hash
  end

  defp cycle_hash(in_hash, offset) do
    new_hash = :crypto.hash(:md5, in_hash) |> Base.encode16(case: :lower)
    cycle_hash(new_hash, offset + 1)
  end

  def part2(input_data) do
    salt = parse_data(input_data)
    search_codes(salt, 0, nil, [], 0, [], &calculate_hash2/2)
  end
end
