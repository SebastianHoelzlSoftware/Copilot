defmodule CopilotWeb.Plugs.Authorization do
  @moduledoc """
  A plug to ensure a user has a specific role.

  This plug checks the `roles` field within `conn.assigns.current_user`.
  It should be used after an authentication plug (like `EnsureAuthenticated`)
  has run.

  ## Example Usage

  In your `router.ex`:

      pipeline :developer_only do
        plug CopilotWeb.Plugs.EnsureAuthenticated
        plug CopilotWeb.Plugs.Authorization, "developer"
      end

      scope "/developer", CopilotWeb do
        pipe_through [:api, :developer_only]
        # ... developer-only routes
      end
  """
  import Plug.Conn
  import Phoenix.Controller

  def init(required_role) when is_binary(required_role), do: required_role

  def call(conn, required_role) do
    # Since EnsureAuthenticated runs before this, we can be sure `current_user` is a struct.
    # We access the role field directly instead of using `get_in`, which would require
    # the User struct to implement the Access behaviour.
    user_roles = conn.assigns.current_user.roles

    if required_role in user_roles do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{code: "forbidden", message: "You do not have the required permissions."}})
      |> halt()
    end
  end
end
