defmodule AdventOfCode.Day10 do

  def part1(args) do
    args
    |> get_cycles()
    |> Enum.with_index()
    |> Enum.drop(19)
    |> Enum.take_every(40)
    |> Enum.map(fn {x, cycle} -> x * (cycle + 1) end)
    |> Enum.sum()
  end

  defp get_cycles(input) do
    input
    |> String.split("\n", trim: true)
    |>Enum.reduce({[], 1}, fn
       "addx " <> num, {accumulated_nums, acc_x} -> add_x(num, accumulated_nums, acc_x)
       "noop", {accumulated_nums, acc_x} -> append_x(accumulated_nums, acc_x)
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp add_x(num, accumulated_nums, acc_x) do
    {[acc_x, acc_x | accumulated_nums], acc_x + String.to_integer(num)}
  end

  defp append_x(accumulated_nums, acc_x) do
    {[acc_x | accumulated_nums], acc_x}
  end

  def part2(args) do
    args
    |> get_cycles()
    |> Enum.chunk_every(40)
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.with_index()
      |> Enum.map(fn
        {acc_x, idx} when abs(acc_x - idx) < 2 -> '█'
        _ -> '.'
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
