defmodule Solution do

  def parse(data) do
    data
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/-?\d+/, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> then(fn [sx, sy, bx, by] -> {{sx, sy}, {bx, by}} end)
    end)
  end

  def ranges_at(signals, row), do: ranges_at(signals, row, [])
  def ranges_at([], _, ranges), do: ranges
  def ranges_at([{{sx, sy}, beacon} | rest], row, ranges) do
    m = manhattan({sx, sy}, beacon)
    if row > sy + m or row < sy - m do
      ranges_at(rest, row, ranges)
    else
      range = (sx - (m - abs(sy - row)))..(sx + (m - abs(sy - row)))
      ranges_at(rest, row, [range | ranges])
    end
  end

  defp manhattan({ax, ay}, {bx, by}), do: abs(ax - bx) + abs(ay - by)

  def combine_ranges(ranges) do
    sorted = Enum.sort(ranges)
    combine_ranges(hd(sorted), tl(sorted), [])
  end
  defp combine_ranges(range, [], past), do: [range | past]
  defp combine_ranges(a..b, [c..d | rest], past) when c <= b, do: combine_ranges(a..max(b, d), rest, past)
  defp combine_ranges(a..b, [c..d | rest], past), do: combine_ranges(c..d, rest, [a..b | past])

end

defmodule AdventOfCode.Day15 do

  import Solution

  @y 2_000_000
  @max_coord 4_000_000

  def part1(args) do
    signals = args
    |> parse()

    n_beacons =
      signals
      |> Enum.map(&elem(&1, 1))
      |> Enum.filter(fn {_, y} -> y == @y end)
      |> MapSet.new()
      |> MapSet.size()

    signals
    |> ranges_at(@y)
    |> combine_ranges()
    |> Enum.map(&Range.size/1)
    |> Enum.sum()
    |> Kernel.-(n_beacons)
  end

  def part2(args) do
    signals = args
    |> parse()

    0..@max_coord
    |> Enum.find_value(fn y ->
      ranges_at(signals, y)
      |> combine_ranges()
      |> Enum.reject(fn a..b -> b < 0 or a > @max_coord end)
      |> then(fn
        [_a..b, _c..d] ->
          (min(b, d) + 1) * 4_000_000 + y
        _ -> false
      end)
    end)
  end
end
