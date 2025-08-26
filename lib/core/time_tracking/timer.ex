defmodule Copilot.Core.TimeTracking.Timer do
  use GenServer

  alias Copilot.Core.TimeTracking

  def start_link(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    GenServer.start_link(__MODULE__, opts, name: via_tuple(user_id))
  end

  def init(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    description = Keyword.get(opts, :description, "")
    project_id = Keyword.fetch!(opts, :project_id)
    start_time = DateTime.utc_now()
    ticker = Process.send_after(self(), :tick, 1000)

    state = %{
      user_id: user_id,
      start_time: start_time,
      description: description,
      project_id: project_id,
      ticker: ticker
    }

    {:ok, state}
  end

  def handle_info(:tick, state) do
    elapsed_seconds = DateTime.diff(DateTime.utc_now(), state.start_time)
    ticker = Process.send_after(self(), :tick, 1000)
    new_state = %{state | ticker: ticker}

    Phoenix.PubSub.broadcast(Copilot.PubSub, "user_timers:#{state.user_id}", %{event: "tick", payload: %{elapsed_seconds: elapsed_seconds}})

    {:noreply, new_state}
  end

  def handle_cast({:update_description, description}, state) do
    {:noreply, %{state | description: description}}
  end

  def handle_cast(:stop, state) do
    end_time = DateTime.utc_now()

    attrs = %{
      start_time: state.start_time,
      end_time: end_time,
      description: state.description,
      developer_id: state.user_id,
      project_id: state.project_id
    }

    case TimeTracking.create_time_entry(attrs) do
      {:ok, time_entry} ->
        Phoenix.PubSub.broadcast(Copilot.PubSub, "user_timers:#{state.user_id}", %{event: "stopped", payload: %{time_entry: time_entry}})

      {:error, changeset} ->
        IO.inspect(changeset, label: "Error creating time entry in Timer GenServer")
    end

    {:stop, :normal, state}
  end

  def via_tuple(user_id) do
    {:via, Registry, {Copilot.Registry, {"timer", user_id}}}
  end
end