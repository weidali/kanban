defmodule Kanban.TaskFSM do
  @moduledoc """
  Process to be run
  """

  alias Kanban.Data.Task

  use GenServer

  require Logger

  def start_link(task: %Task{state: "idle", title: title} = task)
      when not is_nil(title) do
    GenServer.start_link(__MODULE__, task, name: __MODULE__)
    # GenServer.start_link(__MODULE__, task, name: {:via, Registry, {Kanban.TaskRegistry, title}})
  end

  def start(pid \\__MODULE__) do
    GenServer.cast(pid, {:transition, :start})
  end

  def finish(pid \\__MODULE__) do
    GenServer.cast(pid, {:transition, :finish})
  end

  def state(pid \\__MODULE__) do
    GenServer.call(pid, :state)
  end

  @impl GenServer
  def init(state), do: {:ok, state}

  # :idle, :doing, :done
  @impl GenServer
  def handle_cast({:transition, :start}, %Task{state: "idle"} = task) do
    # case Task.update(task) do
    #   :ok -> %Task{task | state: :doing}
    #   :error -> task
    # end
    # new_task = {:noreply, new_task}
    {:noreply, %Task{task | state: "doing"}}
  end

  @impl GenServer
  def handle_cast({:transition, :finish}, %Task{state: "doing"} = task) do
    # Save to external storage or doing something
    {:stop, :normal, %Task{task | state: "done"}}
  end

  @impl GenServer
  def handle_cast({:transition, transition}, %Task{state: state} = task) do
    # IO.inspect({transition, _from, state, task}, label: "CALL")
    Logger.warn(inspect({:error, {:not_allowed, transition, state}}))
    {:noreply, task}
  end

  @impl GenServer
  def handle_call(:state, _from, %Task{state: state} = task) do
    {:reply, state, task}
  end
end
