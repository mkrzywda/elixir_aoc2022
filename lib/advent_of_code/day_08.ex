defmodule AdventOfCode.Day08 do
  def part1(args) do
    {w, h, grid} = parse(args)
    count_visible_points(w, h, grid)
  end

  def parse(args) do
    rows = args
    |> String.split("\n", trim: true)
    |> Enum.map(&to_charlist/1)

    w = hd(rows)
        |> Enum.count()
    h = rows
      |> Enum.count()

    grid =
      for {r, y} <- Enum.with_index(rows),
          row = Enum.with_index(r),
          {i, x} <- row do
        {{x, y}, i}
      end
      |> Map.new()

    {w, h, grid}
  end

  def count_visible_points(w, h, grid) do
    Enum.count(grid, fn {{x, y}, i} -> visible?(w, h, grid, x, y, i) end)
  end


  @spec visible?(integer, integer, any, integer, integer, any) :: boolean
  def visible?(w, h, grid, x, y, i) do
    a = Enum.all?((x + 1)..(w - 1)//1, fn e -> grid[{e, y}] < i end)
    b = Enum.all?((x - 1)..0//-1, fn e -> grid[{e, y}] < i end)
    c = Enum.all?((y + 1)..(h - 1)//1, fn e -> grid[{x, e}] < i end)
    d = Enum.all?((y - 1)..0//-1, fn e -> grid[{x, e}] < i end)

    a || b || c || d
  end


  def part2(args) do
    {w, h, grid} = args |> parse()
    grid
    |> Enum.filter(fn {{x, y}, _} -> x > 0 && y > 0 && x < w - 1 && y < h - 1 end)
    |> Enum.map(&score({w, h, grid}, &1))
    |> Enum.max()
  end


  defp score({w, h, grid}, {{x, y}, i}) do
    a = 1 + (Enum.take_while((x + 1)..(w - 2)//1, fn e -> grid[{e, y}] < i end) |> Enum.count())
    b = 1 + (Enum.take_while((x - 1)..1//-1, fn e -> grid[{e, y}] < i end) |> Enum.count())
    c = 1 + (Enum.take_while((y + 1)..(h - 2)//1, fn e -> grid[{x, e}] < i end) |> Enum.count())
    d = 1 + (Enum.take_while((y - 1)..1//-1, fn e -> grid[{x, e}] < i end) |> Enum.count())
    a * b * c * d
  end

end
