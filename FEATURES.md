# FEATURES


Task state machine description `task_fsm.ex` :
```zsh
{:ok, pid} = Kanban.TaskFSM.start_link %Task{state: :idle} 
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

