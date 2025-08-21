defmodule CopilotWeb.Live.TimeEntryLive.Form do
  use CopilotWeb, :live_view

  alias Copilot.Core.TimeTracking
  alias Copilot.Core.Data.TimeEntry
  alias Copilot.Core.Briefs

  @impl true
  def mount(_params, _session, socket) do
    changeset = TimeTracking.change_time_entry(%TimeEntry{})
    projects = Briefs.list_project_briefs()

    socket =
      socket
      |> assign(changeset: changeset, page_title: "New Time Entry")
      |> assign(projects: projects)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <h1>New Time Entry</h1>
    </.header>

    <.simple_form
      for={@changeset}
      id="time_entry-form"
      phx_submit="save"
      phx_change="validate"
    >
      <.input field={@changeset[:start_time]} type="datetime-local" label="Start Time" />
      <.input field={@changeset[:end_time]} type="datetime-local" label="End Time" />
      <.input field={@changeset[:description]} type="text" label="Description" />
      <.input
        field={@changeset[:project_id]}
        type="select"
        label="Project"
        options={Enum.map(@projects, &{&1.name, &1.id})}
      />
      <:actions>
        <.button phx-disable-with="Saving...">Save Time Entry</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_event("validate", %{"time_entry" => time_entry_params}, socket) do
    changeset = TimeTracking.change_time_entry(%TimeEntry{}, time_entry_params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"time_entry" => time_entry_params}, socket) do
    developer_id = socket.assigns.current_user.id
    params = Map.put(time_entry_params, "developer_id", developer_id)

    case TimeTracking.create_time_entry(params) do
      {:ok, _time_entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Time entry created successfully.")
         |> push_navigate(to: ~p"/time-entries")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
