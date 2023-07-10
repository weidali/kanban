defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def read_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 1))
  end

  def get_data!(path) do
    # {{year, month, date}, title}
    path
    |> IO.inspect()
    |> read_lines!()
    |> IO.inspect()
  end
end
