defmodule Point2DTest do
  use ExUnit.Case

  describe "Point2D.new/2" do
    test "creates a point with the given coordinates" do
      point = Point2D.new(3, -4)
      assert %Point2D{x: 3, y: -4} = point
    end
  end

  describe "Point2D.add/2" do
    test "adds two points correctly" do
      p1 = Point2D.new(1, 2)
      p2 = Point2D.new(3, 4)
      result = Point2D.add(p1, p2)
      assert %Point2D{x: 4, y: 6} = result
    end

    test "works with negative coordinates" do
      p1 = Point2D.new(-1, -2)
      p2 = Point2D.new(5, -3)
      result = Point2D.add(p1, p2)
      assert %Point2D{x: 4, y: -5} = result
    end
  end

  describe "Point2D.carinal/0" do
    test "returns the four cardinal direction points" do
      expected = [
        Point2D.new(1, 0),
        Point2D.new(-1, 0),
        Point2D.new(0, 1),
        Point2D.new(0, -1)
      ]

      result = Point2D.carinal()

      assert length(result) == 4
      assert Enum.sort(result) == Enum.sort(expected)
    end
  end
end
