defmodule CopilotApi.Core.Data.ContactTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.Address
  alias CopilotApi.Core.Data.Contact
  alias CopilotApi.Core.Data.Email
  alias CopilotApi.Core.Data.Name

  defp valid_attrs do
    %{
      name: %{first_name: "John", last_name: "Doe"},
      email: "john.doe@example.com",
      address: %{
        street: "123 Main St",
        city: "Anytown",
        postal_code: "12345",
        country: "USA"
      }
    }
  end

  describe "new/1" do
    test "creates a contact with valid attributes" do
      attrs = valid_attrs()
      assert {:ok, %Contact{} = contact} = Contact.new(attrs)
      assert %Name{first_name: "John"} = contact.name
      assert %Email{address: "john.doe@example.com"} = contact.email
      assert %Address{street: "123 Main St"} = contact.address
    end

    test "returns an error for missing required fields" do
      attrs = %{name: %{}, email: "test@test.com"}
      assert {:error, {:missing_required_fields, [:address]}} = Contact.new(attrs)
    end

    test "returns an error if attributes are not a map" do
      assert {:error, :invalid_attributes_type} = Contact.new("not a map")
    end

    test "propagates errors from nested struct creation" do
      # Invalid email
      attrs = Map.put(valid_attrs(), :email, "invalid-email")
      assert {:error, :invalid_email_format} = Contact.new(attrs)

      # Invalid name
      attrs = Map.put(valid_attrs(), :name, %{first_name: 123})
      assert {:error, {:invalid_first_name_type, 123}} = Contact.new(attrs)

      # Invalid address
      attrs = Map.put(valid_attrs(), :address, %{street: "123"})
      assert {:error, {:missing_required_fields, _}} = Contact.new(attrs)
    end
  end
end
