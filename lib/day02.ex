defmodule Day02 do

  defp input do
    File.read!("input/day02.txt")
    |> String.split
    |> Enum.map(&String.codepoints/1)
  end

  defp check_id([letter|letters], id, count) do
    case check_id(letter, id, count) do
      {count, 1} ->
        {count, 1}
      _ ->
        check_id(letters, id, count)
    end
  end

  defp check_id([], _, count), do: {count, 0}

  defp check_id(letter, id, count) do
    case Regex.match?(~r/([^#{letter}][#{letter}]{#{count}}[^#{letter}]|^[#{letter}]{#{count}}[^#{letter}]|[^#{letter}][#{letter}]{#{count}}$|^[#{letter}]{#{count}}$)/, id)  do
      true ->
        {count, 1}
      _ ->
        {count, 0}
    end
  end

  defp match([], [], acc), do: acc

  defp match([a|b], [x|y], %{nomatch: nomatch, id: id}) do
    acc = case a do
      ^x ->
        %{nomatch: nomatch, id: id <> a}
      _ ->
        %{nomatch: nomatch + 1, id: id}
    end
    match(b, y, acc)
  end

  defp match_filter(a, x) do
    case match(a, x, %{nomatch: 0, id: ""}) do
      %{nomatch: 1} ->
        true
      _ ->
        false
    end
  end

  def part1 do
    %{"2": total2, "3": total3} = input()
    |> Enum.map(&Enum.sort/1)
    |> Enum.map(&({Enum.uniq(&1),  List.to_string(&1)}))
    |> Enum.reduce(%{"2": 0, "3": 0},
        fn {letters, id}, %{"2": acc2, "3": acc3} ->
          {2, count2} = check_id(letters, id, 2)
          {3, count3} = check_id(letters, id, 3)
          %{"2": acc2 + count2, "3": acc3 + count3}
        end
      )
    total2 * total3
  end

  def part2 do
    for a <- input() do
      for x <- input(), match_filter(a, x), do: match(a, x , %{nomatch: 0, id: ""})
    end
    |> List.flatten
    |> Enum.uniq
    |> Enum.map(fn %{id: id} -> id end)
    |> List.first
  end

end
