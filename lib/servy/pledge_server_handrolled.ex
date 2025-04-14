defmodule Servy.GenericServer do

  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})
    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender)->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(state, callback_module)

      unexpected ->
        IO.puts "Unexpected message #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end


defmodule Servy.PledgeServerHandRolled do
  alias Servy.GenericServer

  # this is used to register the process
  @name :pledge_server_handrolled

  # Client functions below ⬇️
  def start do
    IO.puts "starting the pledge server..."
    GenericServer.start(__MODULE__, [], @name)
  end

  def create_pledge(name, amount), do: GenericServer.call(@name, {:create_pledge, name, amount})

  def recent_pledges(), do: GenericServer.call(@name, :recent_pledges)

  def total_pledged(), do: GenericServer.call(@name, :total_pledged)

  def clear, do: GenericServer.cast(@name, :clear)


  def handle_cast(message, _state), do: []

  def handle_call(:total_pledged, state) do
      total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
      {total, state}
  end

  def handle_call(:recent_pledges, state), do: {state, state}

  def handle_call({:create_pledge, name, amount}, state) do
        # send to the external service
        {:ok, id} = send_pledge_to_service(name, amount)

        # take the most recent pledges
        most_recent_pledges = Enum.take(state, 2)

        # make the new state
        new_state = [ {name, amount} | most_recent_pledges]

        # return id
        {id, new_state}
  end

  defp send_pledge_to_service(_name, _amount), do: {:ok, "pledge-#{:rand.uniform(1000)}"}

end


# alias Servy.PledgeServerHandRolled

# pid = PledgeServerHandRolled.start()

# send(pid, {:stop, "hammertime"})

# IO.inspect PledgeServerHandRolled.create_pledge("larry", 10)
# IO.inspect PledgeServerHandRolled.create_pledge("moe", 20)
# IO.inspect PledgeServerHandRolled.create_pledge("curly", 30)
# IO.inspect PledgeServerHandRolled.create_pledge("daisy", 40)

# IO.inspect PledgeServerHandRolled.clear()

# IO.inspect PledgeServerHandRolled.create_pledge("grace", 50)

# IO.inspect PledgeServerHandRolled.recent_pledges()
# IO.inspect PledgeServerHandRolled.total_pledged()

# IO.inspect(Process.info(pid, :messages))
