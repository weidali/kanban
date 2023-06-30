defmodule KanbanTest do
  use ExUnit.Case
  doctest Kanban

  test "start task" do
    (1..1_00) |> Enum.map(&"Task_#{&1}") |> Enum.map(&TaskManager.start_task &1, 3, "Pr1")
    assert Kanban.start_task("Task_99") == :ok
    assert Kanban.query_task("Task_99") == "doing"
  end
end
