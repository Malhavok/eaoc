defmodule Run do
  def part1(day, year) do
    run(day, year, :part1, :input1_file)
  end

  def part2(day, year) do
    run(day, year, :part2, :input2_file)
  end

  defp run(day, year, main_fun, input_path_fun) do
    [{Main, _binary}] = Paths.main_file(day, year) |> Code.compile_file()
    {:ok, input_data} = apply(Paths, input_path_fun, [day, year]) |> File.read()

    try do
      apply(Main, main_fun, [input_data])
    after
      # Removing module from the memory so there's no warning next time we're loading it.
      :code.purge(Main)
      :code.delete(Main)
    end
  end
end
