defmodule CopilotApi.Core.Data.CostEstimateTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.CostEstimate

  describe "new/1" do
    test "creates a cost estimate with valid attributes" do
      attrs = %{amount: 1500, currency: "USD", details: "Initial estimate"}
      assert {:ok, %CostEstimate{} = estimate} = CostEstimate.new(attrs)
      assert estimate.amount == 1500
      assert estimate.currency == "USD"
      assert estimate.details == "Initial estimate"
    end

    test "creates a cost estimate without optional details" do
      attrs = %{amount: 200.50, currency: "EUR"}
      assert {:ok, %CostEstimate{} = estimate} = CostEstimate.new(attrs)
      assert estimate.amount == 200.50
      assert estimate.currency == "EUR"
      assert estimate.details == nil
    end

    test "returns an error for missing required fields" do
      attrs = %{amount: 100}
      assert {:error, {:missing_required_fields, [:currency]}} = CostEstimate.new(attrs)
    end

    test "returns an error for invalid amount" do
      attrs = %{amount: "not a number", currency: "USD"}
      assert {:error, :invalid_amount} = CostEstimate.new(attrs)
    end

    test "returns an error for invalid currency" do
      attrs = %{amount: 100, currency: ""}
      assert {:error, :invalid_currency} = CostEstimate.new(attrs)

      attrs = %{amount: 100, currency: 123}
      assert {:error, :invalid_currency} = CostEstimate.new(attrs)
    end

    test "returns an error if attributes are not a map" do
      assert {:error, :invalid_attributes_type} = CostEstimate.new("not a map")
    end
  end
end
