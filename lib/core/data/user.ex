defmodule CopilotApi.Core.Data.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :provider_id, :string
    field :email, :string
    field :name, :string
    field :role, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:provider_id, :email, :name, :role])
    |> validate_required([:provider_id, :email, :role])
    |> unique_constraint(:provider_id)
    |> unique_constraint(:email)
  end
end
