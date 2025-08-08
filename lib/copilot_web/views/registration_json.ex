defmodule CopilotWeb.RegistrationJSON do
  def show(%{user: user, customer: customer}) do
    %{
      data: %{
        id: user.id,
        customer_id: customer.id,
      }
    }
  end
end
