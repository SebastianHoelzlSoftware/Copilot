defmodule CopilotWeb.TimeEntryControllerTest do
  use CopilotWeb.ConnCase, async: true

  alias Copilot.Core.TimeTracking
  import Copilot.Core.Fixtures

  defp put_auth_header(conn, user) do
    user_payload = %{
      "id" => user.id,
      "provider_id" => user.provider_id,
      "email" => user.email,
      "name" => user.name,
      "roles" => user.roles
    }

    conn
    |> Plug.Conn.assign(:current_user, user)
    |> put_req_header("x-user-info", Jason.encode!(user_payload))
  end

  setup do
    developer = developer_fixture()
    other_developer = developer_fixture(%{email: "other-dev@example.com"})
    customer = customer_fixture()
    customer_user = user_fixture(%{customer_id: customer.id, roles: ["customer"]})
    project_brief = project_brief_fixture()
    time_entry = time_entry_fixture(%{developer_id: developer.id, project_id: project_brief.id})
    other_time_entry = time_entry_fixture(%{developer_id: other_developer.id, project_id: project_brief.id})

    {:ok,
     developer: developer,
     other_developer: other_developer,
     customer: customer,
     customer_user: customer_user,
     project_brief: project_brief,
     time_entry: time_entry,
     other_time_entry: other_time_entry}
  end

  describe "index" do
    test "lists all time_entries for a developer", %{conn: conn, time_entry: time_entry, developer: developer} do
      conn =
        conn
        |> put_auth_header(developer)
        |> get(~p"/api/time_entries")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == time_entry.id))
    end

    test "filters time_entries by developer_id", %{conn: conn, time_entry: time_entry, other_time_entry: other_time_entry, developer: developer} do
      conn =
        conn
        |> put_auth_header(developer)
        |> get(~p"/api/time_entries?developer_id=#{time_entry.developer_id}")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.all?(data, &(&1["developer_id"] == time_entry.developer_id))
      assert Enum.any?(data, &(&1["id"] == time_entry.id))
      assert not Enum.any?(data, &(&1["id"] == other_time_entry.id))
    end

    test "is forbidden for a non-developer", %{conn: conn, customer_user: customer_user} do
      conn =
        conn
        |> put_auth_header(customer_user)
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
        |> put_auth_header(developer)
        |> post(~p"/api/time_entries", %{"time_entry" => create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      time_entry = TimeTracking.get_time_entry!(id)
      assert time_entry.description == "Initial development"
    end

    test "is forbidden for a non-developer", %{conn: conn, customer_user: customer_user} do
      conn =
        conn
        |> put_auth_header(customer_user)
        |> post(~p"/api/time_entries", %{"time_entry" => %{}})

      assert conn.status == 403
    end

    test "returns error when params are missing", %{conn: conn, developer: developer} do
      conn =
        conn
        |> put_auth_header(developer)
        |> post(~p"/api/time_entries", %{"time_entry" => %{}})

      assert json_response(conn, 422)
    end
  end

  describe "show" do
    test "shows a time_entry for the owner developer", %{conn: conn, time_entry: time_entry, developer: developer} do
      conn =
        conn
        |> put_auth_header(developer)
        |> get(~p"/api/time_entries/#{time_entry}")

      assert json_response(conn, 200)["data"]["id"] == time_entry.id
    end

    test "is forbidden for another developer", %{conn: conn, time_entry: time_entry, other_developer: other_developer} do
      conn =
        conn
        |> put_auth_header(other_developer)
        |> get(~p"/api/time_entries/#{time_entry}")

      assert conn.status == 403
    end

    test "is forbidden for a non-developer", %{conn: conn, time_entry: time_entry, customer_user: customer_user} do
      conn =
        conn
        |> put_auth_header(customer_user)
        |> get(~p"/api/time_entries/#{time_entry}")

      assert conn.status == 403
    end
  end

  describe "update" do
    test "updates a time_entry for the owner developer", %{conn: conn, time_entry: time_entry, developer: developer} do
      update_attrs = %{"description" => "Updated description"}

      conn =
        conn
        |> put_auth_header(developer)
        |> put(~p"/api/time_entries/#{time_entry}", %{"time_entry" => update_attrs})

      assert json_response(conn, 200)["data"]["description"] == "Updated description"
    end

    test "is forbidden for another developer", %{conn: conn, time_entry: time_entry, other_developer: other_developer} do
      update_attrs = %{"description" => "Updated description"}

      conn =
        conn
        |> put_auth_header(other_developer)
        |> put(~p"/api/time_entries/#{time_entry}", %{"time_entry" => update_attrs})

      assert conn.status == 403
    end

    test "is forbidden for a non-developer", %{conn: conn, time_entry: time_entry, customer_user: customer_user} do
      update_attrs = %{"description" => "Updated description"}

      conn =
        conn
        |> put_auth_header(customer_user)
        |> put(~p"/api/time_entries/#{time_entry}", %{"time_entry" => update_attrs})

      assert conn.status == 403
    end
  end

  describe "delete" do
    test "deletes a time_entry for the owner developer", %{conn: conn, time_entry: time_entry, developer: developer} do
      conn =
        conn
        |> put_auth_header(developer)
        |> delete(~p"/api/time_entries/#{time_entry}")

      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> TimeTracking.get_time_entry!(time_entry.id) end
    end

    test "is forbidden for another developer", %{conn: conn, time_entry: time_entry, other_developer: other_developer} do
      conn =
        conn
        |> put_auth_header(other_developer)
        |> delete(~p"/api/time_entries/#{time_entry}")

      assert conn.status == 403
    end

    test "is forbidden for a non-developer", %{conn: conn, time_entry: time_entry, customer_user: customer_user} do
      conn =
        conn
        |> put_auth_header(customer_user)
        |> delete(~p"/api/time_entries/#{time_entry}")

      assert conn.status == 403
    end
  end
end