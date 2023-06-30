defmodule Kanban.TaskFSM do
  @moduledoc """
  Process to be run
  """

  alias Kanban.Data.Task

  use GenServer

  def start_link(%Task{state: :idle} = task) do
    GenServer.start_link(__MODULE__, task, name: __MODULE__)
  end

  @impl GenServer

  def init(state), do: {:ok, state}

  def handle_call(:state, _from, %Task{state: state} = task) do
    {:reply, state, task}
  end

  # :idle, :doing, :done
  def handle_call({:transition, :start}, _from, %Task{state: :idle} = task) do
    # task = Task.update(task) or something else
    {:reply, :ok, %Task{task | state: :doing}}
  end

  def handle_call({:transition, :finish}, _from, %Task{state: :doing} = task) do
    # Save to external storage or doing something
    {:stop, :normal, :ok, %Task{task | state: :done}}
  end

  def handle_call({:transition, transition}, _from, %Task{state: state} = task) do
    # IO.inspect({transition, _from, state, task}, label: "CALL")
    {:reply, {:error, {:not_allowed, transition, state}}, task}
  end

  @impl GenServer
  def handle_call({:+, value}, _from, state) do
    state = state + value
    {:reply, state, state}
  end
end
