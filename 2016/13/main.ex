defmodule Main do
  @grid_cache :grid_cache

  defp parse_input(input_data) do
    [numer_raw, point_raw] =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    [x_raw, y_raw] = point_raw |> String.split(",")

    {
      :ok,
      String.to_integer(numer_raw),
      Point2D.new(
        String.to_integer(x_raw),
        String.to_integer(y_raw)
      )
    }
  end

  defp calculate_point_wall(point, number) do
    x_2 = point.x * point.x
    three_x = 3 * point.x
    two_x_y = 2 * point.x * point.y
    y_2 = point.y * point.y

    value = x_2 + three_x + two_x_y + point.y + y_2 + number

    num_ones =
      value |> Integer.to_charlist(2) |> Enum.filter(fn elem -> elem == ?1 end) |> length()

    rem(num_ones, 2) == 1
  end

  defp is_point_wall?(%Point2D{x: x, y: y}, _number) when x < 0 or y < 0 do
    true
  end

  defp is_point_wall?(point, number) do
    case :ets.lookup(@grid_cache, point) do
      [{^point, is_wall}] ->
        is_wall

      [] ->
        is_wall = calculate_point_wall(point, number)
        :ets.insert(@grid_cache, {point, is_wall})
        is_wall
    end
  end

  defp try_move_from_point(current_point, distance, number, priority_queue, visited) do
    if MapSet.member?(visited, current_point) do
      {priority_queue, visited}
    else
      move_from_point(current_point, distance, number, priority_queue, visited)
    end
  end

  defp move_from_point(current_point, distance, number, priority_queue, visited) do
    next_distance = distance + 1

    new_queue =
      Point2D.carinal()
      |> Enum.map(fn direction -> Point2D.add(current_point, direction) end)
      |> Enum.filter(fn position -> !is_point_wall?(position, number) end)
      |> Enum.filter(fn position -> !MapSet.member?(visited, position) end)
      |> Enum.reduce(priority_queue, fn position, acc ->
        PriorityQueue.put(acc, {next_distance, position})
      end)

    # Since we always go from the "smallest" value, we don't really need to keep distances here.
    new_visited = MapSet.put(visited, current_point)

    {new_queue, new_visited}
  end

  defp search_for_target(start_point, end_point, number) do
    queue = PriorityQueue.new() |> PriorityQueue.put({0, start_point})
    run_search(end_point, number, queue, MapSet.new())
  end

  defp run_search(end_point, number, priority_queue, visited) do
    {{distance, current_point}, new_queue} = PriorityQueue.pop(priority_queue)

    if current_point == end_point do
      {:ok, distance}
    else
      {bumped_queue, new_visited} =
        try_move_from_point(current_point, distance, number, new_queue, visited)

      run_search(end_point, number, bumped_queue, new_visited)
    end
  end

  def part1(input_data) do
    {:ok, magic_number, end_position} = parse_input(input_data)
    :ets.new(@grid_cache, [:named_table, :set])
    {:ok, _distance} = search_for_target(Point2D.new(1, 1), end_position, magic_number)
  end

  defp search_for_depth(start_point, max_depth, number) do
    queue = PriorityQueue.new() |> PriorityQueue.put({0, start_point})
    run_depth(max_depth, number, queue, MapSet.new())
  end

  defp run_depth(max_depth, number, priority_queue, visited) do
    {{distance, current_point}, new_queue} = PriorityQueue.pop(priority_queue)

    if {distance, current_point} == {nil, nil} do
      {:ok, MapSet.size(visited)}
    else
      if distance <= max_depth and !MapSet.member?(visited, current_point) do
        {bumped_queue, new_visited} =
          try_move_from_point(current_point, distance, number, new_queue, visited)

        run_depth(max_depth, number, bumped_queue, new_visited)
      else
        run_depth(max_depth, number, new_queue, visited)
      end
    end
  end

  def part2(input_data) do
    {:ok, magic_number, _end_position} = parse_input(input_data)
    :ets.new(@grid_cache, [:named_table, :set])
    search_for_depth(Point2D.new(1, 1), 50, magic_number)
  end
end
