defmodule CopilotWeb.InfoLive do
  use CopilotWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Info Page</h1>
    <p>This is the info page.</p>
    """
  end
end
