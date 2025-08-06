defmodule CopilotWeb.RegistrationControllerTest do
  use CopilotWeb.ConnCase, async: true

  alias Copilot.Core.Users
  alias Copilot.Core.Customers
  alias Copilot.Core.Contacts

  @new_registration_payload %{
    "provider_id" => "new-customer-789",
    "email" => "new.customer@example.com",
    "name" => "New Customer Company",
    "company_name" => "New Customer Company",
    "contact_first_name" => "Jane",
    "contact_last_name" => "Doe",
    "contact_email" => "jane.doe@example.com",
    "contact_phone_number" => "+15557654321"
  }

  @new_developer_registration_payload %{
    "provider_id" => "forbidden-developer-789",
    "email" => "new.developer@example.com",
    "name" => "New Developer Company",
    "roles" => ["developer"],
    "company_name" => "New Developer Company",
    "contact_first_name" => "John",
    "contact_last_name" => "Hacker",
    "contact_email" => "john.hacker@example.com",
    "contact_phone_number" => "+16666666666"
  }

  @invalid_payload %{
    "email" => "invalid-email",
    "name" => "Invalid User"
    # Missing provider_id, which is required
  }

  describe "create" do
    test "creates a new customer user and associated customer and contact record", %{conn: conn} do
      conn = post(conn, ~p"/api/register", %{"registration" => @new_registration_payload})

      response = json_response(conn, 201)
      # IO.inspect(response, label: "REGISTER RESPONSE")
      assert %{"data" => %{"id" => user_id, "customer_id" => customer_id, "contact_id" => contact_id}} = response

      # Verify user was created
      user = Users.get_user!(user_id)
      assert user.email == "new.customer@example.com"
      assert user.name == "New Customer Company"
      assert user.roles == ["customer", "user"]
      assert user.customer_id == customer_id

      # Verify customer was created
      customer = Customers.get_customer!(customer_id)
      assert customer.name.company_name == "New Customer Company"

      # Verify contact was created
      contact = Contacts.get_contact!(contact_id)
      assert contact.customer_id == customer_id
    end



    # test "returns the existing user if they already exist", %{conn: conn} do
    #   # Pre-create the user to simulate a returning user
    #   {:ok, existing_user} = Users.find_or_create_user(@new_user_payload)

    #   conn = post(conn, ~p"/api/register", %{"registration" => @new_registration_payload})

    #   # An idempotent registration endpoint should return 200 OK for an existing user
    #   assert %{"data" => %{"id" => id}} = json_response(conn, 200)
    #   assert id == existing_user.id
    # end

    # test "returns an error if attempting to register a developer user", %{conn: conn} do
    #   conn = post(conn, ~p"/api/register", %{"registration" => @new_developer_registration_payload})
    #   assert json_response(conn, 422)["errors"] != %{}
    # end

    test "returns an error for invalid data", %{conn: conn} do
      conn = post(conn, ~p"/api/register", %{"registration" => @invalid_payload})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
