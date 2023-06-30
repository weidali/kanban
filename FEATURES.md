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

DynamicSuoervisor `aplication.ex`:
```zsh
iex|💧|1 ▶ Process.whereis Kanban.TaskManager
#PID<0.204.0>
iex|💧|2 ▶ Process.whereis Kanban.TaskRegistry
#PID<0.202.0>

iex|💧|3 ▶ DynamicSupervisor.which_children Kanban.TaskRegistry
# [
#   {Kanban.TaskRegistry.PIDPartition0, #PID<0.202.0>, :worker,
#    [Registry.Partition]}
# ]
iex|💧|4 ▶ DynamicSupervisor.which_children Kanban.TaskManager 
# []

iex|💧|4 ▶ Kanban.TaskManager.start_task "Task1", 2, "Pr1"
#PID<0.214.0>
iex|💧|5 ▶ DynamicSupervisor.which_children Kanban.TaskManager
# [{:undefined, #PID<0.214.0>, :worker, [Kanban.TaskFSM]}]
iex|💧|6 ▶ pid = v(4)
#PID<0.214.0>
iex|💧|7 ▶ Process.exit pid, :kill
# true
iex|💧|8 ▶ DynamicSupervisor.which_children Kanban.TaskManager
# [{:undefined, #PID<0.218.0>, :worker, [Kanban.TaskFSM]}]
iex|💧|9 ▶ TaskFSM.start {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
# :ok
iex|💧|10 ▶ TaskFSM.state {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
# "doing"
iex|💧|11 ▶ [{_, pid, _, _}] = v(8)
# [{:undefined, #PID<0.218.0>, :worker, [Kanban.TaskFSM]}]
iex|💧|12 ▶ pid
#PID<0.218.0>

iex|💧|13 ▶ Process.exit pid, :kill                                       
# true
iex|💧|14 ▶ DynamicSupervisor.which_children Kanban.TaskManager           
# [{:undefined, #PID<0.222.0>, :worker, [Kanban.TaskFSM]}]
iex|💧|15 ▶ TaskFSM.state {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
# "idle"

iex|💧|16 ▶ Kanban.TaskManager.start_task "Task2", 3, "Pr1"               
#PID<0.225.0>
iex|💧|17 ▶ Kanban.TaskManager.start_task "Task3", 3, "Pr1"
#PID<0.226.0>
iex|💧|18 ▶ Kanban.TaskManager.start_task "Task4", 3, "Pr1"
#PID<0.227.0>
iex|💧|19 ▶ Kanban.TaskManager.start_task "Task5", 3, "Pr1"
#PID<0.228.0>
iex|💧|20 ▶ DynamicSupervisor.which_children Kanban.TaskManager           
# [
#   {:undefined, #PID<0.222.0>, :worker, [Kanban.TaskFSM]},
#   {:undefined, #PID<0.225.0>, :worker, [Kanban.TaskFSM]},
#   {:undefined, #PID<0.226.0>, :worker, [Kanban.TaskFSM]},
#   {:undefined, #PID<0.227.0>, :worker, [Kanban.TaskFSM]},
#   {:undefined, #PID<0.228.0>, :worker, [Kanban.TaskFSM]}
# ]

```

Get quick access to the status/state of any Task by its name `state.ex`:
```zsh
iex|💧|1 ▶ Kanban.TaskManager.start_task "Task1", 3, "Pr1"
#PID<0.202.0>
iex|💧|2 ▶ Kanban.TaskManager.start_task "Task2", 3, "Pr1"
#PID<0.203.0>
iex|💧|3 ▶ Kanban.TaskManager.start_task "Task3", 3, "Pr1"
#PID<0.204.0>
iex|💧|4 ▶ Kanban.TaskManager.start_task "Task4", 3, "Pr1"
#PID<0.205.0>
iex|💧|5 ▶ Kanban.TaskManager.start_task "Task5", 3, "Pr1"
#PID<0.206.0>
iex|💧|6 ▶ Kanban.State.state
# %{
#   "Task1" => "idle",
#   "Task2" => "idle",
#   "Task3" => "idle",
#   "Task4" => "idle",
#   "Task5" => "idle"
# }
iex|💧|7 ▶ TaskFSM.start {:via, Registry, {Kanban.TaskRegistry, "Task1"}}
# :ok
iex|💧|8 ▶ TaskFSM.start {:via, Registry, {Kanban.TaskRegistry, "Task3"}}
# :ok
iex|💧|9 ▶ TaskFSM.finish {:via, Registry, {Kanban.TaskRegistry, "Task3"}}
# :ok
iex|💧|10 ▶ Kanban.State.state                                             
# %{
#   "Task1" => "doing",
#   "Task2" => "idle",
#   "Task3" => "done",
#   "Task4" => "idle",
#   "Task5" => "idle"
# }

```

Main supervisor `main.ex`:
```zsh
iex|💧|1 ▶ (1..1_00000) |> Enum.map(&"Task_#{&1}") |> Enum.map(&TaskManager.start_task &1, 3, "Pr1") 

iex|💧|2 ▶  TaskManager |> DynamicSupervisor.which_children() |> Enum.map(fn {_, pid, :worker, [TaskFSM]} -> pid end) |> Enum.map(&TaskFSM.state/1)

iex|💧|3 ▶ DynamicSupervisor.which_children TaskManager

iex|💧|4 ▶ DynamicSupervisor.which_children(TaskManager) |> Enum.count()
# 10000

iex|💧|5 ▶ TaskFSM.start {:via, Registry, {Kanban.TaskRegistry, "Task_99"}}
# :ok

iex|💧|8 ▶ State.state |> Map.values |> Enum.uniq                          
# ["idle", "doing"]

iex|💧|9 ▶ TaskFSM.finish {:via, Registry, {Kanban.TaskRegistry, "Task_99"}}
# :ok
iex|💧|10 ▶ State.state |> Map.values |> Enum.uniq                           
# ["idle", "done"]

iex|💧|11 ▶ DynamicSupervisor.which_children(TaskManager) |> Enum.count()    
# 9999

iex|💧|12 ▶ State.state()["Task_99"]
# "done"

```

Application `kanban.ex`:
```zsh
iex|💧|1 ▶ (1..1_00000) |> Enum.map(&"Task_#{&1}") |> Enum.map(&TaskManager.start_task &1, 3, "Pr1") 

iex|💧|3 ▶ Kanban.start_task("Task_999")
:ok
iex|💧|4 ▶ Kanban.query_task("Task_999")
"doing"
iex|💧|5 ▶ Kanban.finish_task("Task_999")
:ok
iex|💧|6 ▶ DynamicSupervisor.which_children(TaskManager) |> Enum.count()
99999
```
