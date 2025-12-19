defmodule CommandLine do
  def main(args) do
    apply(__MODULE__, :handle, args)
  end

  def handle(command, day_str \\ nil, year_str \\ nil)

  def handle("init", day_str, year_str) do
    handle_raw(&handle_init/2, day_str, year_str)
  end

  def handle("run", day_str, year_str) do
    handle_raw(fn day, year -> handle_run(day, year, :run) end, day_str, year_str)
  end

  def handle("test", day_str, year_str) do
    handle_raw(fn day, year -> handle_run(day, year, :test) end, day_str, year_str)
  end

  def handle("log", day_str, year_str) do
    handle_raw(&handle_log/2, day_str, year_str)
  end

  def handle("done", day_str, year_str) do
    handle_raw(&handle_done/2, day_str, year_str)
  end

  def handle_raw(handler_fun, day_str, year_str) do
    {:ok, config} = AoC.Config.load()
    day = if day_str, do: String.to_integer(day_str), else: config.day
    year = if year_str, do: String.to_integer(year_str), else: config.year
    handler_fun.(day, year)
  end

  defp handle_init(day, year) do
    {:ok, _} = Init.day(day, year)
    :ok = AoC.Config.save(%AoC.Config{day: day, year: year})
    :ok
  end

  defp handle_run(day, year, input_source) when input_source in [:run, :test] do
    perform_run(day, year, input_source)
    AoC.Config.save(%AoC.Config{day: day, year: year})
    :ok
  end

  defp perform_run(day, year, input_source) do
    {:ok, %Day.Config{}} = {:ok, day_config} = Day.Config.load(day, year)

    start_time = System.monotonic_time()
    run_result = perform_run(day, year, input_source, day_config.status)
    end_time = System.monotonic_time()

    duration = System.convert_time_unit(end_time - start_time, :native, :millisecond)

    %Day.Config{
      day_config
      | events: [
          Event.Run.new(duration, input_source, Tuple.to_list(run_result)) | day_config.events
        ]
    }
    |> Day.Config.save(day, year)

    run_result |> inspect() |> IO.puts()
  end

  defp perform_run(day, year, input_source, :done) do
    IO.puts("Rerunning part2 for day #{day}/#{year}")
    perform_run(day, year, input_source, :part2)
  end

  defp perform_run(day, year, input_source, part_id) do
    try do
      apply(Run, part_id, [day, year, input_source])
    rescue
      exception ->
        Exception.format_stacktrace() |> IO.puts()
        exception |> Exception.message() |> IO.puts()
        {:exception, inspect(exception)}
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
