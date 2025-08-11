defmodule CopilotWeb.TimeEntryJSON do
  alias Copilot.Core.Data.TimeEntry

  def index(%{time_entries: time_entries}) do
    %{data: for(time_entry <- time_entries, do: data(time_entry))}
  end

  def show(%{time_entry: time_entry}) do
    %{data: data(time_entry)}
  end

  defp data(%TimeEntry{} = time_entry) do
    %{
      id: time_entry.id,
      start_time: time_entry.start_time,
      end_time: time_entry.end_time,
      description: time_entry.description,
      developer_id: time_entry.developer_id,
      project_id: time_entry.project_id
    }
  end
end
