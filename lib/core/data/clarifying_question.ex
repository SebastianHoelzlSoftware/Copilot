defmodule CopilotApi.Core.Data.ClarifyingQuestion do
  @moduledoc "An embedded schema for a clarifying question."
  use Ecto.Schema
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
end
