defmodule Learn.Todo.TodoList do
  # alias MultiDict
  alias Learn.Todo.MultiDict

  def new(), do: MultiDict.new()

  def add_entry(todo_list, date, title) do
    MultiDict.add(todo_list, date, title)
  end

  def add_entry(todo_list, entry) do
    MultiDict.add(todo_list, entry.date, entry)
  end

  def entries(todo_list, date) do
    MultiDict.get(todo_list, date)
  end

  def due_today(todo_list) do
    #
  end
end
