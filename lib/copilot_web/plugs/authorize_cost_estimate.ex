defmodule CopilotWeb.Plugs.AuthorizeCostEstimate do
  @moduledoc """
  Authorization plug for the CostEstimateController.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Copilot.Core.CostEstimates

  def init(opts), do: opts

  def call(conn, action) do
    %{"id" => cost_estimate_id} = conn.params

    cost_estimate = CostEstimates.get_cost_estimate!(cost_estimate_id)

    if authorized?(conn.assigns.current_user, cost_estimate, action) do
      assign(conn, :cost_estimate, cost_estimate)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "You are not authorized to perform this action"}})
      |> halt()
    end
  end

  defp authorized?(user, cost_estimate, :show) do
    is_developer?(user) or is_owner?(user, cost_estimate)
  end

  defp authorized?(user, _cost_estimate, action) when action in [:update, :delete] do
    is_developer?(user)
  end

  defp is_owner?(user, cost_estimate), do: user.customer_id == cost_estimate.customer_id
  defp is_developer?(user), do: "developer" in user.roles
end
