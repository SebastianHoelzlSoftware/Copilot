defmodule CopilotApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider_id, :string, null: false
      add :email, :string, null: false
      add :name, :string
      add :role, :string, null: false, default: "customer"

      timestamps()
    end

    create unique_index(:users, [:provider_id])
    create unique_index(:users, [:email])
  end
end
