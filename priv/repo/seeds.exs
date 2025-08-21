# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Copilot.Repo.insert!(%Copilot.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Copilot.Core.Users

#
# Note: This file is only run when running `mix ecto.setup`.
if Mix.env() == :dev do
  IO.puts("Seeding development data...")

  # Seed a developer for easy testing.
  # You can grant them the developer role with: mix users.grant_role dev@copilot.com developer
  Users.find_or_create_user(%{
    "provider_id" => "dev-seed-001",
    "email" => "dev@copilot.com",
    "name" => "Copilot Developer"
  })
end
