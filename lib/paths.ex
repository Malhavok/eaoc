defmodule Paths do
  def year(year) do
    ~s"#{year}"
  end

  def day(day, year) do
    year(year) <> ~s"/#{day}"
  end

  def input_file(day, year) do
    file("input.txt", day, year)
  end

  def test_file(day, year) do
    file("test.txt", day, year)
  end

  def main_file(day, year) do
    file("main.ex", day, year)
  end

  def config_file(day, year) do
    file(".config.json", day, year)
  end

  defp file(name, day, year) do
    day(day, year) <> ~s"/#{name}"
  end
end
