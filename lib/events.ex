defmodule Event.Run do
  @derive Jason.Encoder
  defstruct log_type: "run", timestamp: nil, duration_ms: nil, result: nil

  def new(duration, result) do
    %__MODULE__{timestamp: DateTime.utc_now(), duration_ms: duration, result: result}
  end
end

defmodule Event.Mark do
  @derive Jason.Encoder
  defstruct log_type: "mark", part: nil, timestamp: nil, is_done: false

  def new(part, is_done) when is_boolean(is_done) do
    %__MODULE__{timestamp: DateTime.utc_now(), part: part, is_done: is_done}
  end
end

defmodule Event do
  def from_map(%{log_type: "mark"} = in_map) do
    struct(Event.Mark, in_map)
  end

  def from_map(%{log_type: "run"} = in_map) do
    struct(Event.Run, in_map)
  end
end
