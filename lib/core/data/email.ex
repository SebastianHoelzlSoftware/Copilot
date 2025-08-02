defmodule CopilotApi.Core.Data.Email do
  @moduledoc "Represents a validated email address as an embedded Ecto schema."
  use Ecto.Schema
  @derive {Jason.Encoder, only: [:address]}
  import Ecto.Changeset

  @doc """
  The Ecto schema definition. An email is embedded and has no primary key.
  """
  @primary_key false
  embedded_schema do
    field :address, :string
  end

  @doc """
  Builds a changeset for an Email.
  """
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:address])
    |> validate_required([:address])
    |> validate_format(:address, ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/,
      message: "must have the @ sign and no spaces"
    )
  end

  @doc "Returns the email address as a string."
  def to_string(%__MODULE__{address: address}), do: address

  @type t() :: %__MODULE__{address: String.t() | nil}
end
