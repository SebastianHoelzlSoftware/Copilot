defmodule CopilotApi.Repo.Migrations.CreateAiAnalyses do
  use Ecto.Migration

  def change do
    create table(:ai_analyses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :suggested_blocks, :map
      add :clarifying_questions, :map
      add :identified_ambiguities, {:array, :string}
      add :cost_estimate_id, references(:cost_estimates, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:ai_analyses, [:cost_estimate_id])
  end
end
