defmodule CopilotApi.AddressTest do
  use ExUnit.Case, async: true
  alias CopilotApi.Core.Data.Address

  describe "new/1" do
    test "creates an address with valid attributes" do
      attrs = %{
        street: "123 Main St",
        city: "Anytown",
        postal_code: "12345",
        country: "USA",
        street_additional: "Apt 4B"
      }

      assert {:ok, %Address{} = address} = Address.new(attrs)
      assert address.street == "123 Main St"
      assert address.street_additional == "Apt 4B"
      assert address.city == "Anytown"
      assert address.postal_code == "12345"
      assert address.country == "USA"
    end

    test "returns an error for missing required fields" do
      attrs = %{street: "123 Main St", city: "Anytown"}
      expected_missing = [:postal_code, :country]
      assert {:error, {:missing_required_fields, missing}} = Address.new(attrs)
      assert Enum.sort(missing) == Enum.sort(expected_missing)
    end

    test "returns an error if attributes are not a map" do
      assert {:error, :invalid_attributes_type} = Address.new("not a map")
    end

    test "filters out unknown attributes" do
      attrs = %{
        street: "123 Main St",
        city: "Anytown",
        postal_code: "12345",
        country: "USA",
        unknown_field: "should be ignored"
      }

      assert {:ok, %Address{} = address} = Address.new(attrs)
      refute Map.has_key?(address, :unknown_field)
    end
  end

  describe "format/1" do
    test "formats the address correctly with additional info" do
      address = %Address{
        street: "123 Main St",
        street_additional: "Apt 4B",
        city: "Anytown",
        postal_code: "12345",
        country: "USA"
      }

      expected = "123 Main St\nApt 4B\nAnytown\n12345\nUSA"
      assert Address.format(address) == expected
    end

    test "formats the address correctly without additional info" do
      address = %Address{
        street: "123 Main St",
        street_additional: nil,
        city: "Anytown",
        postal_code: "12345",
        country: "USA"
      }

      expected = "123 Main St\nAnytown\n12345\nUSA"
      assert Address.format(address) == expected
    end
  end
end
