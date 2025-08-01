defmodule CopilotApiWeb.UserController do
  use CopilotApiWeb, :controller

  def show(conn, _params) do
    # The current_user is already in conn.assigns thanks to the UserInfo plug
    current_user = conn.assigns.current_user
    render(conn, :show, user: current_user)
  end
end
