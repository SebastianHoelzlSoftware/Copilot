defmodule CopilotWeb.Plugs.AuthorizeAIAnalysis do
  @moduledoc """
  Authorization plug for the AIAnalysisController.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Copilot.Core.AIAnalyses

  def init(opts), do: opts

  def call(conn, action) do
    %{"id" => analysis_id} = conn.params

    # get_ai_analysis! preloads the project_brief, which we need for the ownership check.
    analysis = AIAnalyses.get_ai_analysis!(analysis_id)

    if authorized?(conn.assigns.current_user, analysis, action) do
      assign(conn, :ai_analysis, analysis)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "You are not authorized to perform this action"}})
      |> halt()
    end
  end

  defp authorized?(user, analysis, :show) do
    is_developer?(user) or is_owner?(user, analysis.project_brief)
  end

  defp authorized?(user, _analysis, action) when action in [:update, :delete] do
    is_developer?(user)
  end

  defp is_owner?(user, project_brief), do: user.customer_id == project_brief.customer_id

  defp is_developer?(user), do: "developer" in user.roles
end
