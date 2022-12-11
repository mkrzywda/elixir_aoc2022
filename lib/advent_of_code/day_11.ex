defmodule XmasMonkey do
  defstruct([:number, :items, :operation, :next, inspections: 0])

  def parse_monkeys(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn lines -> Enum.map(lines, &String.trim/1) end)
    |> Enum.map(&parse_monkey_data/1)
  end

  defp parse_monkey_data([
         "Monkey " <> number,
         "Starting items: " <> items,
         "Operation: new = old " <> <<op, _, worry_factor::binary>>,
         "Test: divisible by " <> test_factor,
         "If true: throw to monkey " <> monkey_when_true,
         "If false: throw to monkey " <> monkey_when_false
       ]) do
    %XmasMonkey{
      number:
        number
        |> String.replace(":", "")
        |> String.to_integer(),
      items:
        items
        |> String.split(", ")
        |> Enum.map(&String.to_integer/1),
      operation: {op, worry_factor},
      next: {
        String.to_integer(test_factor),
        String.to_integer(monkey_when_true),
        String.to_integer(monkey_when_false)
      }
    }
  end

  def play(monkeys, rounds, part) do
    common_divisor =
      if part == 1 do
        nil
      else
        monkeys
        |> Enum.map(&elem(&1.next, 0))
        |> Enum.product()
      end

    1..rounds
    |> Enum.reduce(monkeys, fn _r, m -> play_round(m, common_divisor) end)
  end

  defp play_round(monkeys, div) do
    turns =
      0..(length(monkeys) - 1)
      |> Enum.map(& &1)

    play_round(turns, monkeys, div)
  end

  defp play_round([number | tl], monkeys, div) do
    monkeys =
      monkeys
      |> Enum.at(number)
      |> turn(monkeys, div)

    play_round(tl, monkeys, div)
  end

  defp play_round([], monkeys, _div), do: monkeys

  defp turn(%XmasMonkey{items: [item | tl]} = monkey, monkeys, div) do
    monkeys =
      item
      |> apply_operation(monkey.operation)
      |> manage_worry(div)
      |> throws(monkey.next, monkeys)
      |> List.update_at(monkey.number, fn monkey ->
        inspections = monkey.inspections + 1
        %{monkey | items: tl, inspections: inspections}
      end)

    turn(Enum.at(monkeys, monkey.number), monkeys, div)
  end

  defp turn(%XmasMonkey{items: []}, monkeys, _div), do: monkeys

  defp apply_operation(item, {?*, "old"}), do: item * item
  defp apply_operation(item, {?+, "old"}), do: item + item
  defp apply_operation(item, {?*, wf}), do: item * String.to_integer(wf)
  defp apply_operation(item, {?+, wf}), do: item + String.to_integer(wf)

  defp manage_worry(item, nil), do: floor(item / 3)
  defp manage_worry(item, divisor), do: rem(item, divisor)

  defp throws(item, {factor, m1, m2}, monkeys) do
    next = if rem(item, factor) == 0, do: m1, else: m2

    List.update_at(monkeys, next, fn monkey ->
      new_items = [item | monkey.items]
      %{monkey | items: new_items}
    end)
  end
end

defmodule AdventOfCode.Day11 do
  import XmasMonkey
  def part1(args) do
    args
    |> parse_monkeys()
    |> play(20, 1)
    |> Enum.map(& &1.inspections)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> then(fn [i1, i2] -> i1 * i2 end)
  end

  def part2(args) do
    args
    |> parse_monkeys()
    |> play(10000, 2)
    |> Enum.map(& &1.inspections)
    |> IO.inspect(charlists: :as_lists)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> then(fn [i1, i2] -> i1 * i2 end)
  end
end
