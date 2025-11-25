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

  def save(config, day, year) do
    binary = config |> Jason.encode!()
    Paths.config_file(day, year) |> File.write(binary)
  end

  def load(day, year) do
    {:ok, binary} = Paths.config_file(day, year) |> File.read()
    {:ok, decoded} = Jason.decode(binary, keys: :atoms)
    converted = %{decoded | status: @status_mapping[decoded.status]}
    {:ok, struct(__MODULE__, converted)}
  end

  def mark_part1_done(config_raw) do
    %__MODULE__{} = config = config_raw

    {:ok,
     %__MODULE__{
       status: :part2,
       events: [Event.Mark.new(@status_part1_done, true) | config.events]
     }}
  end

  def mark_part2_done(config_raw) do
    %__MODULE__{} = config = config_raw

    {:ok,
     %__MODULE__{
       status: :done,
       events: [Event.Mark.new(@status_part2_done, true) | config.events]
     }}
  end
end
