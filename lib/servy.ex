defmodule Servy do

  use Application

  def start(_type, _args) do
    IO.puts "Starting the Servy application..."
    Servy.Supervisor.start_link()
  end

end
