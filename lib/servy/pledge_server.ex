defmodule Servy.PledgeServer do

  # this is used to register the process
  @name :pledge_server

  # 'use' stubs out the default six callbacks that are required to run GenServer
  #
  # 1. `init/1` – Called when the server starts. Used to initialize state.
  # 2. `handle_call/3` – Handles synchronous calls (`GenServer.call/2`).
  # 3. `handle_cast/2` – Handles asynchronous messages (`GenServer.cast/2`).
  # 4. `handle_info/2` – Handles all other messages (e.g. from `send/2` or process monitoring).
  # 5. `terminate/2` – Called when the server is about to shut down.
  # 6. `code_change/3` – Used for hot code upgrades.
  #
  use GenServer


  # a default implementation. I'm guessing the version of elixir used now
  # warns about missing this one out and urges you to add it in yourself.
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start do
    IO.puts "starting the pledge server..."
    GenServer.start(__MODULE__, [], name: @name)
  end

  def create_pledge(name, amount), do: GenServer.call(@name, {:create_pledge, name, amount})

  def recent_pledges(), do: GenServer.call(@name, :recent_pledges)

  def total_pledged(), do: GenServer.call(@name, :total_pledged)

  def clear, do: GenServer.cast(@name, :clear)


  def handle_cast(:clear, _state), do: {:noreply, []}

  def handle_call(:total_pledged, _from, state) do
      total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
      {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state), do: {:reply, state, state}

  def handle_call({:create_pledge, name, amount}, _from, state) do
        # send to the external service
        {:ok, id} = send_pledge_to_service(name, amount)

        # take the most recent pledges
        most_recent_pledges = Enum.take(state, 2)

        # make the new state
        new_state = [ {name, amount} | most_recent_pledges]

        # return id
        {:reply, id, new_state}
  end

  defp send_pledge_to_service(_name, _amount), do: {:ok, "pledge-#{:rand.uniform(1000)}"}

end


alias Servy.PledgeServer

{:ok, pid} = PledgeServer.start()

send(pid, {:stop, "hammertime"})

IO.inspect PledgeServer.create_pledge("larry", 10)
IO.inspect PledgeServer.create_pledge("moe", 20)
IO.inspect PledgeServer.create_pledge("curly", 30)
IO.inspect PledgeServer.create_pledge("daisy", 40)

# IO.inspect PledgeServer.clear()

IO.inspect PledgeServer.create_pledge("grace", 50)

IO.inspect PledgeServer.recent_pledges()
IO.inspect PledgeServer.total_pledged()

# IO.inspect(Process.info(pid, :messages))
