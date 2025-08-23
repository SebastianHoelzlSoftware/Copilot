defmodule CopilotWeb.InfoLive do
  use CopilotWeb, :live_view
  alias CopilotWeb.Components.CoreComponents
  alias Copilot.Core.Users

  def mount(_params, session, socket) do
    current_user =
      if user_id = Map.get(session, "current_user_id") do
        Users.get_user(user_id)
      else
        nil
      end

    IO.inspect(current_user, label: "CURRENT USER in Info live mount")
    {:ok, assign(socket, :current_user, current_user)}
  end

  def render(assigns) do
    ~H"""
    <CoreComponents.header current_user={@current_user} />
    <h1>Info Page</h1>
    <p>This is the info page.</p>
    """
  end
end
