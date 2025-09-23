defmodule CopilotWeb.Plugs.DevAuth do
  @moduledoc """
  Mocks an authentication header in development.
  
  In production, an API Gateway would validate a JWT and inject a similar
  header. This plug simulates that behavior for local development.
  """
  import Plug.Conn

  alias Jason

  def init(opts), do: opts

  def call(conn, opts) do
    user_info =
      case get_req_header(conn, "x-dev-auth-override") do
        [override_json] ->
          Jason.decode!(override_json)

        [] ->
          %{
            "provider_id" => "dev-seed-001",
            "email" => "dev@copilot.com",
            "name" => "Copilot Developer",
            "roles" => ["developer", "user"]
          }
      end

    # Always find or create the user
    case Copilot.Core.Users.find_or_create_user(user_info) do
      {:ok, user} ->
        # If assign_to_conn is true (for browser pipeline/LiveView), put user ID in session
        if opts[:assign_to_conn] do
          put_session(conn, :current_user_id, user.id)
        else
          # For API pipeline, put header
          conn
          |> put_req_header(
            "x-user-info",
            Jason.encode!(%{
              "provider_id" => user.provider_id,
              "email" => user.email,
              "name" => user.name,
              "roles" => user.roles,
              "customer_id" => user.customer_id
            })
          )
          |> delete_req_header("x-dev-auth-override")
        end

      {:error, changeset} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          :bad_request,
          Jason.encode!(%{
            error: "Failed to authenticate dev user",
            details: inspect(changeset.errors)
          })
        )
        |> halt()
    end
  end
end
