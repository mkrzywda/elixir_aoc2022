defmodule MonkeyMathParser do
  def parse(args) do
    for l <- String.trim(args) |> String.split("\n") do
      o1 = ~r"(\w+): (\w+) ([\+\-\*\/]) (\w+)"
      o2 = ~r"(\w+): (\d+)"
      r = Regex.run(o1, l)

      if r do
        [_, id, l, op, r] = r
        {id, {op, l, r}}
      else
        [_, id, n] = Regex.run(o2, l)
        n = Integer.parse(n) |> elem(0)
        {id, n}
      end
    end
    |> Map.new()
  end
end

defmodule Solver do

  def find(_m, "humn", res), do: res
  def find(m, k, res) when is_binary(k), do: find(m, m[k], res)

  def find(m, {op, l, r}, res) do
    if contains(m, l) do
      case op do
        "+" -> find(m, l, res - solve(m, r))
        "*" -> find(m, l, div(res, solve(m, r)))
        "-" -> find(m, l, res + solve(m, r))
        "/" -> find(m, l, res * solve(m, r))
      end
    else
      case op do
        "+" -> find(m, r, res - solve(m, l))
        "*" -> find(m, r, div(res, solve(m, l)))
        "-" -> find(m, r, solve(m, l) - res)
        "/" -> find(m, r, div(solve(m, l), res))
      end
    end
  end

  def solve(m, {op, l, r}) do
    f =
      case op do
        "*" -> &(&1 * &2)
        "/" -> &div(&1, &2)
        "+" -> &(&1 + &2)
        "-" -> &(&1 - &2)
      end

    f.(solve(m, m[l]), solve(m, m[r]))
  end

  def solve(m, s) when is_binary(s), do: solve(m, m[s])
  def solve(_m, n) when is_integer(n), do: n

  def contains(_m, "humn"), do: true
  def contains(_m, c) when is_integer(c), do: false
  def contains(m, s) when is_binary(s), do: contains(m, m[s])
  def contains(m, {_op, l, r}), do: contains(m, l) || contains(m, r)

end

defmodule RootsEqualityTest do

  def test(m,l,r) do

    if Solver.contains(m, l) do
      Solver.find(m, l, Solver.solve(m, m[r]))
    else
      Solver.find(m, r, Solver.solve(m, m[l]))
    end
  end

end

defmodule AdventOfCode.Day21 do

  def part1(args) do
    monkey = args
    |> MonkeyMathParser.parse()

    Solver.solve(monkey, monkey["root"])
  end


  def part2(args) do
    monkey = args
    |> MonkeyMathParser.parse()

    {_, l, r} = monkey["root"]
    RootsEqualityTest.test(monkey,l,r)

    end
  end
