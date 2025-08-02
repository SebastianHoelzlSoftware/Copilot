defmodule CopilotApi.Core.Data.ClarifyingQuestion do
  @moduledoc "An embedded schema for a clarifying question."
  use Ecto.Schema
  @derive {Jason.Encoder, only: [:question, :answer_type]}
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :question, :string
    field :answer_type, :string, default: "text"
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :answer_type])
    |> validate_required([:question])
  end

  @type t() :: %__MODULE__{
          question: String.t() | nil,
          answer_type: String.t() | nil
        }
end
