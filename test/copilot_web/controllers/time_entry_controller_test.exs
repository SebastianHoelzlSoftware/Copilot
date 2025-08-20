
defmodule CopilotWeb.TimeEntryControllerTest do
  use CopilotWeb.ConnCase, async: true

  alias Copilot.Core.TimeTracking
  import Copilot.Core.Fixtures

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
    developer = developer_fixture()
    project_brief = project_brief_fixture()
    time_entry = time_entry_fixture(%{developer: developer, project: project_brief})
    {:ok, developer: developer, project_brief: project_brief, time_entry: time_entry}
  end

  describe "index" do
    test "lists all time_entries for a developer", %{conn: conn, time_entry: time_entry} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> get(~p"/api/time_entries")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == time_entry.id))
    end

    test "is forbidden for a non-developer", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> get(~p"/api/time_entries")

      assert conn.status == 403
    end

    test "is unauthorized without auth header", %{conn: conn} do
        conn = get(conn, ~p"/api/time_entries")
        assert response(conn, 401)
    end
  end

  describe "create" do
    test "creates a time_entry for a developer", %{conn: conn, developer: developer, project_brief: project_brief} do
      create_attrs = %{
        "start_time" => "2025-08-20T10:00:00Z",
        "end_time" => "2025-08-20T11:00:00Z",
        "description" => "Initial development",
        "developer_id" => developer.id,
        "project_id" => project_brief.id
      }

      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> post(~p"/api/time_entries", %{"time_entry" => create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      time_entry = TimeTracking.get_time_entry!(id)
      assert time_entry.description == "Initial development"
    end

    test "is forbidden for a non-developer", %{conn: conn} do
        conn =
            conn
            |> put_auth_header(@customer_payload)
            |> post(~p"/api/time_entries", %{"time_entry" => %{}})

        assert conn.status == 403
    end

    test "returns error when params are missing", %{conn: conn} do
        conn =
            conn
            |> put_auth_header(@developer_payload)
            |> post(~p"/api/time_entries", %{"time_entry" => %{}})
        assert json_response(conn, 422)
    end
  end

  describe "show" do
    test "shows a time_entry for a developer", %{conn: conn, time_entry: time_entry} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> get(~p"/api/time_entries/#{time_entry}")

      assert json_response(conn, 200)["data"]["id"] == time_entry.id
    end

    test "is forbidden for a non-developer", %{conn: conn, time_entry: time_entry} do
        conn =
            conn
            |> put_auth_header(@customer_payload)
            |> get(~p"/api/time_entries/#{time_entry}")

        assert conn.status == 403
    end
  end

  describe "update" do
    test "updates a time_entry for a developer", %{conn: conn, time_entry: time_entry} do
        update_attrs = %{"description" => "Updated description"}
        conn =
            conn
            |> put_auth_header(@developer_payload)
            |> put(~p"/api/time_entries/#{time_entry}", %{"time_entry" => update_attrs})

        assert json_response(conn, 200)["data"]["description"] == "Updated description"
    end

    test "is forbidden for a non-developer", %{conn: conn, time_entry: time_entry} do
        update_attrs = %{"description" => "Updated description"}
        conn =
            conn
            |> put_auth_header(@customer_payload)
            |> put(~p"/api/time_entries/#{time_entry}", %{"time_entry" => update_attrs})

        assert conn.status == 403
    end
  end

  describe "delete" do
    test "deletes a time_entry for a developer", %{conn: conn, time_entry: time_entry} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> delete(~p"/api/time_entries/#{time_entry}")

      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_time_entry!(time_entry.id) end
    end

    test "is forbidden for a non-developer", %{conn: conn, time_entry: time_entry} do
        conn =
            conn
            |> put_auth_header(@customer_payload)
            |> delete(~p"/api/time_entries/#{time_entry}")

        assert conn.status == 403
    end
  end
end
