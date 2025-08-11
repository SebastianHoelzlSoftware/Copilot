defmodule Copilot.Repo.Migrations.CreateTimeEntries do
  use Ecto.Migration

  def change do
    create table(:time_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_time, :naive_datetime, null: false
      add :end_time, :naive_datetime, null: false
      add :description, :text
      add :developer_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :project_id, references(:project_briefs, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:time_entries, [:developer_id])
    create index(:time_entries, [:project_id])
  end
end
