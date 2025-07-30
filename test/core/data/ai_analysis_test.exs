defmodule CopilotApi.Core.Data.AIAnalysisTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.AIAnalysis

  defp valid_attrs do
    %{
      suggested_blocks: [%{name: "User Auth", description: "Handles login"}],
      clarifying_questions: [%{question: "What is the target audience?"}],
      cost_estimate: %{amount: 5000, currency: "USD"},
      identified_ambiguities: ["The payment flow is not detailed."]
    }
  end

  describe "new/1" do
    test "creates an AI analysis with all attributes" do
      assert {:ok, %AIAnalysis{} = analysis} = AIAnalysis.new(valid_attrs())
      assert length(analysis.suggested_blocks) == 1
      assert length(analysis.clarifying_questions) == 1
      assert analysis.cost_estimate.amount == 5000
      assert analysis.identified_ambiguities == ["The payment flow is not detailed."]
    end

    test "creates with an empty map, using defaults" do
      assert {:ok, %AIAnalysis{} = analysis} = AIAnalysis.new(%{})
      assert analysis.suggested_blocks == []
      assert analysis.clarifying_questions == []
      assert analysis.cost_estimate == nil
      assert analysis.identified_ambiguities == []
    end

    test "propagates errors from nested structs" do
      # Invalid cost estimate
      attrs = Map.put(valid_attrs(), :cost_estimate, %{amount: "invalid", currency: "USD"})
      assert {:error, :invalid_amount} = AIAnalysis.new(attrs)

      # Invalid building block
      attrs = Map.put(valid_attrs(), :suggested_blocks, [%{description: "missing name"}])
      assert {:error, :missing_or_invalid_name} = AIAnalysis.new(attrs)
    end
  end
end
