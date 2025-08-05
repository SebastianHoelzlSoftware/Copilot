defmodule CopilotWeb.CostEstimateController do
  use CopilotWeb, :controller

  alias Copilot.Core.CostEstimates
  alias Copilot.Core.Data.CostEstimate
  alias CopilotWeb.Plugs.{Auth, AuthorizeCostEstimate, EnsureParams}

  action_fallback CopilotWeb.FallbackController

  plug :put_view, json: CopilotWeb.CostEstimateJSON
  plug EnsureParams, "cost_estimate" when action in [:create, :update]
  plug Auth
  plug AuthorizeCostEstimate, :show when action == :show
  plug AuthorizeCostEstimate, :update when action == :update
  plug AuthorizeCostEstimate, :delete when action == :delete

  def index(conn, _params) do
    if "developer" in conn.assigns.current_user.roles do
      cost_estimates = CostEstimates.list_cost_estimates()
      render(conn, :index, cost_estimates: cost_estimates)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "You are not authorized to perform this action"}})
    end
  end

  def create(conn, %{"cost_estimate" => cost_estimate_params}) do
    if "developer" in conn.assigns.current_user.roles do
      with {:ok, %CostEstimate{} = cost_estimate} <-
             CostEstimates.create_cost_estimate(cost_estimate_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/cost_estimates/#{cost_estimate}")
        |> render(:show, cost_estimate: cost_estimate)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "Only developers can create a cost estimate"}})
    end
  end

  def show(conn, _params) do
    render(conn, :show, cost_estimate: conn.assigns.cost_estimate)
  end

  def update(conn, %{"cost_estimate" => cost_estimate_params}) do
    cost_estimate = conn.assigns.cost_estimate

    with {:ok, %CostEstimate{} = cost_estimate} <-
           CostEstimates.update_cost_estimate(cost_estimate, cost_estimate_params) do
      render(conn, :show, cost_estimate: cost_estimate)
    end
  end

  def delete(conn, _params) do
    cost_estimate = conn.assigns.cost_estimate

    with {:ok, %CostEstimate{}} <- CostEstimates.delete_cost_estimate(cost_estimate) do
      send_resp(conn, :no_content, "")
    end
  end
end
