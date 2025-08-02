defmodule CopilotApiWeb.Plugs.DevAuth do
  @moduledoc """
  Mocks an authentication header in development.
  
  In production, an API Gateway would validate a JWT and inject a similar
  header. This plug simulates that behavior for local development.
  """
  import Plug.Conn

  alias Jason

  def init(opts), do: opts

  def call(conn, _opts) do
    user_info = %{
      "provider_id" => "dev-user-123",
      "email" => "developer@example.com",
      "name" => "Dev User",
      "roles" => ["developer", "user"]
    }

    put_req_header(conn, "x-user-info", Jason.encode!(user_info))
  end
end
