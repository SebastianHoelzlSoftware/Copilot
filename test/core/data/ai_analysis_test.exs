defmodule CopilotApi.Core.Data.AIAnalysisTest do
  use CopilotApi.DataCase, async: true

  alias CopilotApi.Core.Data.AIAnalysis
  alias CopilotApi.Core.Data.ProjectBrief
  alias CopilotApi.Core.Data.Customer
  alias CopilotApi.Repo

  defp project_brief_fixture do
    customer =
      %Customer{}
      |> Customer.changeset(%{name: %{company_name: "Test Co"}})
      |> Repo.insert!()

    %ProjectBrief{}
    |> ProjectBrief.changeset(%{
      title: "Test Brief",
      summary: "A test project brief.",
      customer_id: customer.id
    })
    |> Repo.insert!()
  end

  describe "changeset/2" do
    test "creates a valid changeset with valid attributes" do
      project_brief = project_brief_fixture()

      attrs = %{
        summary: "some summary",
        suggested_blocks: [
          %{name: "User Auth", description: "Handle user login and registration."}
        ],
        clarifying_questions: [
          %{question: "What is the target audience?"}
        ],
        identified_ambiguities: ["The payment gateway is not specified."],
        project_brief_id: project_brief.id
      }

      changeset = AIAnalysis.changeset(%AIAnalysis{}, attrs)
      assert changeset.valid?

      # Check nested embeds
      block_changeset = hd(changeset.changes.suggested_blocks)
      assert get_field(block_changeset, :name) == "User Auth"
    end
  end
end
