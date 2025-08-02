defmodule CopilotApiWeb.AIAnalysisController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.AIAnalyses
  alias CopilotApi.Core.Data.AIAnalysis
  alias CopilotApiWeb.Plugs.{Auth, AuthorizeAIAnalysis}

  action_fallback CopilotApiWeb.FallbackController

  plug :put_view, json: CopilotApiWeb.AIAnalysisJSON
  plug Auth
  plug AuthorizeAIAnalysis, :show when action == :show
  plug AuthorizeAIAnalysis, :update when action == :update
  plug AuthorizeAIAnalysis, :delete when action == :delete

  def index(conn, _params) do
    if "developer" in conn.assigns.current_user.roles do
      analyses = AIAnalyses.list_ai_analyses()
      render(conn, :index, analyses: analyses)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "You are not authorized to perform this action"}})
    end
  end

  def create(conn, %{"ai_analysis" => analysis_params}) do
    if "developer" in conn.assigns.current_user.roles do
      with {:ok, %AIAnalysis{} = analysis} <- AIAnalyses.create_ai_analysis(analysis_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/ai_analyses/#{analysis}")
        |> render(:show, analysis: analysis)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "Only developers can create an AI analysis"}})
    end
  end

  def show(conn, _params) do
    render(conn, :show, analysis: conn.assigns.ai_analysis)
  end

  def update(conn, %{"ai_analysis" => analysis_params}) do
    analysis = conn.assigns.ai_analysis

    with {:ok, %AIAnalysis{} = analysis} <- AIAnalyses.update_ai_analysis(analysis, analysis_params) do
      render(conn, :show, analysis: analysis)
    end
  end

  def delete(conn, _params) do
    analysis = conn.assigns.ai_analysis

    with {:ok, %AIAnalysis{}} <- AIAnalyses.delete_ai_analysis(analysis) do
      send_resp(conn, :no_content, "")
    end
  end
end
