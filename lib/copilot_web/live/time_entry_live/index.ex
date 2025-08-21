defmodule CopilotWeb.Live.TimeEntryLive.Index do
  use CopilotWeb, :live_view

  alias Copilot.Core.TimeTracking
  alias Copilot.Core.TimeTracking.TimeEntry
  import CopilotWeb.Components.CoreComponents

  @impl true
  def mount(_params, _session, socket) do
    developer = socket.assigns.current_user

    socket =
      socket
      |> stream(:time_entries, TimeTracking.list_time_entries_for_developer(developer))

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    time_entry = TimeTracking.get_time_entry!(id)
    {:ok, _} = TimeTracking.delete_time_entry(time_entry)

    {:noreply, stream_delete(socket, :time_entries, time_entry)}
  end
end
