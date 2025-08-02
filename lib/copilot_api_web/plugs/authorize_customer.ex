defmodule CopilotApiWeb.Plugs.AuthorizeCustomer do
  @moduledoc """
  Authorization plug for the CustomerController.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias CopilotApi.Core.Customers

  def init(opts), do: opts

  def call(conn, _action) do
    %{"id" => customer_id} = conn.params

    case Customers.get_customer!(customer_id) do
      customer ->
        if authorized?(conn.assigns.current_user, customer) do
          assign(conn, :customer, customer)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: %{status: 403, message: "You are not authorized to perform this action"}})
          |> halt()
        end
    end
  end

  defp authorized?(user, customer) do
    is_owner?(user, customer) or is_developer?(user)
  end

  defp is_owner?(user, customer), do: user.customer_id == customer.id

  defp is_developer?(user), do: "developer" in user.roles
end
