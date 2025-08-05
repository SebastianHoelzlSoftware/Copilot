defmodule CopilotWeb.CustomerJSON do
  alias Copilot.Core.Data.Customer
  alias CopilotWeb.ContactJSON

  @doc """
  Renders a list of customers.
  """
  def index(%{customers: customers}) do
    %{data: for(customer <- customers, do: data(customer))}
  end

  @doc """
  Renders a single customer.
  """
  def show(%{customer: customer}) do
    %{data: data(customer)}
  end

  defp data(%Customer{} = customer) do
    %{
      id: customer.id,
      name: customer.name,
      address: customer.address,
      contacts: render_contacts(customer.contacts)
    }
  end

  defp data(nil), do: nil

  defp render_contacts(%Ecto.Association.NotLoaded{}), do: []
  defp render_contacts(nil), do: []
  defp render_contacts(contacts), do: Enum.map(contacts, &ContactJSON.data(&1))
end
