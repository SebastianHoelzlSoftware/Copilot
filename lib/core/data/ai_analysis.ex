defmodule CopilotApi.Core.Data.AIAnalysis do
  @moduledoc "Holds the results of an AI analysis of a project brief."
  use Ecto.Schema
  import Ecto.Changeset

  alias CopilotApi.Core.Data.{BuildingBlock, ClarifyingQuestion, CostEstimate}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ai_analyses" do
    embeds_many :suggested_blocks, BuildingBlock
    embeds_many :clarifying_questions, ClarifyingQuestion
    field :identified_ambiguities, {:array, :string}, default: []

    belongs_to :cost_estimate, CostEstimate

    timestamps()
  end

  @doc """
  Builds a changeset for an AIAnalysis.
  """
  def changeset(analysis, attrs) do
    analysis
    |> cast(attrs, [:identified_ambiguities, :cost_estimate_id])
    |> cast_embed(:suggested_blocks)
    |> cast_embed(:clarifying_questions)
    |> cast_assoc(:cost_estimate)
  end

  @type t() :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          suggested_blocks: [BuildingBlock.t()] | nil,
          clarifying_questions: [ClarifyingQuestion.t()] | nil,
          identified_ambiguities: [String.t()] | nil,
          cost_estimate: CostEstimate.t() | nil,
          cost_estimate_id: Ecto.UUID.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }
end
