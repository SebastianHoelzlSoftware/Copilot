defmodule CopilotApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # Log application startup. This is a great place to put this log
    # as it runs once when the application is booting.
    Logger.info("COPILOT API STARTED", %{
      event: "application_started",
      application: :copilot_api,
      env: Mix.env(),
      version: Application.spec(:copilot_api, :vsn) |> to_string()
    })

    children = [
      CopilotApi.Repo,
      CopilotApiWeb.Telemetry,
      {Phoenix.PubSub, name: CopilotApi.PubSub},
      CopilotApiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CopilotApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
