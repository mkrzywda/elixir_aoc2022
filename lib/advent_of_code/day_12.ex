defmodule GridPoint do
  defstruct [:level, :reached_from, visited: false]
end

defmodule Reachable do
  def reachable?("S", to) when to in ["a", "b"], do: true
  def reachable?("S", _), do: false
  def reachable?(from, "E") when from in ["y", "z"], do: true
  def reachable?(_, "E"), do: false
  def reachable?(from, to) do
    get_ascii_value(to) - get_ascii_value(from) <= 1
  end

  def get_ascii_value(char) do
    [v] = char |> to_charlist()
    v
  end
end

defmodule Parse do
  def parse_point("E"), do: %GridPoint{level: "E", reached_from: {:start, 0}}
  def parse_point(level), do: %GridPoint{level: level}

  def parse_row({row, y_index}) do
    row
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn {level, x_index} -> {{x_index, y_index}, parse_point(level)} end)
  end

  def parse(grid) do
    grid
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(&parse_row/1)
    |> Map.new()
  end
end

defmodule Traverse do
  def traverse(grid) do
    %GridPoint{reached_from: {_coord, steps}} =
      grid
      |> visit_squares()
      |> Map.values()
      |> Enum.find(fn %GridPoint{level: level} -> level == "S" end)

    steps
  end

  def get_adjacent_squares({x, y}), do: [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]

  def get_next_square(grid) do
    grid
    |> Map.to_list()
    |> Enum.filter(fn {_coord, grid_point} ->
      grid_point.reached_from != nil and !grid_point.visited
    end)
    |> Enum.min_by(
      fn {_coord, %GridPoint{reached_from: {_p, steps}}} -> steps end,
      fn -> nil end
    )
  end

  def visit_squares(grid) do
    case get_next_square(grid) do
      nil -> grid
      square -> visit_next_square(grid, square) |> visit_squares()
    end
  end

  def visit_next_square(grid, {coord, %GridPoint{level: level, reached_from: {_p, steps}}}) do
    coord
    |> get_adjacent_squares()
    |> Enum.map(fn c -> try_update_square(c, grid, steps + 1, coord, level) end)
    |> Enum.filter(fn v -> v != nil end)
    |> Enum.reduce(grid, fn {c, updated}, grid -> %{grid | c => updated} end)
    |> Map.update!(coord, fn gp -> %GridPoint{gp | visited: true} end)
  end

  def try_update_square(coord, grid, steps, from_coord, from_level) do
    case grid |> Map.fetch(coord) do
      {:ok, grid_point} ->
        if grid_point.reached_from == nil and Reachable.reachable?(grid_point.level, from_level) do
          {coord, %GridPoint{grid_point | reached_from: {from_coord, steps}}}
        end
      :error ->
        nil
    end
  end
end


defmodule AdventOfCode.Day12 do

  def part1(args) do
    args
    |> Parse.parse()
    |> Traverse.traverse()
  end

  def part2(args) do
    args
    |> Parse.parse()
    |> Traverse.visit_squares()
    |> solve()

  end

  defp solve(traversed_grid) do
    traversed_grid
    |> Map.values()
    |> Enum.filter(fn %GridPoint{level: level, visited: visited} ->
      level in ["a", "S"] and visited
    end)
    |> Enum.map(fn %GridPoint{reached_from: {_c, steps}} -> steps end)
    |> Enum.min()
  end
end
