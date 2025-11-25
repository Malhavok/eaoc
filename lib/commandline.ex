defmodule CommandLine do
  def handle(["init", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      Init.day(day, year) |> inspect() |> IO.puts()
      AoC.Config.save(%AoC.Config{day: day, year: year})
    end
  end

  def handle(["run"]) do
    config = AoC.Config.load()
    Run.part1(config.day, config.year) |> inspect() |> IO.puts()
  end

  def handle(["run", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      Run.part1(day, year) |> inspect() |> IO.puts()
      AoC.Config.save(%AoC.Config{day: day, year: year})
      :ok
    end
  end
end
