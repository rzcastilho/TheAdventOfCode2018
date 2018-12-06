defmodule Day02Test do
  use ExUnit.Case
  doctest Day02

  test "Day: 02 - Part: 1" do
    assert Day02.part1() == 6642
  end

  test "Day: 02 - Part: 2" do
    assert Day02.part2() == "cvqlbidheyujgtrswxmckqnap"
  end

end
