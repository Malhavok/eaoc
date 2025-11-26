defmodule Day.Config do
  @status_new "part1"
  @status_part1_done "part2"
  @status_part2_done "done"

  @status_mapping %{
    @status_new => :part1,
    @status_part1_done => :part2,
    @status_part2_done => :done
  }

  @derive Jason.Encoder
  defstruct status: :part1, events: []

  @type t :: %__MODULE__{
          status: :part1 | :part2 | :done,
          events: [%Event.Run{} | %Event.Mark{}]
        }

  @spec save(t(), non_neg_integer(), non_neg_integer()) :: :ok
  def save(config, day, year) do
    binary = config |> Jason.encode!()
    Paths.config_file(day, year) |> File.write(binary)
  end

  @spec load(non_neg_integer(), non_neg_integer()) :: {:ok, t()}
  def load(day, year) do
    {:ok, binary} = Paths.config_file(day, year) |> File.read()
    {:ok, decoded} = Jason.decode(binary, keys: :atoms)
    converted = %{decoded | status: @status_mapping[decoded.status]}
    {:ok, struct(__MODULE__, converted)}
  end

  def progress_done(config_raw) do
    %__MODULE__{} = config = config_raw

    case config.status do
      :part1 ->
        IO.puts("Congrats! Second part is ahead!")
        mark_part1_done(config)

      :part2 ->
        IO.puts("Congrats! Go for the next task!")
        mark_part2_done(config)

      _ ->
        IO.puts("Task already solved.")
        {:ok, config}
    end
  end

  defp mark_part1_done(config_raw) do
    %__MODULE__{} = config = config_raw

    {:ok,
     %__MODULE__{
       status: :part2,
       events: [Event.Mark.new(@status_part1_done, true) | config.events]
     }}
  end

  defp mark_part2_done(config_raw) do
    %__MODULE__{} = config = config_raw

    {:ok,
     %__MODULE__{
       status: :done,
       events: [Event.Mark.new(@status_part2_done, true) | config.events]
     }}
  end
end
