defmodule Day01 do

  defp input do
    File.read!("input/day01.txt")
    |> String.split
    |> Enum.map(&String.to_integer/1)
  end

  defp process({%{} = freq_map, last_freq}) do
    case Enum.reduce_while(input(), {freq_map,last_freq},
      fn x, {map,acc} ->
        case Map.get(map, Integer.to_string(x + acc), 0) + 1 do
          2 ->
            {:halt, x + acc}
          val ->
            {:cont, {Map.put(map, Integer.to_string(x + acc), val), x + acc}}
        end
      end)
    do
      {%{}, _} = last_process ->
        process(last_process)
      value ->
        value
    end
  end

  def part1 do
    input()
    |> Enum.reduce(&(&1 + &2))
  end

  def part2 do
    process({%{}, 0})
  end

end
