defmodule SolverFullOfHotAir do
  def to_int(snafu) do
    snafu
    |> String.to_charlist()
    |> Enum.reverse
    |> int([])
    |> Enum.reverse()
    |> Enum.with_index()
    |> decimal(0)
  end

  defp decimal([], acc), do: acc
  defp decimal([{hv, hi} | t], acc) do
    acc = (5 ** hi) * hv + acc
    decimal(t, acc)
  end

  def to_snafu(integer) do
    integer
    |> do_to_snafu()
    |> Enum.reverse()
    |> List.to_string()
  end

  defp do_to_snafu(integer) when integer == 0, do: ''
  defp do_to_snafu(integer) do
    char =
      case rem(integer + 2, 5) do
        0 -> ?=
        1 -> ?-
        2 -> ?0
        3 -> ?1
        4 -> ?2
      end
    [char | do_to_snafu(div(integer + 2, 5))]
  end

  def int([], acc), do: acc
  def int([h | t], acc) do
    acc =
      case h do
        ?= -> [-2 | acc]
        ?- -> [-1 | acc]
        ?0 -> [0 | acc]
        ?1 -> [1 | acc]
        ?2 -> [2 | acc]
      end
    int(t, acc)
  end

end


defmodule AdventOfCode.Day25 do
  def part1(args) do
    args
    |> String.split("\n")
    |> Enum.map(&SolverFullOfHotAir.to_int/1)
    |> Enum.sum()
    |> SolverFullOfHotAir.to_snafu()
  end

  def part2(args) do
    IO.puts("Merry Xmas!")
  end
end
