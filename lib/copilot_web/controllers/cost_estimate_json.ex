defmodule CopilotWeb.CostEstimateJSON do
  alias Copilot.Core.Data.CostEstimate

  @doc """
  Renders a list of cost estimates.
  """
  def index(%{cost_estimates: cost_estimates}) do
    %{data: for(cost_estimate <- cost_estimates, do: data(cost_estimate))}
  end

  @doc """
  Renders a single cost estimate.
  """
  def show(%{cost_estimate: cost_estimate}) do
    %{data: data(cost_estimate)}
  end

  defp data(%CostEstimate{} = cost_estimate) do
    %{
      id: cost_estimate.id,
      amount: cost_estimate.amount,
      currency: cost_estimate.currency,
      details: cost_estimate.details,
      customer_id: cost_estimate.customer_id,
      customer: customer_data(cost_estimate.customer)
    }
  end

  defp customer_data(nil), do: nil
  defp customer_data(%Ecto.Association.NotLoaded{}), do: nil
  defp customer_data(customer), do: %{id: customer.id, name: customer.name.company_name}
end
