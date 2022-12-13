defmodule Packets do
  def parse(raw) do
    raw
    |> String.split("\n\n")
    |> Enum.map(&parse_pair/1)
  end

  defp parse_pair(pair) do
    [a, b] =
      pair
      |> String.trim()
      |> String.split("\n")
    {parse_packet(a), parse_packet(b)}
  end

  defp parse_packet(p) do
    {res, _} = Code.eval_string(p)
    res
  end

  def sorted?({left, right}) do
    case sort_packet(left, right) do
      :sorted -> true
      :unsorted -> false
      :unknown -> true
    end
  end

  def sorted?(left, right), do: sorted?({left, right})

  defp sort_packet([], [_right | _right_rest]), do: :sorted
  defp sort_packet([_left | _left_rest], []), do: :unsorted
  defp sort_packet([], []), do: :unknown
  defp sort_packet([left | left_rest], [right | right_rest])
       when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :sorted
      left > right -> :unsorted
      true -> sort_packet(left_rest, right_rest)
    end
  end

  defp sort_packet([left | left_rest], [right | right_rest])
       when is_list(left) and is_list(right) do
    case sort_packet(left, right) do
      :sorted -> :sorted
      :unsorted -> :unsorted
      :unknown -> sort_packet(left_rest, right_rest)
    end
  end

  defp sort_packet([left | left_rest], [right | _right_rest] = right_all)
       when is_integer(left) and is_list(right) do
    sort_packet([[left]] ++ left_rest, right_all)
  end

  defp sort_packet([left | _left_rest] = left_all, [right | right_rest])
       when is_list(left) and is_integer(right) do
    sort_packet(left_all, [[right]] ++ right_rest)
  end
end

defmodule AdventOfCode.Day13 do
  def part1(args) do
    args
    |> Packets.parse()
    |> Enum.with_index()
    |> Enum.filter(fn {packet, _idx} -> Packets.sorted?(packet) end)
    |> Enum.map(fn {_packet, idx} -> idx + 1 end)
    |> Enum.sum()
  end

  def part2(args) do
    sorted_packets =
      args
      |> Packets.parse()
      |> Enum.map(fn {a, b} -> [{a}, {b}] end)
      |> List.flatten()
      |> Kernel.++([{[[2]]}, {[[6]]}])
      |> Enum.map(fn {i} -> i end)
      |> Enum.sort(&Packets.sorted?/2)

    a = sorted_packets |> Enum.find_index(fn v -> v == [[2]] end)
    b = sorted_packets |> Enum.find_index(fn v -> v == [[6]] end)

    (a + 1) * (b + 1)
  end
end
