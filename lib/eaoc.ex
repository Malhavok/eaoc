defmodule Eaoc do
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
  def init_year(year) when is_integer(year) and year > 1980 do
    case File.mkdir("#{year}") do
      :ok -> {:ok, :created}
      {:error, :eexist} -> {:ok, :alreadyexists}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Initialises a given day within a year.

  Returns
  {:ok, :created}
  {:ok, :alreadyexists}
  {:error, reason}
  """
  def init_day(day, year) when is_integer(day) and day > 0 and day < 26 do
    with {:ok, _} = init_year(year) do
      IO.puts("Initialising #{day}, #{year}")
    end

    {:ok, :created}
  end
end
