defmodule CopilotApiWeb.BriefController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.Briefs
  alias CopilotApi.Core.Data.ProjectBrief
  alias CopilotApiWeb.Plugs.{Auth, AuthorizeBrief}

  action_fallback CopilotApiWeb.FallbackController

  plug :put_view, json: CopilotApiWeb.BriefJSON
  plug Auth
  plug AuthorizeBrief, :show when action in [:show]
  plug AuthorizeBrief, :update when action in [:update]
  plug AuthorizeBrief, :delete when action in [:delete]

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    briefs =
      if "developer" in current_user.roles do
        Briefs.list_project_briefs()
      else
        # The customer struct needs an :id key for this function to work
        Briefs.list_project_briefs_for_customer(%{id: current_user.customer_id})
      end

    render(conn, :index, briefs: briefs)
  end

  def create(conn, %{"project_brief" => brief_params}) do
    current_user = conn.assigns.current_user

    if "customer" in current_user.roles do
      params = Map.put(brief_params, "customer_id", current_user.customer_id)

      with {:ok, %ProjectBrief{} = brief} <- Briefs.create_project_brief(params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/briefs/#{brief}")
        |> render(:show, brief: brief)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "Only customers can create briefs"}})
    end
  end

  def show(conn, _params) do
    render(conn, :show, brief: conn.assigns.brief)
  end

  def update(conn, %{"project_brief" => brief_params}) do
    brief = conn.assigns.brief

    with {:ok, %ProjectBrief{} = brief} <- Briefs.update_project_brief(brief, brief_params) do
      render(conn, :show, brief: brief)
    end
  end

  def delete(conn, _params) do
    brief = conn.assigns.brief

    with {:ok, %ProjectBrief{}} <- Briefs.delete_project_brief(brief) do
      send_resp(conn, :no_content, "")
    end
  end
end
