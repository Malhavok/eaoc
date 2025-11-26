defmodule Event.Run do
  @derive Jason.Encoder
  defstruct log_type: "run", timestamp: nil, duration_ms: nil, result: nil

  @type t :: %__MODULE__{
          log_type: String.t(),
          timestamp: DateTime.t(),
          duration_ms: non_neg_integer(),
          result: [any()]
        }

  @spec new(non_neg_integer(), [any()]) :: t()
  def new(duration, result) do
    %__MODULE__{timestamp: DateTime.utc_now(), duration_ms: duration, result: result}
  end
end

defmodule Event.Mark do
  @derive Jason.Encoder
  defstruct log_type: "mark", part: nil, timestamp: nil, is_done: false

  @type t :: %__MODULE__{
          log_type: String.t(),
          part: String.t(),
          timestamp: DateTime.t(),
          is_done: boolean()
        }

  @spec new(String.t(), boolean()) :: t()
  def new(part, is_done) when is_boolean(is_done) do
    %__MODULE__{timestamp: DateTime.utc_now(), part: part, is_done: is_done}
  end
end

defmodule Event do
  @spec from_map(%{}) :: Event.Mark.t()
  def from_map(%{log_type: "mark"} = in_map) do
    struct(Event.Mark, in_map)
  end

  @spec from_map(%{}) :: Event.Run.t()
  def from_map(%{log_type: "run"} = in_map) do
    struct(Event.Run, in_map)
  end
end
