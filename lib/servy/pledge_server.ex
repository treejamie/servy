defmodule Servy.PledgeServer do


  def listen_loop(state) do
    IO.puts "\nWaiting for a message..."

    receive do
      {:create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)

        # make the new state
        new_state = [ {name, amount} | state]
        IO.puts "#{name} pledged #{amount}"
        IO.puts "new state is #{inspect new_state}"

        # and call the loop again
        listen_loop(new_state)
      {sender, :recent_pledges} ->
        send sender, {:response, state}
        IO.puts "Sent pledges to #{inspect sender}"
        listen_loop(state)
    end
  end

  # def create_pledge(name, amount) do
  #   {:ok, id} = send_pledge_to_service(name, amount)

  #   # catche the pledge
  #   [{"larry", 10}]
  # end

  # def recent_pledges do
  #  # returns the most recent, pledges
  #   [{"larry", 10}]
  # end

  defp send_pledge_to_service(_name, _amount) do

    # SEND CODE GOES HERE

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end
