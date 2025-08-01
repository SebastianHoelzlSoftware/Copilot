defmodule CopilotApi.Core.Data.AIAnalysis do
  @moduledoc "Holds the results of an AI analysis of a project brief."
  use Ecto.Schema
  import Ecto.Changeset

  alias CopilotApi.Core.Data.{BuildingBlock, ClarifyingQuestion, CostEstimate, ProjectBrief}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ai_analyses" do
    embeds_many :suggested_blocks, BuildingBlock
    embeds_many :clarifying_questions, ClarifyingQuestion
    field :summary, :string
    field :identified_ambiguities, {:array, :string}, default: []

    belongs_to :project_brief, ProjectBrief
    belongs_to :cost_estimate, CostEstimate

    timestamps()
  end

  @doc """
  Builds a changeset for an AIAnalysis.
  """
  def changeset(analysis, attrs) do
    changeset_base(analysis, attrs)
    |> validate_required([:project_brief_id])
    |> foreign_key_constraint(:project_brief_id)
    |> unique_constraint(:project_brief_id)
  end

  @doc """
  A changeset for when AIAnalysis is created nested within a ProjectBrief.
  It does not validate the `project_brief_id` as Ecto will set it.
  """
  def changeset_for_brief(analysis, attrs) do
    changeset_base(analysis, attrs)
  end

  defp changeset_base(analysis, attrs) do
    analysis
    |> cast(attrs, [:summary, :identified_ambiguities, :cost_estimate_id, :project_brief_id])
    |> validate_required([:summary])
    |> cast_embed(:suggested_blocks)
    |> cast_embed(:clarifying_questions)
    |> cast_assoc(:cost_estimate)
  end

  @type t() :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          summary: String.t() | nil,
          suggested_blocks: [BuildingBlock.t()] | nil,
          clarifying_questions: [ClarifyingQuestion.t()] | nil,
          identified_ambiguities: [String.t()] | nil,
          cost_estimate: CostEstimate.t() | nil,
          project_brief: ProjectBrief.t() | nil,
          project_brief_id: Ecto.UUID.t() | nil,
          cost_estimate_id: Ecto.UUID.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }
end
