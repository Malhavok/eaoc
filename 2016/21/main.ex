defmodule Main do
  defp parse_command("swap position " <> rest) do
    # swap position X with position Y
    parts = rest |> String.split(" ")
    x_value = parts |> Enum.at(0) |> String.to_integer()
    y_value = parts |> Enum.at(-1) |> String.to_integer()
    {:swap_position, x_value, y_value}
  end

  defp parse_command("swap letter " <> rest) do
    # swap letter X with letter Y
    parts = rest |> String.split(" ")
    x_value = parts |> Enum.at(0) |> String.to_charlist() |> Enum.at(0)
    y_value = parts |> Enum.at(-1) |> String.to_charlist() |> Enum.at(0)
    {:swap_letter, x_value, y_value}
  end

  defp parse_command("rotate left " <> rest) do
    # rotate left X steps
    num_steps = rest |> String.split(" ") |> Enum.at(0) |> String.to_integer()
    {:rotate, -1, num_steps}
  end

  defp parse_command("rotate right " <> rest) do
    # rotate right X steps
    num_steps = rest |> String.split(" ") |> Enum.at(0) |> String.to_integer()
    {:rotate, 1, num_steps}
  end

  defp parse_command("rotate based on position of letter " <> rest) do
    # rotate based on position of letter X
    {:rotate_by, rest |> String.to_charlist() |> Enum.at(0)}
  end

  defp parse_command("reverse positions " <> rest) do
    # reverse positions X through Y
    parts = rest |> String.split(" ")
    x_value = parts |> Enum.at(0) |> String.to_integer()
    y_value = parts |> Enum.at(-1) |> String.to_integer()
    {:reverse, x_value, y_value}
  end

  defp parse_command("move position " <> rest) do
    # move position X to position Y
    parts = rest |> String.split(" ")
    x_value = parts |> Enum.at(0) |> String.to_integer()
    y_value = parts |> Enum.at(-1) |> String.to_integer()
    {:move, x_value, y_value}
  end

  defp parse_command(_) do
    :error
  end

  defp parse_input(input_data) do
    lines = input_data |> String.split("\n", trim: true)
    password = lines |> Enum.at(0)
    commands = lines |> Enum.drop(1) |> Enum.map(&parse_command/1)
    {:ok, password, commands}
  end

  defp apply_command(password, {:swap_position, x_value, y_value}) do
    letter_at_x = password |> Enum.at(x_value)
    letter_at_y = password |> Enum.at(y_value)
    first_swap = password |> List.replace_at(x_value, letter_at_y)
    second_swap = first_swap |> List.replace_at(y_value, letter_at_x)
    {:ok, second_swap}
  end

  defp apply_command(password, {:swap_letter, x_value, y_value}) do
    index_of_x = password |> Enum.find_index(fn elem -> elem == x_value end)
    index_of_y = password |> Enum.find_index(fn elem -> elem == y_value end)
    apply_command(password, {:swap_position, index_of_x, index_of_y})
  end

  defp apply_command(password, {:rotate, direction, num_steps}) do
    len = length(password)
    actual_steps = rem(num_steps, len)
    part_password = password ++ password ++ password
    {_start, new_password_start} = part_password |> Enum.split(len - direction * actual_steps)
    {:ok, new_password_start |> Enum.take(len)}
  end

  defp apply_command(password, {:rotate_by, letter}) do
    index_of_letter = password |> Enum.find_index(fn elem -> elem == letter end)

    rotation =
      1 + index_of_letter +
        if index_of_letter >= 4 do
          1
        else
          0
        end

    apply_command(password, {:rotate, 1, rotation})
  end

  defp apply_command(password, {:reverse, x_value, y_value}) do
    {header, remainder} = Enum.split(password, x_value)
    {to_reverse, tail} = Enum.split(remainder, y_value - x_value + 1)
    reversed = to_reverse |> Enum.reverse() |> Enum.to_list()
    {:ok, header ++ reversed ++ tail}
  end

  defp apply_command(password, {:move, x_value, y_value}) do
    letter_at_x = password |> Enum.at(x_value)
    password_without_x = password |> List.delete_at(x_value)
    new_password = password_without_x |> List.insert_at(y_value, letter_at_x)
    {:ok, new_password}
  end

  defp scramble(password, []) do
    {:ok, password}
  end

  defp scramble(password, [command | tail]) do
    {:ok, new_password} = apply_command(password, command)
    scramble(new_password, tail)
  end

  def part1(input_data) do
    {:ok, password, commands} = parse_input(input_data)
    {:ok, _password} = scramble(password |> String.to_charlist(), commands)
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end
