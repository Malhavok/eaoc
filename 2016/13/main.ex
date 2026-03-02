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

  def part1(input_data) do
    {:ok, magic_number, end_position} = parse_input(input_data)
    :ets.new(@grid_cache, [:named_table, :set])
    {:ok, :test}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
