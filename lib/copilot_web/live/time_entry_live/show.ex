defmodule CopilotWeb.Live.TimeEntryLive.Show do
  use CopilotWeb, :live_view

  alias Copilot.Core.TimeTracking
  alias Copilot.Repo
  import CopilotWeb.Components.CoreComponents

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    time_entry = TimeTracking.get_time_entry!(id) |> Repo.preload([:developer, :project])
    {:ok, assign(socket, :time_entry, time_entry)}
  end
end
