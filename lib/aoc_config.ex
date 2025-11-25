defmodule AoC.Config do
  @derive Jason.Encoder
  defstruct [:day, :year]

  @config_path "./.config.json"

  def load() do
    case File.read(@config_path) do
      {:ok, binary} -> load_from_binary(binary)
      {:error, :enoent} -> prepare_new()
    end
  end

  def save(config) do
    {:ok, binary} = Jason.encode(config)
    :ok = File.write(@config_path, binary)
    :ok
  end

  defp load_from_binary(binary) do
    IO.puts(inspect(binary))
    {:ok, decoded} = Jason.decode(binary, keys: :atoms)
    IO.puts(inspect(decoded))
    struct(AoC.Config, decoded)
  end

  defp prepare_new() do
    {:ok, new_instance} = init_new()
    :ok = save(new_instance)
    new_instance
  end

  defp init_new() do
    current_year = Date.utc_today().year
    {:ok, %AoC.Config{day: 1, year: current_year}}
  end
end
