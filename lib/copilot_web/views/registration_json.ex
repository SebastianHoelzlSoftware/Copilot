defmodule CopilotWeb.RegistrationJSON do
  alias Copilot.Core.Data.User
  alias Copilot.Core.Data.Customer
  alias Copilot.Core.Data.Contact

  def create(%{user: user, customer: customer, contact: contact}) do
    %{data: %{
      user: user_data(user),
      customer: customer_data(customer),
      contact: contact_data(contact)
    }}
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      roles: user.roles,
      customer_id: user.customer_id
    }
  end

  defp customer_data(%Customer{} = customer) do
    %{
      id: customer.id,
      name: customer.name,
      # Add other customer fields you want to expose
    }
  end

  defp contact_data(%Contact{} = contact) do
    %{
      id: contact.id,
      name: contact.name,
      email: contact.email,
      phone_number: contact.phone_number,
      customer_id: contact.customer_id
      # Add other contact fields you want to expose
    }
  end
end
