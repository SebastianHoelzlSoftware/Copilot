defmodule CopilotApiWeb.BriefControllerTest do
  use CopilotApiWeb.ConnCase

  import CopilotApi.Core.Fixtures

  @create_attrs %{title: "new title", summary: "new summary"}
  @update_attrs %{title: "updated title", summary: "updated summary"}
  @invalid_attrs %{title: nil}

  defp as_customer(conn, customer) do
    conn
    |> put_req_header("x-user-role", "customer")
    |> put_req_header("x-customer-id", customer.id)
  end

  defp as_developer(conn) do
    conn
    |> put_req_header("x-user-role", "developer")
  end

  setup %{conn: conn} do
    customer = customer_fixture()
    brief = project_brief_fixture(%{customer: customer})
    other_customer = customer_fixture()

    conn = as_customer(conn, customer)

    {:ok, conn: conn, brief: brief, customer: customer, other_customer: other_customer}
  end

  describe "index" do
    test "lists all briefs for a developer", %{conn: conn, brief: brief} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/briefs")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == brief.id))
    end

    test "lists only own briefs for a customer", %{
      conn: conn,
      brief: brief,
      other_customer: other_customer
    } do
      project_brief_fixture(%{customer: other_customer})

      conn = get(conn, ~p"/api/briefs")
      assert %{"data" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == brief.id
    end
  end

  describe "create" do
    test "creates a brief when data is valid for a customer", %{conn: conn, customer: customer} do
      conn = post(conn, ~p"/api/briefs", %{"project_brief" => @create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      brief = CopilotApi.Core.Briefs.get_project_brief!(id)
      assert brief.customer_id == customer.id
      assert brief.title == "new title"
    end

    test "does not create brief with invalid data", %{conn: conn} do
      conn = post(conn, ~p"/api/briefs", %{"project_brief" => @invalid_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns forbidden for a developer", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/briefs", %{"project_brief" => @create_attrs})
      assert json_response(conn, 403)["error"]["message"] == "Only customers can create briefs"
    end

    test "returns 400 when project_brief params are missing", %{conn: conn} do
      conn = post(conn, ~p"/api/briefs", %{})

      assert json_response(conn, 400)
    end
  end

  describe "show" do
    test "shows brief for owner", %{conn: conn, brief: brief} do
      conn = get(conn, ~p"/api/briefs/#{brief}")
      assert json_response(conn, 200)["data"]["id"] == brief.id
    end

    test "shows brief for developer", %{conn: conn, brief: brief} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/briefs/#{brief}")
      assert json_response(conn, 200)["data"]["id"] == brief.id
    end

    test "returns forbidden for other customer", %{
      conn: conn,
      brief: brief,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = get(conn, ~p"/api/briefs/#{brief}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end
  end

  describe "update" do
    test "updates brief for owner", %{conn: conn, brief: brief} do
      conn = put(conn, ~p"/api/briefs/#{brief}", %{"project_brief" => @update_attrs})
      assert json_response(conn, 200)["data"]["title"] == "updated title"
    end

    test "updates brief for developer", %{conn: conn, brief: brief} do
      conn = as_developer(conn)
      conn = put(conn, ~p"/api/briefs/#{brief}", %{"project_brief" => @update_attrs})
      assert json_response(conn, 200)["data"]["title"] == "updated title"
    end

    test "returns forbidden for other customer", %{
      conn: conn,
      brief: brief,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = put(conn, ~p"/api/briefs/#{brief}", %{"project_brief" => @update_attrs})

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "returns 400 when project_brief params are missing", %{conn: conn, brief: brief} do
      conn = put(conn, ~p"/api/briefs/#{brief}", %{})

      assert json_response(conn, 400)
    end
  end

  describe "delete" do
    test "deletes brief for owner", %{conn: conn, brief: brief} do
      conn = delete(conn, ~p"/api/briefs/#{brief}")
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        CopilotApi.Core.Briefs.get_project_brief!(brief.id)
      end
    end

    test "returns forbidden for developer", %{conn: conn, brief: brief} do
      conn = as_developer(conn)
      conn = delete(conn, ~p"/api/briefs/#{brief}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "returns forbidden for other customer", %{
      conn: conn,
      brief: brief,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = delete(conn, ~p"/api/briefs/#{brief}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end
  end
end
