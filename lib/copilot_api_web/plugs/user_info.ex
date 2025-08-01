defmodule CopilotApiWeb.Plugs.UserInfo do
  @moduledoc """
  A plug to extract user information from request headers, typically injected by an API Gateway.
  """
  import Plug.Conn
  alias CopilotApi.Core

  # This header is typically injected by Google Cloud Endpoints when using JWT authentication.
  # The value is a base64-encoded JSON string containing user information.
  @user_info_header "x-apigateway-api-userinfo"

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, @user_info_header) do
      [encoded_user_info | _] ->
        with {:ok, decoded_binary} <- Base.decode64(encoded_user_info, padding: false),
             {:ok, jwt_claims} <- Jason.decode(decoded_binary),
             {:ok, user} <- Core.get_or_create_user(jwt_claims) do
          # Attach the full User struct to the connection's assigns
          assign(conn, :current_user, user)
        else
          _ ->
            # Handle decoding or parsing errors, or simply ignore if not critical
            conn
        end

      _ ->
        # No user info header found, continue without assigning user
        conn
    end
  end
end
