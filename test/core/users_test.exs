defmodule CopilotApi.Core.UsersTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Customers
  alias CopilotApi.Core.Users
  alias CopilotApi.Core.Data.User
  alias CopilotApi.Repo

  @moduletag :users

  describe "users" do
    @valid_attrs %{
      "provider_id" => "test-provider-123",
      "email" => "test@example.com",
      "name" => "Test User"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()

      user
    end

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
      assert user.roles == ["customer", "user"] # Default roles
    end

    test "find_or_create_user/1 finds an existing user" do
      {:ok, existing_user} = Users.create_user(@valid_attrs)

      assert {:ok, %User{} = found_user} = Users.find_or_create_user(@valid_attrs)
      assert found_user.id == existing_user.id
    end

    test "find_or_create_user/1 does not create a customer for a new developer" do
      initial_customer_count = Enum.count(Customers.list_customers())

      developer_attrs = %{
        "provider_id" => "new-dev-456",
        "email" => "new.dev@example.com",
        "name" => "New Developer",
        "roles" => ["developer"]
      }

      assert {:ok, %User{} = user} = Users.find_or_create_user(developer_attrs)
      assert user.roles == ["developer"]
      assert user.customer_id == nil

      assert Enum.count(Customers.list_customers()) == initial_customer_count
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

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user(user.id) == user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "get_user_by/1 returns the user with given clause" do
      user = user_fixture()
      assert Users.get_user_by(email: user.email) == user
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{"name" => "New Name"}

      assert {:ok, %User{} = updated_user} = Users.update_user(user, update_attrs)
      assert updated_user.name == "New Name"
    end

    test "update_user/2 with invalid data returns an error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, %{"email" => "invalid"})
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
