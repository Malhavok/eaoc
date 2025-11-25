defmodule CommandLine do
  def handle(["init", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      handle_init(day, year)
    end
  end

  def handle(["init", day_str]) do
    {:ok, %AoC.Config{}} = {:ok, config} = AoC.Config.load()

    with {day, ""} <- Integer.parse(day_str) do
      handle_init(day, config.year)
    end
  end

  def handle(["run"]) do
    {:ok, config} = AoC.Config.load()
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
    perform_run(day, year)
    AoC.Config.save(%AoC.Config{day: day, year: year})
    :ok
  end

  defp perform_run(day, year) do
    {:ok, %Day.Config{}} = {:ok, day_config} = Day.Config.load(day, year)

    start_time = System.monotonic_time()
    run_result = perform_run(day, year, day_config.status)
    end_time = System.monotonic_time()

    duration = System.convert_time_unit(end_time - start_time, :native, :millisecond)

    %Day.Config{day_config | events: [Event.Run.new(duration, run_result) | day_config.events]}
    |> Day.Config.save(day, year)
  end

  defp perform_run(day, year, :done) do
    IO.puts("Rerunning part2 for day #{day}/#{year}")
    perform_run(day, year, :part2)
  end

  defp perform_run(day, year, part_id) do
    try do
      apply(Run, part_id, [day, year])
    rescue
      exception -> {:exception, inspect(exception)}
    end
  end
end
