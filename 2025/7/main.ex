defmodule Main do
  defp move_beams(_grid, [], _beams_map, new_beam_map, _y_pos, split_count) do
    {:ok, MapSet.to_list(new_beam_map), split_count}
  end

  defp move_beams(grid, [x_pos | tail], beams_map, new_beam_map, y_pos, split_count) do
    case Map.get(grid, {x_pos, y_pos}) do
      ?. ->
        updated_beam_map = new_beam_map |> MapSet.put(x_pos)
        move_beams(grid, tail, beams_map, updated_beam_map, y_pos, split_count)

      ?^ ->
        updated_map_beam = new_beam_map |> MapSet.put(x_pos - 1) |> MapSet.put(x_pos + 1)
        move_beams(grid, tail, beams_map, updated_map_beam, y_pos, split_count + 1)
    end
  end

  defp iterate_beams(grid, beams, y_pos, split_count) do
    case Map.get(grid, {0, y_pos}, nil) do
      nil ->
        {:ok, split_count}

      _ ->
        {:ok, new_beams, new_splits} =
          move_beams(grid, beams, MapSet.new(beams), MapSet.new(), y_pos, 0)

        iterate_beams(grid, new_beams, y_pos + 1, split_count + new_splits)
    end
  end

  def part1(input_data) do
    {:ok, grid} = Grid.init(input_data)
    {:ok, [{x_pos, y_pos}]} = Grid.get_positions(grid, ?S)
    iterate_beams(grid, [x_pos], y_pos + 1, 0)
  end

  defp travel_with_beam(grid, x_pos, y_pos) do
    case Map.get(grid, {x_pos, y_pos}, nil) do
      nil ->
        1

      ?. ->
        travel_with_beam(grid, x_pos, y_pos + 1)

      ?^ ->
        travel_with_beam(grid, x_pos - 1, y_pos + 1) +
          travel_with_beam(grid, x_pos + 1, y_pos + 1)
    end
  end

  def part2(input_data) do
    {:ok, grid} = Grid.init(input_data)
    {:ok, [{x_pos, y_pos}]} = Grid.get_positions(grid, ?S)
    {:ok, travel_with_beam(grid, x_pos, y_pos + 1)}
  end
end
