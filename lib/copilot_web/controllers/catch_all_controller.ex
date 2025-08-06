defmodule CopilotWeb.CatchAllController do
  use CopilotWeb, :controller

  def match_invalid_routes(conn, _params) do
    router_module = CopilotWeb.Router
    routes = Phoenix.Router.routes(router_module)

    conn
    |> put_status(404)
    |> json(%{
      "message" => "Endpoint not found, check list of available routes",
      # We filter the nils added by the map
      "routes" => routes |> Enum.map(&route_info_fn/1) |> Enum.filter(&(&1 != nil))
    })
  end

  defp route_info_fn(route_data) do
    # It will ignore every http method-agnostic endpoint by adding nil for such endpoints
    if route_data.verb != :* do
      %{
        method: route_data.verb |> Atom.to_string() |> String.upcase(),
        path: route_data.path
      }
    end
  end
end
