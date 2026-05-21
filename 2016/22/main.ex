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
    ({:ok, _data} = parse_input(input_data)) |> inspect() |> IO.puts()
    {:ok, :test}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
