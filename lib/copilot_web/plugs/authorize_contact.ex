defmodule CopilotWeb.Plugs.AuthorizeContact do
  @moduledoc """
  Authorization plug for the ContactController.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias Copilot.Core.Contacts

  def init(opts), do: opts

  def call(conn, _action) do
    %{"id" => contact_id} = conn.params

    case Contacts.get_contact!(contact_id) do
      contact ->
        if authorized?(conn.assigns.current_user, contact) do
          assign(conn, :contact, contact)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{
            error: %{status: 403, message: "You are not authorized to perform this action"}
          })
          |> halt()
        end
    end
  end

  defp authorized?(user, contact) do
    is_owner?(user, contact) or is_developer?(user)
  end

  defp is_owner?(user, contact), do: user.customer_id == contact.customer_id

  defp is_developer?(user), do: "developer" in user.roles
end
