defmodule CopilotWeb.Live.TimeEntryLive.Form do
  use CopilotWeb, :live_view

  alias Copilot.Core.TimeTracking
  alias Copilot.Core.Data.TimeEntry
  alias Copilot.Core.Briefs
  import CopilotWeb.Components.CoreComponents

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    time_entry = TimeTracking.get_time_entry!(id)
    changeset = TimeTracking.change_time_entry(time_entry)
    projects = Briefs.list_project_briefs()

    socket =
      socket
      |> assign(
        changeset: changeset,
        page_title: "Edit Time Entry",
        time_entry: time_entry,
        action: :edit
      )
      |> assign(projects: projects)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    one_hour_later = DateTime.add(now, 3600, :second)

    initial_time_entry = %TimeEntry{
      start_time: now,
      end_time: one_hour_later
    }

    changeset = TimeTracking.change_time_entry(initial_time_entry)
    projects = Briefs.list_project_briefs()

    socket =
      socket
      |> assign(
        changeset: changeset,
        page_title: "New Time Entry",
        time_entry: %TimeEntry{},
        action: :new
      )
      |> assign(projects: projects)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <h1 class="text-3xl font-bold leading-tight tracking-tight text-white"><%= @page_title %></h1>
    </.header>

    <.simple_form
      for={@changeset}
      id="time_entry-form"
      phx_submit="save"
      phx_change="validate"
    >
      <:content :let={f}>
        <.input field={f[:start_time]} type="datetime-local" label="Start Time" />
        <.input field={f[:end_time]} type="datetime-local" label="End Time" />
        <.input field={f[:description]} type="text" label="Description" />
        <.input
          field={f[:project_id]}
          type="select"
          label="Project"
          options={Enum.map(@projects, fn p -> {p.title, p.id} end)}
          value={f.data.project_id}
        />
      </:content>
      <:actions>
        <.button phx-disable-with="Saving...">Save Time Entry</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_event("validate", %{"time_entry" => time_entry_params}, socket) do
    changeset =
      TimeTracking.change_time_entry(socket.assigns.time_entry, time_entry_params)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"time_entry" => time_entry_params}, socket) do
    save_time_entry(socket, socket.assigns.action, time_entry_params)
  end

  defp save_time_entry(socket, :edit, time_entry_params) do
    case TimeTracking.update_time_entry(socket.assigns.time_entry, time_entry_params) do
      {:ok, _time_entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Time entry updated successfully.")
         |> redirect(to: ~p"/time-tracking")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_time_entry(socket, :new, time_entry_params) do
    developer_id = socket.assigns.current_user.id
    params = Map.put(time_entry_params, "developer_id", developer_id)

    case TimeTracking.create_time_entry(params) do
      {:ok, _time_entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Time entry created successfully.")
         |> redirect(to: ~p"/time-tracking")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
