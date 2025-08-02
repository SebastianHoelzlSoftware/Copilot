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

  def delete(conn, _params) do
    current_user = conn.assigns.current_user

    {:ok, _user} = Users.delete_user(current_user)
    send_resp(conn, :no_content, "")
  end

  def update_role(conn, %{"id" => id, "roles" => roles}) do
    # This action is protected by the :developer_only pipeline,
    # so we don't need to do additional authorization checks here.
    user = Users.get_user!(id)

    case Users.update_user(user, %{"roles" => roles}) do
      {:ok, updated_user} ->
        render(conn, :show, user: updated_user)

      {:error, changeset} ->
        # Reuse the existing changeset error view
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CopilotApiWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
