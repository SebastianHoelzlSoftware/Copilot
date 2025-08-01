defmodule CopilotApi.Core.CustomersTest do
  use CopilotApi.DataCase

  alias CopilotApi.Core.Customers
  alias CopilotApi.Core.Data.Customer

  import CopilotApi.Core.Fixtures

  @invalid_attrs %{name: nil}

  describe "list_customers/0" do
    test "returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end
  end

  describe "get_customer!/1" do
    test "returns the customer with given id" do
      customer = customer_fixture()
      fetched_customer = Customers.get_customer!(customer.id)

      assert fetched_customer.id == customer.id
      assert fetched_customer.contacts == []
    end

    test "raises if the Customer does not exist" do
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(Ecto.UUID.generate()) end
    end
  end

  describe "create_customer/1" do
    test "with valid data creates a customer" do
      valid_attrs = %{
        name: %{company_name: "some company"}
      }

      assert {:ok, %Customer{} = customer} = Customers.create_customer(valid_attrs)
      assert customer.name.company_name == "some company"
    end

    test "with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end
  end

  describe "update_customer/2" do
    test "with valid data updates the customer" do
      customer = customer_fixture()
      update_attrs = %{name: %{company_name: "new company"}}

      assert {:ok, %Customer{} = updated_customer} =
               Customers.update_customer(customer, update_attrs)

      assert updated_customer.name.company_name == "new company"
    end

    test "with invalid data returns an error changeset" do
      customer = customer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Customers.update_customer(customer, @invalid_attrs)

      assert Customers.get_customer!(customer.id).name.company_name ==
               customer.name.company_name
    end
  end

  describe "delete_customer/1" do
    test "deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Customers.get_customer!(customer.id) end
    end
  end
end
