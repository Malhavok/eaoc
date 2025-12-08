defmodule Main do
  defp list_of_points(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn elem -> String.length(elem) > 0 end)
    |> Enum.map(fn elem -> String.split(elem, ",") end)
    |> Enum.map(fn elem -> Enum.map(elem, &String.to_integer/1) end)
    |> Enum.map(&List.to_tuple/1)
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}) do
    :math.pow(x1 - x2, 2) + :math.pow(y1 - y2, 2) + :math.pow(z1 - z2, 2)
  end

  defp fill_distances(_start, [], distances) do
    {:ok, distances}
  end

  defp fill_distances(start, [point | tail], distances) do
    new_distance = distance(start, point)
    fill_distances(start, tail, [{new_distance, start, point} | distances])
  end

  defp calculate_distances([_], distances) do
    {:ok, distances |> Enum.sort()}
  end

  defp calculate_distances([point | tail], distances) do
    {:ok, new_distances} = fill_distances(point, tail, distances)
    calculate_distances(tail, new_distances)
  end

  defp search_for_connection(point, connections) do
    case Enum.find_index(connections, fn elem -> MapSet.member?(elem, point) end) do
      nil ->
        {:ok, MapSet.new(), connections}

      index ->
        {existing_map_set, new_connections} = List.pop_at(connections, index)
        {:ok, existing_map_set, new_connections}
    end
  end

  defp build_connections(_list, 0, connections) do
    {:ok, connections}
  end

  defp build_connections([{_distance, point1, point2} | tail], counter, connections) do
    {:ok, point1_map_set, point1_connections} = search_for_connection(point1, connections)
    {:ok, point2_map_set, point2_connections} = search_for_connection(point2, point1_connections)

    new_map_set =
      point1_map_set |> MapSet.union(point2_map_set) |> MapSet.put(point1) |> MapSet.put(point2)

    build_connections(tail, counter - 1, [new_map_set | point2_connections])
  end

  defp get_result(connections) do
    connections
    |> Enum.map(fn elem -> elem |> MapSet.to_list() |> length() end)
    |> Enum.sort(:desc)
    |> Enum.slice(0, 3)
    |> Enum.reduce(1, fn elem, acc -> acc * elem end)
  end

  def part1(input_data) do
    data = list_of_points(input_data)
    {:ok, distances} = calculate_distances(data, [])
    {:ok, connections} = build_connections(distances, 1000, [])
    {:ok, get_result(connections)}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
