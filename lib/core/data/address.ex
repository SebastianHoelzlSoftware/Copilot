defmodule CopilotApi.Core.Data.Address do
  @moduledoc "An embedded schema for a physical address."
  use Ecto.Schema
  @derive {Jason.Encoder, only: [:street, :street_additional, :city, :postal_code, :country]}
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :street, :string
    field :street_additional, :string
    field :city, :string
    field :postal_code, :string
    field :country, :string
  end

  @doc """
  Builds a changeset for an Address.
  """
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:street, :street_additional, :city, :postal_code, :country])
    |> validate_required([:street, :city, :postal_code, :country])
  end

  @doc """
  Returns a formatted string of the address.
  """
  def format(%__MODULE__{} = address) do
    [
      address.street,
      address.street_additional,
      address.city,
      address.postal_code,
      address.country
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  @type t() :: %__MODULE__{
          street: String.t() | nil,
          street_additional: String.t() | nil,
          city: String.t() | nil,
          postal_code: String.t() | nil,
          country: String.t() | nil
        }
end
