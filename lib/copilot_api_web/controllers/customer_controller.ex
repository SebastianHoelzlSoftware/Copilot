defmodule CopilotApiWeb.CustomerController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.Customers
  alias CopilotApi.Core.Data.Customer
  alias CopilotApiWeb.Plugs.{Auth, AuthorizeCustomer}

  action_fallback CopilotApiWeb.FallbackController

  plug :put_view, json: CopilotApiWeb.CustomerJSON
  plug Auth
  plug AuthorizeCustomer when action in [:show, :update, :delete]

  def index(conn, _params) do
    if "developer" in conn.assigns.current_user.roles do
      customers = Customers.list_customers()
      render(conn, :index, customers: customers)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "You are not authorized to perform this action"}})
    end
  end

  def create(conn, %{"customer" => customer_params}) do
    if "developer" in conn.assigns.current_user.roles do
      with {:ok, %Customer{} = customer} <- Customers.create_customer(customer_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/customers/#{customer}")
        |> render(:show, customer: customer)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "Only developers can create customers"}})
    end
  end

  def show(conn, _params) do
    render(conn, :show, customer: conn.assigns.customer)
  end

  def update(conn, %{"customer" => customer_params}) do
    customer = conn.assigns.customer

    with {:ok, %Customer{} = customer} <- Customers.update_customer(customer, customer_params) do
      render(conn, :show, customer: customer)
    end
  end

  def delete(conn, _params) do
    customer = conn.assigns.customer

    with {:ok, %Customer{}} <- Customers.delete_customer(customer) do
      send_resp(conn, :no_content, "")
    end
  end
end
