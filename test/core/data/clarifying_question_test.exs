defmodule CopilotApi.Core.Data.ClarifyingQuestionTest do
  use ExUnit.Case, async: true

  alias CopilotApi.Core.Data.ClarifyingQuestion

  describe "new/1" do
    test "creates a question with valid attributes" do
      attrs = %{question: "What is the primary goal?", answer: "To increase user engagement."}
      assert {:ok, %ClarifyingQuestion{} = q} = ClarifyingQuestion.new(attrs)
      assert q.question == "What is the primary goal?"
      assert q.answer == "To increase user engagement."
    end

    test "returns an error if question is missing" do
      attrs = %{answer: "An answer without a question"}
      assert {:error, :missing_or_invalid_question} = ClarifyingQuestion.new(attrs)
    end

    test "returns an error if question is not a non-empty string" do
      attrs = %{question: ""}
      assert {:error, :missing_or_invalid_question} = ClarifyingQuestion.new(attrs)

      attrs = %{question: 123}
      assert {:error, :missing_or_invalid_question} = ClarifyingQuestion.new(attrs)
    end
  end
end
