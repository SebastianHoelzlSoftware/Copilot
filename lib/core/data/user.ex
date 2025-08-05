defmodule Copilot.Core.Data.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :provider_id, :string
    field :email, :string
    field :name, :string
    field :roles, {:array, :string}, default: []

    belongs_to :customer, Copilot.Core.Data.Customer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:provider_id, :email, :name, :roles, :customer_id])
    |> validate_required([:provider_id, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint(:provider_id)
    |> unique_constraint(:email)
  end
end
