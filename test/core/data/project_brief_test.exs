defmodule CopilotApi.Core.Data.ProjectBriefTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.ProjectBrief

  defp valid_attrs do
    %{
      id: "brief_123",
      customer_id: "cust_456",
      title: "New Website",
      summary: "A brief summary of the project."
    }
  end

  describe "new/1" do
    test "creates a project brief with valid attributes" do
      assert {:ok, %ProjectBrief{} = brief} = ProjectBrief.new(valid_attrs())
      assert brief.id == "brief_123"
      assert brief.customer_id == "cust_456"
      assert brief.title == "New Website"
      assert brief.summary == "A brief summary of the project."
      assert brief.status == :new
      assert brief.ai_analysis == nil
    end

    test "returns an error for missing required fields" do
      attrs = Map.drop(valid_attrs(), [:title])
      assert {:error, {:missing_required_fields, [:title]}} = ProjectBrief.new(attrs)
    end

    test "returns an error for invalid id" do
      attrs = Map.put(valid_attrs(), :id, "")
      assert {:error, :invalid_id_format} = ProjectBrief.new(attrs)
    end

    test "can be created with an AI analysis" do
      ai_attrs = %{
        cost_estimate: %{amount: 1000, currency: "USD"},
        suggested_blocks: [%{name: "Auth"}],
        clarifying_questions: [%{question: "What is the deadline?"}],
        identified_ambiguities: ["Unclear scope"]
      }

      attrs = Map.put(valid_attrs(), :ai_analysis, ai_attrs)

      assert {:ok, %ProjectBrief{ai_analysis: %CopilotApi.Core.Data.AIAnalysis{}} = brief} =
               ProjectBrief.new(attrs)

      assert brief.ai_analysis.cost_estimate.amount == 1000
    end
  end
end
