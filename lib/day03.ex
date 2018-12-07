defmodule Day03 do

  defmodule Matrix do
    defstruct [id: nil, x: nil, y: nil]
  end

  defmodule Range do
    defstruct [from: %Matrix{}.__struct__, to: %Matrix{}.__struct__]
  end

  defmodule Point do
    defstruct [x: nil, y: nil]
  end

  def parse_claim(value) do
    Regex.named_captures(~r/#(?<id>[0-9]+) @ (?<left>[0-9]+),(?<top>[0-9]+): (?<wide>[0-9]+)x(?<tall>[0-9]+)/, value)
  end

  defp build_matrix(%{"id" => id, "left" => left, "top" => top, "wide" => wide, "tall" => tall}) do
    %Matrix{
      id: String.to_integer(id),
      x: %Range{
        from: String.to_integer(left),
        to: ((String.to_integer(left)-1)+String.to_integer(wide))},
      y: %Range{
        from: String.to_integer(top),
        to: ((String.to_integer(top)-1)+String.to_integer(tall))
      }
    }
  end

  defp generate_points(%Matrix{id: _, x: %Range{from: x_from, to: x_to}, y: %Range{from: y_from, to: y_to}}) do
    for x <- x_from..x_to, do: for y <- y_from..y_to, do: %Point{x: x, y: y}
  end

  defp input do
    File.read!("input/day03.txt")
    |> String.split("\n")
    |> Enum.map(&parse_claim/1)
    |> Enum.map(&build_matrix/1)
  end

  def part1 do
    input()
    |> Enum.map(&generate_points/1)
    |> List.flatten
    |> Enum.group_by(&(&1))
    |> Enum.filter(fn {_, claims} -> Enum.count(claims) > 1 end)
    |> Enum.count
  end

  def part2 do
    overlap_points = input()
    |> Enum.map(&generate_points/1)
    |> List.flatten
    |> Enum.group_by(&(&1))
    |> Enum.filter(fn {_, claims} -> Enum.count(claims) > 1 end)
    |> Enum.map(fn {claim, _} -> claim end)
    |> MapSet.new
    input()
    |> Enum.map(fn matrix -> %{id: matrix.id, overlap: not MapSet.disjoint?(MapSet.new(List.flatten(generate_points(matrix))), overlap_points)} end)
    |> Enum.filter(fn %{overlap: overlap} -> !overlap end)
    |> List.first
    |> Map.get(:id)
  end

end
