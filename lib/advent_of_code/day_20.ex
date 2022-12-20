defmodule Parser do
  def parse(text, decryption_key \\ 1) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&(&1 |> String.to_integer() |> Kernel.*(decryption_key)))
    |> Enum.with_index()
    |> then(fn list ->
      len = length(list)
      map =
        Enum.map(list, fn
          {n, i} when i + 1 == len -> {i, %{n: n, prev: i - 1, next: 0}}
          {n, 0} -> {0, %{n: n, prev: len - 1, next: 1}}
          {n, i} -> {i, %{n: n, prev: i - 1, next: i + 1}}
        end)
        |> Enum.into(%{})
      {map, list}
    end)
  end
end

defmodule GroveCoordinates do

  defp encrypt(map, list) do
    len = length(list)
    rem_list = Enum.map(list, fn {n, i} -> {rem(n, len - 1), i} end)

    encrypt(rem_list, map, hd(rem_list))
  end


  defp forward(map, b) do
    a = map[b].prev
    c = map[b].next
    d = map[c].next

    map
    |> Map.update!(a, fn m -> m |> Map.put(:next, c) end)
    |> Map.update!(b, fn m -> m |> Map.put(:prev, c) |> Map.put(:next, d) end)
    |> Map.update!(c, fn m -> m |> Map.put(:prev, a) |> Map.put(:next, b) end)
    |> Map.update!(d, fn m -> m |> Map.put(:prev, b) end)
  end

  defp backward(map, c) do
    d = map[c].next
    b = map[c].prev
    a = map[b].prev

    map
    |> Map.update!(d, fn m -> m |> Map.put(:prev, b) end)
    |> Map.update!(c, fn m -> m |> Map.put(:prev, a) |> Map.put(:next, b) end)
    |> Map.update!(b, fn m -> m |> Map.put(:prev, c) |> Map.put(:next, d) end)
    |> Map.update!(a, fn m -> m |> Map.put(:next, c) end)
  end

  defp grove_coordinates(map) do
    {id_0, _} = Enum.find(map, fn {_, %{n: n}} -> n == 0 end)

    Stream.iterate(id_0, fn id -> map[id].next end)
    |> Enum.reduce_while({0, 0}, fn
      id, {3000, acc} -> {:halt, map[id].n + acc}
      id, {i, acc} when i in [1000, 2000] -> {:cont, {i + 1, map[id].n + acc}}
      _, {i, acc} -> {:cont, {i + 1, acc}}
    end)
  end

  defp encrypt([_], map, {0, _}), do: map
  defp encrypt([_ | rest], map, {0, _}), do: encrypt(rest, map, hd(rest))
  defp encrypt(list, map, {n, i}) when n > 0, do: encrypt(list, forward(map, i), {n - 1, i})
  defp encrypt(list, map, {n, i}) when n < 0, do: encrypt(list, backward(map, i), {n + 1, i})

end

defmodule AdventOfCode.Day20 do

  def part1(args) do
    args
    |> Parser.parse()
    |> then(fn {map, list} -> GroveCoordinates.encrypt(map, list) end)
    |> GroveCoordinates.grove_coordinates()

  end

  def part2(args) do
    @key 811589153
    args
    |> Parser.parse(@key)
    |> then(fn {map, list} ->
      Stream.iterate(map, &GroveCoordinates.encrypt(&1, list))
      |> Enum.at(10)
    end)
    |> GroveCoordinates.grove_coordinates()
  end
end
