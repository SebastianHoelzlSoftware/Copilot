defmodule CopilotWeb.Plugs.Auth do
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
    user_id = List.first(get_req_header(conn, "x-user-id")) || Ecto.UUID.generate()

    user =
      if get_req_header(conn, "x-user-role") == ["developer"] do
        %{id: user_id, roles: ["developer"], customer_id: nil}
      else
        customer_id_from_header = List.first(get_req_header(conn, "x-customer-id"))
        customer_id_from_body = get_in(conn.params, ["project_brief", "customer_id"])

        customer_id = customer_id_from_header || customer_id_from_body

        %{
          id: user_id,
          roles: ["customer"],
          customer_id: customer_id
        }
      end

    assign(conn, :current_user, user)
  end
end
