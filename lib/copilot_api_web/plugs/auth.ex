defmodule CopilotApiWeb.Plugs.Auth do
  @moduledoc """
  A placeholder plug for authentication.

  In a real application, this plug would verify a token (e.g., JWT)
  from the request headers, load the corresponding user from the database,
  and assign it to the connection. It would halt with a 401 Unauthorized
  error if authentication fails.

  For this example, it assigns a mock user to the connection based on
  request headers to allow the authorization plugs to function.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # In a real app, you'd get the user from a token.
    # For now, we'll create a mock user based on headers for demonstration.
    user =
      if get_req_header(conn, "x-user-role") == ["developer"] do
        %{id: Ecto.UUID.generate(), roles: ["developer"], customer_id: nil}
      else
        %{id: Ecto.UUID.generate(), roles: ["customer"], customer_id: List.first(get_req_header(conn, "x-customer-id")) || Ecto.UUID.generate()}
      end

    assign(conn, :current_user, user)
  end
end
