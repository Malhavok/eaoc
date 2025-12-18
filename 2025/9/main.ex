defmodule Main do
  defp load_input(input_data) do
    input_data
    |> String.split("\n")
    |> Enum.filter(fn elem -> String.length(elem) > 0 end)
    |> Enum.map(fn elem ->
      elem |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  defp largest_square(_start_point, [], largest_area) do
    {:ok, largest_area}
  end

  defp largest_square({x1, y1} = start_point, [{x2, y2} | tail], largest_area) do
    area = (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
    largest_square(start_point, tail, max(largest_area, area))
  end

  defp largest_square([_], largest_area) do
    {:ok, largest_area}
  end

  defp largest_square([point | tail], largest_area) do
    {:ok, new_large} = largest_square(point, tail, largest_area)
    largest_square(tail, new_large)
  end

  def part1(input_data) do
    data = load_input(input_data)
    largest_square(data, 0)
  end

  defp validate_no_non_90deg([], _) do
    {:ok, :valid}
  end

  defp validate_no_non_90deg([{x1, y1} = point | tail], {x2, y2}) when x1 == x2 or y1 == y2 do
    validate_no_non_90deg(tail, point)
  end

  defp validate_no_non_90deg(_list, _point) do
    {:error, :invalid}
  end

  defp build_edges([], _point, edges) do
    {:ok, edges}
  end

  defp build_edges([{x1, y1} = point | tail], {x2, y2}, edges) do
    case x1 == x2 do
      true ->
        new_edge = {:x, x1, {min(y1, y2), max(y1, y2)}}
        build_edges(tail, point, [new_edge | edges])

      false ->
        new_edge = {:y, y1, {min(x1, x2), max(x1, x2)}}
        build_edges(tail, point, [new_edge | edges])
    end
  end

  defp does_cross_any_edge?(_, []) do
    false
  end

  defp does_cross_any_edge?(
         {x_index, x_val, {min_y, max_y}} = input,
         [{y_index, y_val, {min_x, max_x}} | tail]
       )
       when x_index != y_index do
    if min_x < x_val && x_val < max_x && min_y < y_val && y_val < max_y do
      true
    else
      does_cross_any_edge?(input, tail)
    end
  end

  defp does_cross_any_edge?(input, [_ | tail]) do
    does_cross_any_edge?(input, tail)
  end

  defp is_valid_square?({min_x, min_y}, {max_x, max_y}, edges) do
    working_edges = [
      {:x, min_x, {min_y, max_y}},
      {:x, max_x, {min_y, max_y}},
      {:y, min_y, {min_x, max_x}},
      {:y, max_y, {min_x, max_x}}
    ]

    !(working_edges |> Enum.any?(fn entry -> does_cross_any_edge?(entry, edges) end))
  end

  defp largest_square2(_start_point, [], largest_area, _edges) do
    {:ok, largest_area}
  end

  defp largest_square2({x1, y1} = start_point, [{x2, y2} | tail], largest_area, edges) do
    area = (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)

    min_x = min(x1, x2)
    max_x = max(x1, x2)
    min_y = min(y1, y2)
    max_y = max(y1, y2)

    # Skip if there's nothing to do.
    if area <= largest_area || !is_valid_square?({min_x, min_y}, {max_x, max_y}, edges) do
      largest_square2(start_point, tail, largest_area, edges)
    else
      largest_square2(start_point, tail, area, edges)
    end
  end

  defp largest_square2([_], largest_area, _edges) do
    {:ok, largest_area}
  end

  defp largest_square2([point | tail], largest_area, edges) do
    {:ok, new_large} = largest_square2(point, tail, largest_area, edges)
    largest_square2(tail, new_large, edges)
  end

  def part2(input_data) do
    data = load_input(input_data)

    # Ensure that there are only basic edges.
    [head | tail] = data
    {:ok, :valid} = validate_no_non_90deg(tail ++ [head], head)
    {:ok, edges} = build_edges(tail ++ [head], head, [])

    largest_square2(data, 0, edges)
  end
end
