defmodule Init do
  @typep results :: {:ok, :created} | {:ok, :alreadyexists} | {:error, atom()}

  @moduledoc """
  The main handler of commands coming to Elixir Advent of Code
  """

  @doc """
  Initialises a given year.
  """
  @spec year(non_neg_integer()) :: results()
  def year(year) when is_integer(year) and year > 1980 do
    Paths.year(year) |> mkdir()
  end

  @doc """
  Initialises a given day within a year.
  """
  @spec day(non_neg_integer(), non_neg_integer()) :: results()
  def day(day, year) when is_integer(day) and day > 0 and day < 26 do
    # If already exists,
    with {:ok, _} <- year(year),
         {:ok, :created} <- create_day(day, year) do
      :ok = template_day(day, year)
      {:ok, :created}
    end
  end

  @spec mkdir(String.t()) :: results()
  defp mkdir(path) do
    case File.mkdir(path) do
      :ok -> {:ok, :created}
      {:error, :eexist} -> {:ok, :alreadyexists}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec create_day(non_neg_integer(), non_neg_integer()) :: results()
  defp create_day(day, year) do
    Paths.day(day, year) |> mkdir()
  end

  @spec create_day(non_neg_integer(), non_neg_integer()) :: :ok
  defp template_day(day, year) do
    :ok = Paths.input_file(day, year) |> File.touch()
    :ok = Paths.test_file(day, year) |> File.touch()
    :ok = Paths.main_file(day, year) |> File.write("defmodule Main do
  def part1(_input_data) do
    {:error, :notimplemented}
  end

  def part2(_input_data) do
    {:error, :notimplemented}
  end
end")
    :ok = Day.Config.save(%Day.Config{}, day, year)
  end
end
