defmodule CopilotApi.Core.AIAnalysesTest do
  use CopilotApi.DataCase

  alias CopilotApi.Core.AIAnalyses
  alias CopilotApi.Core.Data.AIAnalysis

  import CopilotApi.Core.Fixtures

  @invalid_attrs %{project_brief_id: nil}

  describe "list_ai_analyses/0" do
    test "returns all ai_analyses" do
      ai_analysis = ai_analysis_fixture()
      assert AIAnalyses.list_ai_analyses() == [ai_analysis]
    end
  end

  describe "get_ai_analysis!/1" do
    test "returns the ai_analysis with given id" do
      ai_analysis = ai_analysis_fixture()
      fetched_analysis = AIAnalyses.get_ai_analysis!(ai_analysis.id)

      assert fetched_analysis.id == ai_analysis.id
      assert fetched_analysis.project_brief
      assert fetched_analysis.cost_estimate == nil
    end

    test "raises if the AI analysis does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        AIAnalyses.get_ai_analysis!(Ecto.UUID.generate())
      end
    end
  end

  describe "create_ai_analysis/1" do
    test "with valid data creates an ai_analysis" do
      project_brief = project_brief_fixture()
      cost_estimate = cost_estimate_fixture(%{customer: project_brief.customer})

      valid_attrs = %{
        summary: "some summary",
        project_brief_id: project_brief.id,
        cost_estimate_id: cost_estimate.id
      }

      assert {:ok, %AIAnalysis{} = ai_analysis} = AIAnalyses.create_ai_analysis(valid_attrs)
      assert ai_analysis.summary == "some summary"
      assert ai_analysis.project_brief_id == project_brief.id
      assert ai_analysis.cost_estimate_id == cost_estimate.id
    end

    test "with invalid data returns an error changeset" do
      assert {:error, %Ecto.Changeset{}} = AIAnalyses.create_ai_analysis(@invalid_attrs)
    end
  end

  describe "update_ai_analysis/2" do
    test "with valid data updates the ai_analysis" do
      ai_analysis = ai_analysis_fixture()
      update_attrs = %{summary: "new summary"}

      assert {:ok, %AIAnalysis{} = updated_analysis} =
               AIAnalyses.update_ai_analysis(ai_analysis, update_attrs)

      assert updated_analysis.summary == "new summary"
    end

    test "with invalid data returns an error changeset" do
      ai_analysis = ai_analysis_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AIAnalyses.update_ai_analysis(ai_analysis, @invalid_attrs)

      assert AIAnalyses.get_ai_analysis!(ai_analysis.id).summary == ai_analysis.summary
    end
  end

  describe "delete_ai_analysis/1" do
    test "deletes the ai_analysis" do
      ai_analysis = ai_analysis_fixture()
      assert {:ok, %AIAnalysis{}} = AIAnalyses.delete_ai_analysis(ai_analysis)
      assert_raise Ecto.NoResultsError, fn -> AIAnalyses.get_ai_analysis!(ai_analysis.id) end
    end
  end
end
