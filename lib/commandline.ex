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

  def handle(["log"]) do
    {:ok, config} = AoC.Config.load()
    handle_log(config.day, config.year)
  end

  def handle(["log", day_str]) do
    {:ok, config} = AoC.Config.load()

    with {day, ""} <- Integer.parse(day_str) do
      handle_log(day, config.year)
    end
  end

  def handle(["log", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      handle_log(day, year)
    end
  end

  def handle(["done"]) do
    {:ok, config} = AoC.Config.load()
    handle_done(config.day, config.year)
  end

  def handle(["done", day_str]) do
    {:ok, config} = AoC.Config.load()

    with {day, ""} <- Integer.parse(day_str) do
      handle_done(day, config.year)
    end
  end

  def handle(["done", day_str, year_str]) do
    with {day, ""} <- Integer.parse(day_str), {year, ""} <- Integer.parse(year_str) do
      handle_done(day, year)
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

    %Day.Config{
      day_config
      | events: [Event.Run.new(duration, Tuple.to_list(run_result)) | day_config.events]
    }
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

  defp handle_log(day, year) do
    {:ok, %Day.Config{}} = {:ok, day_config} = Day.Config.load(day, year)
    decoded_events = for elem <- day_config.events, do: Event.from_map(elem)

    for elem <- Enum.reverse(decoded_events), do: elem |> inspect() |> IO.puts()

    AoC.Config.save(%AoC.Config{day: day, year: year})
    :ok
  end

  defp handle_done(day, year) do
    {:ok, %Day.Config{}} = {:ok, day_config} = Day.Config.load(day, year)
    {:ok, new_config} = Day.Config.progress_done(day_config)
    :ok = Day.Config.save(new_config, day, year)
    AoC.Config.save(%AoC.Config{day: day, year: year})
  end
end
