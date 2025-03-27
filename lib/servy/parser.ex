defmodule Servy.Parser do

  def parse(request) do
    # get the method and path
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    # la fin
    %{ method: method,
    path: path,
    status: 0,
    resp_body: "" }
  end
end
