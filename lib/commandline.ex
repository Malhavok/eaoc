defmodule CommandLine do
  def handle(["init", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      Init.day(day, year) |> inspect() |> IO.puts()
    end
  end

  def handle(["run", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      Run.part1(day, year) |> inspect() |> IO.puts()
    end
  end
end
