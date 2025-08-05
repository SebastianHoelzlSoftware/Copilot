defmodule Copilot.Core.Data.AddressTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Data.Address
  import Ecto.Changeset

  describe "changeset/2" do
    test "creates a valid changeset with all attributes" do
      attrs = %{
        street: "123 Main St",
        city: "Anytown",
        postal_code: "12345",
        country: "USA",
        street_additional: "Apt 4B"
      }

      changeset = Address.changeset(%Address{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :street) == "123 Main St"
      assert get_field(changeset, :street_additional) == "Apt 4B"
    end

    test "returns an error for missing required fields" do
      attrs = %{street: "123 Main St", city: "Anytown"}
      changeset = Address.changeset(%Address{}, attrs)
      refute changeset.valid?
      assert Enum.sort(Map.keys(errors_on(changeset))) == [:country, :postal_code]
    end

    test "filters out unknown attributes" do
      attrs = %{
        street: "123 Main St",
        city: "Anytown",
        postal_code: "12345",
        country: "USA",
        unknown_field: "should be ignored"
      }

      changeset = Address.changeset(%Address{}, attrs)
      assert changeset.valid?
      # Ecto.Changeset.cast/3 filters out unknown fields, so we just need to check
      # that the changeset is valid and doesn't contain an error for the unknown field.
      refute Map.has_key?(changeset.changes, :unknown_field)
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
