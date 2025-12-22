defmodule Run do
  @mapping %{
    :run => :input_file,
    :test => :test_file
  }

  @spec part1(non_neg_integer(), non_neg_integer(), atom()) :: {:ok, any()}
  def part1(day, year, input_source) when input_source in [:run, :test] do
    run(day, year, :part1, @mapping[input_source])
  end

  @spec part1(non_neg_integer(), non_neg_integer(), atom()) :: {:ok, any()}
  def part2(day, year, input_source) when input_source in [:run, :test] do
    run(day, year, :part2, @mapping[input_source])
  end

  @spec run(non_neg_integer(), non_neg_integer(), atom(), atom()) :: {:ok, any()}
  defp run(day, year, main_fun, input_path_fun) do
    [Main] =
      Paths.main_file(day, year)
      |> Code.compile_file()
      |> Enum.map(fn {module, _binary} -> module end)
      |> Enum.filter(fn module -> module == Main end)

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
