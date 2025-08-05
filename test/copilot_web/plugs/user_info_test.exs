defmodule CopilotWeb.Plugs.UserInfoTest do
  use CopilotWeb.ConnCase, async: true

  alias Copilot.Core.Data.User
  alias CopilotWeb.Plugs.UserInfo

  describe "UserInfo plug" do
    test "assigns current_user when header is valid and user can be found or created", %{
      conn: conn
    } do
      user_attrs = %{
        "provider_id" => "test-user-123",
        "email" => "test@example.com",
        "name" => "Test User",
        "roles" => ["user"]
      }

      conn =
        conn
        |> put_req_header("x-user-info", Jason.encode!(user_attrs))
        |> UserInfo.call([])

      assert %User{email: "test@example.com"} = conn.assigns.current_user
      assert conn.assigns.current_user.provider_id == "test-user-123"
    end

    test "assigns nil to current_user when header is missing", %{conn: conn} do
      conn = UserInfo.call(conn, [])
      assert conn.assigns.current_user == nil
    end

    test "assigns nil to current_user when header has invalid JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-user-info", "this-is-not-json")
        |> UserInfo.call([])

      assert conn.assigns.current_user == nil
    end

    test "assigns nil to current_user when user attributes are invalid", %{conn: conn} do
      # The `provider_id` is required by the User changeset, so this will fail.
      invalid_attrs = %{"email" => "invalid@example.com", "name" => "Invalid User"}

      conn =
        conn
        |> put_req_header("x-user-info", Jason.encode!(invalid_attrs))
        |> UserInfo.call([])

      assert conn.assigns.current_user == nil
    end
  end
end
