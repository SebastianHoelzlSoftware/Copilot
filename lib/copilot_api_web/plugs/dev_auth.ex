defmodule CopilotApiWeb.Plugs.DevAuth do
  @moduledoc """
  A plug to mock the API Gateway's authentication for local development.

  This plug injects a fake `x-apigateway-api-userinfo` header into the
  request, simulating a successfully authenticated user. It should only
  be used in the `:dev` environment.
  """
  import Plug.Conn

  @user_info_header "x-apigateway-api-userinfo"

  def init(opts), do: opts

  def call(conn, _opts) do
    # Create a mock user payload, mimicking a decoded Firebase JWT.
    mock_user = %{
      "user_id" => "dev-user-123",
      "email" => "dev@example.com",
      "name" => "Dev User",
      "issuer" => "https://securetoken.google.com/mock-project-id",
      "role" => "developer" # Add a mock role for authorization testing
    }

    # Encode the payload to JSON, then Base64, and put it in the header.
    encoded_user_info = mock_user |> Jason.encode!() |> Base.encode64(padding: false)
    put_req_header(conn, @user_info_header, encoded_user_info)
  end
end
