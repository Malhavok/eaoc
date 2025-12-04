defmodule Main do
  @neighbours [{1, 1}, {1, 0}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, 0}, {-1, -1}]
  @max_around 4

  defp count_from_position(_point, ?., _grid) do
    {:ok, 0}
  end

  defp count_from_position(point, ?@, grid) do
    {:ok, neighbours} = Grid.get_neighbours(grid, point, @neighbours)

    counter =
      neighbours
      |> Enum.map(fn {_point, entry} -> entry end)
      |> Enum.filter(fn entry -> entry == ?@ end)
      |> length()

    bump =
      if counter < @max_around do
        1
      else
        0
      end

    {:ok, bump}
  end

  defp count_neighbours([], _grid, result) do
    {:ok, result}
  end

  defp count_neighbours([point | tail], grid, result) do
    grid_entry = Map.get(grid, point)
    {:ok, addition} = count_from_position(point, grid_entry, grid)
    count_neighbours(tail, grid, result + addition)
  end

  def part1(input_data) do
    {:ok, grid} = Grid.init(input_data)
    {:ok, _counter} = count_neighbours(Map.keys(grid), grid, 0)
  end

  defp fetch_important_entries([], _grid, result) do
    {:ok, result}
  end

  defp fetch_important_entries([point | tail], grid, result) do
    case Map.get(grid, point) do
      ?@ -> fetch_important_entries(tail, grid, [point | result])
      _ -> fetch_important_entries(tail, grid, result)
    end
  end

  defp clear_grid(grid, []) do
    {:ok, grid}
  end

  defp clear_grid(grid, [point | tail]) do
    new_grid = Map.put(grid, point, ?.)
    clear_grid(new_grid, tail)
  end

  defp remove_nonlocked_entries(_grid, [], to_remove_list, still_important_list) do
    {:ok, to_remove_list, still_important_list}
  end

  defp remove_nonlocked_entries(grid, [point | tail], to_remove_list, still_important_list) do
    case count_from_position(point, ?@, grid) do
      {:ok, 1} ->
        remove_nonlocked_entries(grid, tail, [point | to_remove_list], still_important_list)

      _ ->
        remove_nonlocked_entries(grid, tail, to_remove_list, [point | still_important_list])
    end
  end

  defp step_non_locked_entries(grid, move_points) do
    {:ok, removed_list, new_move_points} = remove_nonlocked_entries(grid, move_points, [], [])
    {:ok, new_grid} = clear_grid(grid, removed_list)
    {:ok, new_grid, removed_list, new_move_points}
  end

  defp iterate_non_locked_entries(grid, move_points, counter) do
    {:ok, new_grid, remove_list, new_move_points} = step_non_locked_entries(grid, move_points)
    remove_list_count = length(remove_list)

    case remove_list_count do
      0 -> {:ok, counter}
      _ -> iterate_non_locked_entries(new_grid, new_move_points, counter + remove_list_count)
    end
  end

  def part2(input_data) do
    {:ok, grid} = Grid.init(input_data)
    {:ok, paper_roll_points} = fetch_important_entries(Map.keys(grid), grid, [])
    iterate_non_locked_entries(grid, paper_roll_points, 0)
  end
end
