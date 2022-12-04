defmodule AdventOfCode.Day04 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.filter(fn [a, b] -> MapSet.subset?(a, b) || MapSet.subset?(b, a) end)
    |> Enum.count()
  end

  defp parse_line(string) do
    string
    |> String.split(",")
    |> Enum.map(fn s ->
      [h, l] = s |> String.split("-") |> Enum.map(&String.to_integer/1)
      MapSet.new(h..l)
    end)
  end
    def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.filter(fn [a, b] -> MapSet.intersection(a, b) |> Enum.count() != 0 end)
    |> Enum.count()
  end
end
