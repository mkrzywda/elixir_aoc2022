defmodule ParserMonkeyMap do
  def parse(text) do
    [grid, directions] = String.split(text, ~r/\R\R/)

    grid =
      grid
      |> String.split(~r/\R/)
      |> Enum.with_index(1)
      |> Enum.map(fn {row, y} ->
        row
        |> String.graphemes()
        |> Enum.with_index(1)
        |> Enum.reject(fn {c, _} -> c == " " end)
        |> Enum.map(fn
          {".", x} -> {{x, y}, true}
          {"#", x} -> {{x, y}, false}
        end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    directions =
      Regex.scan(~r/\d+|\w/, directions)
      |> List.flatten()
      |> Enum.map(fn str ->
        case Integer.parse(str) do
          :error -> str
          {n, ""} -> n
        end
      end)

    {grid, directions}
  end
end

defmodule Wrapper do

  def wrap({x, _}, :north, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {col, _} -> x == col end)
    |> Enum.max_by(fn {_, row} -> row end)
    |> then(fn next -> {next, :north} end)
  end

  def wrap({x, _}, :south, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {col, _} -> x == col end)
    |> Enum.min_by(fn {_, row} -> row end)
    |> then(fn next -> {next, :south} end)
  end

  def wrap({_, y}, :west, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {_, row} -> y == row end)
    |> Enum.max_by(fn {col, _} -> col end)
    |> then(fn next -> {next, :west} end)
  end

  def wrap({_, y}, :east, grid, :flat) do
    grid
    |> Map.keys()
    |> Enum.filter(fn {_, row} -> y == row end)
    |> Enum.min_by(fn {col, _} -> col end)
    |> then(fn next -> {next, :east} end)
  end

  def wrap({x, _y}, :north, _, :cube) when x in 1..50, do: {{51, 50 + x}, :east}
  def wrap({x, _y}, :north, _, :cube) when x in 51..100, do: {{1, 150 + x - 50}, :east}
  def wrap({x, _y}, :north, _, :cube) when x in 101..150, do: {{x - 100, 200}, :north}
  def wrap({x, _y}, :south, _, :cube) when x in 1..50, do: {{x + 100, 1}, :south}
  def wrap({x, _y}, :south, _, :cube) when x in 51..100, do: {{50, 150 + x - 50}, :west}
  def wrap({x, _y}, :south, _, :cube) when x in 101..150, do: {{100, 50 + x - 100}, :west}
  def wrap({_x, y}, :west, _, :cube) when y in 1..50, do: {{1, 151 - y}, :east}
  def wrap({_x, y}, :west, _, :cube) when y in 51..100, do: {{y - 50, 101}, :south}
  def wrap({_x, y}, :west, _, :cube) when y in 101..150, do: {{51, 51 - (y - 100)}, :east}
  def wrap({_x, y}, :west, _, :cube) when y in 151..200, do: {{50 + y - 150, 1}, :south}
  def wrap({_x, y}, :east, _, :cube) when y in 1..50, do: {{100, 151 - y}, :west}
  def wrap({_x, y}, :east, _, :cube) when y in 51..100, do: {{100 + y - 50, 50}, :north}
  def wrap({_x, y}, :east, _, :cube) when y in 101..150, do: {{150, 51 - (y - 100)}, :west}
  def wrap({_x, y}, :east, _, :cube) when y in 151..200, do: {{50 + y - 150, 150}, :north}

end

defmodule Solver do

  def run({grid, directions}, geometry) do
    {start, _} =
      grid
      |> Enum.filter(fn {{_, y}, c} -> y == 1 and c end)
      |> Enum.min_by(fn {{x, _}, _} -> x end)
    run(directions, grid, {start, :east}, geometry)
  end
  def run([], _, state, _), do: state
  def run(["L" | rest], grid, {pos, dir}, geo), do: run(rest, grid, {pos, new_dir(dir, "L")}, geo)
  def run(["R" | rest], grid, {pos, dir}, geo), do: run(rest, grid, {pos, new_dir(dir, "R")}, geo)
  def run([0 | rest], grid, state, geo), do: run(rest, grid, state, geo)
  def run([n | rest], grid, state, geo), do: run([n - 1 | rest], grid, move(state, grid, geo), geo)

  defp new_dir(:north, "L"), do: :west
  defp new_dir(:north, "R"), do: :east
  defp new_dir(:south, "L"), do: :east
  defp new_dir(:south, "R"), do: :west
  defp new_dir(:west, "L"), do: :south
  defp new_dir(:west, "R"), do: :north
  defp new_dir(:east, "L"), do: :north
  defp new_dir(:east, "R"), do: :south

  defp move({pos, dir}, grid, geo) do
    forward = forward(pos, dir)
    if Map.has_key?(grid, forward) do
      if grid[forward], do: {forward, dir}, else: {pos, dir}
    else
      {next, next_dir} = Wrapper.wrap(pos, dir, grid, geo)
      if grid[next], do: {next, next_dir}, else: {pos, dir}
    end
  end

  defp forward({x, y}, :north), do: {x, y - 1}
  defp forward({x, y}, :south), do: {x, y + 1}
  defp forward({x, y}, :west), do: {x - 1, y}
  defp forward({x, y}, :east), do: {x + 1, y}

end

defmodule MonkeyPassword do
  def password({{x, y}, :east}), do: (y * 1000) + (x * 4) + 0
  def password({{x, y}, :south}), do: (y * 1000) + (x * 4) + 1
  def password({{x, y}, :west}), do: (y * 1000) + (x * 4) + 2
  def password({{x, y}, :north}), do: (y * 1000) + (x * 4) + 3
end

defmodule AdventOfCode.Day22 do
  def part1(args) do
    args
    |> ParserMonkeyMap.parse()
    |> Solver.run(:flat)
    |> MonkeyPassword.password()
  end

  def part2(args) do
    args
    |> ParserMonkeyMap.parse()
    |> Solver.run(:cube)
    |> MonkeyPassword.password()
  end
end
