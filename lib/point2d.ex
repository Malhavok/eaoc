defmodule Point2D do
  @derive Jason.Encoder
  defstruct x: 0, y: 0

  @type t :: %__MODULE__{
          x: integer(),
          y: integer()
        }

  @spec new(integer(), integer()) :: t()
  def new(x, y) do
    %__MODULE__{x: x, y: y}
  end

  @spec add(t(), t()) :: t()
  def add(point1, point2) do
    %__MODULE__{x: point1.x + point2.x, y: point1.y + point2.y}
  end

  @spec carinal() :: [t(), ...]
  def carinal() do
    [new(1, 0), new(-1, 0), new(0, 1), new(0, -1)]
  end
end
