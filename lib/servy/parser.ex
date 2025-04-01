defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # get the top of the request and the  params
    [top, params_strings] = String.split(request, "\n\n")

    # now split the top into a request line and header list
    [request_line | header_lines] = String.split(top, "\n")

    # get the method and path
    [method, path, _] = String.split(request_line, " ")

    # now parse the headers
    headers = parse_headers(header_lines, %{})

    # parse params
    params = parse_params(headers["Content-Type"], params_strings)


    # la fin
    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers([head | tail], headers) do

    # split up the head into key values - this is ok, becasue there's a spec for HTTP headers
    # and even if this one didn't match, we'd return a 400 Bad Request
    [key, value] = String.split(head, ": ")

    # now build the headers by adding key and value onto the map
    headers = Map.put(headers, key, value)

    # and now recurse
    parse_headers(tail, headers)
  end

  # fin
  def parse_headers([], headers), do: headers


  def parse_params("application/x-www-form-urlencoded", params) do
    params |> String.trim |> URI.decode_query
  end

  # catch all
  def parse_params(_, _), do: %{}
end
