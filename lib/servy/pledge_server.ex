defmodule Servy.PledgeServer do

  # this is used to register the process
  @name :pledge_server

  # Client functions below ⬇️
  def start do
    IO.puts "starting the pledge server..."
    # start it
    pid = spawn(__MODULE__, :listen_loop, [[]])

    # register the process
    Process.register(pid, @name)

    # just incase
    pid
  end

  def create_pledge(name, amount) do
    # send the pledge
    send(@name, {self(), :create_pledge, name, amount})

    # and receive it - this blocks
    receive do {:response, status} -> status end
  end

  def recent_pledges() do
    # send the message - async
    send(@name, {self(), :recent_pledges})

    # and receive it - this blocks
    receive do {:response, pledges} -> pledges end
  end

  def total_pledged do
    # send
    send(@name, {self(), :total_pledged})

    # receive
    receive do {:response, total} -> total end
  end


  # client functions above ⬆️
  # Server functions below ⬇️
  def listen_loop(state) do

    receive do
      {sender, :create_pledge, name, amount} ->
        # send to the external service
        {:ok, id} = send_pledge_to_service(name, amount)

        # take the most recent pledges
        most_recent_pledges = Enum.take(state, 2)

        # make the new state
        new_state = [ {name, amount} | most_recent_pledges]

        # reply to the sender
        send(sender, {:response, id})

        # and call the loop again
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        # send
        send(sender, {:response, state})

        # and recurse
        listen_loop(state)

      {sender, :total_pledged} ->
        # the server is now doing work
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum

        send(sender, {:response, total})

        listen_loop(state)

      unexpected ->
        IO.puts "Unexpected message #{inspect unexpected}"
        listen_loop(state)

    end
  end


  defp send_pledge_to_service(_name, _amount) do

    # SEND CODE GOES HERE

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end


# alias Servy.PledgeServer

# pid = PledgeServer.start()

# send(pid, {:stop, "hammertime"})

# IO.inspect PledgeServer.create_pledge("larry", 10)
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
# IO.inspect PledgeServer.create_pledge("daisy", 40)
# IO.inspect PledgeServer.create_pledge("grace", 50)

# IO.inspect PledgeServer.recent_pledges()
# IO.inspect PledgeServer.total_pledged()

# IO.inspect(Process.info(pid, :messages))
