defmodule CopilotWeb.RegistrationJSON do

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
