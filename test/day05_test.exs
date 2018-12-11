defmodule Day05Test do
  use ExUnit.Case
  doctest Day05

  test "Day: 05 - Part: 1" do
    assert Day05.part1() == 11310
  end

  test "Day: 05 - Part: 2" do
    assert Day05.part2() == 6020
  end

end
