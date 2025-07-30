defmodule CopilotApi.Core.Data.CustomerTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.Address
  alias CopilotApi.Core.Data.Contact
  alias CopilotApi.Core.Data.Customer
  alias CopilotApi.Core.Data.Name

  defp valid_attrs do
    %{
      id: "cust_12345",
      name: %{company_name: "Test Corp"},
      contact: %{
        name: %{first_name: "Contact", last_name: "Person"},
        email: "contact@testcorp.com",
        address: %{
          street: "456 Corp Ave",
          city: "Businesstown",
          postal_code: "67890",
          country: "USA"
        }
      },
      address: %{
        street: "123 Main St",
        city: "Anytown",
        postal_code: "12345",
        country: "USA"
      }
    }
  end

  describe "new/1" do
    test "creates a customer with valid attributes" do
      attrs = valid_attrs()
      assert {:ok, %Customer{} = customer} = Customer.new(attrs)
      assert customer.id == "cust_12345"
      assert %Name{company_name: "Test Corp"} = customer.name
      assert %Contact{} = customer.contact
      assert %Address{street: "123 Main St"} = customer.address
    end

    test "returns an error for missing required fields" do
      attrs = Map.drop(valid_attrs(), [:contact])
      assert {:error, {:missing_required_fields, [:contact]}} = Customer.new(attrs)
    end

    test "returns an error for an invalid ID" do
      attrs = Map.put(valid_attrs(), :id, "")
      assert {:error, :invalid_id_format} = Customer.new(attrs)

      attrs = Map.put(valid_attrs(), :id, 123)
      assert {:error, :invalid_id_format} = Customer.new(attrs)
    end

    test "returns an error if attributes are not a map" do
      assert {:error, :invalid_attributes_type} = Customer.new("not a map")
    end

    test "propagates errors from nested struct creation" do
      # Invalid contact email
      attrs = put_in(valid_attrs(), [:contact, :email], "bad-email")
      assert {:error, :invalid_email_format} = Customer.new(attrs)

      # Invalid main address
      attrs = update_in(valid_attrs(), [:address], &Map.delete(&1, :city))
      assert {:error, {:missing_required_fields, [:city]}} = Customer.new(attrs)
    end
  end
end
