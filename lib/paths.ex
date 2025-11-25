defmodule Paths do
  def year(year) do
    ~s"#{year}"
  end

  def day(day, year) do
    year(year) <> ~s"/#{day}"
  end

  def input1_file(day, year) do
    file("input1.txt", day, year)
  end

  def input2_file(day, year) do
    file("input2.txt", day, year)
  end

  def main_file(day, year) do
    file("main.ex", day, year)
  end

  defp file(name, day, year) do
    day(day, year) <> ~s"/#{name}"
  end
end
