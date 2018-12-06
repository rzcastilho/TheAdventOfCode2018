defmodule Day01Test do
  use ExUnit.Case
  doctest Day01

  test "Day: 01 - Part: 1" do
    assert Day01.part1() == 497
  end

  test "Day: 01 - Part: 2" do
    assert Day01.part2() == 558
  end

end
