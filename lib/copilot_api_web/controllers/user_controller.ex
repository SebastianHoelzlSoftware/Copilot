defmodule CopilotApiWeb.UserController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.Users
  require Logger

  action_fallback CopilotApiWeb.FallbackController

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

    # We expect this to always succeed. If it fails, the MatchError will correctly
    # result in a 500 server error.
    {:ok, user} = Users.delete_user(current_user)

    Logger.info("User deleted their own account", %{
      event: "user_self_deleted",
      user_id: user.id
    })

    send_resp(conn, :no_content, "")
  end

  def update_role(conn, %{"id" => id} = params) do
    # This action is protected by the :developer_only pipeline,
    # so we don't need to do additional authorization checks here.
    user = Users.get_user!(id)

    case params do
      %{"roles" => roles} ->
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
            |> put_view(json: CopilotApiWeb.ChangesetJSON)
            |> render(:error, changeset: changeset)
        end

      _ ->
        {:error, :bad_request}
    end
  end
end
