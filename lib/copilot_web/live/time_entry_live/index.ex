defmodule CopilotWeb.Live.TimeEntryLive.Index do
  use CopilotWeb, :live_view

  alias Copilot.Core.TimeTracking
  import CopilotWeb.Components.CoreComponents

  @impl true
  def mount(_params, _session, socket) do
    developer = socket.assigns.current_user
    time_entries = TimeTracking.list_time_entries_for_developer(developer)

    socket =
      socket
      |> assign(time_entries: time_entries)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <h1>Time Entries</h1>
    </.header>

    <div class="flex justify-end my-4">
        <.link href={~p"/time-entries/new"}>
          <.button>New Time Entry</.button>
        </.link>
    </div>

    <.table id="time_entries" rows={@time_entries}>
      <:col :let={time_entry} label="Start Time"><%= time_entry.start_time %></:col>
      <:col :let={time_entry} label="End Time"><%= time_entry.end_time %></:col>
      <:col :let={time_entry} label="Description"><%= time_entry.description %></:col>
      <:col :let={time_entry} label="Project"><%= time_entry.project.name %></:col>
    </.table>
    """
  end
end
