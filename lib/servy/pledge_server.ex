defmodule Servy.PledgeServer do


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
    end
  end

  def create_pledge(pid, name, amount) do
    # send the pledge
    send(pid, {self(), :create_pledge, name, amount})

    # and receive it - this blocks
    receive do {:response, status} -> status end
  end

  def recent_pledges(pid) do
    # send the message - async
    send(pid, {self(), :recent_pledges})

    # and receive it - this blocks
    receive do {:response, pledges} -> pledges end
  end

  defp send_pledge_to_service(_name, _amount) do

    # SEND CODE GOES HERE

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end


alias Servy.PledgeServer

pid = spawn(PledgeServer, :listen_loop, [[]])

IO.inspect PledgeServer.create_pledge(pid, "larry", 10)
IO.inspect PledgeServer.create_pledge(pid, "moe", 20)
IO.inspect PledgeServer.create_pledge(pid, "curly", 30)
IO.inspect PledgeServer.create_pledge(pid, "daisy", 40)
IO.inspect PledgeServer.create_pledge(pid, "grace", 50)

IO.inspect PledgeServer.recent_pledges(pid)


receive do {:response, pledges} -> IO.inspect pledges end
