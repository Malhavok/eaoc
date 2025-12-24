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
  @lp_file "input.lp"
  @txt_file "out.txt"
  @solved_line "SCIP Status        : problem is solved"
  @not_ok_line "SCIP Status        : problem is solved [infeasible]"
  @solver_path "/opt/homebrew/bin/scip"
  @infeasible_timeout_ms 10_000

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

  defp generate_polyomino(poly_pos_list, poly_index, transform_index, x_size, y_size) do
    Enum.reduce(0..x_size, {[], %{}}, fn x_index, state_pair ->
      Enum.reduce(0..y_size, state_pair, fn y_index, {variable_names, position_map} ->
        new_variable = "poly_#{poly_index}_#{transform_index}_#{x_index}_#{y_index}"

        new_position_map =
          poly_pos_list
          |> Enum.reduce(position_map, fn {x_pos, y_pos}, mapping ->
            full_x = x_pos + x_index
            full_y = y_pos + y_index
            cell_name = "cell_#{full_x}_#{full_y}"
            current = Map.get(mapping, new_variable, [])
            Map.put(mapping, new_variable, [cell_name | current])
          end)

        {[new_variable | variable_names], new_position_map}
      end)
    end)
  end

  defp generate_polyominoes({{polyomino, poly_index}, length}, board_x_size, board_y_size) do
    x_size = board_x_size - polyomino.x_size
    y_size = board_y_size - polyomino.y_size

    {variables_list, cell_mapping} =
      polyomino.transformed
      |> Enum.with_index()
      |> Enum.map(fn {poly_pos_list, transform_index} ->
        generate_polyomino(poly_pos_list, poly_index, transform_index, x_size, y_size)
      end)
      |> Enum.reduce({[], %{}}, fn {variables, mapping}, {out_variables, out_mapping} ->
        {
          out_variables ++ variables,
          Map.merge(out_mapping, mapping)
        }
      end)

    {length, variables_list, cell_mapping}
  end

  defp build_variable_equations([], _index, result, variables) do
    {:ok, variables, result}
  end

  defp build_variable_equations([{count, variables, _} | tail], index, result, out_variables) do
    sum_variables = variables |> Enum.join(" + ")
    new_equation = "vars_#{index}: #{sum_variables} = #{count}"
    build_variable_equations(tail, index + 1, [new_equation | result], out_variables ++ variables)
  end

  defp build_cell_equations(all_polyominoes) do
    # Input are tuples of 3, but we're only interested in the last entry.
    variable_mapping = all_polyominoes |> Enum.map(fn {_, _, map} -> map end)

    # So we have a map variable -> list-of-cells, and we want cell -> list-of-variables
    equations =
      variable_mapping
      |> Enum.reduce(%{}, fn mapping, accumulator ->
        mapping
        |> Map.keys()
        |> Enum.reduce(accumulator, fn variable, out_mapping ->
          Map.get(mapping, variable)
          |> Enum.reduce(out_mapping, fn cell_id, out_map ->
            current = Map.get(out_map, cell_id, [])
            Map.put(out_map, cell_id, [variable | current])
          end)
        end)
      end)
      |> Map.to_list()
      |> Enum.map(fn {cell_id, variable_list} ->
        variable_join = variable_list |> Enum.join(" + ")
        "#{cell_id}: #{variable_join} <= 1"
      end)

    {:ok, equations}
  end

  defp build_lp(variables, equations) do
    lines =
      [
        "Minimize",
        "  obj: dummy",
        "Subject To"
      ] ++
        (equations |> Enum.map(fn eq -> "  #{eq}" end)) ++
        [
          "Bounds",
          "  dummy = 0"
        ] ++
        (variables |> Enum.map(fn var -> "  0 <= #{var} <= 1" end)) ++
        [
          "Binaries"
        ] ++
        (variables |> Enum.map(fn var -> "  #{var}" end)) ++
        [
          "End"
        ]

    {:ok, lines |> Enum.join("\n")}
  end

  defp generate_lp(board, polyominoes) do
    poly_with_length =
      polyominoes
      |> Enum.with_index()
      |> Enum.zip(board.poly_count)
      |> Enum.filter(fn {_, count} -> count > 0 end)

    # Here we get a list of:
    # {<how many instances should be>, <all variables>, <map from variable to all the cells>}
    all_polyominoes =
      poly_with_length
      |> Enum.map(fn poly_index_len ->
        generate_polyominoes(poly_index_len, board.x_size, board.y_size)
      end)

    {:ok, variables, variables_equations} = build_variable_equations(all_polyominoes, 0, [], [])
    {:ok, cell_equations} = build_cell_equations(all_polyominoes)

    {:ok, lp_content} = build_lp(variables, variables_equations ++ cell_equations)
    File.write(@lp_file, lp_content)
  end

  defp read_output() do
    lines =
      @txt_file
      |> File.read!()
      |> String.split("\n")
      |> Enum.filter(fn line ->
        case line do
          @not_ok_line <> _ -> true
          _ -> false
        end
      end)

    @txt_file
    |> File.read!()
    |> String.split("\n")
    |> Enum.filter(fn line ->
      case line do
        @solved_line <> _ -> true
        _ -> false
      end
    end)
    |> inspect()
    |> IO.puts()

    case lines do
      [] -> :ok
      _ -> :error
    end
  end

  defp run_solver() do
    {_, 0} = System.cmd(@solver_path, ["-f", @lp_file, "-l", @txt_file])

    case read_output() do
      :ok -> 1
      :error -> 0
    end
  end

  defp solve([], _polyominoes, counter) do
    {:ok, counter}
  end

  defp solve([board | tail], polyominoes, counter) do
    :ok = generate_lp(board, polyominoes)

    task = Task.async(&run_solver/0)

    mod =
      case Task.yield(task, @infeasible_timeout_ms) do
        nil ->
          Task.shutdown(task, :brutal_kill)
          {_, 0} = System.cmd("pkill", ["-9", "scip"])

          IO.puts(
            "SCIP killed after #{@infeasible_timeout_ms} ms timeout. Considering [infeasible]."
          )

          0

        {:ok, mod} ->
          mod
      end

    File.rm(@lp_file)
    File.rm(@txt_file)

    solve(tail, polyominoes, counter + mod)
  end

  def part1(input_data) do
    File.rm(@lp_file)
    File.rm(@txt_file)

    {:ok, polyominoes, boards} = parse_data(input_data)
    solve(boards, polyominoes, 0)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
