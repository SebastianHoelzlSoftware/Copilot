defmodule CopilotApi.Core.Data.NameTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.Name

  describe "new/1" do
    test "creates a name with all attributes" do
      attrs = %{
        company_name: "ACME Inc.",
        first_name: "John",
        last_name: "Doe"
      }

      assert {:ok, %Name{} = name} = Name.new(attrs)
      assert name.company_name == "ACME Inc."
      assert name.first_name == "John"
      assert name.last_name == "Doe"
    end

    test "creates a name with partial attributes" do
      attrs = %{first_name: "Jane"}
      assert {:ok, %Name{} = name} = Name.new(attrs)
      assert name.first_name == "Jane"
      assert name.last_name == nil
      assert name.company_name == nil
    end

    test "creates a name with an empty map" do
      assert {:ok, %Name{} = name} = Name.new(%{})
      assert name.first_name == nil
      assert name.last_name == nil
      assert name.company_name == nil
    end

    test "returns an error for invalid attribute type" do
      attrs = %{first_name: 123}
      assert {:error, {:invalid_first_name_type, 123}} = Name.new(attrs)
    end

    test "returns an error if attributes are not a map" do
      assert {:error, :invalid_attributes_type} = Name.new("not a map")
    end

    test "filters out unknown attributes" do
      attrs = %{first_name: "John", middle_name: "Danger"}
      assert {:ok, %Name{} = name} = Name.new(attrs)
      assert name.first_name == "John"
      refute Map.has_key?(name, :middle_name)
    end
  end
end
