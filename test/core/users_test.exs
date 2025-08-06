defmodule Copilot.Core.UsersTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Customers
  alias Copilot.Core.Users
  alias Copilot.Core.Data.User
  alias Copilot.Core.Data.Customer
  alias Copilot.Core.Data.Contact
  alias Copilot.Repo

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

    test "create_user/1 with no arguments returns an error changeset" do
      # This test covers the default argument path of create_user/1
      assert {:error, %Ecto.Changeset{}} = Users.create_user()
    end

    test "find_or_create_user/1 creates a user if they don't exist" do
      # Temporarily set the log level to :info to ensure the logger metadata is
      # evaluated for full test coverage. We restore the original level on exit.
      original_level = Logger.level()
      Logger.configure(level: :info)
      on_exit(fn -> Logger.configure(level: original_level) end)

      assert {:ok, %User{} = user} = Users.find_or_create_user(@valid_attrs)
      assert user.provider_id == "test-provider-123"
      # Default roles
      assert user.roles == ["customer", "user"]
    end

    test "find_or_create_user/1 finds an existing user" do
      {:ok, existing_user} = Users.create_user(@valid_attrs)

      assert {:ok, %User{} = found_user} = Users.find_or_create_user(@valid_attrs)
      assert found_user.id == existing_user.id
    end

    test "find_or_create_user/1 does not create a customer for a new developer" do
      # Temporarily set the log level to :info to ensure the logger metadata is
      # evaluated for full test coverage. We restore the original level on exit.
      original_level = Logger.level()
      Logger.configure(level: :info)
      on_exit(fn -> Logger.configure(level: original_level) end)

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

    test "find_or_create_user/1 with no provider_id returns an error changeset" do
      attrs_without_provider = %{
        "email" => "no.provider@example.com",
        "name" => "No Provider"
      }

      # This covers the `else` branch where provider_id is nil
      assert {:error, %Ecto.Changeset{}} = Users.find_or_create_user(attrs_without_provider)
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

    test "change_user/2 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  describe "register_user/1" do
    @valid_registration_attrs %{
      "provider_id" => "reg-provider-123",
      "email" => "register@example.com",
      "name" => "Register User",
      "company_name" => "Registered Inc.",
      "contact_first_name" => "Regi",
      "contact_last_name" => "Ster",
      "contact_email" => "regi.ster@example.com",
      "contact_phone_number" => "123-456-7890"
    }

    test "with valid data for a new user, creates user, customer, and contact" do
      assert {:ok, {:created, %User{} = user, customer, contact}} =
               Users.register_user(@valid_registration_attrs)

      assert user.email == "register@example.com"
      assert customer.name.company_name == "Registered Inc."
      assert contact.name.first_name == "Regi"
      assert contact.customer_id == customer.id
      assert user.customer_id == customer.id
      assert contact.email.address == "regi.ster@example.com"
      assert contact.phone_number.number == "123-456-7890"
    end

    test "with invalid data for a new user, returns an error and rolls back" do
      invalid_attrs = Map.put(@valid_registration_attrs, "email", "invalid-email")

      assert {:error, %Ecto.Changeset{valid?: false}} = Users.register_user(invalid_attrs)

      # Assert that nothing was created due to transaction rollback
      assert Repo.all(User) == []
      assert Repo.all(Customer) == []
      assert Repo.all(Contact) == []
    end

    test "with an existing user, finds and returns the user, customer, and contact" do
      # First, register the user
      {:ok, {:created, user, customer, contact}} = Users.register_user(@valid_registration_attrs)

      # Now, call register_user again with the same provider_id
      assert {:ok, {:found, found_user, found_customer, found_contact}} =
               Users.register_user(@valid_registration_attrs)

      assert found_user.id == user.id
      assert found_customer.id == customer.id
      assert found_contact.id == contact.id
    end

    test "without a provider_id, returns an error changeset" do
      attrs_without_provider = Map.delete(@valid_registration_attrs, "provider_id")
      assert {:error, %Ecto.Changeset{}} = Users.register_user(attrs_without_provider)
    end

    test "with an existing user but missing customer, returns an error" do
      # Setup: create a user and customer, then delete the customer
      {:ok, customer} = Customers.create_customer(%{name: %{company_name: "Temp Corp"}})
      user_attrs = Map.merge(@valid_attrs, %{"customer_id" => customer.id})
      {:ok, user} = Users.create_user(user_attrs)
      Repo.delete!(customer)

      registration_attrs = %{"provider_id" => user.provider_id}
      assert {:error, %Ecto.Changeset{data: %Customer{}}} = Users.register_user(registration_attrs)
    end

    test "with an existing user and customer but no contacts, returns an error" do
      # Setup: create a user and customer, but no contact
      {:ok, customer} = Customers.create_customer(%{name: %{company_name: "No Contact Corp"}})
      user_attrs = Map.merge(@valid_attrs, %{"customer_id" => customer.id})
      {:ok, user} = Users.create_user(user_attrs)

      registration_attrs = %{"provider_id" => user.provider_id}
      assert {:error, %Ecto.Changeset{data: %Contact{}}} = Users.register_user(registration_attrs)
    end
  end
end
