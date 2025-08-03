defmodule CopilotApi.Core.CostEstimatesTest do
  use CopilotApi.DataCase

  alias CopilotApi.Core.CostEstimates
  alias CopilotApi.Core.AIAnalyses
  alias CopilotApi.Core.Data.CostEstimate

  import CopilotApi.Core.Fixtures

  @invalid_attrs %{amount: nil}

  describe "list_cost_estimates/0" do
    test "returns all cost_estimates" do
      cost_estimate = cost_estimate_fixture()
      [fetched_estimate] = CostEstimates.list_cost_estimates()

      assert fetched_estimate.id == cost_estimate.id
      assert fetched_estimate.customer
    end
  end

  describe "get_cost_estimate!/1" do
    test "returns the cost_estimate with given id" do
      customer = customer_fixture()
      project_brief = project_brief_fixture(%{customer: customer})
      cost_estimate = cost_estimate_fixture(%{customer: customer})

      {:ok, ai_analysis} =
        AIAnalyses.create_ai_analysis(%{
          summary: "test analysis",
          project_brief_id: project_brief.id,
          cost_estimate_id: cost_estimate.id
        })

      fetched_estimate = CostEstimates.get_cost_estimate!(cost_estimate.id)

      assert fetched_estimate.id == cost_estimate.id
      assert fetched_estimate.customer
      assert fetched_estimate.ai_analysis.id == ai_analysis.id
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

    test "with no arguments returns an error changeset" do
      # This test covers the default argument path of create_cost_estimate/1
      assert {:error, %Ecto.Changeset{}} = CostEstimates.create_cost_estimate()
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

  describe "change_cost_estimate/2" do
    test "returns a cost_estimate changeset" do
      cost_estimate = cost_estimate_fixture()
      assert %Ecto.Changeset{} = CostEstimates.change_cost_estimate(cost_estimate)
    end
  end
end
