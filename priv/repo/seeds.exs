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
alias Copilot.Core.Data.Customer
alias Copilot.Core.Data.Name
alias Copilot.Core.Data.ProjectBrief
alias Copilot.Repo

#
# Note: This file is only run when running `mix ecto.setup`.
if Mix.env() == :dev do
  IO.puts("Seeding development data...")

  # Seed a developer for easy testing.
  # You can grant them the developer role with: mix users.grant_role dev@copilot.com developer
  {:ok, developer} = Users.find_or_create_user(%{
    "provider_id" => "dev-seed-001",
    "email" => "dev@copilot.com",
    "name" => "Copilot Developer"
  })
  IO.puts("Seeded developer: #{developer.email}")

  # Seed a customer
  customer_name = %{first_name: "Acme", last_name: "Corp"}
  customer_attrs = %{name: customer_name}
  {:ok, customer} = Repo.insert(Customer.changeset(%Customer{}, customer_attrs))
  IO.puts("Seeded customer: #{customer.name.first_name} #{customer.name.last_name}")

  # Seed a project brief
  project_brief_attrs = %{
    title: "Develop Time Tracking Feature",
    summary: "Develop a new time tracking feature for the Copilot application, allowing developers to log their work hours against specific projects.",
    customer_id: customer.id,
    developer_id: developer.id
  }
  {:ok, project_brief} = Repo.insert(ProjectBrief.changeset(%ProjectBrief{}, project_brief_attrs))
  IO.puts("Seeded project brief: #{project_brief.title}")
end
