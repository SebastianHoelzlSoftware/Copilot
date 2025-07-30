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

    test "creates a name with only first_name and last_name" do
      attrs = %{first_name: "Jane", last_name: "Doe"}
      assert {:ok, %Name{} = name} = Name.new(attrs)
      assert name.first_name == "Jane"
      assert name.last_name == "Doe"
      assert name.company_name == nil
    end

    test "creates a name with only company_name" do
      attrs = %{company_name: "ACME Inc."}
      assert {:ok, %Name{} = name} = Name.new(attrs)
      assert name.first_name == nil
      assert name.last_name == nil
      assert name.company_name == "ACME Inc."
    end

    test "creates a name with an empty map" do
      assert {:error, :missing_name_or_company} = Name.new(%{})
    end

    test "returns an error if only first_name is provided" do
      attrs = %{first_name: "John"}
      assert {:error, :missing_name_or_company} = Name.new(attrs)
    end

    test "returns an error if only last_name is provided" do
      attrs = %{last_name: "Doe"}
      assert {:error, :missing_name_or_company} = Name.new(attrs)
    end

    test "returns an error for invalid attribute type" do
      attrs = %{first_name: 123}
      assert {:error, {:invalid_first_name_type, 123}} = Name.new(attrs)
    end

    test "returns an error if attributes are not a map" do
      assert {:error, :invalid_attributes_type} = Name.new("not a map")
    end

    test "filters out unknown attributes" do
      attrs = %{first_name: "John", last_name: "Doe", middle_name: "Danger"}
      assert {:ok, %Name{} = name} = Name.new(attrs)
      assert name.first_name == "John"
      refute Map.has_key?(name, :middle_name)
    end
  end
end
