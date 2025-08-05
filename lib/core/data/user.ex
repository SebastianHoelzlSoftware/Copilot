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

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:provider_id, :email, :name, :customer_id, :roles])
    |> validate_required([:provider_id, :email, :name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_roles_for_registration()
    |> unique_constraint(:provider_id)
    |> unique_constraint(:email)
  end

  defp validate_roles_for_registration(changeset) do
    case get_change(changeset, :roles) do
      nil ->
        put_change(changeset, :roles, ["customer"])
      roles when is_list(roles) ->
        if Enum.all?(roles, &(&1 == "customer")) do
          changeset
        else
          add_error(changeset, :roles, "only 'customer' role is allowed for registration")
        end
      _ ->
        add_error(changeset, :roles, "invalid roles format")
    end
  end
end
