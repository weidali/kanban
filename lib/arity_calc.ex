defmodule Calculator do
  def sum(a, b \\ 0) do
    a + b
  end

  def fun(a, b \\ 1, c, d \\ 2) do
    a + b + c + d
  end
end
