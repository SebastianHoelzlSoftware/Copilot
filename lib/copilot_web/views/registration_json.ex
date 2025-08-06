defmodule CopilotWeb.RegistrationJSON do
  alias Copilot.Core.Data.User
  alias Copilot.Core.Data.Customer
  alias Copilot.Core.Data.Contact

  def show(%{user: user, customer: customer, contact: contact}) do
    %{
      data: %{
        id: user.id,
        customer_id: customer.id,
        contact_id: contact.id
      }
    }
  end
end
