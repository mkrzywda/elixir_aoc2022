defmodule AdventOfCode.Day03 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn str -> String.split_at(str, div(String.length(str), 2)) end)
    |> Enum.map(fn {str1, str2} -> {str1
                                      |> String.to_charlist()
                                      |> MapSet.new(),
                                    str2
                                      |> String.to_charlist()
                                      |> MapSet.new()
                                    }
    end)
    |> Enum.map(fn {map1, map2} -> MapSet.intersection(map1, map2) |> MapSet.to_list()
    end)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  defp score([char]) when char > ?Z, do: rem(char, ?a) + 1
  defp score([char]), do: rem(char, ?A) + 27


  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [str1, str2, str3] -> {str1
                                            |> String.to_charlist()
                                            |> MapSet.new(),
                                          str2
                                            |> String.to_charlist()
                                            |> MapSet.new(),
                                          str3
                                            |> String.to_charlist()
                                            |> MapSet.new()
                                          }
    end)
    |> Enum.map(fn {map1, map2, map3} ->
      MapSet.intersection(map1, map2) |> MapSet.intersection(map3) |> MapSet.to_list()
    end)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end
end
