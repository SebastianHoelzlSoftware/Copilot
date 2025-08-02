defmodule CopilotApiWeb.UserController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.Users

  def show(conn, _params) do
    # The current_user is already in conn.assigns thanks to the UserInfo plug
    current_user = conn.assigns.current_user
    render(conn, :show, user: current_user)
  end

  def update(conn, params) do
    current_user = conn.assigns.current_user

    case Users.update_user(current_user, params) do
      {:ok, user} ->
        render(conn, :show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CopilotApiWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
