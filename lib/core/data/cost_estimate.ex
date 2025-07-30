defmodule CopilotApi.Core.Data.CostEstimate do
  @moduledoc "Represents a cost estimate for a project or service."
  use Ecto.Schema
  import Ecto.Changeset

  alias CopilotApi.Core.Data.Customer

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cost_estimates" do
    field :amount, :decimal
    field :currency, :string
    field :details, :string

    # Assuming a cost estimate belongs to a customer
    belongs_to :customer, Customer

    timestamps()
  end

  @doc """
  Builds a changeset for a CostEstimate.
  """
  def changeset(cost_estimate, attrs) do
    cost_estimate
    |> cast(attrs, [:amount, :currency, :details, :customer_id])
    |> validate_required([:amount, :currency, :customer_id])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:customer_id)
  end
end
