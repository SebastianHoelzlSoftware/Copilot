defmodule CopilotApi.Core.Data.AIAnalysisTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.AIAnalysis
  alias CopilotApi.Core.Data.CostEstimate
  alias CopilotApi.Core.Data.Customer
  alias CopilotApi.Repo

  defp cost_estimate_fixture do
    customer =
      %Customer{}
      |> Customer.changeset(%{name: %{company_name: "Test Co"}})
      |> Repo.insert!()

    {:ok, cost_estimate} =
      %CostEstimate{}
      |> CostEstimate.changeset(%{
        amount: Decimal.new("1000"),
        currency: "USD",
        customer_id: customer.id
      })
      |> Repo.insert()

    cost_estimate
  end

  describe "changeset/2" do
    test "creates a valid changeset with valid attributes" do
      cost_estimate = cost_estimate_fixture()

      attrs = %{
        suggested_blocks: [
          %{name: "User Auth", description: "Handle user login and registration."}
        ],
        clarifying_questions: [
          %{question: "What is the target audience?"}
        ],
        identified_ambiguities: ["The payment gateway is not specified."],
        cost_estimate_id: cost_estimate.id
      }

      changeset = AIAnalysis.changeset(%AIAnalysis{}, attrs)
      assert changeset.valid?

      # Check nested embeds
      block_changeset = hd(changeset.changes.suggested_blocks)
      assert get_field(block_changeset, :name) == "User Auth"
    end
  end
end
