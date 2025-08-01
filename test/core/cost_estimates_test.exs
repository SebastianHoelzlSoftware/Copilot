defmodule CopilotApi.Core.CostEstimatesTest do
  use CopilotApi.DataCase

  alias CopilotApi.Core.CostEstimates
  alias CopilotApi.Core.Data.CostEstimate

  import CopilotApi.Core.Fixtures

  @invalid_attrs %{amount: nil}

  describe "list_cost_estimates/0" do
    test "returns all cost_estimates" do
      cost_estimate = cost_estimate_fixture()
      assert CostEstimates.list_cost_estimates() == [cost_estimate]
    end
  end

  describe "get_cost_estimate!/1" do
    test "returns the cost_estimate with given id" do
      cost_estimate = cost_estimate_fixture()
      fetched_estimate = CostEstimates.get_cost_estimate!(cost_estimate.id)

      assert fetched_estimate.id == cost_estimate.id
      assert fetched_estimate.customer
      assert fetched_estimate.ai_analysis == nil
    end

    test "raises if the Cost estimate does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        CostEstimates.get_cost_estimate!(Ecto.UUID.generate())
      end
    end
  end

  describe "create_cost_estimate/1" do
    test "with valid data creates a cost_estimate" do
      customer = customer_fixture()

      valid_attrs = %{
        amount: "500.00",
        currency: "EUR",
        customer_id: customer.id
      }

      assert {:ok, %CostEstimate{} = cost_estimate} =
               CostEstimates.create_cost_estimate(valid_attrs)

      assert cost_estimate.amount == Decimal.new("500.00")
      assert cost_estimate.currency == "EUR"
      assert cost_estimate.customer_id == customer.id
    end

    test "with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = CostEstimates.create_cost_estimate(@invalid_attrs)
    end
  end

  describe "update_cost_estimate/2" do
    test "with valid data updates the cost_estimate" do
      cost_estimate = cost_estimate_fixture()
      update_attrs = %{amount: "999.99"}

      assert {:ok, %CostEstimate{} = updated_estimate} =
               CostEstimates.update_cost_estimate(cost_estimate, update_attrs)

      assert updated_estimate.amount == Decimal.new("999.99")
    end

    test "with invalid data returns an error changeset" do
      cost_estimate = cost_estimate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CostEstimates.update_cost_estimate(cost_estimate, @invalid_attrs)

      assert CostEstimates.get_cost_estimate!(cost_estimate.id).amount == cost_estimate.amount
    end
  end

  describe "delete_cost_estimate/1" do
    test "deletes the cost_estimate" do
      cost_estimate = cost_estimate_fixture()
      assert {:ok, %CostEstimate{}} = CostEstimates.delete_cost_estimate(cost_estimate)

      assert_raise Ecto.NoResultsError, fn ->
        CostEstimates.get_cost_estimate!(cost_estimate.id)
      end
    end
  end
end
