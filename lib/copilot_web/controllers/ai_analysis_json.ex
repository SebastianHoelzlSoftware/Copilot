defmodule CopilotWeb.AIAnalysisJSON do
  alias Copilot.Core.Data.AIAnalysis

  @doc """
  Renders a list of AI analyses.
  """
  def index(%{analyses: analyses}) do
    %{data: for(analysis <- analyses, do: data(analysis))}
  end

  @doc """
  Renders a single AI analysis.
  """
  def show(%{analysis: analysis}) do
    %{data: data(analysis)}
  end

  defp data(%AIAnalysis{} = analysis) do
    %{
      id: analysis.id,
      summary: analysis.summary,
      suggested_blocks: analysis.suggested_blocks,
      clarifying_questions: analysis.clarifying_questions,
      identified_ambiguities: analysis.identified_ambiguities,
      project_brief_id: analysis.project_brief_id,
      cost_estimate_id: analysis.cost_estimate_id
    }
  end
end
