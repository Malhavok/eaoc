defmodule EaocTest do
  use ExUnit.Case
  doctest Eaoc

  test "greets the world" do
    assert Eaoc.hello() == :world
  end
end
