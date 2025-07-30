defmodule CopilotApi.Repo do
  use Ecto.Repo,
    otp_app: :copilot_api,
    adapter: Ecto.Adapters.Postgres
end
