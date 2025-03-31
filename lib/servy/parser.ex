defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # get the method and path
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    # la fin
    %Conv{
      method: method,
      path: path,
    }
  end
end
