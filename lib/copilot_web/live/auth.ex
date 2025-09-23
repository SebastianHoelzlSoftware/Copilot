defmodule CopilotWeb.Live.Auth do
  use CopilotWeb, :live_view

  def on_mount(:default, _params, %{"current_user_id" => user_id}, socket) do
    socket = assign(socket, :current_user, Copilot.Core.Users.get_user!(user_id))
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/")

    {:halt, socket}
  end
end
