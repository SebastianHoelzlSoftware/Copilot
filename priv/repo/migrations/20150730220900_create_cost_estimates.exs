defmodule CopilotApi.Repo.Migrations.CreateCostEstimates do
  use Ecto.Migration

  def change do
    create table(:cost_estimates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :decimal, null: false
      add :currency, :string, null: false
      add :details, :text
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:cost_estimates, [:customer_id])
  end
end
