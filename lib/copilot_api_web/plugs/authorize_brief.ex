defmodule CopilotApiWeb.Plugs.AuthorizeBrief do
  @moduledoc """
  Authorization plug for the BriefController.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias CopilotApi.Core.Briefs

  def init(opts), do: opts

  def call(conn, action) do
    %{"id" => brief_id} = conn.params

    case Briefs.get_project_brief!(brief_id) do
      brief ->
        if authorized?(conn.assigns.current_user, brief, action) do
          assign(conn, :brief, brief)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{
            error: %{status: 403, message: "You are not authorized to perform this action"}
          })
          |> halt()
        end
    end
  end

  defp authorized?(user, brief, action) when action in [:show, :update] do
    is_owner?(user, brief) or is_developer?(user)
  end

  defp authorized?(user, brief, :delete) do
    is_owner?(user, brief)
  end

  defp is_owner?(user, brief), do: user.customer_id == brief.customer_id

  defp is_developer?(user), do: "developer" in user.roles
end
