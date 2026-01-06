defmodule Main.Board do
  defstruct x_size: 0, y_size: 0

  def parse_line(line) do
    [x_str, y_str] = line |> String.split("x")
    %__MODULE__{x_size: String.to_integer(x_str), y_size: String.to_integer(y_str)}
  end
end

defmodule Main.Instruction do
  defstruct type: :none, param1: 0, param2: 0

  defp parse_params(params, instruction, separator) do
    [param1_str, param2_str] = params |> String.split(separator)

    %__MODULE__{
      type: instruction,
      param1: String.to_integer(param1_str),
      param2: String.to_integer(param2_str)
    }
  end

  def parse_line("rect " <> params) do
    parse_params(params, :rect, "x")
  end

  def parse_line("rotate column x=" <> params) do
    parse_params(params, :rotate_column, " by ")
  end

  def parse_line("rotate row y=" <> params) do
    parse_params(params, :rotate_row, " by ")
  end
end

defmodule Main do
  defp parse_input([], board, instructions) do
    {:ok, board, instructions |> Enum.reverse()}
  end

  defp parse_input([head | tail], nil, instructions) do
    board = Main.Board.parse_line(head)
    parse_input(tail, board, instructions)
  end

  defp parse_input([head | tail], board, instructions) do
    instruction = Main.Instruction.parse_line(head)
    parse_input(tail, board, [instruction | instructions])
  end

  defp parse_input(input_data) do
    lines =
      input_data |> String.split("\n") |> Enum.filter(fn line -> String.length(line) > 0 end)

    parse_input(lines, nil, [])
  end

  defp print_board(board, lit_entries) do
    0..(board.y_size - 1)
    |> Enum.each(fn y_index ->
      0..(board.x_size - 1)
      |> Enum.each(fn x_index ->
        char_to_write =
          if MapSet.member?(lit_entries, {x_index, y_index}) do
            "#"
          else
            " "
          end

        :ok = IO.write(char_to_write)
      end)

      :ok = IO.write("\n")
    end)

    :ok = IO.write("\n")
  end

  defp apply_instructions(_board, lit_entries, []) do
    {:ok, lit_entries}
  end

  defp apply_instructions(
         board,
         lit_entries,
         [
           %Main.Instruction{type: :rect, param1: x_size, param2: y_size}
           | tail
         ]
       ) do
    new_entries =
      0..(x_size - 1)
      |> Enum.map(fn x_index ->
        0..(y_size - 1) |> Enum.map(fn y_index -> {x_index, y_index} end)
      end)
      |> List.flatten()
      |> MapSet.new()

    new_lit_entries = MapSet.union(lit_entries, new_entries)

    apply_instructions(board, new_lit_entries, tail)
  end

  defp apply_instructions(
         board,
         lit_entries,
         [
           %Main.Instruction{type: :rotate_column, param1: x_idx, param2: move_by}
           | tail
         ]
       ) do
    entries_to_move =
      lit_entries |> MapSet.to_list() |> Enum.filter(fn {x_pos, _y_pos} -> x_pos == x_idx end)

    removed_entries = lit_entries |> MapSet.difference(MapSet.new(entries_to_move))

    new_entries =
      entries_to_move
      |> Enum.map(fn {x_pos, y_pos} -> {x_pos, rem(y_pos + move_by, board.y_size)} end)

    new_lit_entries = MapSet.union(removed_entries, MapSet.new(new_entries))

    apply_instructions(board, new_lit_entries, tail)
  end

  defp apply_instructions(
         board,
         lit_entries,
         [
           %Main.Instruction{type: :rotate_row, param1: y_idx, param2: move_by}
           | tail
         ]
       ) do
    entries_to_move =
      lit_entries |> MapSet.to_list() |> Enum.filter(fn {_x_pos, y_pos} -> y_pos == y_idx end)

    removed_entries = lit_entries |> MapSet.difference(MapSet.new(entries_to_move))

    new_entries =
      entries_to_move
      |> Enum.map(fn {x_pos, y_pos} -> {rem(x_pos + move_by, board.x_size), y_pos} end)

    new_lit_entries = MapSet.union(removed_entries, MapSet.new(new_entries))

    apply_instructions(board, new_lit_entries, tail)
  end

  defp apply_instructions(board, instructions) do
    apply_instructions(board, MapSet.new(), instructions)
  end

  def part1(input_data) do
    {:ok, board, instructions} = parse_input(input_data)
    {:ok, lit_entries} = apply_instructions(board, instructions)
    {:ok, MapSet.size(lit_entries)}
  end

  def part2(input_data) do
    {:ok, board, instructions} = parse_input(input_data)
    {:ok, lit_entries} = apply_instructions(board, instructions)
    print_board(board, lit_entries)
    {:ok, :human_readable}
  end
end
