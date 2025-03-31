defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    # get the top of the request and the  params
    [top, params_strings] = String.split(request, "\n\n")

    # now split the top into a request line and header list
    [request_line | header_lines] = String.split(top, "\n")

    # get the method and path
    [method, path, _] = String.split(request_line, " ")

    # parse params
    params = parse_params(params_strings)

    # la fin
    %Conv{
      method: method,
      path: path,
      params: params
    }
  end

  def parse_params(params) do
    params |> String.trim |> URI.decode_query
  end
end
