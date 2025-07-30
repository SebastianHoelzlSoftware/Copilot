defmodule CopilotApi.Core.Data.Contact do
  @moduledoc """
  A struct representing a customer contact.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias CopilotApi.Core.Data.{Address, Customer, Email, Name, PhoneNumber}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    embeds_one :name, Name, on_replace: :delete
    embeds_one :email, Email, on_replace: :delete
    embeds_one :address, Address, on_replace: :delete
    embeds_one :phone_number, PhoneNumber, on_replace: :delete
    belongs_to :customer, Customer
    timestamps()
  end

  @doc """
  Builds a changeset for a Contact.
  """
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [])
    |> cast_embed(:name, required: true)
    |> cast_embed(:email, required: true)
    |> cast_embed(:address)
    |> cast_embed(:phone_number)
    |> cast_assoc(:customer)
  end
end
