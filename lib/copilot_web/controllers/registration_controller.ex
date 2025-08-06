defmodule CopilotWeb.RegistrationController do
  use CopilotWeb, :controller

  alias Copilot.Core.Users
  alias CopilotWeb.RegistrationJSON

  action_fallback CopilotWeb.FallbackController

  def create(conn, %{"registration" => registration_params}) do
    case Users.register_user(registration_params) do
      {:ok, {status, user, customer, contact}} ->
        conn
        |> put_status(status_to_code(status))
        |> put_view(json: RegistrationJSON)
        |> render(:show, user: user, customer: customer, contact: contact)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CopilotWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end

  defp status_to_code(:created), do: :created
  defp status_to_code(:found), do: :ok
end
