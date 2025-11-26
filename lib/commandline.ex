defmodule CommandLineHelper do
  defmacro make_handle(command, call) do
    quote do
      def handle(unquote(command), day_str, year_str) do
        {:ok, config} = AoC.Config.load()
        day = if day_str, do: String.to_integer(day_str), else: config.day
        year = if year_str, do: String.to_integer(year_str), else: config.year
        unquote(call).(day, year)
      end
    end
  end
end

defmodule CommandLine do
  require CommandLineHelper

  def handle(command, day_str \\ nil, year_str \\ nil)

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
      | events: [Event.Run.new(duration, Tuple.to_list(run_result)) | day_config.events]
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

  CommandLineHelper.make_handle("init", &handle_init/2)
  CommandLineHelper.make_handle("run", fn day, year -> handle_run(day, year, :run) end)
  CommandLineHelper.make_handle("test", fn day, year -> handle_run(day, year, :test) end)
  CommandLineHelper.make_handle("log", &handle_log/2)
  CommandLineHelper.make_handle("done", &handle_done/2)
end
