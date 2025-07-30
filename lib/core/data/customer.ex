defmodule CopilotApi.Core.Data.Customer do
  @moduledoc "Represents a customer account."
  use Ecto.Schema
  import Ecto.Changeset

  alias CopilotApi.Core.Data.{Address, Contact, Name}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "customers" do
    embeds_one :name, Name, on_replace: :delete
    embeds_one :address, Address, on_replace: :delete

    has_many :contacts, Contact

    timestamps()
  end

  @doc """
  Builds a changeset for a Customer.
  """
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [])
    |> cast_embed(:name, required: true)
    |> cast_embed(:address)
    |> cast_assoc(:contacts)
  end
end
