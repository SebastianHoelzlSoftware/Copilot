defmodule CopilotWeb.RegistrationController do
  use CopilotWeb, :controller

  alias Copilot.Core.Users
  alias CopilotWeb.RegistrationJSON

  action_fallback CopilotWeb.FallbackController

  def create(conn, %{"registration" => registration_params}) do
    with {:ok, {status, user, customer, contact}} <- Users.register_user(registration_params) do
      conn
      |> put_status(status_to_code(status))
      |> put_view(json: RegistrationJSON)
      |> render(:show, user: user, customer: customer, contact: contact)
    end
  end

  defp status_to_code(:created), do: :created
  defp status_to_code(:found), do: :ok
end
