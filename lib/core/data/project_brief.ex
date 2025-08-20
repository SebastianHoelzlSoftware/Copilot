defmodule Copilot.Core.Data.ProjectBrief do
  @moduledoc "Represents a project brief submitted by a customer."
  use Ecto.Schema
  import Ecto.Changeset

  alias Copilot.Core.Data.{AIAnalysis, Customer}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "project_briefs" do
    field :title, :string
    field :summary, :string
    field :status, Ecto.Enum, values: [:new, :under_review, :accepted, :declined], default: :new
    field :developer_id, :binary_id

    belongs_to :customer, Customer
    has_one :ai_analysis, AIAnalysis

    timestamps()
  end

  @doc """
  Builds a changeset for a ProjectBrief.
  """
  def changeset(brief, attrs) do
    IO.inspect(attrs, label: "ProjectBrief changeset attrs")
    brief
        |> cast(attrs, [:title, :summary, :status, :developer_id, :customer_id])
    |> validate_required([:title, :summary, :customer_id])
    |> foreign_key_constraint(:customer_id)
    |> cast_assoc(:ai_analysis, with: &AIAnalysis.changeset_for_brief/2)
  end
end
