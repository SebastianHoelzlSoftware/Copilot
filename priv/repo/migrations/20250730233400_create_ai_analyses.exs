defmodule CopilotApi.Repo.Migrations.CreateAiAnalyses do
  use Ecto.Migration

  def change do
    create table(:ai_analyses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :summary, :string, null: false
      add :suggested_blocks, :map
      add :clarifying_questions, :map
      add :identified_ambiguities, {:array, :string}
      add :cost_estimate_id, references(:cost_estimates, on_delete: :nothing, type: :binary_id)

      add :project_brief_id, references(:project_briefs, on_delete: :nothing, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:ai_analyses, [:cost_estimate_id])
    create unique_index(:ai_analyses, [:project_brief_id])
  end
end
