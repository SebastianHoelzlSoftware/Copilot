defmodule CopilotApi.Repo.Migrations.CreateProjectBriefs do
  use Ecto.Migration

  def change do
    create table(:project_briefs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :summary, :text, null: false
      add :status, :string, null: false, default: "new"
      add :developer_id, :binary_id
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id), null: false

      timestamps()
    end

    create index(:project_briefs, [:customer_id])
  end
end
