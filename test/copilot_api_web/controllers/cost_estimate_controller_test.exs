defmodule CopilotApiWeb.CostEstimateControllerTest do
  use CopilotApiWeb.ConnCase

  import CopilotApi.Core.Fixtures

  @create_attrs %{amount: "1000.00", currency: "USD"}
  @update_attrs %{amount: "2000.00"}
  @invalid_attrs %{amount: nil}

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
    owner_customer = customer_fixture()
    cost_estimate = cost_estimate_fixture(%{customer: owner_customer})
    other_customer = customer_fixture()

    conn = as_customer(conn, owner_customer)

    {:ok,
     conn: conn,
     cost_estimate: cost_estimate,
     owner_customer: owner_customer,
     other_customer: other_customer}
  end

  describe "index" do
    test "is forbidden for a customer", %{conn: conn} do
      conn = get(conn, ~p"/api/cost_estimates")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "lists all cost estimates for a developer", %{conn: conn, cost_estimate: cost_estimate} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/cost_estimates")
      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == cost_estimate.id))
    end
  end

  describe "create" do
    test "is forbidden for a customer", %{conn: conn, owner_customer: owner_customer} do
      create_attrs = Map.put(@create_attrs, "customer_id", owner_customer.id)
      conn = post(conn, ~p"/api/cost_estimates", %{"cost_estimate" => create_attrs})

      assert json_response(conn, 403)["error"]["message"] ==
               "Only developers can create a cost estimate"
    end

    test "creates a cost estimate for a developer", %{conn: conn, owner_customer: owner_customer} do
      create_attrs = Map.put(@create_attrs, "customer_id", owner_customer.id)
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/cost_estimates", %{"cost_estimate" => create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      cost_estimate = CopilotApi.Core.CostEstimates.get_cost_estimate!(id)
      assert cost_estimate.amount == Decimal.new("1000.00")
      assert cost_estimate.customer_id == owner_customer.id
    end

    test "does not create cost estimate with invalid data", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/cost_estimates", %{"cost_estimate" => @invalid_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show" do
    test "shows cost estimate for owner", %{conn: conn, cost_estimate: cost_estimate} do
      conn = get(conn, ~p"/api/cost_estimates/#{cost_estimate}")
      assert json_response(conn, 200)["data"]["id"] == cost_estimate.id
    end

    test "shows cost estimate for developer", %{conn: conn, cost_estimate: cost_estimate} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/cost_estimates/#{cost_estimate}")
      assert json_response(conn, 200)["data"]["id"] == cost_estimate.id
    end

    test "is forbidden for other customer", %{
      conn: conn,
      cost_estimate: cost_estimate,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = get(conn, ~p"/api/cost_estimates/#{cost_estimate}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end
  end

  describe "update" do
    test "is forbidden for owner", %{conn: conn, cost_estimate: cost_estimate} do
      conn =
        put(conn, ~p"/api/cost_estimates/#{cost_estimate}", %{"cost_estimate" => @update_attrs})

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "updates cost estimate for developer", %{conn: conn, cost_estimate: cost_estimate} do
      conn = as_developer(conn)

      conn =
        put(conn, ~p"/api/cost_estimates/#{cost_estimate}", %{"cost_estimate" => @update_attrs})

      assert json_response(conn, 200)["data"]["amount"] == "2000.00"
    end
  end

  describe "delete" do
    test "is forbidden for owner", %{conn: conn, cost_estimate: cost_estimate} do
      conn = delete(conn, ~p"/api/cost_estimates/#{cost_estimate}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "deletes cost estimate for developer", %{conn: conn, cost_estimate: cost_estimate} do
      conn = as_developer(conn)
      conn = delete(conn, ~p"/api/cost_estimates/#{cost_estimate}")
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        CopilotApi.Core.CostEstimates.get_cost_estimate!(cost_estimate.id)
      end
    end
  end
end
