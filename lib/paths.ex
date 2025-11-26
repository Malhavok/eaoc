defmodule Paths do
  @spec year(non_neg_integer()) :: String.t()
  def year(year) do
    ~s"#{year}"
  end

  @spec day(non_neg_integer(), non_neg_integer()) :: String.t()
  def day(day, year) do
    year(year) <> ~s"/#{day}"
  end

  @spec input_file(non_neg_integer(), non_neg_integer()) :: String.t()
  def input_file(day, year) do
    file("input.txt", day, year)
  end

  @spec test_file(non_neg_integer(), non_neg_integer()) :: String.t()
  def test_file(day, year) do
    file("test.txt", day, year)
  end

  @spec main_file(non_neg_integer(), non_neg_integer()) :: String.t()
  def main_file(day, year) do
    file("main.ex", day, year)
  end

  @spec config_file(non_neg_integer(), non_neg_integer()) :: String.t()
  def config_file(day, year) do
    file(".config.json", day, year)
  end

  @spec file(String.t(), non_neg_integer(), non_neg_integer()) :: String.t()
  defp file(name, day, year) do
    day(day, year) <> ~s"/#{name}"
  end
end
