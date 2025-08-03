defmodule CopilotApi.Core.CostEstimates do
  @moduledoc """
  The CostEstimates context.
  """

  import Ecto.Query, warn: false
  alias CopilotApi.Repo

  alias CopilotApi.Core.Data.CostEstimate

  @doc """
  Returns the list of cost_estimates.

  ## Examples

      iex> list_cost_estimates()
      [%CostEstimate{}, ...]

  """
  def list_cost_estimates do
    Repo.all(from ce in CostEstimate, preload: [:customer])
  end

  @doc """
  Gets a single cost_estimate.

  Raises `Ecto.NoResultsError` if the Cost estimate does not exist.

  ## Examples

      iex> get_cost_estimate!(123)
      %CostEstimate{}

      iex> get_cost_estimate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cost_estimate!(id),
    do: Repo.get!(CostEstimate, id) |> Repo.preload([:customer, :ai_analysis])

  @doc """
  Creates a cost_estimate.

  ## Examples

      iex> create_cost_estimate(%{field: value})
      {:ok, %CostEstimate{}}

      iex> create_cost_estimate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cost_estimate(attrs \\ %{}) do
    %CostEstimate{}
    |> CostEstimate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cost_estimate.
  """
  def update_cost_estimate(%CostEstimate{} = cost_estimate, attrs) do
    cost_estimate
    |> CostEstimate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cost_estimate.
  """
  def delete_cost_estimate(%CostEstimate{} = cost_estimate) do
    Repo.delete(cost_estimate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cost_estimate changes.

  ## Examples

      iex> change_cost_estimate(cost_estimate)
      %Ecto.Changeset{data: %CostEstimate{}}

  """
  def change_cost_estimate(%CostEstimate{} = cost_estimate, attrs \\ %{}) do
    CostEstimate.changeset(cost_estimate, attrs)
  end
end
