defmodule CopilotApiWeb.UserControllerTest do
  use CopilotApiWeb.ConnCase, async: true

  # Helper function to create the auth header, mimicking the DevAuth plug.
  defp put_auth_header(conn, user_payload) do
    encoded_user_info = user_payload |> Jason.encode!() |> Base.encode64(padding: false)
    put_req_header(conn, "x-apigateway-api-userinfo", encoded_user_info)
  end

  describe "GET /api/me" do
    test "returns 200 and current user data for an authenticated developer", %{conn: conn} do
      # This payload mimics what DevAuth or a real API gateway would provide.
      developer_payload = %{
        "user_id" => "dev-user-123",
        "email" => "dev@example.com",
        "name" => "Dev User",
        "role" => "developer"
      }

      conn =
        conn
        |> put_auth_header(developer_payload)
        |> get(~p"/api/me")

      assert conn.status == 200

      json_response = json_response(conn, 200)
      assert json_response["data"]["email"] == "dev@example.com"
      assert json_response["data"]["role"] == "developer"
    end

    test "returns 403 Forbidden for a user without the developer role", %{conn: conn} do
      customer_payload = %{
        "user_id" => "customer-456",
        "email" => "customer@example.com",
        "name" => "Customer User",
        "role" => "customer"
      }

      conn =
        conn
        |> put_auth_header(customer_payload)
        |> get(~p"/api/me")

      assert response(conn, 403) == "{\"error\":{\"code\":\"forbidden\",\"message\":\"You do not have the required permissions.\"}}"
    end

    test "returns 401 Unauthorized for a request without authentication", %{conn: conn} do
      # We don't call put_auth_header, so the request is unauthenticated.
      conn = get(conn, ~p"/api/me")

      assert response(conn, 401) == "{\"error\":{\"code\":\"unauthorized\",\"message\":\"Authentication required\"}}"
    end
  end
end
