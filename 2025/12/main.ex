# A really simple `.lp` file:
#
# Minimize
#   obj: x_dummy
# Subject To
#   field_1_2_3: e_0_1_2 + e_0_2_3 + e_1_2_3 > 4
# Bounds
#   1 <= e_0_1_2 <= 2
#   x_dummy = 0
# Generals
#   e_0_1_2
# Binaries
#   e_0_2_3
#   e_1_2_3
# End
#
# Solver examples:
# >>> /opt/homebrew/bin/scip -f test.lp -l out.txt
# >>> /opt/homebrew/Cellar/glpk/5.0/bin/glpsol --lp test.lp -o out.txt

defmodule Main.Polyomino do
  defstruct index: -1, original: %{}, x_size: -1, y_size: -1, transformed: []

  defp grab_lines(["" | tail], lines) do
    {:ok, lines |> Enum.reverse(), tail}
  end

  defp grab_lines([head | tail], lines) do
    grab_lines(tail, [head | lines])
  end

  def parse(index, lines) do
    {:ok, board_lines, new_tail} = grab_lines(lines, [])
    {:ok, grid} = Grid.init(board_lines |> Enum.join("\n"))

    first_transform =
      grid
      |> Map.to_list()
      |> Enum.filter(fn {_key, value} -> value == ?# end)
      |> Enum.map(fn {key, _} -> key end)
      |> Enum.sort()
      |> MapSet.new()

    {
      :ok,
      %__MODULE__{
        index: index,
        original: grid,
        x_size:
          1 + (grid |> Map.to_list() |> Enum.map(fn {{x_pos, _}, _} -> x_pos end) |> Enum.max()),
        y_size:
          1 + (grid |> Map.to_list() |> Enum.map(fn {{_, y_pos}, _} -> y_pos end) |> Enum.max()),
        transformed: [first_transform]
      },
      new_tail
    }
  end

  defp print_polyomio(_, _, y_size, y_size) do
    IO.puts("")
    :ok
  end

  defp print_polyomio(entry, x_size, y_size, y_index) do
    line_characters =
      0..x_size
      |> Enum.map(fn x_index ->
        key = {x_index, y_index}

        case MapSet.member?(entry, key) do
          true ->
            "#"

          false ->
            " "
        end
      end)

    line_characters |> Enum.join("") |> IO.puts()

    print_polyomio(entry, x_size, y_size, y_index + 1)
  end

  defp print_transform([], _, _) do
    :ok
  end

  defp print_transform([head | tail], x_size, y_size) do
    :ok = print_polyomio(head, x_size, y_size, 0)
    print_transform(tail, x_size, y_size)
  end

  @spec print(%__MODULE__{}) :: :ok
  def print(element) do
    :ok = print_transform(element.transformed, element.x_size, element.y_size)
  end
end

defmodule Main.Board do
  defstruct x_size: 0, y_size: 0, poly_count: []

  def parse(line) do
    [size, indices_str] = line |> String.split(":", parts: 2)
    [x_size, y_size] = size |> String.split("x") |> Enum.map(&String.to_integer/1)
    indices_count = indices_str |> String.split() |> Enum.map(&String.to_integer/1)

    {:ok, %__MODULE__{x_size: x_size, y_size: y_size, poly_count: indices_count}}
  end
end

defmodule Main do
  defp parse_lines([], polyominoes, boards) do
    {:ok, polyominoes |> Enum.reverse(), boards |> Enum.reverse()}
  end

  defp parse_lines([line | tail], polyominoes, boards) do
    [line_head | _] = line |> String.split(":", parts: 2)

    case line_head |> Integer.parse() do
      {_value, "x" <> _rest} ->
        {:ok, board} = Main.Board.parse(line)
        parse_lines(tail, polyominoes, [board | boards])

      {value, _} ->
        {:ok, polyomino, new_tail} = Main.Polyomino.parse(value, tail)
        parse_lines(new_tail, [polyomino | polyominoes], boards)

      # For empty lines.
      :error ->
        parse_lines(tail, polyominoes, boards)
    end
  end

  defp parse_data(input_data) do
    lines = input_data |> String.split("\n")
    parse_lines(lines, [], [])
  end

  def part1(input_data) do
    {:ok, polyominoes, boards} = parse_data(input_data)

    [polyomino | _] = polyominoes
    polyomino |> inspect() |> IO.puts()
    Main.Polyomino.print(polyomino)

    {:ok, :test}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
