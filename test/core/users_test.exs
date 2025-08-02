defmodule CopilotApi.Core.UsersTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Users
  alias CopilotApi.Core.Customers
  alias CopilotApi.Core.Data.User
  alias CopilotApi.Repo

  describe "users" do
    @valid_attrs %{
      "provider_id" => "test-provider-123",
      "email" => "test@example.com",
      "name" => "Test User"
    }

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "test@example.com"
    end

    test "create_user/1 with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(%{"email" => nil})
    end

    test "find_or_create_user/1 creates a user if they don't exist" do
      assert {:ok, %User{} = user} = Users.find_or_create_user(@valid_attrs)
      assert user.provider_id == "test-provider-123"
      assert user.roles == ["user"] # Default role
    end

    test "find_or_create_user/1 finds an existing user" do
      {:ok, existing_user} = Users.create_user(@valid_attrs)

      assert {:ok, %User{} = found_user} = Users.find_or_create_user(@valid_attrs)
      assert found_user.id == existing_user.id
    end

    test "can create a user associated with a customer" do
      # First, create a customer to associate with
      {:ok, customer} = Customers.create_customer(%{name: %{company_name: "Test Corp"}})

      # Now, create a user with the customer's ID
      user_attrs = Map.put(@valid_attrs, "customer_id", customer.id)

      assert {:ok, %User{} = user} = Users.create_user(user_attrs)
      assert user.customer_id == customer.id

      # Verify the association can be preloaded
      preloaded_user = Repo.preload(user, :customer)
      assert preloaded_user.customer.id == customer.id
      assert preloaded_user.customer.name.company_name == "Test Corp"
    end
  end
end
