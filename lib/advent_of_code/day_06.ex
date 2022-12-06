defmodule AdventOfCode.Day06 do
  def part1(args) do
    args
    |> String.graphemes()
    |> Enum.chunk_every(4, 1)
    |> Enum.find_index(fn chars -> Enum.uniq(chars) == chars end)
    |> Kernel.+(4)
  end

  def part2(args) do
    args
    |> String.graphemes()
    |> Enum.chunk_every(14, 1)
    |> Enum.find_index(fn chars -> Enum.uniq(chars) == chars end)
    |> Kernel.+(14)
  end
end
