defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "Day: 03 - Part: 1" do
    assert Day03.part1() == 101469
  end

  test "Day: 03 - Part: 2" do
    assert Day03.part2() == 1067
  end

end
