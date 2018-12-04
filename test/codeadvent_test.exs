defmodule CodeadventTest do
  use ExUnit.Case
  doctest Codeadvent

  test "greets the world" do
    assert Codeadvent.hello() == :world
  end
end
