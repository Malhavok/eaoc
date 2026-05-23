defmodule Main.Node do
  defstruct x: 0, y: 0, size: 0, used: 0

  defp string_drop(in_str, place) do
    in_str |> String.to_charlist() |> Enum.drop(place) |> List.to_string()
  end

  def parse_line(line) do
    # Filesystem              Size  Used  Avail  Use%
    # /dev/grid/node-x22-y12  507T  495T    12T   97%
    # Interesting data:
    # x, y, size, used (available = size - used)
    parts = line |> String.split(" ", trim: true)
    grid_parts = parts |> Enum.at(0) |> String.split("-")

    x = grid_parts |> Enum.at(-2) |> string_drop(1) |> String.to_integer()
    y = grid_parts |> Enum.at(-1) |> string_drop(1) |> String.to_integer()

    size = parts |> Enum.at(1) |> string_drop(-1) |> String.to_integer()
    used = parts |> Enum.at(2) |> string_drop(-1) |> String.to_integer()

    %__MODULE__{x: x, y: y, size: size, used: used}
  end

  def get_available(node) do
    node.size - node.used
  end
end

defmodule Main do
  defp parse_input(input_data) do
    # First two lines are meaningless – command and a header.
    result =
      input_data
      |> String.split("\n", trim: true)
      |> Enum.drop(2)
      |> Enum.map(&Main.Node.parse_line/1)

    {:ok, result}
  end

  def part1(input_data) do
    {:ok, data} = parse_input(input_data)

    with_available =
      data
      |> Enum.map(fn node ->
        {"#{node.x}-#{node.y}", node.used, Main.Node.get_available(node)}
      end)

    sort_by_used =
      with_available |> Enum.sort(fn {_, value1, _}, {_, value2, _} -> value1 < value2 end)

    sort_by_available =
      with_available |> Enum.sort(fn {_, _, value1}, {_, _, value2} -> value1 < value2 end)

    group =
      sort_by_used
      |> Enum.map(fn {key1, used, _} ->
        sort_by_available
        |> Enum.filter(fn {key2, _, available} ->
          key1 != key2 and used > 0 and available >= used
        end)
        |> Enum.map(fn {key2, _, _} -> "#{key1}-#{key2}" end)
      end)
      |> List.flatten()
      |> Enum.uniq()

    {:ok, group |> length()}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
