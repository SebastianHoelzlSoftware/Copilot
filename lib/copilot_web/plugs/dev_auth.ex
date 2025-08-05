defmodule CopilotWeb.Plugs.DevAuth do
  @moduledoc """
  Mocks an authentication header in development.

  In production, an API Gateway would validate a JWT and inject a similar
  header. This plug simulates that behavior for local development.
  """
  import Plug.Conn

  alias Jason

  def init(opts), do: opts

  def call(conn, _opts) do
    # Check for an override header for more flexible testing.
    # (e.g. when using end to end tesing via curl):

    # curl -i -X GET http://localhost:4000/api/me \
    # -H 'x-dev-auth-override: {"provider_id":"new-customer-123","email":"new.customer@example.com",
    # "name":"New Customer","roles":["customer","user"]}'

    # If the x-dev-auth-override header is not present, the default developer payload will be used.

    case get_req_header(conn, "x-dev-auth-override") do
      [override_json] ->
        # If the override exists, use it and pass it through.
        conn
        |> put_req_header("x-user-info", override_json)
        |> delete_req_header("x-dev-auth-override")

      [] ->
        # Otherwise, use the default developer payload.
        user_info = %{
          "provider_id" => "dev-user-123",
          "email" => "developer@example.com",
          "name" => "Dev User",
          "roles" => ["developer", "user"]
        }

        put_req_header(conn, "x-user-info", Jason.encode!(user_info))
    end
  end
end
