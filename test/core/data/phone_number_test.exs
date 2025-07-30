defmodule CopilotApi.Core.Data.PhoneNumberTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.PhoneNumber
  import Ecto.Changeset

  describe "changeset/2" do
    test "creates a valid changeset for a valid phone number" do
      attrs = %{number: "+1 (555) 555-5555"}
      changeset = PhoneNumber.changeset(%PhoneNumber{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :number) == "+1 (555) 555-5555"
    end

    test "creates a valid changeset for a simple phone number" do
      attrs = %{number: "5551234567"}
      changeset = PhoneNumber.changeset(%PhoneNumber{}, attrs)
      assert changeset.valid?
    end

    test "returns an error for an invalid phone number format" do
      attrs = %{number: "not-a-number"}
      changeset = PhoneNumber.changeset(%PhoneNumber{}, attrs)

      refute changeset.valid?
      assert %{number: ["is not a valid phone number format"]} = errors_on(changeset)
    end

    test "returns an error for a missing number" do
      attrs = %{}
      changeset = PhoneNumber.changeset(%PhoneNumber{}, attrs)

      refute changeset.valid?
      assert %{number: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns an error for a blank number" do
      attrs = %{number: ""}
      changeset = PhoneNumber.changeset(%PhoneNumber{}, attrs)

      refute changeset.valid?
      assert %{number: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
