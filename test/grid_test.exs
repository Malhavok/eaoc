defmodule GridTest do
  use ExUnit.Case

  describe "Grid.init/1" do
    test "parses a simple 2x2 grid" do
      content = "AB\nCD"
      assert {:ok, map} = Grid.init(content)

      assert map == %{
               {0, 0} => ?A,
               {1, 0} => ?B,
               {0, 1} => ?C,
               {1, 1} => ?D
             }
    end

    test "handles empty input" do
      content = ""
      assert {:ok, map} = Grid.init(content)
      assert map == %{}
    end
  end

  describe "Grid.get_neighbours/3" do
    setup do
      content = "A\nB"
      {:ok, map} = Grid.init(content)
      %{map: map}
    end

    test "returns neighbours for a point", %{map: map} do
      assert {:ok, neighbours} = Grid.get_neighbours(map, {0, 0})

      assert {{0, 1}, ?B} in neighbours
      assert length(neighbours) == 1
    end

    test "returns empty list when no neighbours are requested", %{map: map} do
      assert {:ok, []} = Grid.get_neighbours(map, {0, 1}, [])
    end

    test "returns empty list when point not in grid and no neighbours exist", %{map: map} do
      assert {:ok, []} = Grid.get_neighbours(map, {10, 10})
    end
  end

  describe "Grid.get_positions/2" do
    setup do
      content = "A\nB\nA"
      {:ok, map} = Grid.init(content)
      %{map: map}
    end

    test "returns all positions of a character", %{map: map} do
      assert {:ok, positions} = Grid.get_positions(map, ?A)
      assert Enum.sort(positions) == [{0, 0}, {0, 2}]
    end

    test "returns empty list if character not present", %{map: map} do
      assert {:ok, []} = Grid.get_positions(map, ?Z)
    end
  end
end
