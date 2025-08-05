defmodule Copilot.Core.Data.BuildingBlockTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Data.BuildingBlock

  describe "changeset/2" do
    test "creates a valid changeset with valid attributes" do
      attrs = %{name: "User Authentication", description: "Handles user login and registration."}
      changeset = BuildingBlock.changeset(%BuildingBlock{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :name) == "User Authentication"
      assert get_field(changeset, :description) == "Handles user login and registration."
    end

    test "creates a valid changeset without optional description" do
      attrs = %{name: "User Authentication"}
      changeset = BuildingBlock.changeset(%BuildingBlock{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :description) == nil
    end

    test "is invalid if name is missing" do
      attrs = %{description: "A description without a name"}
      changeset = BuildingBlock.changeset(%BuildingBlock{}, attrs)

      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "is invalid if name is a blank string" do
      attrs = %{name: ""}
      changeset = BuildingBlock.changeset(%BuildingBlock{}, attrs)
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
