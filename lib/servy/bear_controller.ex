defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  @templates_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings \\  []) do
    content =
      @templates_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)
  end

  def index(conv) do
    # started life off as anon functions, then moved into controller and then
    # we introduced the shortcuts of the ampersands.
    # warning: clear code is always better than clever code
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name/2)

    # render the template
    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    # get the bear
    bear = Wildthings.get_bear(id)

    # render the template
    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type} = _params) do
    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}"
    }
  end

end
