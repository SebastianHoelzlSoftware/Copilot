defmodule CopilotApi.Core.Data.EmailTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.Email
  import Ecto.Changeset

  describe "changeset/2" do
    test "creates a valid changeset for a valid email" do
      attrs = %{address: "test@example.com"}
      changeset = Email.changeset(%Email{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :address) == "test@example.com"
    end

    test "returns an error for an invalid email format" do
      attrs = %{address: "invalid-email"}
      changeset = Email.changeset(%Email{}, attrs)

      refute changeset.valid?
      assert %{address: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "returns an error for a missing address" do
      attrs = %{}
      changeset = Email.changeset(%Email{}, attrs)

      refute changeset.valid?
      assert %{address: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns an error for a blank address" do
      attrs = %{address: ""}
      changeset = Email.changeset(%Email{}, attrs)

      refute changeset.valid?
      assert %{address: ["can't be blank"]} = errors_on(changeset)
    end
  end

  describe "to_string/1" do
    test "returns the address string" do
      email = %Email{address: "test@example.com"}
      assert Email.to_string(email) == "test@example.com"
    end
  end
end
