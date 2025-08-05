defmodule Copilot.Core.Data.BuildingBlock do
  @moduledoc "An embedded schema for a suggested building block."
  use Ecto.Schema
  @derive {Jason.Encoder, only: [:name, :description]}
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :description, :string
  end

  def changeset(block, attrs) do
    block
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end

  @type t() :: %__MODULE__{
          name: String.t() | nil,
          description: String.t() | nil
        }
end
