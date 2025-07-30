defmodule CopilotApi.Core.Data.CustomerTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.Customer

  describe "changeset/2" do
    test "creates a valid changeset with valid nested attributes" do
      attrs = %{
        name: %{company_name: "Stark Industries"},
        address: %{
          street: "10880 Malibu Point",
          city: "Malibu",
          postal_code: "90265",
          country: "USA"
        }
      }

      changeset = Customer.changeset(%Customer{}, attrs)
      assert changeset.valid?

      name_changeset = changeset.changes.name
      assert name_changeset.valid?
      assert get_field(name_changeset, :company_name) == "Stark Industries"
    end

    test "is invalid if required name is missing" do
      attrs = %{
        address: %{
          street: "10880 Malibu Point",
          city: "Malibu",
          postal_code: "90265",
          country: "USA"
        }
      }

      changeset = Customer.changeset(%Customer{}, attrs)
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "is invalid if a nested changeset is invalid" do
      attrs = %{
        name: %{company_name: "Stark Industries"},
        address: %{street: "10880 Malibu Point"} # Invalid: missing city, postal_code, country
      }

      changeset = Customer.changeset(%Customer{}, attrs)
      refute changeset.valid?

      address_changeset = changeset.changes.address
      refute address_changeset.valid?
      assert Keyword.has_key?(address_changeset.errors, :city)
      assert Keyword.has_key?(address_changeset.errors, :postal_code)
      assert Keyword.has_key?(address_changeset.errors, :country)
    end
  end
end
