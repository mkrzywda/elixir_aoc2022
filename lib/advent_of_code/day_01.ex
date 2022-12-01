defmodule AdventOfCode.Day01 do
  def part1(args) do
  	args
	    |> String.split("\n\n", trim: true)
      |> Enum.map(&parse_elves/1)
	    |> Enum.map(&Enum.sum/1)
      |> Enum.max()
  end

  defp parse_elves(elves_stuff) do
    elves_stuff
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
  end


  def part2(args) do
    args
      |> String.split("\n\n", trim: true)
      |> Enum.map(&parse_elves/1)
	    |> Enum.map(&Enum.sum/1)
      |> Enum.sort(:desc)
      |> Enum.take(3)
      |> Enum.sum()
end
end
