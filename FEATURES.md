# FEATURES


Task state machine description `task_fsm.ex` :
```zsh
iex|💧|1 ▶ {:ok, pid} = Kanban.TaskFSM.start_link %Task{state: :idle} 
#=> {:ok, #PID<0.198.0>}

Process.alive? pid                                      
#=> true
GenServer.call(pid, :state)
#=> :idle
GenServer.call(pid, {:transition, :finish})
#=> {:error, {:not_allowed, :finish, :idle}}

GenServer.call(pid, {:transition, :start}) 
#=> :ok
Process.alive? pid                                      
#=> true
GenServer.call(pid, :state)
#=> :doing

GenServer.call(pid, {:transition, :finish}) 
#=> :ok
Process.alive? pid                         
#=> false
GenServer.call(pid, :state)                
#=> ** (exit) exited in: GenServer.call(#PID<0.210.0>, :state, 5000)
    ** (EXIT) no process: the process is not alive or there's no process currently associated with the given name, possibly because its application isn't started
    (elixir 1.15.0) lib/gen_server.ex:1074: GenServer.call/3
    iex:10: (file)

```

```zsh
alias Kanban.TaskFSM, as: F
F.start_link %Task{state: :idle} 
#=> {:ok, #PID<0.198.0>}

Process.alive? self()
#=> true
F.state
#=> :idle
F.finish
#=> {:error, {:not_allowed, :finish, :idle}}

F.start
#=> :ok
Process.alive? self()
#=> true
F.state
#=> :doing

F.finish
#=> :ok
```

```zsh
iex|💧|1 ▶  {:ok, pid} = TaskFSM.start_link task: Task.create("Task1", 3, "Pr1")
#=> {:ok, #PID<0.198.0>}
Process.alive? pid
#=> true
iex|💧|3 ▶ TaskFSM.state pid
#=> "idle"
iex|💧|4 ▶ TaskFSM.start pid
#=> :ok
iex|💧|5 ▶ Process.alive? pid
#=> true
iex|💧|7 ▶ TaskFSM.finish pid
#=> :ok
iex|💧|8 ▶ Process.alive? pid
#=> false
```

Use name instead pid `Supervision`:
```zsh
iex|💧|1 ▶ {:ok, pid} = {:ok, pid} = TaskFSM.start_link task: Task.create("Task1", 3, "Pr1") 
#=> {:ok, #PID<0.198.0>}
iex|💧|2 ▶ TaskFSM.state {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
#=> :
iex|💧|3 ▶ TaskFSM.start {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
#=>:ok
iex|💧|4 ▶ TaskFSM.state {:via, Registry, {Kanban.TaskRegistry, "Task1"}} 
#=> "doing"
iex|💧|5 ▶ Process.alive? pid 
#=> true
iex|💧|6 ▶ TaskFSM.finish {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
#=> :ok
iex|💧|7 ▶ Process.alive? pid                                             
#=> false

iex|💧|8 ▶ pid
#=> #PID<0.218.0>
iex|💧|9 ▶ Process.exit pid, :kill
#=> true
iex|💧|10 ▶ Process.alive? pid                                             
#=> false

```
