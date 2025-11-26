defmodule AoC.Config do
  @derive Jason.Encoder
  defstruct [:day, :year]

  @type t :: %__MODULE__{day: non_neg_integer(), year: non_neg_integer()}

  @config_path "./.config.json"

  @spec load() :: {:ok, t()}
  def load() do
    case File.read(@config_path) do
      {:ok, binary} -> load_from_binary(binary)
      {:error, :enoent} -> prepare_new()
    end
  end

  @spec save(t()) :: :ok
  def save(config) do
    {:ok, binary} = Jason.encode(config)
    :ok = File.write(@config_path, binary)
    :ok
  end

  @spec load_from_binary(String.t()) :: {:ok, t()}
  defp load_from_binary(binary) do
    {:ok, decoded} = Jason.decode(binary, keys: :atoms)
    {:ok, struct(__MODULE__, decoded)}
  end

  @spec prepare_new() :: {:ok, t()}
  defp prepare_new() do
    {:ok, new_instance} = init_new()
    :ok = save(new_instance)
    {:ok, new_instance}
  end

  @spec init_new() :: {:ok, t()}
  defp init_new() do
    current_year = Date.utc_today().year
    {:ok, %__MODULE__{day: 1, year: current_year}}
  end
end
