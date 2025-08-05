defmodule CopilotWeb.RegistrationControllerTest do
  use CopilotWeb.ConnCase, async: true

  alias Copilot.Core.Users
  alias Copilot.Core.Customers

  @new_customer_payload %{
    "provider_id" => "new-customer-789",
    "email" => "new.customer@example.com",
    "name" => "New Customer Company",
    "roles" => ["customer"]
  }

  

  @invalid_payload %{
    "email" => "invalid-email",
    "name" => "Invalid User"
    # Missing provider_id, which is required
  }

  describe "create" do
    test "creates a new customer user and associated customer record", %{conn: conn} do
      conn = post(conn, ~p"/api/register", %{"user" => @new_customer_payload})

      assert %{"data" => %{"id" => user_id, "customer_id" => customer_id}} = json_response(conn, 201)

      # Verify user was created
      user = Users.get_user!(user_id)
      assert user.email == "new.customer@example.com"
      assert user.name == "New Customer Company"
      assert user.roles == ["customer"]
      assert user.customer_id == customer_id

      # Verify customer was created
      customer = Customers.get_customer!(customer_id)
      assert customer.name.company_name == "New Customer Company"
    end

    

    test "returns the existing user if they already exist", %{conn: conn} do
      # Pre-create the user to simulate a returning user
      {:ok, existing_user} = Users.find_or_create_user(@new_customer_payload)

      conn = post(conn, ~p"/api/register", %{"user" => @new_customer_payload})

      # An idempotent registration endpoint should return 200 OK for an existing user
      assert %{"data" => %{"id" => id}} = json_response(conn, 200)
      assert id == existing_user.id
    end

    test "returns an error if attempting to register a developer user", %{conn: conn} do
      developer_payload = %{
        "provider_id" => "dev-register-123",
        "email" => "dev.register@example.com",
        "name" => "Developer User",
        "roles" => ["developer"]
      }

      conn = post(conn, ~p"/api/register", %{"user" => developer_payload})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns an error for invalid data", %{conn: conn} do
      conn = post(conn, ~p"/api/register", %{"user" => @invalid_payload})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
