defmodule CopilotWeb.RegistrationController do
  use CopilotWeb, :controller

  alias Copilot.Core.Users
  alias CopilotWeb.RegistrationJSON

  action_fallback CopilotWeb.FallbackController

  def create(conn, %{"registration" => registration_params}) do
    case Users.register_user(registration_params) do
      {:ok, {:created, user, customer}} ->
        conn
        |> put_status(:created)
        |> put_view(json: RegistrationJSON)
        |> render(:show, user: user, customer: customer)

      {:ok, {:found, user, customer}} ->
        conn
        |> put_status(:ok)
        |> put_view(json: RegistrationJSON)
        |> render(:show, user: user, customer: customer)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CopilotWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end


end
