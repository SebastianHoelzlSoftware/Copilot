defmodule CopilotWeb.TimeEntryController do
  use CopilotWeb, :controller

  alias Copilot.Core.TimeTracking
  alias Copilot.Core.Data.TimeEntry

  action_fallback CopilotWeb.FallbackController

  def index(conn, _params) do
    time_entries = TimeTracking.list_time_entries()
    render(conn, :index, time_entries: time_entries)
  end

  def show(conn, %{"id" => id}) do
    time_entry = TimeTracking.get_time_entry!(id)
    render(conn, :show, time_entry: time_entry)
  end

  def create(conn, %{"time_entry" => time_entry_params}) do
    with {:ok, %TimeEntry{} = time_entry} <- TimeTracking.create_time_entry(time_entry_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/time_entries/#{time_entry}")
      |> render(:show, time_entry: time_entry)
    end
  end

  def update(conn, %{"id" => id, "time_entry" => time_entry_params}) do
    time_entry = TimeTracking.get_time_entry!(id)

    with {:ok, %TimeEntry{} = time_entry} <- TimeTracking.update_time_entry(time_entry, time_entry_params) do
      render(conn, :show, time_entry: time_entry)
    end
  end

  def delete(conn, %{"id" => id}) do
    time_entry = TimeTracking.get_time_entry!(id)

    with {:ok, %TimeEntry{}} <- TimeTracking.delete_time_entry(time_entry) do
      send_resp(conn, :no_content, "")
    end
  end
end
