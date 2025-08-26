defmodule CopilotWeb.Live.TimeEntryLive.Index do
  use CopilotWeb, :live_view

  alias Copilot.Core.TimeTracking
  alias Copilot.Core.Briefs
  import CopilotWeb.Components.CoreComponents

  @impl true
  def mount(_params, _session, socket) do
    developer = socket.assigns.current_user
    projects = Briefs.list_project_briefs_for_developer(developer)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Copilot.PubSub, "user_timers:#{developer.id}")
    end

    socket =
      socket
      |> stream(:time_entries, TimeTracking.list_time_entries_for_developer(developer))
      |> assign(
        projects: projects,
        selected_project_id: (if not Enum.empty?(projects), do: List.first(projects).id, else: nil),
        timer_running?: TimeTracking.is_timer_running?(developer.id),
        elapsed_time: "00:00:00",
        description: ""
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    time_entry = TimeTracking.get_time_entry!(id)
    {:ok, _} = TimeTracking.delete_time_entry(time_entry)

    {:noreply, stream_delete(socket, :time_entries, time_entry)}
  end

  def handle_event("select_project", %{"project_id" => project_id}, socket) do
    {:noreply, assign(socket, :selected_project_id, project_id)}
  end

  def handle_event("update_description", %{"description" => description}, socket) do
    TimeTracking.update_timer_description(socket.assigns.current_user.id, description)
    {:noreply, assign(socket, :description, description)}
  end

  def handle_event("start_timer", _, socket) do
    developer = socket.assigns.current_user
    description = socket.assigns.description
    project_id = socket.assigns.selected_project_id

    TimeTracking.start_timer(developer.id, description, project_id)

    {:noreply, assign(socket, :timer_running?, true)}
  end

  def handle_event("stop_timer", _, socket) do
    developer = socket.assigns.current_user
    TimeTracking.stop_timer(developer.id)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "tick", payload: %{elapsed_seconds: elapsed_seconds}}, socket) do
    elapsed_time = format_time(elapsed_seconds)
    {:noreply, assign(socket, :elapsed_time, elapsed_time)}
  end

  def handle_info(%{event: "stopped", payload: %{time_entry: time_entry}}, socket) do
    socket =
      assign(socket,
        timer_running?: false,
        elapsed_time: "00:00:00",
        description: ""
      )
      |> stream_insert(:time_entries, time_entry, at: 0)

    {:noreply, socket}
  end

  defp format_time(total_seconds) do
    hours = div(total_seconds, 3600)
    minutes = div(rem(total_seconds, 3600), 60)
    seconds = rem(total_seconds, 60)

    "#{pad(hours)}:#{pad(minutes)}:#{pad(seconds)}"
  end

  defp pad(n) when n < 10, do: "0#{n}"
  defp pad(n), do: "#{n}"
end