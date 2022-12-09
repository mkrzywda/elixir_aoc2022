defmodule AdventOfCode.Day09 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      [dir, steps] = String.split(line)
      List.duplicate(dir, String.to_integer(steps))
    end)
    |> move([{0, 0}, {0, 0}], MapSet.new())
    |> MapSet.size()
  end


  defp move([], _rope, tail_path) do
    tail_path
  end

  defp move([dir | rest], [head | knots], tail_path) do
    new_head = head_move(dir, head)
    new_rope = Enum.scan([new_head | knots], fn tail, head -> follow(head, tail) end)
    move(rest, new_rope, MapSet.put(tail_path, Enum.at(new_rope, -1)))
  end

  def head_move(direction, {x, y}) do
    case direction do
      "L" -> {x - 1, y}
      "R" -> {x + 1, y}
      "U" -> {x, y + 1}
      "D" -> {x, y - 1}
    end
  end

  defp follow({hx, hy}, {tx, ty} = tail) do
    if abs(hx - tx) <= 1 and abs(hy - ty) <= 1 do
      tail
    else
      {coord(hx, tx), coord(hy, ty)}
    end
  end

  defp coord(h, t) do
    cond do
      h == t -> t
      h > t -> t + 1
      h < t -> t - 1
    end
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      [dir, steps] = String.split(line)
      List.duplicate(dir, String.to_integer(steps))
    end)
    |> move(List.duplicate({0, 0}, 10), MapSet.new())
    |> MapSet.size()
  end
end
