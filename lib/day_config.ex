defmodule Day.Config do
  @derive Jason.Encoder
  defstruct status: :new, events: []

  def save(config, day, year) do
    binary = config |> Jason.encode!()
    :ok = Paths.config_file(day, year) |> File.write(binary)
  end
end
