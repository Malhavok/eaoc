defmodule Main.Polyomino do
  defstruct index: -1, original: %{}, transformed: []

  defp grab_lines(["" | tail], lines) do
    {:ok, lines |> Enum.reverse(), tail}
  end

  defp grab_lines([head | tail], lines) do
    grab_lines(tail, [head | lines])
  end

  def parse(index, lines) do
    {:ok, board_lines, new_tail} = grab_lines(lines, [])
    {:ok, grid} = Grid.init(board_lines |> Enum.join("\n"))

    {
      :ok,
      %__MODULE__{index: index, original: grid, transformed: []},
      new_tail
    }
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
    {:ok, polyominoes, boards} |> inspect() |> IO.puts()

    {:error, :notimplemented}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
