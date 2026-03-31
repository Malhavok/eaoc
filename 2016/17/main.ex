defmodule Main.Data do
  defstruct position: nil, path: nil
end

defmodule Main do
  # Up arrow goes downwards.
  @up Point2D.new(0, -1)
  @down Point2D.new(0, 1)
  @left Point2D.new(-1, 0)
  @right Point2D.new(1, 0)

  @start Point2D.new(0, 0)
  @goal Point2D.new(3, 3)

  @direction_string %{@up => "U", @down => "D", @left => "L", @right => "R"}
  @open_doors MapSet.new([?b, ?c, ?d, ?e, ?f])

  defp parse_input(input_data) do
    password = input_data |> String.split("\n") |> Enum.at(0)
    {:ok, password}
  end

  defp open_directions(password, path_string) do
    full_string = password <> path_string
    hash = :crypto.hash(:md5, full_string) |> Base.encode16(case: :lower) |> String.to_charlist()

    directions =
      [@up, @down, @left, @right]
      |> Enum.with_index()
      |> Enum.filter(fn {_direction, index} ->
        character = hash |> Enum.at(index)
        MapSet.member?(@open_doors, character)
      end)
      |> Enum.map(fn {direction, _index} -> direction end)

    {:ok, directions}
  end

  defp move_part1(priority_queue, distance, position, password, path, bounds_fun) do
    {:ok, directions} = open_directions(password, path)

    new_queue =
      directions
      |> Enum.map(fn direction -> {direction, Map.get(@direction_string, direction)} end)
      |> Enum.map(fn {direction, new_path} ->
        %Main.Data{
          position: Point2D.add(position, direction),
          path: path <> new_path
        }
      end)
      |> Enum.filter(fn %Main.Data{position: pos} -> bounds_fun.(pos) end)
      |> Enum.reduce(priority_queue, fn data, queue ->
        PriorityQueue.put(queue, distance + 1, data)
      end)

    {:ok, new_queue}
  end

  defp iterate_part1(priority_queue, end_pos, password, bounds_fun) do
    {{distance, main_data}, new_queue} = PriorityQueue.pop!(priority_queue)
    %Main.Data{position: position, path: path} = main_data

    if position == end_pos do
      {:ok, path}
    else
      {:ok, updated_queue} =
        move_part1(new_queue, distance, position, password, path, bounds_fun)

      iterate_part1(updated_queue, end_pos, password, bounds_fun)
    end
  end

  defp run_part1(start_pos, end_pos, password, bounds_fun) do
    priority_queue =
      PriorityQueue.new() |> PriorityQueue.put(0, %Main.Data{position: start_pos, path: ""})

    iterate_part1(priority_queue, end_pos, password, bounds_fun)
  end

  @spec in_bounds_part1?(Point2D.t()) :: bool
  defp in_bounds_part1?(point) do
    point.x >= 0 and point.y >= 0 and point.x <= 3 and point.y <= 3
  end

  def part1(input_data) do
    {:ok, password} = parse_input(input_data)
    {:ok, _path} = run_part1(@start, @goal, password, &in_bounds_part1?/1)
  end

  defp safe_pop(priority_queue) do
    {item, new_queue} = PriorityQueue.pop(priority_queue)

    if item == nil do
      {{nil, nil}, new_queue}
    else
      {item, new_queue}
    end
  end

  defp iterate_part2(priority_queue, end_pos, password, bounds_fun, max_distance) do
    {{distance, main_data}, new_queue} = safe_pop(priority_queue)

    if distance == nil do
      {:ok, max_distance}
    else
      %Main.Data{position: position, path: path} = main_data

      if position == end_pos do
        # Since we're going breadth-first, each new distance we find will be larger than the previous one.
        iterate_part2(new_queue, end_pos, password, bounds_fun, distance)
      else
        {:ok, updated_queue} =
          move_part1(new_queue, distance, position, password, path, bounds_fun)

        iterate_part2(updated_queue, end_pos, password, bounds_fun, max_distance)
      end
    end
  end

  defp run_part2(start_pos, end_pos, password, bounds_fun) do
    priority_queue =
      PriorityQueue.new() |> PriorityQueue.put(0, %Main.Data{position: start_pos, path: ""})

    iterate_part2(priority_queue, end_pos, password, bounds_fun, 0)
  end

  def part2(input_data) do
    {:ok, password} = parse_input(input_data)
    {:ok, _max_len} = run_part2(@start, @goal, password, &in_bounds_part1?/1)
  end
end
