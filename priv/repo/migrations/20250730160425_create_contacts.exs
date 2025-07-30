defmodule CopilotApi.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :map, null: false
      add :email, :map, null: false
      add :address, :map
      add :phone_number, :map
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contacts, [:customer_id])
  end
end
