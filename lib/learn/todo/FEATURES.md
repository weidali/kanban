# TODO FEATURES

Description for `todo_importer.ex` :
```iex
path = "/paath/totodo_list = TodoList.CsvImporter.import("todos.csv")/todos.csv"
todo_list = TodoList.CsvImporter.import(path)
TodoList.update_entry( todo_list, 1, &Map.put(&1, :date, Date.utc_today))
```


Protocols:
```iex
String.Chars.to_string(TodoList.new())
IO.puts(TodoList.new())
```