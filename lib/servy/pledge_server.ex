defmodule Servy.PledgeServer do

  def create_pledge(name, amount) do
    {:ok, id} = send_pledge_to_service(name, amount)

    # catche the pledge
    [{"larry", 10}]
  end

  def recent_pledges do
   # returns the most recent, pledges
    [{"larry", 10}]
  end

  defp send_pledge_to_service(_name, _amount) do

    # SEND CODE GOES HERE

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

end
