defmodule CopilotApiWeb.CustomerControllerTest do
  use CopilotApiWeb.ConnCase

  import CopilotApi.Core.Fixtures

  @create_attrs %{name: %{company_name: "New Company Inc."}}
  @update_attrs %{name: %{company_name: "Updated Company Inc."}}
  @invalid_attrs %{name: nil}

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
    # The "current" customer for the connection
    customer = customer_fixture()
    # Another customer to test authorization against
    other_customer = customer_fixture()

    conn = as_customer(conn, customer)

    {:ok, conn: conn, customer: customer, other_customer: other_customer}
  end

  describe "index" do
    test "is forbidden for a customer", %{conn: conn} do
      conn = get(conn, ~p"/api/customers")
      assert json_response(conn, 403)["error"]["message"] == "You are not authorized to perform this action"
    end

    test "lists all customers for a developer", %{conn: conn, customer: customer, other_customer: other_customer} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/customers")

      assert %{"data" => data} = json_response(conn, 200)
      assert length(data) == 2
      assert Enum.any?(data, &(&1["id"] == customer.id))
      assert Enum.any?(data, &(&1["id"] == other_customer.id))
    end
  end

  describe "create" do
    test "is forbidden for a customer", %{conn: conn} do
      conn = post(conn, ~p"/api/customers", %{"customer" => @create_attrs})
      assert json_response(conn, 403)["error"]["message"] == "Only developers can create customers"
    end

    test "creates a customer for a developer", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/customers", %{"customer" => @create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      customer = CopilotApi.Core.Customers.get_customer!(id)
      assert customer.name.company_name == "New Company Inc."
    end

    test "does not create customer with invalid data", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/customers", %{"customer" => @invalid_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show" do
    test "shows own customer record", %{conn: conn, customer: customer} do
      conn = get(conn, ~p"/api/customers/#{customer}")
      assert json_response(conn, 200)["data"]["id"] == customer.id
    end

    test "shows any customer record for a developer", %{conn: conn, other_customer: other_customer} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/customers/#{other_customer}")
      assert json_response(conn, 200)["data"]["id"] == other_customer.id
    end

    test "is forbidden for other customers", %{conn: conn, other_customer: other_customer} do
      conn = get(conn, ~p"/api/customers/#{other_customer}")
      assert json_response(conn, 403)["error"]["message"] == "You are not authorized to perform this action"
    end
  end

  describe "update" do
    test "updates own customer record", %{conn: conn, customer: customer} do
      conn = put(conn, ~p"/api/customers/#{customer}", %{"customer" => @update_attrs})
      assert json_response(conn, 200)["data"]["name"]["company_name"] == "Updated Company Inc."
    end

    test "updates any customer record for a developer", %{conn: conn, other_customer: other_customer} do
      conn = as_developer(conn)
      conn = put(conn, ~p"/api/customers/#{other_customer}", %{"customer" => @update_attrs})
      assert json_response(conn, 200)["data"]["name"]["company_name"] == "Updated Company Inc."
    end

    test "is forbidden for other customers", %{conn: conn, other_customer: other_customer} do
      conn = put(conn, ~p"/api/customers/#{other_customer}", %{"customer" => @update_attrs})
      assert json_response(conn, 403)["error"]["message"] == "You are not authorized to perform this action"
    end
  end

  describe "delete" do
    test "deletes own customer record", %{conn: conn, customer: customer} do
      conn = delete(conn, ~p"/api/customers/#{customer}")
      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> CopilotApi.Core.Customers.get_customer!(customer.id) end
    end

    test "deletes any customer record for a developer", %{conn: conn, other_customer: other_customer} do
      conn = as_developer(conn)
      conn = delete(conn, ~p"/api/customers/#{other_customer}")
      assert response(conn, 204)
      assert_raise Ecto.NoResultsError, fn -> CopilotApi.Core.Customers.get_customer!(other_customer.id) end
    end

    test "is forbidden for other customers", %{conn: conn, other_customer: other_customer} do
      conn = delete(conn, ~p"/api/customers/#{other_customer}")
      assert json_response(conn, 403)["error"]["message"] == "You are not authorized to perform this action"
    end
  end
end
