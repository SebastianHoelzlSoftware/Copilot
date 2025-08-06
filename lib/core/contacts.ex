defmodule Copilot.Core.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Copilot.Repo

  alias Copilot.Core.Data.Contact

  @doc """
  Returns the list of contacts.
  
  ## Examples
  
      iex> list_contacts()
      [%Contact{}, ...]
  
  """
  def list_contacts do
    Repo.all(Contact)
  end

  @doc """
  Gets a single contact.
  
  Raises `Ecto.NoResultsError` if the Contact does not exist.
  
  ## Examples
  
      iex> get_contact!(123)
      %Contact{}
  
      iex> get_contact!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_contact!(id), do: Repo.get!(Contact, id) |> Repo.preload(:customer)

  @doc """
  Creates a contact.
  
  ## Examples
  
      iex> create_contact(%{field: value})
      {:ok, %Contact{}}
  
      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.
  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact.
  """
  def delete_contact(%Contact{} = contact) do
    Repo.delete(contact)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.
  
  ## Examples
  
      iex> change_contact(contact)
      %Ecto.Changeset{data: %Contact{}}
  
  """
  def change_contact(%Contact{} = contact, attrs \\ %{}) do
    Contact.changeset(contact, attrs)
  end

  @doc """
  Returns the list of contacts for a given customer.
  """
  def list_contacts_for_customer(customer) do
    Contact
    |> where([c], c.customer_id == ^customer.id)
    |> Repo.all()
    |> Repo.preload(:customer)
  end
end
