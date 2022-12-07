defmodule AdventOfCode.Day07 do
  def part1(args) do
    args
    |> browse_filesystem()
    |> Enum.filter(fn {_dir, size} -> size <= 100_000 end)
    |> Enum.map(fn {_dir, size} -> size end)
    |> Enum.sum()
  end

  defp browse_filesystem(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.reduce({%{}, []}, fn command, {map, dirs} -> parse(command, map, dirs) end)
    |> elem(0)
  end

  defp update_directory_size([], _size, map) do
    map
  end

  defp update_directory_size(dirs, size, map) do
    update_directory_size(tl(dirs), size, Map.update(map, Enum.join(dirs, "/"), size, &(&1 + size)))
  end

  defp parse("$ cd /", map, _dirs) do
    {map, [".."]}
  end

  defp parse("$ cd ..", map, dirs) do
    {map, tl(dirs)}
  end

  defp parse("$ cd " <> dir_name, map, dirs) do
    {map, [dir_name | dirs]}
  end

  defp parse("$ ls", map, dirs) do
    {map, dirs}
  end

  defp parse("dir " <> dir_name, map, dirs) do
    {map, dirs}
  end

  defp parse(file, map, dirs) do
    [size, _file_name] = String.split(file, " ")
    size = String.to_integer(size)
    {update_directory_size(dirs, size, map), dirs}
  end

  def part2(args) do

    files = args
    |>browse_filesystem()

    used_space = files[".."]

    total_space = 70_000_000
    total_space_needed = 30_000_000
    to_delete = total_space_needed - (total_space - used_space)

    files
    |> Enum.filter(fn {_dir, size} -> size >= to_delete end)
    |> Enum.min_by(fn {_dir, size} -> size end)
  end
end
