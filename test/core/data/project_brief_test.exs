defmodule CopilotApi.Core.Data.ProjectBriefTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.ProjectBrief
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
        title: "New Website",
        summary: "A brief summary of the project.",
        customer_id: customer.id
      }

      changeset = ProjectBrief.changeset(%ProjectBrief{}, attrs)
      assert changeset.valid?
    end

    test "is invalid without a title" do
      customer = customer_fixture()
      attrs = %{summary: "A brief summary.", customer_id: customer.id}
      changeset = ProjectBrief.changeset(%ProjectBrief{}, attrs)
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "creates a valid changeset with a nested AI analysis" do
      customer = customer_fixture()

      attrs = %{
        title: "New Website",
        summary: "A brief summary.",
        customer_id: customer.id,
        ai_analysis: %{
          suggested_blocks: [%{name: "User Auth"}],
          cost_estimate: %{
            amount: Decimal.new("2500"),
            currency: "EUR",
            # The cost_estimate changeset requires a customer_id.
            # cast_assoc will handle creating this correctly, but we need to provide it.
            customer_id: customer.id
          }
        }
      }

      changeset = ProjectBrief.changeset(%ProjectBrief{}, attrs)
      assert changeset.valid?

      # Check the nested association
      analysis_changeset = get_change(changeset, :ai_analysis)
      assert analysis_changeset.valid?
      cost_estimate_changeset = get_change(analysis_changeset, :cost_estimate)
      assert cost_estimate_changeset.valid?
      assert get_field(cost_estimate_changeset, :amount) == Decimal.new("2500")
    end
  end
end
