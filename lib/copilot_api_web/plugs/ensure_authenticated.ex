defmodule CopilotApiWeb.Plugs.EnsureAuthenticated do
  @moduledoc """
  A plug to ensure a user is authenticated.

  This plug checks for the presence of `conn.assigns.current_user`.
  If the user is not found, it halts the connection and sends a
  401 Unauthorized response.

  It should be placed in pipelines for routes that require authentication.
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: %{code: "unauthorized", message: "Authentication required"}})
      |> halt()
    end
  end
end
