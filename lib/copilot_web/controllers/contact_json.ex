defmodule CopilotWeb.ContactJSON do
  alias Copilot.Core.Data.Contact

  @doc """
  Renders a list of contacts.
  """
  def index(%{contacts: contacts}) do
    %{data: for(contact <- contacts, do: data(contact))}
  end

  @doc """
  Renders a single contact.
  """
  def show(%{contact: contact}) do
    %{data: data(contact)}
  end

  def data(%Contact{} = contact) do
    %{
      id: contact.id,
      name: contact.name,
      email: contact.email,
      phone_number: contact.phone_number,
      address: contact.address,
      customer_id: contact.customer_id
    }
  end
end
