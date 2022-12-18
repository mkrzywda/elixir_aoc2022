defmodule AdventOfCode.Day16 do
  def part1(args) do
    m = parse(args) |> Map.new()
    start = "AA"

    cand =
      Enum.filter(m, fn {id, {flow, _}} -> flow > 0 || id == start end)
      |> Map.new()

    dist =
      for {c, _} <- cand, {t, _} <- cand, t != c do
        {{c, t}, dist(m, [c], t)}
      end
      |> Map.new()

    find(cand |> Map.delete(start), dist, start, 30, 0, 0, MapSet.new())
    |> Enum.map(&elem(&1, 0))
    |> Enum.max()
  end

  defp find(m, _, _, time, flow, press, acc) when map_size(m) == 0,
    do: [{time * flow + press, MapSet.new(acc)}]

  defp find(next, dist, pos, time, flow, press, acc) do
    [
      {time * flow + press, MapSet.new(acc)}
      | for {n, {f, _}} <- next, d = dist[{pos, n}] + 1, d <= time do
          acc = MapSet.put(acc, n)
          find(Map.delete(next, n), dist, n, time - d, flow + f, press + flow * d, acc)
        end
        |> Enum.flat_map(& &1)
    ]
    |> Enum.uniq()
  end

  defp dist(map, start, goal, n \\ 0) do
    if Enum.find(start, &(&1 == goal)) do
      n
    else
      next =
        start
        |> Enum.map(fn t -> map[t] end)
        |> Enum.flat_map(fn {_, t} -> t end)
        |> Enum.uniq()

      dist(map, next, goal, n + 1)
    end
  end

  defp parse(args) do
    for l <- args |> String.trim() |> String.split("\n") do
      [_, valve, flow, targets] =
        Regex.run(~r"Valve (.*) has flow rate=(\d+); tunnels? leads? to valves? (.*)", l)

      {f, _} = Integer.parse(flow)
      t = String.split(targets, ", ", trim: true)
      {valve, {f, t}}
    end
  end

  def part2(args) do
    m = parse(args) |> Map.new()
    start = "AA"

    cand =
      Enum.filter(m, fn {id, {flow, _}} -> flow > 0 || id == start end)
      |> Map.new()

    dist =
      for {c, _} <- cand, {t, _} <- cand, t != c do
        {{c, t}, dist(m, [c], t)}
      end
      |> Map.new()

    results =
      cand
      |> Map.delete(start)
      |> find(dist, start, 26, 0, 0, MapSet.new())
      |> Enum.group_by(fn {_, k} -> k end, fn {v, _} -> v end)
      |> Enum.map(fn {k, l} -> {k, Enum.max(l)} end)

    for {path, press} <- results do
      res =
        results
        |> Enum.filter(fn {k, _} -> MapSet.disjoint?(path, k) end)
        |> Enum.map(&elem(&1, 1))

      if [] == res do
        press
      else
        press + Enum.max(res)
      end
    end
    |> Enum.max()
  end
end
