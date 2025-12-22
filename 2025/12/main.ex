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

  defp mirror_transform([], _x_mult, _y_mult, _sizes, result) do
    result |> Enum.sort()
  end

  defp mirror_transform([{x_pos, y_pos} | tail], x_mult, y_mult, {x_size, y_size} = sizes, result) do
    x_mod = div(1 - x_mult, 2)
    y_mod = div(1 - y_mult, 2)
    new_x_pos = rem(x_size - x_mod + x_pos * x_mult, x_size)
    new_y_pos = rem(y_size - y_mod + y_pos * y_mult, y_size)
    mirror_transform(tail, x_mult, y_mult, sizes, [{new_x_pos, new_y_pos} | result])
  end

  defp rotate_flip_90([], result) do
    result |> Enum.sort()
  end

  defp rotate_flip_90([{x_pos, y_pos} | tail], result) do
    rotate_flip_90(tail, [{y_pos, x_pos} | result])
  end

  defp apply_all_mirrors(state, sizes) do
    {:ok,
     [
       state,
       state |> mirror_transform(-1, 1, sizes, []),
       state |> mirror_transform(1, -1, sizes, []),
       state |> mirror_transform(-1, -1, sizes, [])
     ]}
  end

  defp build_transforms(initial, sizes) do
    {:ok, all_from_initial} = initial |> apply_all_mirrors(sizes)
    {:ok, all_rotated} = initial |> rotate_flip_90([]) |> apply_all_mirrors(sizes)
    unique_elements = (all_from_initial ++ all_rotated) |> Enum.uniq()
    {:ok, unique_elements}
  end

  def parse(index, lines) do
    {:ok, board_lines, new_tail} = grab_lines(lines, [])
    {:ok, grid} = Grid.init(board_lines |> Enum.join("\n"))

    x_size =
      1 + (grid |> Map.to_list() |> Enum.map(fn {{x_pos, _}, _} -> x_pos end) |> Enum.max())

    y_size =
      1 + (grid |> Map.to_list() |> Enum.map(fn {{_, y_pos}, _} -> y_pos end) |> Enum.max())

    first_transform =
      grid
      |> Map.to_list()
      |> Enum.filter(fn {_key, value} -> value == ?# end)
      |> Enum.map(fn {key, _} -> key end)
      |> Enum.sort()

    {:ok, all_transforms} = build_transforms(first_transform, {x_size, y_size})

    {
      :ok,
      %__MODULE__{
        index: index,
        original: grid,
        x_size: x_size,
        y_size: y_size,
        transformed: all_transforms
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
    :ok = print_polyomio(head |> MapSet.new(), x_size, y_size, 0)
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
    {:ok, _polyominoes, _boards} = parse_data(input_data)
    {:ok, :test}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
