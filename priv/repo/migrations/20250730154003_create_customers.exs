defmodule Copilot.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :map, null: false
      add :address, :map

      timestamps()
    end
  end
end
