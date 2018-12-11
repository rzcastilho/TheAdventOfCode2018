defmodule Day05 do

  defmodule Event do
    defstruct [date: nil, time: nil, event: nil, guard: nil]
  end

  defp input do
    File.read!("input/day05.txt")
  end

  defp build_regex(polymers) do
    polymers
    |> String.downcase
    |> String.codepoints
    |> Enum.sort
    |> Enum.uniq
    |> Enum.map(&(&1 <> String.upcase(&1) <> "|" <> String.upcase(&1) <> &1))
    |> Enum.join("|")
    |> Regex.compile
  end

  defp replace_polymers(pattern, data) do
    case Regex.scan(pattern, data) |> List.flatten |> Enum.reduce(data, fn x, acc -> String.replace(acc, x, "") end) do
      ^data ->
        data
      new_data ->
        replace_polymers(pattern, new_data)
    end
  end

  def part1 do
    {:ok, pattern} = build_regex(input())
    replace_polymers(pattern, input())
    |> String.length
  end

  def part2 do
    {:ok, pattern} = build_regex(input())
    polymer = input()
    polymer
    |> String.downcase
    |> String.codepoints
    |> Enum.sort
    |> Enum.uniq
    |> Enum.reduce(polymer,
        fn x, acc ->
          new_acc = replace_polymers(pattern, Regex.replace(Regex.compile!(x, [:caseless]), polymer, ""))
          case String.length(new_acc) < String.length(acc) do
            true -> new_acc
            _ -> acc
          end
        end)
    |> String.length
  end

end
