defmodule CopilotApiWeb.ContactControllerTest do
  use CopilotApiWeb.ConnCase

  import CopilotApi.Core.Fixtures

  @create_attrs %{
    name: %{first_name: "Jane", last_name: "Doe"},
    email: %{address: "jane.doe@example.com"}
  }
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
    customer = customer_fixture()
    contact = contact_fixture(%{customer: customer})
    other_customer = customer_fixture()

    conn = as_customer(conn, customer)

    {:ok, conn: conn, contact: contact, customer: customer, other_customer: other_customer}
  end

  describe "index" do
    test "lists all contacts for a developer", %{conn: conn, contact: contact} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/contacts")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == contact.id))
    end

    test "lists only own contacts for a customer", %{
      conn: conn,
      contact: contact,
      other_customer: other_customer
    } do
      contact_fixture(%{customer: other_customer})

      conn = get(conn, ~p"/api/contacts")
      assert %{"data" => [%{"id" => id}]} = json_response(conn, 200)
      assert id == contact.id
    end
  end

  describe "create" do
    test "creates a contact when data is valid for a customer", %{conn: conn, customer: customer} do
      conn = post(conn, ~p"/api/contacts", %{"contact" => @create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      contact = CopilotApi.Core.Contacts.get_contact!(id)
      assert contact.customer_id == customer.id
      assert contact.name.first_name == "Jane"
    end

    test "does not create contact with invalid data", %{conn: conn} do
      conn = post(conn, ~p"/api/contacts", %{"contact" => @invalid_attrs})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns forbidden for a developer", %{conn: conn} do
      conn = as_developer(conn)
      conn = post(conn, ~p"/api/contacts", %{"contact" => @create_attrs})
      assert json_response(conn, 403)["error"]["message"] == "Only customers can create contacts"
    end
  end

  describe "show" do
    test "shows contact for owner", %{conn: conn, contact: contact} do
      conn = get(conn, ~p"/api/contacts/#{contact}")
      assert json_response(conn, 200)["data"]["id"] == contact.id
    end

    test "shows contact for developer", %{conn: conn, contact: contact} do
      conn = as_developer(conn)
      conn = get(conn, ~p"/api/contacts/#{contact}")
      assert json_response(conn, 200)["data"]["id"] == contact.id
    end

    test "returns forbidden for other customer", %{
      conn: conn,
      contact: contact,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = get(conn, ~p"/api/contacts/#{contact}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end
  end

  describe "update" do
    test "updates contact for owner", %{conn: conn, contact: contact} do
      update_attrs = %{name: %{first_name: "Janet", last_name: contact.name.last_name}}
      conn = put(conn, ~p"/api/contacts/#{contact}", %{"contact" => update_attrs})
      assert json_response(conn, 200)["data"]["name"]["first_name"] == "Janet"
    end

    test "updates contact for developer", %{conn: conn, contact: contact} do
      update_attrs = %{name: %{first_name: "Janet", last_name: contact.name.last_name}}
      conn = as_developer(conn)
      conn = put(conn, ~p"/api/contacts/#{contact}", %{"contact" => update_attrs})
      assert json_response(conn, 200)["data"]["name"]["first_name"] == "Janet"
    end

    test "returns forbidden for other customer", %{
      conn: conn,
      contact: contact,
      other_customer: other_customer
    } do
      update_attrs = %{name: %{first_name: "Janet", last_name: contact.name.last_name}}
      conn = as_customer(conn, other_customer)
      conn = put(conn, ~p"/api/contacts/#{contact}", %{"contact" => update_attrs})

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end

    test "returns 400 when contact params are missing", %{conn: conn, contact: contact} do
      conn = put(conn, ~p"/api/contacts/#{contact}", %{})

      assert json_response(conn, 400)
    end
  end

  describe "delete" do
    test "deletes contact for owner", %{conn: conn, contact: contact} do
      conn = delete(conn, ~p"/api/contacts/#{contact}")
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        CopilotApi.Core.Contacts.get_contact!(contact.id)
      end
    end

    test "deletes contact for developer", %{conn: conn, contact: contact} do
      conn = as_developer(conn)
      conn = delete(conn, ~p"/api/contacts/#{contact}")
      assert response(conn, 204)

      assert_raise Ecto.NoResultsError, fn ->
        CopilotApi.Core.Contacts.get_contact!(contact.id)
      end
    end

    test "returns forbidden for other customer", %{
      conn: conn,
      contact: contact,
      other_customer: other_customer
    } do
      conn = as_customer(conn, other_customer)
      conn = delete(conn, ~p"/api/contacts/#{contact}")

      assert json_response(conn, 403)["error"]["message"] ==
               "You are not authorized to perform this action"
    end
  end
end
