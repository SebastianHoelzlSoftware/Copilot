defmodule Copilot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # Log application startup. This is a great place to put this log
    # as it runs once when the application is booting.
    Logger.info(
      """
      \n
      WOJTILA's                                         2025
      ░█████╗░░█████╗░██████╗░██╗██╗░░░░░░█████╗░████████╗
      ██╔══██╗██╔══██╗██╔══██╗██║██║░░░░░██╔══██╗╚══██╔══╝
      ██║░░╚═╝██║░░██║██████╔╝██║██║░░░░░██║░░██║░░░██║░░░
      ██║░░██╗██║░░██║██╔═══╝░██║██║░░░░░██║░░██║░░░██║░░░
      ╚█████╔╝╚█████╔╝██║░░░░░██║███████╗╚█████╔╝░░░██║░░░
      ░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░
      \n
      """,
      %{
        event: "application_started",
        application: :copilot,
        env: Mix.env(),
        version: Application.spec(:copilot, :vsn) |> to_string()
      }
    )

    children = [
      Copilot.Repo,
      CopilotWeb.Telemetry,
      {Phoenix.PubSub, name: Copilot.PubSub},
      CopilotWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Copilot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
