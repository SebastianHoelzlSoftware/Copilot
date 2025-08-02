defmodule CopilotApi.Core.Data.PhoneNumber do
  @moduledoc "Represents a validated phone number as an embedded Ecto schema."
  use Ecto.Schema
  @derive {Jason.Encoder, only: [:number]}
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :number, :string
  end

  @doc """
  Builds a changeset for a PhoneNumber.
  """
  def changeset(phone_number, attrs) do
    phone_number
    |> cast(attrs, [:number])
    |> validate_required([:number])
    # A simple regex to allow digits, spaces, hyphens, parentheses, dots, slashes, and a plus sign.
    |> validate_format(:number, ~r'^(?=.*\d)[+()0-9\s./-]*$',
      message: "is not a valid phone number format"
    )
  end

  @type t() :: %__MODULE__{number: String.t() | nil}
end
