defmodule Copilot.Core.Data.Customer do
  @moduledoc "Represents a customer account."
  use Ecto.Schema
  import Ecto.Changeset

  alias Copilot.Core.Data.{
    Address,
    Contact,
    CostEstimate,
    Name,
    ProjectBrief,
    User
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "customers" do
    embeds_one :name, Name, on_replace: :delete
    embeds_one :address, Address, on_replace: :delete

    has_many :contacts, Contact, on_delete: :delete_all
    has_many :project_briefs, ProjectBrief, on_delete: :delete_all
    has_many :cost_estimates, CostEstimate, on_delete: :delete_all
    has_many :users, User, on_delete: :delete_all

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
    |> cast_assoc(:project_briefs)
    |> cast_assoc(:cost_estimates)
    |> cast_assoc(:users)
  end
end
