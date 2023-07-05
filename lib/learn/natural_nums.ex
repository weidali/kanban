defmodule NaturalNums do
  def print(1), do: IO.puts(1)
  def print(0), do: IO.puts(0)

  def print(n) when is_number(n) and n > 0 do
    print(n - 1)
    IO.puts(n)
  end

  def print(n) when is_number(n) and n < 0 do
    IO.puts("Negative number: #{n}")
  end

  def print(n) when not is_number(n) do
    IO.puts("Not number: #{n}")
  end
end
