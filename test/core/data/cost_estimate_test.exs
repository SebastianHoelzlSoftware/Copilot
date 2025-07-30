defmodule CopilotApi.Core.Data.CostEstimateTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.CostEstimate
  alias CopilotApi.Core.Data.Customer
  alias CopilotApi.Repo

  defp customer_fixture do
    {:ok, customer} =
      %Customer{}
      |> Customer.changeset(%{name: %{company_name: "Test Co"}})
      |> Repo.insert()

    customer
  end

  describe "changeset/2" do
    test "creates a valid changeset with valid attributes" do
      customer = customer_fixture()

      attrs = %{
        amount: Decimal.new("1500.50"),
        currency: "USD",
        details: "Initial estimate",
        customer_id: customer.id
      }

      changeset = CostEstimate.changeset(%CostEstimate{}, attrs)
      assert changeset.valid?
    end

    test "creates a valid changeset without optional details" do
      customer = customer_fixture()
      attrs = %{amount: Decimal.new("200.50"), currency: "EUR", customer_id: customer.id}
      changeset = CostEstimate.changeset(%CostEstimate{}, attrs)
      assert changeset.valid?
      assert get_field(changeset, :details) == nil
    end

    test "is invalid for missing required fields" do
      customer = customer_fixture()
      attrs = %{amount: Decimal.new("100"), customer_id: customer.id}
      changeset = CostEstimate.changeset(%CostEstimate{}, attrs)
      refute changeset.valid?
      assert %{currency: ["can't be blank"]} = errors_on(changeset)
    end

    test "is invalid for non-numeric amount" do
      customer = customer_fixture()
      attrs = %{amount: "not a number", currency: "USD", customer_id: customer.id}
      changeset = CostEstimate.changeset(%CostEstimate{}, attrs)
      refute changeset.valid?
      assert %{amount: ["is invalid"]} = errors_on(changeset)
    end

    test "is invalid for missing customer" do
      attrs = %{amount: Decimal.new("100"), currency: "USD"}
      changeset = CostEstimate.changeset(%CostEstimate{}, attrs)
      refute changeset.valid?
      assert %{customer_id: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
