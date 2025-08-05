defmodule Copilot.Core.Data.ClarifyingQuestionTest do
  use Copilot.DataCase, async: true

  alias Copilot.Core.Data.ClarifyingQuestion

  describe "changeset/2" do
    test "creates a valid changeset with valid attributes" do
      attrs = %{question: "What is the primary goal?", answer_type: "multiple_choice"}
      changeset = ClarifyingQuestion.changeset(%ClarifyingQuestion{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :question) == "What is the primary goal?"
      assert get_field(changeset, :answer_type) == "multiple_choice"
    end

    test "creates a valid changeset with default answer_type" do
      attrs = %{question: "What is the primary goal?"}
      changeset = ClarifyingQuestion.changeset(%ClarifyingQuestion{}, attrs)

      assert changeset.valid?
      assert get_field(changeset, :answer_type) == "text"
    end

    test "is invalid if question is missing" do
      attrs = %{answer_type: "text"}
      changeset = ClarifyingQuestion.changeset(%ClarifyingQuestion{}, attrs)

      refute changeset.valid?
      assert %{question: ["can't be blank"]} = errors_on(changeset)
    end

    test "is invalid if question is a blank string" do
      attrs = %{question: ""}
      changeset = ClarifyingQuestion.changeset(%ClarifyingQuestion{}, attrs)
      refute changeset.valid?
      assert %{question: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
