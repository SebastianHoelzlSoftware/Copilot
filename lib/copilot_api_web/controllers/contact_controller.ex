defmodule CopilotApiWeb.ContactController do
  use CopilotApiWeb, :controller

  alias CopilotApi.Core.Contacts
  alias CopilotApi.Core.Data.Contact
  alias CopilotApiWeb.Plugs.{Auth, AuthorizeContact, EnsureParams}

  action_fallback CopilotApiWeb.FallbackController

  plug :put_view, json: CopilotApiWeb.ContactJSON
  plug EnsureParams, "contact" when action in [:create, :update]
  plug Auth
  plug AuthorizeContact when action in [:show, :update, :delete]

  def index(conn, _params) do
    current_user = conn.assigns.current_user

    contacts =
      if "developer" in current_user.roles do
        Contacts.list_contacts()
      else
        Contacts.list_contacts_for_customer(%{id: current_user.customer_id})
      end

    render(conn, :index, contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    current_user = conn.assigns.current_user

    if "customer" in current_user.roles do
      params_with_customer = Map.put(contact_params, "customer_id", current_user.customer_id)

      with {:ok, %Contact{} = contact} <- Contacts.create_contact(params_with_customer) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/contacts/#{contact}")
        |> render(:show, contact: contact)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: %{status: 403, message: "Only customers can create contacts"}})
    end
  end

  def show(conn, _params) do
    render(conn, :show, contact: conn.assigns.contact)
  end

  def update(conn, %{"contact" => contact_params}) do
    contact = conn.assigns.contact

    with {:ok, %Contact{} = contact} <- Contacts.update_contact(contact, contact_params) do
      render(conn, :show, contact: contact)
    end
  end

  def delete(conn, _params) do
    contact = conn.assigns.contact

    with {:ok, %Contact{}} <- Contacts.delete_contact(contact) do
      send_resp(conn, :no_content, "")
    end
  end
end
