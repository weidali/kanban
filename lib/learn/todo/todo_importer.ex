defmodule TodoList.CsvImporter do
  def import(file_name) do
    file_name
    |> read_lines
    |> get_data
    |> create_entries
    |> IO.inspect()
  end

  def import_origin(file_name) do
    file_name
    |> read_lines_origin
    |> get_data
    |> create_entries
    |> IO.inspect()
  end

  defp read_lines_origin(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 1))
  end

  defp read_lines(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 1))
  end

  defp get_data(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> IO.inspect()
  end

  defp extract_fields(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  defp create_entries(lines) do
    lines
    |> Stream.map(&create_entry/1)
  end

  defp convert_date([date_string, title]) do
    {parse_date(date_string), title}
  end

  defp parse_date(date_string) do
    [year, month, day] =
      date_string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end

  defp create_entry({date, title}) do
    %{date: date, title: title}
  end
end
