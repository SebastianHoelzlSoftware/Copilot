defmodule CopilotWeb.Live.TimeEntryLive.Index do
  use CopilotWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Time Entries</h1>
    """
  end
end
