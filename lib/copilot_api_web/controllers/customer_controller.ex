defmodule CopilotApiWeb.CustomerController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.Customers
  alias CopilotApi.Core.Data.Customer

  action_fallback CopilotApiWeb.FallbackController

  plug :put_view, json: CopilotApiWeb.CustomerJSON

  def index(conn, _params) do
    # Authorization is handled by the :developer_only pipeline in the router
    customers = Customers.list_customers()
    render(conn, :index, customers: customers)
  end

  def create(conn, params) do
    # Authorization is handled by the :developer_only pipeline in the router
    case params do
      %{"customer" => customer_params} ->
        with {:ok, %Customer{} = customer} <- Customers.create_customer(customer_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", ~p"/api/customers/#{customer}")
          |> render(:show, customer: customer)
        end

      _ ->
        {:error, :bad_request}
    end
  end

  def show(conn, %{"id" => id}) do
    # Authorization is handled by the :developer_only pipeline in the router
    customer = Customers.get_customer!(id)
    render(conn, :show, customer: customer)
  end

  def update(conn, %{"id" => id} = params) do
    # Authorization is handled by the :developer_only pipeline in the router
    customer = Customers.get_customer!(id)

    case params do
      %{"customer" => customer_params} ->
        with {:ok, %Customer{} = customer} <- Customers.update_customer(customer, customer_params) do
          render(conn, :show, customer: customer)
        end

      _ ->
        {:error, :bad_request}
    end
  end

  def delete(conn, %{"id" => id}) do
    # Authorization is handled by the :developer_only pipeline in the router
    customer = Customers.get_customer!(id)

    with {:ok, %Customer{}} <- Customers.delete_customer(customer) do
      send_resp(conn, :no_content, "")
    end
  end
end
