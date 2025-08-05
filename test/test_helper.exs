ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Copilot.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:phoenix_live_view)
