defmodule Servy.Handler do

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.VideoCam

  @moduledoc """
  Servy!
  """

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  @doc "transforms request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    Servy.PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    Servy.PledgeController.index(conv)
  end
  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do

     # the request handling process
    parent = self()


    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    # spawn the processes
    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)


    # receive the messages - very naive, single,  pattern match
    where_is_bigfoot = Task.await(task)

    # now the response
    %{ conv | status: 200, resp_body: inspect {snapshots, where_is_bigfoot} }
  end


  def route(%Conv{method: "GET", path: "/kaboom"} = conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep
    %{ conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end


  def route(%Conv{method: "GET", path: "/about"} = conv) do
    # get the file
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{path: path} = conv) do
    %{ conv | resp_body: "No #{path} here.", status: 404}
  end

  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200,  resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 500, resp_body: "File error: does not exist"}
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error: #{reason}"}
  end


  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end

end
