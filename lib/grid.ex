defmodule Grid do
  @type point :: {pos_integer(), pos_integer()}
  @type mapSpec :: %{point() => char()}

  @spec init(binary()) :: {:ok, mapSpec}
  def init(file_content) do
    lines = file_content |> String.split("\n")
    build_line(lines, 0, %{})
  end

  @spec get_neighbours(mapSpec(), point(), [{integer(), integer()}, ...]) ::
          {:ok, [{point(), char()}, ...]}
  def get_neighbours(map, point, neighbours \\ [{0, 1}, {1, 0}, {-1, 0}, {0, -1}]) do
    get_neighbour(map, point, neighbours, [])
  end

  @spec get_positions(mapSpec(), char()) :: {:ok, [point(), ...]}
  def get_positions(map, symbol) do
    get_positions(map, Map.keys(map), symbol, [])
  end

  defp get_positions(_map, [], _symbol, found) do
    {:ok, found}
  end

  defp get_positions(map, [point | tail], symbol, found) do
    case Map.get(map, point) do
      ^symbol -> get_positions(map, tail, symbol, [point | found])
      _ -> get_positions(map, tail, symbol, found)
    end
  end

  defp get_neighbour(_map, _point, [], result) do
    {:ok, result}
  end

  defp get_neighbour(map, {pos_x, pos_y} = point, [{diff_x, diff_y} | tail], result) do
    new_x = pos_x + diff_x
    new_y = pos_y + diff_y
    new_key = {new_x, new_y}

    case Map.get(map, new_key, nil) do
      nil -> get_neighbour(map, point, tail, result)
      value -> get_neighbour(map, point, tail, [{new_key, value} | result])
    end
  end

  defp build_char([], _char_idx, _line_idx, out_map) do
    {:ok, out_map}
  end

  defp build_char([elem | tail], char_idx, line_idx, out_map) do
    new_map = Map.put(out_map, {char_idx, line_idx}, elem)
    build_char(tail, char_idx + 1, line_idx, new_map)
  end

  defp build_line([], _line_idx, out_map) do
    {:ok, out_map}
  end

  defp build_line([line | tail], line_idx, out_map) do
    {:ok, new_map} = build_char(String.to_charlist(line), 0, line_idx, out_map)
    build_line(tail, line_idx + 1, new_map)
  end
end
