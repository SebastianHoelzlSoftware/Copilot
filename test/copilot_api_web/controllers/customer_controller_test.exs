defmodule CopilotApiWeb.CustomerControllerTest do
  use CopilotApiWeb.ConnCase, async: true

  alias CopilotApi.Core.Customers
  alias CopilotApi.Core.Users
  alias CopilotApi.Core.Contacts
  alias CopilotApi.Core.Briefs
  import CopilotApi.Core.Fixtures

  # Helper function to create the auth header, mimicking the DevAuth plug.
  defp put_auth_header(conn, user_payload) do
    encoded_user_info = Jason.encode!(user_payload)
    put_req_header(conn, "x-user-info", encoded_user_info)
  end

  @create_attrs %{name: %{company_name: "New Company Inc."}}
  @update_attrs %{name: %{company_name: "Updated Company Inc."}}

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
    customer = customer_fixture()
    {:ok, customer: customer}
  end

  describe "index" do
    test "lists all customers for a developer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> get(~p"/api/customers")

      assert %{"data" => data} = json_response(conn, 200)
      assert Enum.any?(data, &(&1["id"] == customer.id))
    end

    test "is forbidden for a non-developer", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> get(~p"/api/customers")

      assert conn.status == 403
    end
  end

  describe "create" do
    test "creates a customer for a developer", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> post(~p"/api/customers", %{"customer" => @create_attrs})

      assert %{"data" => %{"id" => id}} = json_response(conn, 201)
      customer = Customers.get_customer!(id)
      assert customer.name.company_name == "New Company Inc."
    end

    test "is forbidden for a non-developer", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> post(~p"/api/customers", %{"customer" => @create_attrs})

      assert conn.status == 403
    end

    test "returns 400 when customer params are missing", %{conn: conn} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> post(~p"/api/customers", %{"customer" => %{}})

      assert json_response(conn, 422)
    end
  end

  describe "show" do
    test "shows a customer for a developer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> get(~p"/api/customers/#{customer}")

      assert json_response(conn, 200)["data"]["id"] == customer.id
    end

    test "is forbidden for a non-developer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> get(~p"/api/customers/#{customer}")

      assert conn.status == 403
    end
  end

  describe "update" do
    test "updates a customer for a developer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> put(~p"/api/customers/#{customer}", %{"customer" => @update_attrs})

      assert json_response(conn, 200)["data"]["name"]["company_name"] == "Updated Company Inc."
    end

    test "is forbidden for a non-developer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> put(~p"/api/customers/#{customer}", %{"customer" => @update_attrs})

      assert conn.status == 403
    end

    test "returns 400 when customer params are missing", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> put(~p"/api/customers/#{customer}", %{})

      assert json_response(conn, 400)
    end
  end

  describe "delete" do
    test "deletes a customer and all associated data for a developer", %{
      conn: conn,
      customer: customer
    } do
      # Create associated data to ensure it's deleted via cascading.
      {:ok, user} =
        Users.create_user(%{
          "provider_id" => "user-to-delete-123",
          "email" => "user.to.delete@example.com",
          "name" => "User To Delete",
          "customer_id" => customer.id
        })

      {:ok, contact} =
        Contacts.create_contact(%{
          "customer_id" => customer.id,
          "name" => %{"first_name" => "Contact", "last_name" => "ToDelete"},
          "email" => %{"address" => "contact.to.delete@example.com"}
        })

      {:ok, brief} =
        Briefs.create_project_brief(%{
          "customer_id" => customer.id,
          "title" => "Brief To Delete",
          "summary" => "A summary for the brief to be deleted."
        })

      conn =
        conn
        |> put_auth_header(@developer_payload)
        |> delete(~p"/api/customers/#{customer}")

      assert response(conn, 204)

      # Assert that the customer and all its associated data is gone.
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
      assert_raise Ecto.NoResultsError, fn -> Briefs.get_project_brief!(brief.id) end
    end

    test "is forbidden for a non-developer", %{conn: conn, customer: customer} do
      conn =
        conn
        |> put_auth_header(@customer_payload)
        |> delete(~p"/api/customers/#{customer}")

      assert conn.status == 403
    end
  end
end
