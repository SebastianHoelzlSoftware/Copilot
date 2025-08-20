defmodule CopilotWeb.Plugs.AuthorizeTimeEntry do
  @moduledoc """
  Authorization plug for the TimeEntryController.
  """
  import Plug.Conn
  import Phoenix.Controller
  require Logger

  alias Copilot.Core.TimeTracking

  def init(opts), do: opts

  def call(conn, _action) do
    %{"id" => time_entry_id} = conn.params

    case TimeTracking.get_time_entry!(time_entry_id) do
      time_entry ->
        Logger.info("--- AuthorizeTimeEntry Debug ---")
        Logger.info("User ID: #{inspect(conn.assigns.current_user.id)}")
        Logger.info("Time Entry Developer ID: #{inspect(time_entry.developer_id)}")
        Logger.info("------------------------------")
        if authorized?(conn.assigns.current_user, time_entry) do
          assign(conn, :time_entry, time_entry)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{
            error: %{status: 403, message: "You are not authorized to perform this action"}
          })
          |> halt()
        end
    end
  end

  defp authorized?(user, time_entry) do
    user.id == time_entry.developer_id
  end
end
