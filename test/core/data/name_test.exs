defmodule CopilotApi.Core.Data.NameTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.Name
  import Ecto.Changeset

  describe "changeset/2" do
    test "creates a valid changeset for a person's name" do
      attrs = %{first_name: "John", last_name: "Doe"}
      changeset = Name.changeset(%Name{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :first_name) == "John"
      assert get_field(changeset, :last_name) == "Doe"
    end

    test "creates a valid changeset for a company name" do
      attrs = %{company_name: "ACME Inc."}
      changeset = Name.changeset(%Name{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :company_name) == "ACME Inc."
    end

    test "creates a valid changeset for both person and company name" do
      attrs = %{first_name: "Jane", last_name: "Doe", company_name: "Stark Industries"}
      changeset = Name.changeset(%Name{}, attrs)
      assert changeset.valid?
    end

    test "returns an error for missing name or company" do
      attrs = %{}
      changeset = Name.changeset(%Name{}, attrs)
      refute changeset.valid?

      assert %{base: ["must provide either a company name or a person's full name"]} =
               errors_on(changeset)
    end

    test "returns an error for only a first name" do
      attrs = %{first_name: "John"}
      changeset = Name.changeset(%Name{}, attrs)
      refute changeset.valid?

      assert %{base: ["must provide both first and last name for a person"]} =
               errors_on(changeset)
    end

    test "returns an error for only a last name" do
      attrs = %{last_name: "Doe"}
      changeset = Name.changeset(%Name{}, attrs)
      refute changeset.valid?

      assert %{base: ["must provide both first and last name for a person"]} =
               errors_on(changeset)
    end
  end
end
