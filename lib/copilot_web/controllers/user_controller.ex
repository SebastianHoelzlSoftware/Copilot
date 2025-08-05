defmodule CopilotWeb.UserController do
  use CopilotWeb, :controller

  alias Copilot.Core.Users
  alias CopilotWeb.Plugs.EnsureParams
  require Logger

  action_fallback CopilotWeb.FallbackController
  plug EnsureParams, "roles" when action in [:update_role]

  def show(conn, _params) do
    # The current_user is already in conn.assigns thanks to the UserInfo plug
    current_user = conn.assigns.current_user
    render(conn, :show, user: current_user)
  end

  def update(conn, %{"user" => user_params}) do
    current_user = conn.assigns.current_user

    # Prevent users from updating their own roles via /api/me
    user_params_without_roles = Map.delete(user_params, "roles")

    case Users.update_user(current_user, user_params_without_roles) do
      {:ok, user} ->
        render(conn, :show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CopilotWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  def delete(conn, _params) do
    current_user = conn.assigns.current_user

    # We expect this to always succeed. If it fails, the MatchError will correctly
    # result in a 500 server error.
    {:ok, user} = Users.delete_user(current_user)

    Logger.info("User deleted their own account", %{
      event: "user_self_deleted",
      user_id: user.id
    })

    send_resp(conn, :no_content, "")
  end

  def update_role(conn, %{"id" => id, "roles" => roles}) do
    # This action is protected by the :developer_only pipeline,
    # so we don't need to do additional authorization checks here.
    user = Users.get_user!(id)

    case Users.update_user(user, %{"roles" => roles}) do
      {:ok, updated_user} ->
        # Log this important administrative action with structured metadata.
        Logger.info("User role updated by admin", %{
          event: "user_role_updated",
          admin_user_id: conn.assigns.current_user.id,
          target_user_id: updated_user.id,
          new_roles: updated_user.roles
        })

        render(conn, :show, user: updated_user)

      {:error, changeset} ->
        # Reuse the existing changeset error view
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CopilotWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
