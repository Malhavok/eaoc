defmodule CommandLine do
  def handle(["init", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      handle_init(day, year)
    end
  end

  def handle(["init", day_str]) do
    %AoC.Config{} = config = AoC.Config.load()

    with {day, ""} <- Integer.parse(day_str) do
      handle_init(day, config.year)
    end
  end

  def handle(["run"]) do
    config = AoC.Config.load()
    handle_run(config.day, config.year)
  end

  def handle(["run", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      handle_run(day, year)
    end
  end

  defp handle_init(day, year) do
    {:ok, _} = Init.day(day, year)
    :ok = AoC.Config.save(%AoC.Config{day: day, year: year})
    :ok
  end

  defp handle_run(day, year) do
    Run.part1(day, year) |> inspect() |> IO.puts()
    AoC.Config.save(%AoC.Config{day: day, year: year})
    :ok
  end
end
