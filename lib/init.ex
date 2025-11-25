defmodule Init do
  @moduledoc """
  The main handler of commands coming to Elixir Advent of Code
  """

  @doc """
  Initialises a given year.

  Returns:
  {:ok, :created}
  {:ok, :alreadyexists}
  {:error, reason}
  """
  def year(year) when is_integer(year) and year > 1980 do
    Paths.year(year) |> mkdir()
  end

  @doc """
  Initialises a given day within a year.

  Returns
  {:ok, :created}
  {:ok, :alreadyexists}
  {:error, reason}
  """
  def day(day, year) when is_integer(day) and day > 0 and day < 26 do
    # If already exists,
    with {:ok, _} = year(year),
         {:ok, :created} = create_day(day, year) do
      :ok = template_day(day, year)
    end
  end

  defp mkdir(path) do
    case File.mkdir(path) do
      :ok -> {:ok, :created}
      {:error, :eexist} -> {:ok, :alreadyexists}
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_day(day, year) do
    Paths.day(day, year) |> mkdir()
  end

  defp template_day(day, year) do
    :ok = Paths.input1_file(day, year) |> File.touch()
    :ok = Paths.input2_file(day, year) |> File.touch()
    :ok = Paths.main_file(day, year) |> File.write("defmodule Main do
  def part1(inputData) do
    {:error, :notimplemented}
  end

  def part2(inputData) do
    {:error, :notimplemented}
  end
end")
  end
end
