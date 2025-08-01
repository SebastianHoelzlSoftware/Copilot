defmodule CopilotApiWeb.BriefJSON do
  alias CopilotApi.Core.Data.ProjectBrief

  @doc """
  Renders a list of briefs.
  """
  def index(%{briefs: briefs}) do
    %{data: for(brief <- briefs, do: data(brief))}
  end

  @doc """
  Renders a single brief.
  """
  def show(%{brief: brief}) do
    %{data: data(brief)}
  end

  defp data(%ProjectBrief{} = brief) do
    %{
      id: brief.id,
      title: brief.title,
      summary: brief.summary,
      status: brief.status,
      customer: customer_data(brief.customer),
      ai_analysis: ai_analysis_data(brief.ai_analysis)
    }
  end

  defp customer_data(nil), do: nil
  defp customer_data(%Ecto.Association.NotLoaded{}), do: nil

  defp customer_data(customer) do
    %{
      id: customer.id,
      name: customer.name.company_name || "#{customer.name.first_name} #{customer.name.last_name}"
    }
  end

  defp ai_analysis_data(nil), do: nil
  defp ai_analysis_data(%Ecto.Association.NotLoaded{}), do: nil

  defp ai_analysis_data(ai_analysis) do
    %{id: ai_analysis.id, summary: ai_analysis.summary}
  end
end
