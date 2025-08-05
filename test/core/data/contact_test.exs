defmodule Copilot.Core.Data.ContactTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Data.Contact

  describe "changeset/2" do
    test "creates a valid changeset with valid nested attributes" do
      attrs = %{
        customer_id: Ecto.UUID.generate(),
        name: %{first_name: "John", last_name: "Doe"},
        email: %{address: "john.doe@example.com"},
        address: %{
          street: "123 Main St",
          city: "Anytown",
          postal_code: "12345",
          country: "USA"
        },
        phone_number: %{number: "555-555-5555"}
      }

      changeset = Contact.changeset(%Contact{}, attrs)
      assert changeset.valid?

      name_changeset = changeset.changes.name
      assert name_changeset.valid?
      assert get_field(name_changeset, :first_name) == "John"
    end

    test "is invalid if a required embedded schema is missing" do
      attrs = %{
        name: %{first_name: "John", last_name: "Doe"}
        # Missing customer_id and email
      }

      changeset = Contact.changeset(%Contact{}, attrs)
      refute changeset.valid?
      errors = errors_on(changeset)
      assert errors.email == ["can't be blank"]
      assert errors.customer_id == ["can't be blank"]
    end

    test "is invalid if a nested changeset is invalid" do
      attrs = %{
        # Invalid: missing last name
        name: %{first_name: "John"},
        email: %{address: "john.doe@example.com"}
      }

      changeset = Contact.changeset(%Contact{}, attrs)
      refute changeset.valid?

      # Check for the specific nested error
      name_changeset = changeset.changes.name
      refute name_changeset.valid?

      assert %{base: ["must provide both first and last name for a person"]} =
               errors_on(name_changeset)
    end
  end
end
