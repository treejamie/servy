defmodule Servy.Handler do

  def handle(request) do
    request
    |> parse
    |> route
    |> format_response
  end


  def parse(_request) do
    # get the method and path
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    # la fin
    %{ method: method, path: path, resp_body: "" }
  end

  def route(_conv) do
    # TODO: Create a new map that also has the response body:
    %{ method: "GET", path: "/wildthings", resp_body: "Bears, Lions, Tigers" }
  end

  def format_response(_conv) do
    # TODO: Use values in the map to create an HTTP response string:
    """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 20

    Bears, Lions, Tigers
    """
  end
end
