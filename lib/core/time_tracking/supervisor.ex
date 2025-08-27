defmodule Copilot.Core.TimeTracking.TimerSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_timer(user_id, description, project_id) do
    spec = %{
      id: {Copilot.Core.TimeTracking.Timer, user_id},
      start: {
        Copilot.Core.TimeTracking.Timer,
        :start_link,
        [[user_id: user_id, description: description, project_id: project_id]]
      },
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_timer(user_id) do
    GenServer.call(Copilot.Core.TimeTracking.Timer.via_tuple(user_id), :stop)
  end

  def update_timer_description(user_id, description) do
    GenServer.cast(Copilot.Core.TimeTracking.Timer.via_tuple(user_id), {:update_description, description})
  end

  def get_timer_description(user_id) do
    GenServer.call(Copilot.Core.TimeTracking.Timer.via_tuple(user_id), :get_description)
  end
end
