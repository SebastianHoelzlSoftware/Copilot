defmodule CopilotApi.Core.Data.BuildingBlockTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.BuildingBlock

  describe "new/1" do
    test "creates a building block with valid attributes" do
      attrs = %{name: "User Authentication", description: "OAuth2 integration"}
      assert {:ok, %BuildingBlock{} = block} = BuildingBlock.new(attrs)
      assert block.name == "User Authentication"
      assert block.description == "OAuth2 integration"
    end

    test "returns an error if name is missing" do
      attrs = %{description: "A block without a name"}
      assert {:error, :missing_or_invalid_name} = BuildingBlock.new(attrs)
    end

    test "returns an error if name is not a non-empty string" do
      attrs = %{name: ""}
      assert {:error, :missing_or_invalid_name} = BuildingBlock.new(attrs)

      attrs = %{name: 123}
      assert {:error, :missing_or_invalid_name} = BuildingBlock.new(attrs)
    end
  end
end
