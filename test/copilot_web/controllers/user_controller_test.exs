defmodule CopilotWeb.UserControllerTest do
  use CopilotWeb.ConnCase, async: true

  alias Copilot.Core.Users

  # Helper function to create the auth header, mimicking the DevAuth plug.
  defp put_auth_header(conn, user_payload) do
    encoded_user_info = Jason.encode!(user_payload)
    put_req_header(conn, "x-user-info", encoded_user_info)
  end

  @developer_payload %{
    "provider_id" => "dev-user-123",
    "email" => "dev@example.com",
    "name" => "Dev User",
    "roles" => ["developer"]
  }

  @customer_payload %{
    "provider_id" => "customer-456",
    "email" => "customer@example.com",
    "name" => "Customer User",
    "roles" => ["customer"]
  }

  setup do
    # Create a user to be acted upon in tests
    {:ok, user} = Users.find_or_create_user(@customer_payload)
    {:ok, user: user}
  end

  describe "show" do
    test "shows the current user's data", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> get(~p"/api/me")

      assert %{"data" => data} = json_response(conn, 200)
      assert data["email"] == "customer@example.com"
    end
  end

  describe "update" do
    test "updates the current user's data", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> put(~p"/api/me", %{"user" => %{"name" => "Updated Name"}})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["name"] == "Updated Name"
    end

    test "returns an error for invalid data", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> put(~p"/api/me", %{"user" => %{"email" => "invalid-email"}})

      assert %{"errors" => %{"email" => ["must have the @ sign and no spaces"]}} =
               json_response(conn, 422)
    end

    test "does not allow users to update their own roles", %{conn: conn, user: user} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> put(~p"/api/me", %{"user" => %{"roles" => ["developer"]}})

      # The roles should not have changed, even if the request was successful for other fields
      assert %{"data" => data} = json_response(conn, 200)
      assert data["roles"] == ["customer"]

      # Verify directly from the database that the roles were not updated
      updated_user = Users.get_user!(user.id)
      assert updated_user.roles == ["customer"]
    end
  end

  describe "delete" do
    test "deletes the current user's account", %{conn: conn, user: user} do
      # Temporarily set the log level to :info to ensure the logger metadata is
      # evaluated for full test coverage. We restore the original level on exit.
      original_level = Logger.level()
      Logger.configure(level: :info)
      on_exit(fn -> Logger.configure(level: original_level) end)

      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> delete(~p"/api/me")

      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end
  end

  describe "update_role" do
    test "updates a user's role for a developer", %{conn: conn, user: user} do
      # Temporarily set the log level to :info to ensure the logger metadata is
      # evaluated for full test coverage. We restore the original level on exit.
      original_level = Logger.level()
      Logger.configure(level: :info)
      on_exit(fn -> Logger.configure(level: original_level) end)

      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> put(~p"/api/users/#{user.id}/role", %{"roles" => ["customer", "beta_tester"]})

      assert %{"data" => data} = json_response(conn, 200)
      assert data["roles"] == ["customer", "beta_tester"]
    end

    test "returns an error for invalid role data", %{conn: conn, user: user} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> put(~p"/api/users/#{user.id}/role", %{"roles" => "not-a-list"})

      # The exact error message depends on the User changeset validation
      assert %{"errors" => %{"roles" => ["is invalid"]}} = json_response(conn, 422)
    end

    test "is forbidden for a non-developer", %{conn: conn, user: user} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> put(~p"/api/users/#{user.id}/role", %{"roles" => ["admin"]})

      assert response(conn, 403)
      assert json_response(conn, 403)["error"]["code"] == "forbidden"
    end

    test "returns 400 when roles are missing", %{conn: conn, user: user} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> put(~p"/api/users/#{user.id}/role", %{})

      assert json_response(conn, 400)
    end
  end
end
