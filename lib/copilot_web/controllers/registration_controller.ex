defmodule CopilotWeb.RegistrationController do
  use CopilotWeb, :controller

  alias Copilot.Core.Users
  alias CopilotWeb.RegistrationJSON
  alias CopilotWeb.ChangesetJSON

  action_fallback CopilotWeb.FallbackController

  def create(conn, %{"user" => user_params, "customer" => customer_params, "contact" => contact_params}) do
    case Users.create_user_with_customer_and_contact(user_params, customer_params, contact_params) do
      {:ok, user, customer, contact} ->
        conn
        |> put_status(:created)
        |> put_view(json: RegistrationJSON)
        |> render(:create, user: user, customer: customer, contact: contact)

      {:error, :user, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: ChangesetJSON)
        |> render(:error, changeset: changeset)

      {:error, :customer, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: ChangesetJSON)
        |> render(:error, changeset: changeset)

      {:error, :contact, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
